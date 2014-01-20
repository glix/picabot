require 'rest-client'
require 'json'

module Picabot
  module Bot  
    BRANCH  = 'optimize-via-picabot'
    COMMIT  = 'Optimize images via Picabot'
    ADDRESS = "#{Storage[:user]}/#{BRANCH}"

    class << self
      def fetch
        id = Storage[:last_id] || 0
      end

      def fork(repo)
        # ...
      end

      def pull_request(repo)
        # ...
      end

      def send_to_pushover(error)
        # ...
      end
    end
  end
end
