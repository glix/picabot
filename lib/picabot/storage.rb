require 'moneta'
require 'logger'

module Picabot
  Storage = Moneta.new(:YAML, file: "#{Dir.home}/.picabot.yml")
  
  def self.default(hash)
    Storage[hash.keys.first] ||= hash.values.first
  end

  default queue: []

  # See description of values in cli.rb
  default id: '0'
  default branch: 'optimize-via-picabot'
  default commit_message: 'Optimize images via Picabot'
  default error_time: 30
  default fork_time: 20

  default pull_request_title: 'Losslessly compress images via Picabot'
  default pull_request_body: <<-BODY
Hello! It is [**Picabot**, an automatic GitHub image optimizer](https://github.com/somu/picabot).

Your repository cointains some images, and I compressed them for you.
Do not worry: the compression is lossless and uses [ImageOptim](http://imageoptim.com) toolkit.

This bot exists to make the Internet faster. There are people who've got a fast internet connection,
but there are countries where additional 50 KBs take a reasonable time to download (like additional 2-3 minutes).
Additionally, this PR is going to save some precious disk space and decrease your server load. Picabot saves
approximately 25% of space. Still, if you do not need your images optimized, feel free to close this pull request.

If I have enough money, I'll build a server which will send these precious pull requests much faster.
And if I had monthly donations, I would dedicate all my work time to open-source, so donations are very appreciated.

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ZXESQ83MM3H78)

Pull requests, forks and favs are welcome: https://github.com/somu/picabot
BODY
end
