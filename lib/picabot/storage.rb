require 'moneta'

module Picabot
  Storage = Moneta.new(:YAML, file: "#{Dir.home}/picabot.yaml")
  
  Storage[:id]             ||= '0'
  Storage[:branch]         ||= 'optimize-via-picabot'
  Storage[:commit_message] ||= 'Optimize images via Picabot'
  Storage[:error_time]     ||= 360
  Storage[:fork_time]      ||= 300

  Storage[:pr_title]       ||= ''
  Storage[:pr_text]        ||= ''

# Storage[:token]
# Storage[:user]
end
