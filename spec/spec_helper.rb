$:.push File.expand_path("../lib", __FILE__)
require "httparty"

require 'webmock/rspec'

def file_fixture(filename)
  open(File.join(File.dirname(__FILE__), 'fixtures', "#{filename.to_s}")).read
end

def stub_http_response_with(filename)
  format = filename.split('.').last.intern
  data = file_fixture(filename)

  response = Net::HTTPOK.new("1.1", 200, "Content for you")
  response.stub!(:body).and_return(data)

  if format == :txt
    http_request = HTTParty::Request.new(Net::HTTP::Get, 'http://localhost', :format => format, :parser => HTTParty::Parser::Txt)
  else
    http_request = HTTParty::Request.new(Net::HTTP::Get, 'http://localhost', :format => format)
  end
  http_request.stub_chain(:http, :request).and_return(response)

  HTTParty::Request.should_receive(:new).and_return(http_request)
end

def stub_response(body, code = 200)
  @request.options[:base_uri] ||= 'http://localhost'
  unless defined?(@http) && @http
    @http = Net::HTTP.new('localhost', 80)
    @request.stub!(:http).and_return(@http)
  end

  response = Net::HTTPResponse::CODE_TO_OBJ[code.to_s].new("1.1", code, body)
  response.stub!(:body).and_return(body)

  @http.stub!(:request).and_return(response)
  response
end
