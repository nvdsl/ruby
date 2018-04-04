#encoding:UTF-8
require 'net/http'
require 'openssl'
class Httclient
  def get(httpUrl, headers = {})
    return self.invoke("GET", httpUrl, headers = headers)
  end

  def post(httpUrl, body, headers = {})
    return self.invoke("POST", httpUrl, body = body, headers = headers)
  end

  def invoke(method, httpUrl, body = nil, headers = {})
    uri = URI(httpUrl)
    Net::HTTP.start(uri.host, port: uri.port, use_ssl: uri.scheme == 'https', verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      request = nil
      case method
        when "GET"
          request = Net::HTTP::Get.new(uri)
        when "POST"
          request = Net::HTTP::Post.new(uri)
          request.body = body
      end
      headers.each do |key, value|
        request[key.to_s] = value
      end
      response = http.request(request)
      rHeaders = {}
      response.each do |k, v|
        rHeaders[k.downcase] = v
      end
      return [true, response.code, response.body, rHeaders]
    end
    return [false, nil, nil, {}]
  end
end