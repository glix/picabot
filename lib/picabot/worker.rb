require 'image_optim'
require 'digest/md5'
require 'fileutils'

module Picabot
  Worker = Module.new
  def Worker.new
    optimizer = ImageOptim.new nice: 20, optipng: {level: 7}
    loop do
      Repo.all while Storage[:queue].empty?
      sleep 0.2 while @semaphore == true
      @semaphore = true
        repo = Storage[:queue].shift
        Storage[:queue] = Storage[:queue].drop(1)
      @semaphore = false

      directory = repo.clone '/tmp/picabot/%s'
      optimizer.optimize_images! Dir["#{directory}/**/**.{png,jpg,gif}"]
      repo.proccess
    end
  rescue
    $stderr.puts "\n", $!, $@, "Going to sleep for #{Storage[:error_time]} secs...\n\n"
    sleep Storage[:error_time]
    retry
  end
end
