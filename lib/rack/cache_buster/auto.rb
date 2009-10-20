require "rack/cache_buster"

class Rack::CacheBuster::Auto < Rack::CacheBuster
  def initialize(app, key_filename, enabled_filename)
    @enabled = File.exists?(enabled_filename)
    key = File.exists?(key_filename) && File.open(key_filename).gets.chomp
    super(app, key)
  end

  def bust_cache!(headers)
    @enabled ? super(headers) : headers
  end
end
