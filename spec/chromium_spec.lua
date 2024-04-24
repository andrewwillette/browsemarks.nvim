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


      -- assert(chrome_json ~= nil)
      -- print runtime path
      -- print(vim.inspect(vim.opt.rtp))
    end)
  end)
end)
