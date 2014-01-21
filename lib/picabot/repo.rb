require 'rest-client'
require 'forwardable'
require 'logger'
require 'json'
require 'git'

module Picabot
  class Repo
    include API
    attr_reader :id

    def initialize(repo)
      @repo = repo[:full_name]
      @fork = repo[:fork]
      @id   = repo[:id]
    end

    def include_images?
      get("/repos/#{@repo}/git/trees/master?recursive=1")[:tree].any? do |f|
        f[:path] =~ /\.(jpg|png|gif)$/
      end
    rescue
      false
    end

    def fork?
      @fork
    end

    def fork
      organization = Store[:organization]
      payload = organization ? { organization: organization } : {}
      response = post "/repos/#{@repo}/forks", payload
      sleep Store[:fork_time].to_i
      @branch = response[:default_branch]
      response[:ssh_url]
    end

    def clone(pattern = '/tmp/picabot/%s')
      directory = pattern % @repo
      @directory = directory
      @base = Git.clone(fork, directory)
      @base.branch(Store[:branch]).checkout
      directory
    end

    def proccess(&block)
      yield clone
      commit
      pull_request
      mark_as_processed
      remove
    end

    def commit
      @base.commit_all Store[:commit_message]
      @base.push 'origin', Store[:branch]
    end

    def location
      Store[:organization] || Store[:user]
    end

    def pull_request
      post "/repos/#{@repo}/pulls", {
        title: Store[:pull_request_title],
        body:  Store[:pull_request_body],
        base: @branch,
        head: "#{location}:#{Store[:branch]}"
      }
    end

    def mark_as_processed
      Store[:processed] <<= repo.id
    end

    def remove
      FileUtils.rm_rf(@directory)
    end
  end
end
