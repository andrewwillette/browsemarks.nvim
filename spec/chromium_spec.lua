local chromium = require "browsemarks.browsers.chromium"
local utils = require "browsemarks.utils"

-- local helpers = require "spec.helpers"

describe("chrome", function()
  before_each(function()
  end)

  after_each(function()
  end)

  describe("collect_bookmarks", function()
    it("should return all the bookmarks for chromium", function()
      bookmarks = chromium.collect_bookmarks { selected_browser = "chrome" }
      print(vim.inspect(bookmarks))
    end)
  end)
end)
