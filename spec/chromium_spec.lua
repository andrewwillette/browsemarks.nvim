local chromium = require("browsemarks.browsers.chromium")
local utils = require("browsemarks.utils")

-- local helpers = require "spec.helpers"

describe("chrome", function()
  before_each(function()
  end)

  after_each(function()
  end)


  describe("collect_bookmarks", function()
    it("should return all the bookmarks for chromium", function()
      -- bookmarks, folders = chromium.collect_bookmarks { selected_browser = "chrome" }
      -- print(vim.inspect(folders))
      -- print(vim.inspect(bookmarks))

      local chrome_json_location = utils.get_config_dir("chrome") .. "/Bookmarks"
      local chrome_json = io.open(chrome_json_location, "r")
      assert(chrome_json ~= nil)
    end)
  end)
end)
