module Picabot
  module Tuner
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
        @threads = number
      end

      on '-f', '--forks', "Don't skip forks" do
        Queue.allow_forks!
      end

      option :commit_message, 'text', 'Commit title'
      option :branch, 'name', 'Name of the optimized branch'
      option :error_time, 'time', 'How many seconds to wait after an exception'
      option :fork_time, 'time', 'How many seconds to wait after a fork API call'
      option :id, 'number', '`since` param in http://developer.github.com/v3/repos/#list-all-public-repositories'
      option :organization, 'name', 'Organization to save forks into'

      on '--no-organization', 'Delete organization info' do
        Store[:organization] = nil
      end

      option :pull_request_title, 'text', 'Title of the bot\'s PR'
      on '--pull-request-body <path>', 'Path to the file with PR text' do |path|
        Store[:pull_request_body] = File.read(path)
      end

      o.separator 'Queue customizers:'
      on '-u', '--add-user <name>', 'Add user repos' do |name|
        Queue.fill { user name }
        Queue.new
        exit
      end
    end.parse! arguments
  end
end
