require 'digest/md5'

module Rack
  class CacheBuster
    autoload :Auto, "rack/cache_buster/auto"

    def initialize(app, key = nil)
      @app = app
      if key
        @key = "-"+Digest::MD5.hexdigest(key).freeze
        @key_regexp = /#{@key}/.freeze
      end
    end

    def call(env)
      env = env.dup
      unpatch_etag!(env) if key

      status, headers, body = app.call(env)

      headers = headers.dup
      patch_etag!(headers) if key
      bust_cache!(headers)

      [status, headers, body]
    end

  protected
    QUOTE_STRIPPER=/^"|"$/.freeze
    ETAGGY_HEADERS = ["HTTP_IF_NONE_MATCH", "HTTP_IF_MATCH", "HTTP_IF_RANGE"].freeze
    ETag = "ETag".freeze
    CacheControl = "Cache-Control".freeze

    attr_reader :app
    attr_reader :key


    def bust_cache!(headers)
      headers[CacheControl] = "no-cache"
    end

    def unpatch_etag!(headers)
      ETAGGY_HEADERS.each do |k|
        headers[k] = headers[k].gsub(@key_regexp, "") if headers[k]
      end
    end

    def patch_etag!(headers)
      stripped_tag = headers[ETag].to_s.gsub(QUOTE_STRIPPER, "")
      return if stripped_tag.empty?
      headers[ETag] = %Q{"#{stripped_tag}#{key}"}
    end
  end
end
