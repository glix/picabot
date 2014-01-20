require 'rest-client'
require 'json'
require 'git'

module Picabot
  class Repo
    GITHUB  = 'https://api.github.com'

    def self.all
      repos = get("/repositories?since=#{Storage[:id]}").map { |r| r[:full_name] }
      repos.each do |repo|
        files = get "/repos/#{repo}/git/trees/master?recursive=1"
        repos.delete repo unless files.any? { |f| f[:path] =~ /\.(jpg|png)$/ }
      end
      Storage[:id] = repos.last[:id]
      repos.map { |r| new(r) }
    end

    def initialize(repo)
      @repo = repo
    end

    def clone(pattern)
      directory = pattern % Digest::MD5.hexdigest(@repo)
      @directory = directory
      @base = Git.clone(fork, directory)
      @base.checkout @base.branch Storage[:branch]
      @base
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
      @base.push
    end

    def pull_request
      head = Storage[:organization] || Storage[:user]
      post "/repos/#{@repo}/pulls", {
        title: Storage[:pr_title],
        body:  Storage[:pr_text],
        base: 'master',
        head: head
      }
    end

    def remove
      FileUtils.rm_rf(@directory)
    end

    private

    def execute(method, *args)
      options = { method: method, url: "#{GITHUB}#{args[0]}", headers: {:Authorization => "token #{Storage[:token]}"} }
      options[:payload] = args[1] if args[1]
      JSON.parse(RestClient.execute(options), symbolize_names: true)
    end

    def get(path)
      execute(:get, path)
    end

    def post(path, payload)
      execute(:post, path, payload)
    end
  end
end
