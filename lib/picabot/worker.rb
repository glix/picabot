require 'image_optim'
require 'digest/md5'
require 'fileutils'

module Picabot
  Worker = Module.new
  def Worker.new
    loop do
      @repos = Storage[:queue] || Repo.all
      @repos.each do |repo|
        repo.clone '/tmp/%s'

        # Hero of the day:
        ImageOptim.new.optimize_images! Dir["#{directory}/**/**.{png,jpg}"]

        repo.proccess
        @repos.shift
      end
    end
  # rescue => error
  #   puts error
  #   sleep 360
  #   retry
  ensure
    Storage[:queue] = @repos
  end
end
