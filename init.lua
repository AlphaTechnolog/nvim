local present, Loader = pcall(require, "plugins.loader")
if not present then
  error("cannot load the plugins loader: " .. Loader)
end

require("opts")
require("maps")

local loader = Loader()

local ok, err = pcall(function ()
  loader:install_lazy()
end)

if not ok then
  error("Cannot check for lazy.nvim installation (required): " .. err)
end

local configured_lazy, errmsg = pcall(function ()
  loader:configure_lazy()
end)

if not configured_lazy then
  error("Cannot configure lazy.nvim: " .. errmsg)
end
