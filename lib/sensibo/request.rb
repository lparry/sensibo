require 'faraday'
require 'faraday_middleware'

class Sensibo
  class Request
    class << self
      def get(path, queryParams = {})
        payload_to_snake(connection.get(url(path, queryParams)).body.fetch('result'))
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
        payload_to_snake(
          connection
            .send(
              method,
              url(path, queryParams),
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
