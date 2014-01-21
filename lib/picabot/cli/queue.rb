Picabot::CLI.parse do
  separator <<-DESC
Queue
-----

These fill up your queue.

DESC
  queue = Picabot::Queue

  option :id, :number, '`since` param in http://developer.github.com/v3/repos/#list-all-public-repositories'

  on '-u', '--add-user <name>', 'Add user repos' do |name|
    queue.fill { user name }
    queue.new
    exit
  end
end

