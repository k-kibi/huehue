module Huehue
  module Request
    def get(url, options = {})
      Typhoeus.get(url, options)
    end

    def put(url, params = {})
      Typhoeus::Request.new(
        url,
        method: 'put',
        headers: { 'Content-Type' => 'application/json' },
        body: JSON.dump(params)
      ).run
    end
  end
end
