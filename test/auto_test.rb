#FOO
require "test_helper"

class CacheBusterAutoTest < IntegrationTest
  DIGEST_OF_HASH_FOO=Digest::MD5.hexdigest("#FOO")

  context "with no key files" do
    setup do
      @app = Rack::CacheBuster::Auto.new(CACHEY_APP, "/no-file-here.txt", "/no-file-here.txt")
    end

    should "not set cache-control to no-cache" do
      get "/foooo"
      assert_not_equal "no-cache", last_response["Cache-Control"]
    end

    should "leave the ETag alone" do
      get "/foooo"
      assert_equal %Q{"an-etag"}, last_response["ETag"]
    end
  end

  context "with a key file" do
    setup do
      @app = Rack::CacheBuster::Auto.new(CACHEY_APP, __FILE__, "/no-file-here.txt")
    end

    should "still not set cache-control to no-cache" do
      get "/foooo"
      assert_not_equal "no-cache", last_response["Cache-Control"]
    end

    should "fiddle with the ETag" do
      get "/foooo"
      assert_equal %Q{"an-etag-#{DIGEST_OF_HASH_FOO}"}, last_response["ETag"]
    end
  end

  context "with an enabled file" do
    setup do
      @app = Rack::CacheBuster::Auto.new(CACHEY_APP, "/no-file-here.txt", __FILE__)
    end

    should "set cache-control to no-cache" do
      get "/foooo"
      assert_equal "no-cache", last_response["Cache-Control"]
    end

    should "leave the ETag alone" do
      get "/foooo"
      assert_equal %Q{"an-etag"}, last_response["ETag"]
    end
  end

  context "with an enabled file and a key file" do
    setup do
      @app = Rack::CacheBuster::Auto.new(CACHEY_APP, __FILE__, __FILE__)
    end

    should "set cache-control to no-cache" do
      get "/foooo"
      assert_equal "no-cache", last_response["Cache-Control"]
    end

    should "fiddle with the ETag" do
      get "/foooo"
      assert_equal %Q{"an-etag-#{DIGEST_OF_HASH_FOO}"}, last_response["ETag"]
    end
  end
end
