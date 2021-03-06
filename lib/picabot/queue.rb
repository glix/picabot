module Picabot
  class Queue
    include API

    class << self
      def empty?
        Store[:queue].empty?
      end

      alias :_new :new

      def fill(&block)
        @@filler = proc(&block)
      end

      def new
        return sleep(0.5) if @@lock
        _new.fill
      end
    end

    @@lock = false
    @@filler = proc { search('stars:>100') }

    def initialize
      @@lock = true
      @page = 1
    end

    def fill
      self.instance_eval(&@@filler)
      unlock
    end

    def self.allow_forks!
      @@forks = true
    end

    protected

    def all
      process "/repositories?since=#{Store[:id]}" do |repo|
        Store[:id] = repo.id
      end
    end

    def user(name)
      process "/users/#{name}/repos?per_page=100"
    end

    def search(keyword)
      process "/search/repositories?q=#{URI.encode keyword}&per_page=100&page=#{@page}"
      @page += 1
    end

    private

    def process(endpoint)
      get(endpoint)[:items].each do |object|
        repo = Repo.new(object)
        next if repo.fork? unless @@forks ||= false
        save repo if repo.not_processed? && repo.include_images?
        yield repo if block_given?
      end
    end

    def save(repo)
      Store[:queue] <<= repo
      $stderr.puts "QUEUE #{repo}"
    end

    def unlock
      @@lock = false
    end
  end
end
