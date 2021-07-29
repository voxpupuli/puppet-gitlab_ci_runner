require 'json'
require 'net/http'
require 'uri'

module PuppetX
  module Gitlab
    module APIClient
      def self.delete(url, options)
        response = request(url, Net::HTTP::Delete, options)
        validate(response)

        {}
      end

      def self.post(url, options)
        response = request(url, Net::HTTP::Post, options)
        validate(response)

        JSON.parse(response.body)
      end

      def self.request(url, http_method, options)
        uri     = URI.parse(url)
        headers = {
          'Accept'       => 'application/json',
          'Content-Type' => 'application/json'
        }

        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.use_ssl     = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        end
        request          = http_method.new(uri.request_uri, headers)
        request.body     = options.to_json
        http.request(request)
      end

      def self.validate(response)
        raise Net::HTTPError.new(response.message, response) unless response.code.start_with?('2')
      end
    end

    module Runner
      def self.register(host, options)
        url = "#{host}/api/v4/runners"
        PuppetX::Gitlab::APIClient.post(url, options)
      end

      def self.unregister(host, options)
        url = "#{host}/api/v4/runners"
        PuppetX::Gitlab::APIClient.delete(url, options)
      end
    end
  end
end
