require "rack/cache_buster"

class Rack::CacheBuster::Rails < Rack::CacheBuster
  def initialize(app)
    app_version    = File.read(File.join(::Rails.root, "REVISION")) rescue nil
    wind_down_time = Time.parse(File.read(File.join(::Rails.root, "WIND_DOWN"))) rescue nil
    super(app, app_version, wind_down_time)
  end
end
