require 'rest-client'
require 'json'
require 'git'

module Picabot
  class Repo
    include API
    attr_reader :id

    def initialize(repo)
      @cache = {}
      @repo  = repo[:full_name]
      @fork  = repo[:fork]
      @id    = repo[:id]
    end

    def fork?
      @fork
    end

    def include_images?
      tree = get("/repos/#{@repo}/git/trees/master?recursive=1")[:tree]
      check = tree.any? { |f| f[:path] =~ /\.(jpg|png|gif)$/ }
      mark_as_processed unless check
      check
    rescue
      mark_as_processed
      false
    end

    def not_processed?
      !Store[:processed].include?(@id)
    end

    def process(&block)
      yield clone
      commit
      pull_request
      mark_as_processed
      remove
    end

    protected

    def fork
      payload = organization ? { organization: organization } : {}
      response = post "/repos/#{@repo}/forks", payload
      @default_branch = response[:default_branch]
      sleep Store[:fork_time].to_i
      rename_repo response
    end

    def rename_repo(response)
      random = rand(36**4).to_s(36).gsub(/\d/, 'a')
      patch("/repos/#{response[:full_name]}", {name: "#{response[:name]}-#{random}"})[:ssh_url]
    end

    def clone(pattern = '/tmp/picabot/%s')
      @base = Git.clone(fork, @directory = pattern % @repo)
      @base.branch(branch).checkout
      @directory
    end

    def commit
      @base.commit_all Store[:commit_message]
      @base.push 'origin', branch
    end

    def pull_request
      post "/repos/#{@repo}/pulls", {
        title: Store[:pull_request_title],
        body:  Store[:pull_request_body],
        base: @default_branch,
        head: "#{location}:#{branch}"
      }
    end

    def mark_as_processed
      Store[:processed] <<= repo.id
    end

    def remove
      FileUtils.rm_rf(@directory)
    end

    private

    [:organization, :user, :branch].each do |method|
      define_method method do
        @cache[method] ||= Store[method]
      end
    end

    def location
      organization || user
    end
  end
end
