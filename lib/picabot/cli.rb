require 'picabot'
require 'picabot/version'
require 'optparse'

module Picabot
  class CLI
    def self.parse(position = nil, &block)
      @@parsers ||= []
      @@parsers << proc(&block)
    end

    def initialize(arguments = ARGV)
      OptionParser.new do |o|
        def o.option(key, type, description)
          description << " (current: #{Store[key] || 'none'})"
          on("--#{key.to_s.gsub('_','-')} <#{type}>", description) do |arg|
            Store[key] = arg
          end
        end

        require_parsers
        @@parsers.each { |p| o.separator "\n"; o.instance_eval(&p) }
      end.parse! arguments
    end

    def run
      on_stop { @workers.each { |w| w.stop } }
      run!
      sleep 1 until @workers.all? { |w| !w.running? }
    ensure
      Store.close
    end

    def run!
      @workers = []
      @threads ||= 1

      @threads.times { @workers << Picabot::Worker.new }
      @workers[1..-1].each { |w| Thread.new { w.run } }
      @workers.first.run
    end

    private

    def require_parsers
      require 'picabot/cli/common'
      require 'picabot/cli/required'
      require 'picabot/cli/settings'
      require 'picabot/cli/optional'
      require 'picabot/cli/queue'
    end

    def on_stop(&block)
      [:INT, :TERM, :KILL].each { |sig| trap(sig) { yield } }
    end
  end
end
