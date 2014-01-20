require 'rest-client'
require 'forwardable'
require 'logger'
require 'json'
require 'git'

module Picabot
  class Repo
    GITHUB  = 'https://api.github.com'

    def self.all
      repos = get("/repositories?since=#{Storage[:id]}")
      repos.delete_if do |repo|
        begin
          files = get "/repos/#{repo[:full_name]}/git/trees/master?recursive=1"
          !files[:tree].any? { |f| f[:path] =~ /\.(jpg|png)$/ }
        rescue RestClient::ResourceNotFound
          next
        end
      end
      Storage[:id] = repos.last[:id]
      repos.map { |r| new(r[:full_name]) }
    end

    def initialize(repo)
      @repo = repo
    end

    def clone(pattern)
      directory = pattern % Digest::MD5.hexdigest(@repo)
      @directory = directory
      @base = Git.clone(fork, directory)
      @base.branch(Storage[:branch]).checkout
      directory
    end

    def fork
      payload = Storage[:organization] ? { organization: Storage[:organization] } : {}
      response = post "/repos/#{@repo}/forks", payload
      sleep Storage[:fork_time]
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
        title: Storage[:pr_title],
        body:  Storage[:pr_text],
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
      def execute(method, *args)
        options = { method: method, url: "#{GITHUB}#{args[0]}", headers: {:Authorization => "token #{Storage[:token]}"} }
        options[:payload] = args[1].to_json if args[1]
        p options
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
