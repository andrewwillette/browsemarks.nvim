local M = {}

local config = require("browsemarks.config")
local chromium = require("browsemarks.browsers.chromium")

-- Setup function for the plugin.
---@param opts? BrowsemarksConfig
function M.setup(opts)
  config.setup(opts)
end

function M.add_bookmark()
  chromium.add_bookmark()
end

return M
