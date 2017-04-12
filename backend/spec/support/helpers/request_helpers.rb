module Requests
  module JsonHelpers
    def json_response
      @json ||= JSON.parse(response.body, symbolize_names: true)
      @json
    end
  end

  module HeadersHelpers
    def request_headers
      {
        'Content-Type' => 'application/json',
        'Accept' => 'application/hal+json,application/json'
      }
    end

    def api_authorization_header(token)
      request_headers['Authorization'] = token
    end
  end
end
