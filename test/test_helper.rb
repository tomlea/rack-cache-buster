$:<<File.join(File.dirname(__FILE__), *%w[.. lib])
require 'shoulda'
require 'rack/cache_buster'
require 'test/unit'
require 'rack/test'

class IntegrationTest < Test::Unit::TestCase
  include Rack::Test::Methods
  attr_reader :app

  CACHEY_APP = lambda{|env| [200, {"Cache-Control" => "max-age=200, public", "ETag" => '"an-etag"'}, []] }

  def test_nothing
  end
end
