require 'rest-client'
require 'forwardable'
require 'logger'
require 'json'
require 'git'

module Picabot
  class Repo
    GITHUB  = 'https://api.github.com'

    class << self
      def all
        if @semaphore
          sleep 1
          return
        end

        @semaphore = true
        put_to_queue "/repositories?since=#{Storage[:id]}", true
        @semaphore = false
      end

      def user(name)
        put_to_queue "/users/#{name}/repos"
      end
    end

    def initialize(repo)
      @repo = repo
    end

    def clone(pattern)
      directory = pattern % @repo
      @directory = directory
      @base = Git.clone(fork, directory)
      @base.branch(Storage[:branch]).checkout
      directory
    end

    def fork
      payload = Storage[:organization] ? { organization: Storage[:organization] } : {}
      response = post "/repos/#{@repo}/forks", payload
      sleep Storage[:fork_time].to_i
      response[:ssh_url]
    end

    def proccess
      commit
      pull_request
      remove
    end

    def commit
      @base.commit_all Storage[:commit_message]
      @base.push 'origin', Storage[:branch]
    end

    def pull_request
      location = Storage[:organization] || Storage[:user]
      post "/repos/#{@repo}/pulls", {
        title: Storage[:pull_request_title],
        body:  Storage[:pull_request_body],
        base: 'master',
        head: "#{location}:#{Storage[:branch]}"
      }
    end

    def remove
      FileUtils.rm_rf(@directory)
    end

    private

    extend Forwardable
    def_delegators self, :get, :post

    class << self
      def put_to_queue(endpoint, save_id = false)
        get(endpoint).each do |repo|
          begin
            next if repo[:fork] unless $FORKS
            files = get "/repos/#{repo[:full_name]}/git/trees/master?recursive=1"
            if files[:tree].any? { |f| f[:path] =~ /\.(jpg|png|gif)$/ }
              Storage[:queue] <<= new(name = repo[:full_name])
              $stderr.puts "FOUND #{name}"
            end
            Storage[:id] = repo[:id] if save_id
          rescue
            next
          end
        end
      end

      def execute(method, *args)
        options = { method: method, url: "#{GITHUB}#{args[0]}", headers: {:Authorization => "token #{Storage[:token]}"} }
        options[:payload] = args[1].to_json if args[1]
        $stderr.puts "#{method.upcase} #{args[0]} #{options[:payload]}"
        JSON.parse(RestClient::Request.execute(options), symbolize_names: true)
      end

      def get(path)
        execute(:get, path)
      end

      def post(path, payload)
        execute(:post, path, payload)
      end
    end
  end
end
