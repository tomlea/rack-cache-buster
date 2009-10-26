# Rack::CacheBuster

Use to wind down a running app when needed.

Limits the max-age to the contents of the `WIND_DOWN` file, and salts the ETags to unsure clients see different deployments as having different contents.

## Usage:
    require "rack/cache_buster"
    …
    use Rack::CacheBuster, APP_VERSION, WIND_DOWN_TIME


## Rails Usage:
    require "rack/cache_buster"
    …
    use Rack::CacheBuster::Rails

### Before you deploy (capistrano):

Add this to your `deploy.rb`:

    begin
      gem "rack-cache-buster"
      require 'rack_cache_buster_recipes'
    rescue LoadError
      puts "\n\n*** Please gem install rack-cache-buster before trying to deploy.\n\n"
    end

    # set :wind_down_time, 60*60 # defaults to 1hr

Then:

    cap cache:winddown

… wait 1 hr …

    cap deploy:migrations

… profit!

### Before you deploy (other):

* Find the maximum cache duration for all pages in your app, start this process with at least that amount time before you deploy.

* Create a WIND_DOWN file in the app root of all your app servers.

* Restart all instances (touch tmp/restart.txt will be fine for passenger apps).

* Once all the caches should have expired you can deploy as normal.

## Notes

If you are using Rack::Cache, you can safely put the CacheBuster below it in the stack, but only if you clear Rack::Cache's cache upon deploy.

This is actually the recommended approach as it will prevent the increased amount of hits between `WIND_DOWN_TIME` and your actual deployment from making it through to your app.