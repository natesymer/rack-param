#!/usr/bin/env ruby

require "rspec"

module TestHelpers
  require_relative File.dirname(File.dirname(__FILE__)) + "/lib/rack/param.rb"
  
  require "rack"
  require "cgi"
  require "stringio"
  
  def env params
    {
      "CONTENT_TYPE" => "text/plain",
      "QUERY_STRING" => params.map { |k,v| "#{k.to_s}=#{CGI.escape(v.to_s)}" }.join('&'),
      "REQUEST_METHOD" => "GET",
      "REQUEST_PATH" => "/",
      "REQUEST_URI" => "/",
      "HTTP_HOST" => "localhost:2000",
      "SERVER_NAME" => "localhost",
      "SERVER_PORT" => "2000",
      "PATH_INFO" => "/",
      "rack.url_scheme" => "http",
      "rack.input" => StringIO.new("")
    }
  end
end

RSpec.configure do |c|
  c.include TestHelpers
  
  c.before :each do
    @p ||= {}
    @r = Rack::Request.new env(@p.dup)
  end
end