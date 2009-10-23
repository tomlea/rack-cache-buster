require "test_helper"

class CacheBustingTest < IntegrationTest
  DIGEST_OF_FOO=Digest::MD5.hexdigest("foo")

  should "forward the request to the app" do
    given_env = nil
    @app = Rack::CacheBuster.new(lambda { |env| given_env = env; [200, {}, []]  }, nil, Time.now)
    get "/foooo"
    assert_not_nil given_env
    assert_equal given_env["PATH_INFO"], "/foooo"
  end

  should "forward the request to the app with digests removed" do
    given_env = nil

    @app = Rack::CacheBuster.new(lambda { |env| given_env = env; [200, {}, []]  }, "foo", Time.now)

    ["If-None-Match", "If-Match", "If-Range"].each do |k|
      header(k, "foo-#{DIGEST_OF_FOO}")
    end

    get "/foooo"

    Rack::CacheBuster::ETAGGY_HEADERS.each do |k|
      assert_equal "foo", given_env[k], "#{k} should be set to foo"
    end
  end

  should "set max-age to 0 if we should already have expired" do
    @app = Rack::CacheBuster.new(CACHEY_APP, nil, Time.now - 100)
    get "/foooo"
    assert_equal "max-age=0, public", last_response["Cache-Control"]
  end

  should "set max-age to 0 if we are at expirey time" do
    @app = Rack::CacheBuster.new(CACHEY_APP, nil, Time.now)
    get "/foooo"
    assert_equal "max-age=0, public", last_response["Cache-Control"]
  end

  should "set max-age to 10 if we have 10s left" do
    @app = Rack::CacheBuster.new(CACHEY_APP, nil, Time.now + 10)
    get "/foooo"
    assert_equal "max-age=10, public", last_response["Cache-Control"]
  end

  should 'append version to etag of response' do
    @app = Rack::CacheBuster.new(CACHEY_APP, "foo", Time.now)
    get "/"
    assert_equal %Q{"an-etag-#{DIGEST_OF_FOO}"}, last_response["ETag"]
  end

end
