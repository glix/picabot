require 'picabot'
require 'picabot/version'
require 'optparse'

module Picabot
  module CLI
    def self.on(*args, &block)
      @option_parser.on(*args, &block)
    end

    def self.option(key, type, description)
      on("--#{key.to_s.gsub('_','-')} <#{type}>", description) do |arg|
        if arg == 'default'
          Storage[key] = nil
          puts ":#{key} reset to default. Now exiting."
          exit
        end
        Storage[key] = arg
      end
    end

    def self.spawn
      Picabot::Worker.new
    end

    def self.new(arguments = ARGV)
      OptionParser.new do |o|
        o.version = Picabot::VERSION
        @option_parser = o

        o.separator <<-DESC
You need to use all options (except ones with shorthands) only once.
Your choice is saved and automatically used on the next launch.
Alternatively you can manually edit ~/.picabot.yml, but beware.

Required:
DESC
        option :token, 'hex', 'Generate it at https://github.com/settings/tokens/new'
        option :user, 'name', 'Your (or your bot\'s) GitHub username'

        o.separator 'Optional:'
        on '-l', '--log <path>', 'Send STDERR to the specified file' do |path|
          $stderr = open(path, 'a')
        end

        on '-w', '--workers <number>', 'Number of concurrent workers' do |number|
          @workers = number
        end

        on '-d', '--daemonize', 'Daemonize the process' do
          Process.daemonize
        end

        option :commit_message, 'text', 'Commit title'
        option :branch, 'name', 'Name of the optimized branch'
        option :error_time, 'time', 'How many seconds to wait after an exception'
        option :fork_time, 'time', 'How many seconds to wait after a fork API call'
        option :id, 'number', '`since` param in http://developer.github.com/v3/repos/#list-all-public-repositories'
        option :organization, 'name', 'Organization to save forks into'

        on '--no-organization', 'Delete organization info' do
          Storage[:organization] = nil
        end

        option :pull_request_title, 'text', 'Title of the bot\'s PR'
        on '--pull-request-body <path>', 'Path to the file with PR text' do |path|
          Storage[:pull_request_body] = File.read(path)
        end
      end.parse! arguments

      if @workers
        @workers.to_i.times do 
          Thread.new { spawn }
          sleep 0.1
        end
        loop { sleep 1 }
      else
        spawn
      end
    end
  end
end
