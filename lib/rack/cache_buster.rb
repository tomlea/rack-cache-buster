require 'digest/md5'

module Rack
  class CacheBuster
    def initialize(app, key, target_time = nil)
      @app, @target_time = app, target_time
      @key = "-"+Digest::MD5.hexdigest(key || "blank-key").freeze
      @key_regexp = /#{@key}/.freeze
    end

    def call(env)
      status, headers, body = app.call(unpatch_etag(env))
      [status, patch_etag(limit_cache(headers)), body]
    end

  protected
    QUOTE_STRIPPER=/^"|"$/.freeze
    ETAGGY_HEADERS = ["HTTP_IF_NONE_MATCH", "HTTP_IF_MATCH", "HTTP_IF_RANGE"].freeze
    ETag = "ETag".freeze

    attr_reader :app
    attr_reader :key


    def limit_cache(headers)
      return headers if @target_time.nil?
      cache_control_header = CacheControlHeader.new(headers)
      if cache_control_header.expired?
        headers
      else
        cache_control_header.expire_time = [@target_time, cache_control_header.expire_time].min
        headers.merge(CacheControlHeader::CacheControl => cache_control_header.to_s)
      end
    end

    def unpatch_etag(headers)
      ETAGGY_HEADERS.inject(headers){|memo, k|
        memo.has_key?(k) ? memo.merge(k => strip_etag(memo[k])) : memo
      }
    end

    def strip_etag(s)
      s.gsub(@key_regexp, "")
    end

    def modify_etag(s)
      s = s.to_s.gsub(QUOTE_STRIPPER, "")
      s.empty? ? s : %Q{"#{s}#{key}"}
    end

    def patch_etag(headers)
      headers.merge(ETag => modify_etag(headers[ETag]))
    end

    autoload :CacheControlHeader, "rack/cache_buster/cache_control_header"
    autoload :Rails, "rack/cache_buster/rails"
  end
end
