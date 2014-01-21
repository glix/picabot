Picabot::CLI.parse do
  self.banner = <<-DESC
Picabot
=======

Picabot is a GitHub optimization bot that crawls GitHub repos and
losslessly optimizes images. This is an overall usage information,
feel free to ask me at https://github.com/somu/picabot/issues/new,
I'll do my best to help you.
DESC

  on '-h', '--help', 'Prints this message' do
    puts self
    Picabot::Store.close
    exit
  end

  on '-v', '--version', 'Prints Picabot version' do
    require 'picabot/version'
    puts Picabot::VERSION
    Picabot::Store.close
    exit
  end
end
