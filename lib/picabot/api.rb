module Picabot
  module API
    GITHUB = 'https://api.github.com'

    def execute(method, *args)
      options = { method: method, url: "#{GITHUB}#{args[0]}", headers: {:Authorization => "token #{Store[:token]}"} }
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

    def patch(path, payload)
      execute(:patch, path, payload)
    end
  end
end
