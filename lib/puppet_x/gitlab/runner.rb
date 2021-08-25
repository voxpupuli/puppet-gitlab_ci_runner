require 'json'
require 'net/http'
require 'uri'

module PuppetX
  module Gitlab
    module APIClient
      def self.delete(url, options, proxy)
        response = request(url, Net::HTTP::Delete, options, proxy)
        validate(response)

        {}
      end

      def self.post(url, options, proxy)
        response = request(url, Net::HTTP::Post, options, proxy)
        validate(response)

        JSON.parse(response.body)
      end

      def self.request(url, http_method, options, proxy)
        uri     = URI.parse(url)
        headers = {
          'Accept'       => 'application/json',
          'Content-Type' => 'application/json'
        }
        if proxy
          proxy_uri = URI.parse(proxy)
          proxy_host = proxy_uri.host
          proxy_port = proxy_uri.port
        else
          proxy_host = nil
          proxy_port = nil
        end

        http = Net::HTTP.new(uri.host, uri.port, proxy_host, proxy_port)
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
      def self.register(host, options, proxy = nil)
        url = "#{host}/api/v4/runners"
        PuppetX::Gitlab::APIClient.post(url, options, proxy)
      end

      def self.unregister(host, options, proxy = nil)
        url = "#{host}/api/v4/runners"
        PuppetX::Gitlab::APIClient.delete(url, options, proxy)
      end
    end
  end
end
