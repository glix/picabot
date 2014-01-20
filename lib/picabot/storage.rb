require 'moneta'

module Picabot
  Storage = Moneta.new(:YAML, file: "#{Dir.home}/picabot.yaml")
  
  Storage[:id]             ||= '0'
  Storage[:branch]         ||= 'optimize-via-picabot'
  Storage[:commit_message] ||= 'Optimize images via Picabot'
  Storage[:error_time]     ||= 360
  Storage[:fork_time]      ||= 300

  Storage[:pr_title]       ||= 'Losslessly compress images via Picabot'
  Storage[:pr_text]        ||= "Hello! It is [**Picabot**, an automatic GitHub image optimizer](https://github.com/somu/picabot).\n\n" \
                               "Your repository cointains some images, and I compressed them for you. " \
                               "Do not worry: the compression is lossless and based on [ImageOptim](http://imageoptim.com).\n\n" \
                               "The reason why this bot exists: we need a faster web. There are people who have got a " \
                               "broadband, 4G and all the cool stuff. But still there are some countries where additional 50 kilobytes " \
                               "take a reasonable time to download (like couple of minutes). Plus, this PR is going to save some precious " \
                               "disk space, decrease server load, and so on. Still, if you do not need your images optimized, feel " \
                               "free to close this pull request.\n\n" \
                               "Drop me a line: <somu@so.mu>, especially if you think the bot bugged this time. " \
                               "You also can donate so I could build a server which will send these precious pull requests more " \
                               "often. And also I could dedicate all my work time to open-source, and it is my dream, in fact. \n\n" \
                               "[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ZXESQ83MM3H78)\n\n" \
                               "Pull requests, forks and favs are welcome: https://github.com/somu/picabot"
# Storage[:token]
# Storage[:user]
end
