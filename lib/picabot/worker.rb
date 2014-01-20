require 'image_optim'
require 'digest/md5'
require 'fileutils'

module Picabot
  Worker = Module.new
  def Worker.new
    loop do
      @repos = Storage[:queue] || Repo.all
      @repos.each do |repo|
        begin
          directory = repo.clone '/tmp/%s'
          ImageOptim.new.optimize_images! Dir["#{directory}/**/**.{png,jpg}"]
          repo.proccess
        ensure
          @repos.shift
        end
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
