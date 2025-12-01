local opts = {
  showSelectedThumbnail = false,
  showThumbnails = false,
  thumbnailSize = 112,
  showTitles = true,
  titleBackgroundColor = {0, 0, 0, 0},
  textSize = 11,
  selectedThumbnailSize = 112,
  backgroundColor = {0.1, 0.1, 0.1, 0.9},
  highlightColor = {0.4, 0.4, 0.4, 0.8},
  textColor = {1, 1, 1},
  maxWidth = 100, 
}

local switcher_space = hs.window.switcher.new(
  hs.window.filter.new():setCurrentSpace(true):setDefaultFilter{}, 
  opts
)

hs.hotkey.bind({"cmd"}, "²", function()
  switcher_space:next()
end)
