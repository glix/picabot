Picabot::CLI.parse do
  separator <<-DESC
Optional
--------

DESC

  on '-l', '--log <path>', 'Send STDERR to the specified file' do |path|
    $stderr = open(path, 'a')
  end

  on '-t', '--threads <number>', 'Number of concurrent workers', Integer do |number|
    @threads = number
  end

  on '-f', '--forks', "Don't skip forks" do
    Picabot::Queue.allow_forks!
  end
end
