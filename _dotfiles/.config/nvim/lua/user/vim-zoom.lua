vim.api.nvim_set_keymap('n', '<c-z>', [[<cmd>lua min_max_win()<CR>]], {silent=true,noremap=true})
vim.api.nvim_set_keymap('t', '<c-z>', [[<cmd>lua min_max_win()<CR>]], {silent=true,noremap=true})
local last = -1
function _G.min_max_win()
  local total_height = tonumber(vim.api.nvim_command_output([[echo &lines]]))
  local win_nr = vim.api.nvim_get_current_win()
  local cur_height = vim.api.nvim_win_get_height(win_nr)
  --print("total height: "..total_height.."\ncurrent height: "..cur_height.."\nlast: "..last)
  if cur_height+6 < total_height or last < 0 then
    --print("max")
    vim.api.nvim_win_set_height(win_nr, total_height)
    last = cur_height
  else
    --print("min")
    vim.api.nvim_win_set_height(win_nr, last)
    last = -1
  end
end

