require "test_helper"

class CacheBustingTest < IntegrationTest
  DIGEST_OF_FOO=Digest::MD5.hexdigest("foo")

  should "forward the request to the app" do
    given_env = nil
    @app = Rack::CacheBuster.new(lambda { |env| given_env = env; [200, {}, []]  })
    get "/foooo"
    assert_not_nil given_env
    assert_equal given_env["PATH_INFO"], "/foooo"
  end

  should "forward the request to the app with digests removed" do
    given_env = nil

    @app = Rack::CacheBuster.new(lambda { |env| given_env = env; [200, {}, []]  }, "foo")

    ["If-None-Match", "If-Match", "If-Range"].each do |k|
      header(k, "foo-#{DIGEST_OF_FOO}")
    end

    get "/foooo"

    Rack::CacheBuster::ETAGGY_HEADERS.each do |k|
      assert_equal "foo", given_env[k], "#{k} should be set to foo"
    end
  end

  should "set cache-control to no-cache" do
    @app = Rack::CacheBuster.new(CACHEY_APP)
    get "/foooo"
    assert_equal "no-cache", last_response["Cache-Control"]
  end

  should 'append version to etag of response' do
    @app = Rack::CacheBuster.new(CACHEY_APP, "foo")
    get "/"
    assert_equal %Q{"an-etag-#{DIGEST_OF_FOO}"}, last_response["ETag"]
  end

  should "leave the ETag alone if no key is given" do
    @app = Rack::CacheBuster.new(CACHEY_APP)
    get "/foooo"
    assert_equal %Q{"an-etag"}, last_response["ETag"]
  end
end
