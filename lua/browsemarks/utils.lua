local utils = {}

---@enum Browser
local Browser = {
  BRAVE = "brave",
  CHROME = "chrome",
  -- ARC = "arc",
  -- BRAVE_BETA = "brave_beta",
  -- BUKU = "buku",
  -- CHROME_BETA = "chrome_beta",
  -- CHROMIUM = "chromium",
  -- EDGE = "edge",
  -- FIREFOX = "firefox",
  -- QUTEBROWSER = "qutebrowser",
  -- RAINDROP = "raindrop",
  -- SAFARI = "safari",
  -- VIVALDI = "vivaldi",
  -- WATERFOX = "waterfox",
}

local config = require "browsemarks.config"
local state = require "browsemarks.state"

local default_config_dir = {
  Darwin = {
    [Browser.BRAVE] = {
      "Library",
      "Application Support",
      "BraveSoftware",
      "Brave-Browser",
    },
    [Browser.CHROME] = {
      "Library",
      "Application Support",
      "Google",
      "Chrome",
    }
  },
}

-- The character used by the operating system to separate pathname components.
-- This is '/' for POSIX and '\\' for Windows.
local sep = package.config:sub(1, 1)

-- Return a path string made up of the given mix of strings or tables in the
-- order they are provided.
---@param ... string|string[]
---@return string
function utils.join_path(...)
  return table.concat(vim.tbl_flatten { ... }, sep)
end

-- Send a notification using `vim.notify`.
---@param msg string
---@param level integer
local function notify(msg, level)
  vim.notify(msg, level, { title = "browser-bookmarks.nvim" })
end

-- Emit a info message.
---@param msg string
function utils.info(msg)
  notify(msg, vim.log.levels.INFO)
end

-- Emit a warning message.
---@param msg string
function utils.warn(msg)
  notify(msg, vim.log.levels.WARN)
end

-- Return the absolute path to the config directory for the respective OS and
-- browser.
--
-- It first checks if the user provided the path in the configuration, else
-- uses the default path.
--
-- It returns nil if:
--    - the OS or browser is not supported
--    - user provided config path does not exists
---@param selected_browser Browser
---@return string?
function utils.get_config_dir(selected_browser)
  local config_dir = config.values.config_dir
  if config_dir ~= nil then
    if not utils.path_exists(config_dir) then
      utils.warn(
        (
          "No such directory for %s browser: %s "
          .. "(make sure to provide the absolute path which includes "
          .. "the home directory as well)"
        ):format(selected_browser, config_dir)
      )
      return nil
    end
    return config_dir
  end
  local components = (default_config_dir[state.os_name] or {})[selected_browser]
  if components == nil then
    -- This assumes that the check for browser support was already done before
    -- calling this function, thus the message for unsupported OS.
    utils.warn(
      ("Unsupported OS for %s browser: %s"):format(
        selected_browser,
        state.os_name
      )
    )
    return nil
  end
  return utils.join_path(state.os_homedir, components)
end

return utils
