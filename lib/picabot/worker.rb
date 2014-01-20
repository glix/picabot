require 'image_optim'
require 'digest/md5'
require 'fileutils'
require 'git'

module Picabot
  Worker = Module.new
  def Worker.new
    loop do
      @repos = Storage[:queue] || Bot.fetch
      @repos.each do |repo|
        base = Git.clone(Bot.fork(repo), directory = "/tmp/picabot/#{Digest::MD5.hexdigest(repo)}")
        base.checkout base.branch(Bot::BRANCH)

        ImageOptim.new.optimize_images! Dir["#{directory}/**/**.{png,jpg}"]
        base.commit_all(Bot::COMMIT)
        base.push

        Bot.pull_request(repo)
        FileUtils.rm_rf(directory)
        @repos.delete repo
      end
    end
  rescue => error
    send_to_pushover(error)
    retry
  ensure
    Storage.transaction { Storage[:queue] = @repos }
  end
end
