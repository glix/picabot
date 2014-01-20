require 'pstore'

module Picabot
  Storage = PStore.new("#{Dir.home}/picabot.pstore")
end
