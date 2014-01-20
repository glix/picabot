require 'picabot'
require 'picabot/version'
require 'optparse'

module Picabot
  module CLI
    def self.on(*args, &block)
      @option_parser.on(*args, &block)
    end

    def self.option(key, type, description)
      on("--#{key.to_s.gsub('_','-')} <#{type}>", description) { |arg| Storage[key] = arg }
    end

    def self.spawn
      Picabot::Worker.new
    end

    def self.new(arguments = ARGV)
      OptionParser.new do |o|
        o.version = Picabot::VERSION
        @option_parser = o

        on '-w', '--workers <number>', 'Number of workers' do |number|
          @workers = number
        end

        option :commit_message, 'text', 'Commit title'
        option :error_time, 'time', 'How many seconds to wait after an exception'
        option :fork_time, 'time', 'How many seconds to wait after a fork API call'
        option :id, 'number', '`since` param in http://developer.github.com/v3/repos/#list-all-public-repositories'
        option :token, 'hex', 'Generate it at https://github.com/settings/tokens/new'
        option :user, 'name', 'Your GitHub username'
        option :organization, 'name', 'Organization to save forks into'

        on '--no-organization', 'Delete organization info' do
          Storage[:organization] = nil
        end
      end.parse! arguments

      @workers ? @workers.times { Thread.new { spawn } } : spawn
    end
  end
end
