# Rack::CacheBuster

Place this in your rack stack and all caching will be gone.

Add an optional key to salt the ETags in and out of your app.

## Usage:
    use Rack::CacheBuster, APP_VERSION

# Rack::CacheBuster::Auto

Use to wind down a running app when needed.

Busts the cache when enabled file exists, salts the ETags when key_file exists.

## Usage:

### Setup:

ensure you have a REVISION file on your production servers, capistrano does this by default.

    use Rack::CacheBuster::Auto, File.join(Rails.root, "REVISION"), File.join(Rails.root, "WIND_DOWN")

### Before you deploy:

* Find the maximum cache duration for all pages in your app, start this process with at least that amount time before you deploy.

* Create a WIND_DOWN file in the app root of all your app servers.

* Restart all instances (touch tmp/restart.txt will be fine for passenger apps).

During this period all caching will be disabled. If you respect If-Modified (using `stale?` in rails for example), these will still be respected.

Once all the caches should have expired you can deploy as normal.