Picabot::CLI.parse do
  separator <<-DESC
Settings
--------

Picabot saves them, so you need to set them only once.

DESC

  option :commit_message, :text, 'Commit title'
  option :branch, :name, 'Name of the optimized branch'
  option :error_time, :time, 'How many seconds to wait after an exception'
  option :fork_time, :time, 'How many seconds to wait after a fork API call'
  option :organization, :name, 'Organization to save forks into'

  on '--no-organization', 'Delete organization info' do
    Store[:organization] = nil
  end

  option :pull_request_title, 'text', "Title of the bot's PR"
  on '--pull-request-body <path>', 'Path to the file with PR text' do |path|
    Store[:pull_request_body] = File.read(path)
  end
end
