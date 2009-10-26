require "rack/cache_buster"

class Rack::CacheBuster::CacheControlHeader
  CacheControl = "Cache-Control".freeze
  Age = "Age".freeze
  MaxAge = "max-age".freeze

  def initialize(env)
    @age = env[Age].to_i
    @max_age = 0
    if env[CacheControl]
      parts = env[CacheControl].split(/ *, */)
      settings, options = parts.partition{|part| part =~ /=/ }
      settings = settings.inject({}){|acc, part|
        k, v = part.split(/ *= */, 2)
        acc.merge(k => v)
      }
      @max_age = settings.delete(MaxAge).to_i
      @other_parts = options + settings.map{|k,v| "#{k}=#{v}"}
    end
  end

  def expires_in
    @max_age - @age
  end

  def expired?
    expires_in <= 0
  end

  def expire_time
    Time.now + expires_in
  end

  def expire_time=(t)
    @max_age = [t.to_i - Time.now.to_i + @age, @age].max
  end

  def update_env(env)
    env[CacheControl] = to_s
  end

  def to_s
    ["max-age=#{@max_age}", *@other_parts].join(", ")
  end
end
