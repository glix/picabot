module Picabot
  class Queue
    include API

    class << self
      def empty?
        Storage[:queue].empty?
      end

      alias :_new :new

      def fill(&block)
        @filler = proc(&block)
      end

      def new
        return sleep(0.5) if @@lock
        _new.fill
      end
    end

    @@lock = false
    @@filler = -> { all }

    def initialize
      @@lock = true
    end

    def fill
      @@filler[]
      unlock
    end

    def self.allow_forks!
      @@forks = true
    end

    protected

    def all
      process "/repositories?since=#{Storage[:id]}" do |repo|
        Storage[:id] = repo.id
      end
    end

    def user(name)
      process "/users/#{name}/repos?per_page=100"
    end

    def search(keyword)
      process "/search/repositories?q=#{keyword.gsub(' ','+')}&per_page=100&page=#{@page}"
      @page += 1
    end

    private

    def process(endpoint)
      get(endpoint).each do |object|
        repo = Repo.new(object)
        next if repo.fork? unless @@forks
        save repo if repo.include_images? && repo.not_processed?
        yield repo if block_given?
      end
    end

    def save(repo)
      Storage[:queue] <<= repo
      $stderr.puts "QUEUE #{name}"
    end

    def unlock
      @@lock = false
    end
  end
end
