#!/usr/bin/env ruby

require "rspec"
require "cgi"

RSpec.configure do |c|
  require "rack"
  @foo = 1
  @bar = "this is a string"
  env = {
    "rack.version" => [1, 2],
    "rack.multithread" => true,
    "rack.multiprocess" => false,
    "rack.run_once" => false,
    "SCRIPT_NAME" => "",
    "CONTENT_TYPE" => "text/plain",
    "QUERY_STRING" => "foo=#{@foo}&bar=#{CGI.escape(@bar)}",
    "SERVER_PROTOCOL" => "HTTP/1.1",
    "SERVER_SOFTWARE" => "2.9.0",
    "GATEWAY_INTERFACE" => "CGI/1.2",
    "REQUEST_METHOD" => "GET",
    "REQUEST_PATH" => "/",
    "REQUEST_URI" => "/",
    "HTTP_VERSION" => "HTTP/1.1",
    "HTTP_HOST" => "localhost:2000",
    "HTTP_ACCEPT" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "HTTP_ACCEPT_LANGUAGE" => "en-us",
    "HTTP_CONNECTION" => "keep-alive",
    "HTTP_ACCEPT_ENCODING" => "gzip, deflate",
    "HTTP_USER_AGENT" =>" Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.77.4 (KHTML, like Gecko) Version/7.0.5 Safari/537.77.4",
    "SERVER_NAME" => "localhost",
    "SERVER_PORT" => "2000",
    "PATH_INFO" => "/",
    "REMOTE_ADDR" => "127.0.0.1",
    "rack.hijack?" => false,
    "rack.url_scheme" => "http",
    "rack.after_reply" => []
  }
  @r = Rack::Request.new env
  puts @r.params.inspect
end