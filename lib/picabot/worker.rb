require 'image_optim'
require 'digest/md5'
require 'fileutils'

module Picabot
  class Worker
    SEMAPHORE = Moneta::Mutex.new(Store, :mutex)

    def initialize
      @optimizer = ImageOptim.new nice: 50, optipng: {level: 7}
    end

    def repo
      SEMAPHORE.synchronize do
        repo, *Store[:queue] = Store[:queue]
        repo
      end
    end

    def run!
      loop {
        Queue.new while Queue.empty?
        repo.proccess do |directory|
          @optimizer.optimize_images! Dir["#{directory}/**/**.{png,jpg,gif}"]
        end
      }
    rescue
      time = Store[:error_time]
      $stderr.puts "\n", $!, $@, "SLEEP #{time}\n\n"
      sleep time.to_i
      retry
    end
  end
end
