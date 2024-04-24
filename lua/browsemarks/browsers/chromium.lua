local chromium = {}

local utils = require "browsemarks.utils"

-- Returns the absolute path to the profile directory for chromium based
-- browsers.
--
-- It will return `nil` if:
--   - the "Local State" file is not found in the config directory
--   - given profile name does not exist
--
-- The profile name will either be the one provided by the user or the default
-- one. The user can define the profile name using `profile_name` option.
---@param config BrowsemarksConfig
---@return string?
local function get_profile_dir(config)
  local config_dir = utils.get_config_dir(config.selected_browser)
  -- print config_dir
  if config_dir == nil then
    return nil
  end

  if config.profile_name == nil then
    return utils.join_path(config_dir, "Default")
  end

  -- state_file holds the profile information for the browser.
  local state_file = utils.join_path(config_dir, "Local State")
  local file = io.open(state_file, "r")
  if not file then
    utils.warn(
      ("No state file found for %s at: %s"):format(
        config.selected_browser,
        state_file
      )
    )
    return nil
  end

  local content = file:read "*a"
  file:close()
  local data = vim.json.decode(content)
  ---@cast data table
  for profile_dir, profile_info in pairs(data.profile.info_cache) do
    -- 'Default' set above
    if profile_info.name == config.profile_name then
      return utils.join_path(config_dir, profile_dir)
    end
  end

  utils.warn(
    ("Given %s profile does not exist: %s"):format(
      config.selected_browser,
      config.profile_name
    )
  )
end

-- Construct the path from the root to the bookmark.
---@param parent_path string
---@param bookmark Bookmark
function construct_path_with_parent(parent_path, bookmark)
  local path = parent_path
      and (parent_path ~= "" and parent_path .. "/" .. bookmark.name or bookmark.name)
      or ""
  return path
end

-- Parse the bookmarks data to a lua table.
---@param data table
---@return Bookmark[] folders
local function parse_data_folders(data)
  local folders = {}
  local function insert_folders(parent_path, bookmark)
    local path = construct_path_with_parent(parent_path, bookmark)
    if bookmark.type == "folder" then
      table.insert(folders, { name = bookmark.name, path = path, url = bookmark.url })
      for _, child in ipairs(bookmark.children) do
        insert_folders(path, child)
      end
    end
  end
  insert_folders(nil, data.roots["bookmark_bar"])
  return folders
end

local function parse_data_bookmarks(data)
  local items = {}
  local function insert_items(parent_path, bookmark)
    local path = construct_path_with_parent(parent_path, bookmark)
    if bookmark.type == "folder" then
      for _, child in ipairs(bookmark.children) do
        insert_items(path, child)
      end
    else
      table.insert(items, {
        name = bookmark.name,
        path = path,
        url = bookmark.url,
      })
    end
  end
  insert_items(nil, data.roots["bookmark_bar"])
  return items
end

function get_bookmark_data(config)
  local profile_dir = get_profile_dir(config)
  if profile_dir == nil then
    utils.warn(("No profile directory found for %s"):format(config.selected_browser))
    return nil, nil
  end

  local filepath = utils.join_path(profile_dir, "Bookmarks")
  local file = io.open(filepath, "r")
  if not file then
    utils.warn(
      ("No %s bookmarks file found at: %s"):format(
        config.selected_browser,
        filepath
      )
    )
    return nil, nil
  end

  local content = file:read "*a"
  file:close()
  if content == nil or content == "" then
    utils.warn(
      ("No content found in %s bookmarks file at: %s"):format(
        config.selected_browser,
        filepath
      )
    )
    return nil, nil
  end

  return vim.json.decode(content)
end

-- Collect all the bookmarks for Chromium based browsers.
---@param config BrowsemarksConfig
---@return Bookmark[]? items
function chromium.collect_bookmarks(config)
  local data = get_bookmark_data(config)
  ---@cast data table
  return parse_data_bookmarks(data)
end

function chromium.collect_folders(config)
  local data = get_bookmark_data(config)
  ---@cast data table
  return parse_data_folders(data)
end

chromium._get_profile_dir = get_profile_dir

local function get_folder_paths(folders)
  local names = {}
  for _, folder in ipairs(folders) do
    table.insert(names, folder.path)
  end
  return names
end


function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

function get_bookmark_with_path(path)
  -- print("calling get_bookmark_with_path with arg: " .. path)
  --@cast data table
  local data = get_bookmark_data({ selected_browser = "chrome" })
  local bookmarks = data.roots["bookmark_bar"]
  local path_table = split(path, "/")
  print("path table: " .. vim.inspect(path_table))
end

-- create keymap 'tm' running this function
--@param bookmarks Bookmark[]
function chromium.new_bookmark()
  folders = chromium.collect_folders { selected_browser = "chrome" }
  folder_paths = get_folder_paths(folders)
  vim.ui.select(folder_paths, {
    prompt = 'folder for new bookmark: ',
  }, function(folder_path)
    local bookmark_data = get_bookmark_with_path(folder_path)
    -- vim.ui.input({
    --   prompt = 'bookmark name: ',
    -- }, function(bookmark_name)
    -- end)
  end)
end

function add_bookmark(bookmark, folder)
  -- get the full data from disk
  -- update the data.bookmarks.'folder'.children with new bookmark
  -- write the data back to disk
  -- local data =
end

-- for quick testing during development
vim.keymap.set("n", "<leader>tm", function()
  chromium.new_bookmark()
end, { silent = true })

return chromium
