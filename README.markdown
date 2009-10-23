# Rack::CacheBuster

Use to wind down a running app when needed.

Limits the max-age to the contents of the `WIND_DOWN` file, and salts the ETags to unsure clients see different deployments as having different contents.

## Usage:
    require "rack/cache_buster"
    WIND_DOWN_TIME = Time.parse(File.read(File.join(Rails.root, "WIND_DOWN"))) rescue nil
    APP_VERSION    = File.read(File.join(Rails.root, "REVISION")) rescue nil
    
    …

    use Rack::CacheBuster, APP_VERSION, WIND_DOWN_TIME

### Before you deploy:

* Find the maximum cache duration for all pages in your app, start this process with at least that amount time before you deploy.

* Create a WIND_DOWN file in the app root of all your app servers.

* Restart all instances (touch tmp/restart.txt will be fine for passenger apps).

* Once all the caches should have expired you can deploy as normal.

## Notes

If you are using Rack::Cache, you can safely put the CacheBuster below it in the stack, but only if you clear Rack::Cache's cache upon deploy.

This is actually the recommended approach as it will prevent the increased amount of hits between `WIND_DOWN_TIME` and your actual deployment from making it through to your app.