# frozen_string_literal: true

require 'dotenv/load'

root = Dir.getwd.to_s
threads_count = Integer(ENV['MAX_THREADS'] || 5)

workers Integer(ENV['WEB_CONCURRENCY'] || 2)
pidfile     "#{root}/pids/puma.pid"
state_path  "#{root}/pids/puma.state"
threads threads_count, threads_count

bind 'tcp://0.0.0.0:9292'

if File.exist?('./privkey.pem') && File.exist?('./fullchain.pem')
  ssl_bind '0.0.0.0', 9293, key: './privkey.pem', cert: './fullchain.pem'
end
