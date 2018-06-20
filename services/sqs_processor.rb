#!/usr/bin/env ruby

$:.unshift(File.expand_path("../../lib", __FILE__))

require "dotenv"
Dotenv.load

require "logger"
require "aws-sdk"
require "optparse"
require "cityhash"
require "iqdb/responses/collection"
require "iqdb/responses/error"
require "iqdb/responses/responses"
require "iqdb/server"
require "iqdb/command"

unless ENV["RUN"]
  Process.daemon
end

$running = true
$options = {
  pidfile: "/var/run/iqdbs/sqs_processor.pid",
  logfile: "/var/log/iqdbs/sqs_processor.log"
}

OptionParser.new do |opts|
  opts.on("--pidfile=PIDFILE") do |pidfile|
    $options[:pidfile] = pidfile
  end

  opts.on("--logfile=LOGFILE") do |logfile|
    $options[:logfile] = logfile
  end
end.parse!

LOGFILE = $options[:logfile] == "stdout" ? STDOUT : File.open($options[:logfile], "a")
LOGFILE.sync = true
LOGGER = Logger.new(LOGFILE, 0)
Aws.config.update(
  region: ENV["AMAZON_SQS_REGION"],
  credentials: Aws::Credentials.new(
    ENV["AMAZON_KEY"],
    ENV["AMAZON_SECRET"]
  )
)
SQS = Aws::SQS::Client.new
QUEUE = Aws::SQS::QueuePoller.new(ENV["SQS_IQDBS_URL"], client: SQS)

File.open($options[:pidfile], "w") do |f|
  f.write(Process.pid)
end

Signal.trap("TERM") do
  $running = false
end

def remove_from_iqdb(post_id)
  server = Iqdb::Server.new(ENV["IQDB_HOSTNAME"], ENV["IQDB_PORT"])
  command = Iqdb::Command.new(ENV["IQDB_DATABASE_FILE"])

  server.remove(post_id)
  command.remove(post_id)
end

def add_to_iqdb(post_id, image_url)
  server = Iqdb::Server.new(ENV["IQDB_HOSTNAME"], ENV["IQDB_PORT"])
  command = Iqdb::Command.new(ENV["IQDB_DATABASE_FILE"])
  url_hash = CityHash.hash64(image_url).to_s(36)
  url = URI.parse(image_url)

  Tempfile.open("iqdbs-#{url_hash}") do |f|
    begin
      Net::HTTP.start(url.host, url.port, :use_ssl => url.is_a?(URI::HTTPS)) do |http|
        http.request_get(url.to_s) do |res|
          if res.is_a?(Net::HTTPSuccess)
            res.read_body(f)
            size = f.size
            f.close
            LOGGER.debug("added #{image_url} for #{post_id} (size:#{size})")
          else
            LOGGER.error(res.to_s)
          end
        end
      end
    rescue Net::HTTPServiceUnavailable, Net::HTTPBadGateway, Net::HTTPGatewayTimeOut
      sleep(60)
      retry
    end
    server.add(post_id, f.path)
    command.add(post_id, f.path)
  end
end

def process_queue(poller, logger)
  logger.info "Starting"
  
  poller.before_request do
    unless $running
      throw :stop_polling
    end
  end

  while $running
    begin
      poller.poll do |msg|
        command, post_id, image_url = msg.body.split(/\n/)

        case command
        when "update"
          logger.info("adding #{post_id} #{image_url}")
          add_to_iqdb(post_id.to_i, image_url)

        when "remove"
          logger.info("removing #{post_id}")
          remove_from_iqdb(post_id.to_i)

        else
          logger.info("unknown command: #{command}")
        end
      end
      
    rescue Interrupt
      exit(0)

    rescue Exception => e
      logger.error("#{e.class} thrown")
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))

      if ENV["RUN"]
        exit(1)
      end

      sleep(60)
      retry
    end
  end
end

process_queue(QUEUE, LOGGER)