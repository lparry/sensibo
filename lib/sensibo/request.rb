require 'faraday'
require 'faraday_middleware'

class Sensibo
  class Request
    class << self
      def get(path, queryParams = {})
        connection.get(url(path, queryParams)).body.fetch('result')
      end

      def post(path, queryParams = {}, bodyData = {})
        send(:post, path, queryParams, bodyData)
      end

      def patch(path, queryParams = {}, bodyData = {})
        send(:patch, path, queryParams, bodyData)
      end

      def put(path, queryParams = {}, bodyData = {})
        send(:put, path, queryParams, bodyData)
      end

      def delete(path, queryParams = {}, bodyData = {})
        send(:delete, path, queryParams, bodyData)
      end

      private

      def send(method, path, queryParams = {}, bodyData = {})
        connection
          .send(
            method,
            url(path, queryParams),
            JSON.dump(bodyData),
            'Content-Type' => 'application/json',
          )
          .body
          .fetch('result')
      end

      def connection
        Faraday.new('https://home.sensibo.com/') do |c|
          c.request :retry

          c.response :raise_error
          c.response :json
        end
      end

      def api_key
        ENV['SENSIBO_API_KEY']
      end

      def url(path, body = {})
        "#{File.join(url_base, path)}?#{URI.encode_www_form({ apiKey: api_key }.merge(body))}"
      end

      def url_base
        '/api/v2'
      end
    end
  end
end
