require 'faraday'
require 'faraday_middleware'

class Sensibo
  class Request
    class << self
      def get(path, query = {})
        payload_to_snake(connection.get(url(path, query)).body.fetch('result'))
      end

      def post(path, bodyData = {}, query: {})
        send(:post, path, query, bodyData)
      end

      def patch(path, bodyData = {}, query: {})
        send(:patch, path, query, bodyData)
      end

      def put(path, bodyData = {}, query: {})
        send(:put, path, query, bodyData)
      end

      def delete(path, bodyData = {}, query: {})
        send(:delete, path, query, bodyData)
      end

      private

      def send(method, path, query = {}, bodyData = {})
        payload_to_snake(
          connection
            .send(
              method,
              url(path, query),
              JSON.dump(payload_to_camel(bodyData)),
              'Content-Type' => 'application/json',
            )
            .body
            .fetch('result'),
        )
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

      def url(path, params = {})
        query = payload_to_camel({ apiKey: api_key }.merge(params))
        "#{File.join(url_base, path)}?#{URI.encode_www_form(query)}"
      end

      def url_base
        '/api/v2'
      end

      def payload_to_camel(payload)
        return payload.map { |x| payload_to_camel(x) } if payload.is_a?(Array)
        payload.deep_transform_keys { |key| key.to_s.camelize(:lower) }
      end

      def payload_to_snake(payload)
        return payload.map { |x| payload_to_snake(x) } if payload.is_a?(Array)
        payload.deep_transform_keys { |key| key.to_s.underscore.to_sym }
      end
    end
  end
end
