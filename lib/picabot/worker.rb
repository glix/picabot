require 'image_optim'
require 'digest/md5'
require 'fileutils'

module Picabot
  class Worker
    MUTEX = Moneta::Mutex.new(Store, :mutex)

    def initialize
      @optimizer = ImageOptim.new nice: 50, optipng: {level: 7}
      @handler = Thread.current.to_s.gsub(/[<>#Thread:]/, '')
      @running = false
    end

    def repo
      MUTEX.synchronize do
        repo, *Store[:queue] = Store[:queue]
        repo
      end
    end

    def run
      raise 'Already running!' if @running
      @running = true
      work
    end

    def stop
      raise 'Already stopped!' unless @running
      @stopped = true
    end

    def self.stop!
      @@stopped = true
    end

    private

    def work
      puts "WORKER #{@handler}"
      until @stopped || @@stopped ||= false
        Queue.new while Queue.empty?
        repo.proccess do |directory|
          @optimizer.optimize_images! Dir["#{directory}/**/**.{png,jpg,gif}"]
        end
      end
      
      @running = false
      @stopped = false
    rescue
      time = Store[:error_time]
      $stderr.puts "\n", $!, $@, "SLEEP #{time}\n\n"
      sleep time.to_i
      retry
    end
  end
end
