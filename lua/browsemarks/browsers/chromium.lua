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

local function get_folder_paths(folders)
  local names = {}
  for _, folder in ipairs(folders) do
    table.insert(names, folder.path)
  end
  return names
end


---@param inputstr string
---@param sep string
---@return string[]
local function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

local function add_bookmark(new_bookmark, bookmark_folder_path)
  local data = get_bookmark_data({ selected_browser = "chrome" })
  ---@cast data table
  local bookmarks = data.roots["bookmark_bar"]
  if bookmark_folder_path == "" then
    table.insert(bookmarks.children, new_bookmark)
  else
    local path_table = split(bookmark_folder_path, "/")
    local current_folder = bookmarks

    local function find_bookmark_in_folder(bookmark_folder, name)
      for _, child in ipairs(bookmark_folder.children) do
        if child.name == name then
          return child
        end
      end
    end
    for _, name in ipairs(path_table) do
      current_folder = find_bookmark_in_folder(current_folder, name)
    end
    table.insert(current_folder.children, new_bookmark)
  end
  local profile_dir = get_profile_dir({ selected_browser = "chrome" })
  local filepath = utils.join_path(profile_dir, "Bookmarks")
  local file = io.open(filepath, "w")
  if not file then
    utils.warn(
      ("No %s bookmarks file found at: %s"):format(
        "chrome",
        filepath
      )
    )
    return nil, nil
  end
  file:write(vim.json.encode(data))
  file:close()
end

function chromium.new_bookmark()
  bookmark_folders = chromium.collect_folders { selected_browser = "chrome" }
  folder_paths = get_folder_paths(bookmark_folders)
  vim.ui.select(folder_paths, {
    prompt = 'folder for new bookmark: ',
  }, function(folder_path)
    vim.ui.input({
      prompt = 'bookmark name: ',
    }, function(bookmark_name)
      vim.ui.input({
        prompt = 'bookmark name: ',
      }, function(bookmark_url)
        local new_bookmark = {
          name = bookmark_name,
          url = bookmark_url,
          type = 'url',
        }
        add_bookmark(new_bookmark, folder_path)
      end)
    end)
  end)
end

-- for quick testing during development
vim.keymap.set("n", "<leader>tm", function()
  chromium.new_bookmark()
end, { silent = true })

return chromium
