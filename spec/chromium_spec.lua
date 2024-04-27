local chromium = require("browsemarks.browsers.chromium")
local utils = require("browsemarks.utils")

-- local helpers = require "spec.helpers"

describe("chromium", function()
  before_each(function()
  end)

  after_each(function()
  end)


  describe("collect_bookmarks", function()
    it("should return all the bookmarks and folders for chromium", function()
      local chrome_json_location = utils.get_config_dir("chrome") .. "/Bookmarks"
      local chrome_json = io.open(chrome_json_location, "r")
      local test = { "heello", "world" }
      local swag = { test = test }
      print(vim.inspect(swag))
      local change_swag = swag.test
      table.insert(change_swag, "new")
      print(vim.inspect(change_swag))
      print(vim.inspect(swag))
    end)
  end)
end)
