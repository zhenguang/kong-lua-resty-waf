-- If you're not sure your plugin is executing, uncomment the line below and restart Kong
-- then it will throw an error which indicates the plugin is being loaded at least.

--assert(ngx.get_phase() == "timer", "The world is coming to an end!")

---------------------------------------------------------------------------------------------
-- In the code below, just remove the opening brackets; `[[` to enable a specific handler
--
-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.
---------------------------------------------------------------------------------------------
--
--
  --  sudo apt-get install -y libpcre3-dev , lua-rex-pcre , 
  --  luarocks install lrexlib-pcre
  --  copy cp /kong-plugin/kong/plugins/myplugin/resty/libc.musl-x86_64.so.1 /lib


local plugin = {
  PRIORITY = 10000, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1",
}



-- do initialization here, any module level code runs in the 'init_by_lua_block',
-- before worker processes are forked. So anything you add here will run once,
-- but be available in all workers.



---[[ handles more initialization, but AFTER the worker process has been forked/created.
-- It runs in the 'init_worker_by_lua_block'
function plugin:init_worker()

  -- your custom code here
  kong.log.debug("saying hi from the 'init_worker' handler")

  -- use resty.core for performance improvement, see the status note above
  require "resty.core"

  -- require the base module
  local lua_resty_waf = require "kong.plugins.myplugin.resty.waf"

  -- perform some preloading and optimization
  lua_resty_waf.init()

end --]]



--[[ runs in the ssl_certificate_by_lua_block handler
function plugin:certificate(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'certificate' handler")

end --]]



--[[ runs in the 'rewrite_by_lua_block'
-- IMPORTANT: during the `rewrite` phase neither `route`, `service`, nor `consumer`
-- will have been identified, hence this handler will only be executed if the plugin is
-- configured as a global plugin!
function plugin:rewrite(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'rewrite' handler")

end --]]



---[[ runs in the 'access_by_lua_block'
function plugin:access(plugin_conf)

  -- your custom code here
  kong.log.inspect(plugin_conf)   -- check the logs for a pretty-printed config!
  -- ngx.req.set_header(plugin_conf.request_header, "this is on a request")

  local lua_resty_waf = require "kong.plugins.myplugin.resty.waf"
  local waf = lua_resty_waf:new()

  -- define options that will be inherited across all scopes
  waf:set_option("debug", true)
  waf:set_option("mode", "ACTIVE")
  waf:set_option("error_response", plugin_conf.error_response)

  -- this may be desirable for low-traffic or testing sites
  -- by default, event logs are not written until the buffer is full
  -- for testing, flush the log buffer every 5 seconds
  --
  -- this is only necessary when configuring a remote TCP/UDP
  -- socket server for event logs. otherwise, this is ignored
  waf:set_option("event_log_periodic_flush", 5)

  -- run the firewall
  waf:exec()


end --]]


---[[ runs in the 'header_filter_by_lua_block'
function plugin:header_filter(plugin_conf)
  local lua_resty_waf = require "kong.plugins.myplugin.resty.waf"
  local waf = lua_resty_waf:new()
  waf:exec()
end --]]


 -- runs in the 'body_filter_by_lua_block'
function plugin:body_filter(plugin_conf)
  local lua_resty_waf = require "kong.plugins.myplugin.resty.waf"
  local waf = lua_resty_waf:new()
  waf:exec()
end 


 -- runs in the 'log_by_lua_block'
function plugin:log(plugin_conf)
  local lua_resty_waf = require "kong.plugins.myplugin.resty.waf"
  local waf = lua_resty_waf:new()
  waf:exec()
end 


-- return our plugin object
return plugin