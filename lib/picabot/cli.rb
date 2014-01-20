require 'picabot'
require 'optparse'

module Picabot
  CLI = Class.new
  def CLI.new(arguments = ARGV)
    OptionParser.new do |o|
      o.on('--token <hex>', 'Specify a token')                 { |token|  Storage[:token] = token       }
      o.on('--user <name>', 'Specify a username')              { |name|   Storage[:user]  = name        }
      o.on('--organization <name>', 'Specify an organization') { |name|   Storage[:organization] = name }
      o.on('--no-organization', 'Delete organization info')    {          Storage[:organization] = nil  }
      o.on('-v', '--version', 'Print Picabot version')         {          puts Picabot::VERSION; exit   }
      o.on('-w', '--workers <number>', 'Number of workers')    { |number| @workers = number             }
      o.on('-h', '--help') { puts o; exit }
    end.parse!(arguments)

    worker = -> { Picabot::Worker.new }
    return worker[] unless @workers
    @workers ? @workers.times { Thread.new { worker[] } } : worker[]    
  end
end
