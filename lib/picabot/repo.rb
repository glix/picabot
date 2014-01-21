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
      payload = Storage[:organization] ? { organization: Storage[:organization] } : {}
      response = post "/repos/#{@repo}/forks", payload
      sleep Storage[:fork_time].to_i
      response[:ssh_url]
    end

    def clone(pattern = '/tmp/picabot/%s')
      directory = pattern % @repo
      @directory = directory
      @base = Git.clone(fork, directory)
      @base.branch(Storage[:branch]).checkout
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
      @base.commit_all Storage[:commit_message]
      @base.push 'origin', Storage[:branch]
    end

    def location
      Storage[:organization] || Storage[:user]
    end

    def pull_request
      post "/repos/#{@repo}/pulls", {
        title: Storage[:pull_request_title],
        body:  Storage[:pull_request_body],
        base: 'master',
        head: "#{location}:#{Storage[:branch]}"
      }
    end

    def mark_as_processed
      Storage[:processed] <<= repo.id
    end

    def remove
      FileUtils.rm_rf(@directory)
    end
  end
end
