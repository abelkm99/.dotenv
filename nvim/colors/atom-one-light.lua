-- Alias: :colorscheme atom-one-light → onedark.nvim with style=light.
-- The package.loaded clearing is critical: onedark.colors runs select_colors()
-- at require-time and caches the palette, so without this loop a previous
-- style sticks and re-applying dark/light mid-session does nothing.
for k in pairs(package.loaded) do
  if k:match("^onedark") then package.loaded[k] = nil end
end
require("onedark").setup({ style = "light" })
require("onedark").colorscheme()
vim.g.colors_name = "atom-one-light"
