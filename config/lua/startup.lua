local function should_skip_dashboard()
    if vim.fn.argc() > 0 then return true end

	local lines = vim.api.nvim_buf_line_count(0)
    if lines > 1 or vim.api.nvim_get_current_line() ~= "" then
		return true
	end

    -- Skip when there are other listed buffers in windows.
    local curr_buf = vim.api.nvim_get_current_buf()
    for _, win in pairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if buf ~= curr_buf and vim.bo[buf].buflisted then return true end
    end

    -- Handle nvim -M
    if not vim.o.modifiable then return true end

    ---@diagnostic disable-next-line: undefined-field
    for _, arg in ipairs(vim.v.argv) do
        -- whitelisted arguments
        -- always open
        if arg == "--startuptime"
        then return false
        end

        -- blacklisted arguments
        -- always skip
        if arg == "-b"
            -- commands, typically used for scripting
            or arg == "-c" or vim.startswith(arg, "+")
            or arg == "-S"
        then return true
        end
    end

    -- base case: don't skip
    return false
end


local function setup_buffer(conf, state)
	local bo = vim.bo
	bo.bufhidden = "wipe"
	bo.buflisted = false
	bo.swapfile = false
	bo.buftype = "nofile"
	bo.filetype = ""
	bo.modifiable = false

	local wo = vim.wo
	-- wo.wrap = false
	-- wo.colorcolumn = ""
	-- wo.foldlevel = 999
	-- wo.foldcolumn = "0"
	-- wo.cursorcolumn = false
	-- wo.cursorline = false
	-- wo.number = false
	-- wo.relativenumber = false
	-- wo.list = false
	-- wo.spell = false
	-- wo.signcolumn = "no"

	local opt = vim.opt_local
	opt.matchpairs = {}
	opt.synmaxcol = 0
end

local function most_recently_used(max_cwd, max_global)
	local cwd = vim.fn.getcwd();
	local cwd_mru = {}
	local global = {}

	for i=1, math.min(#vim.v.oldfiles, 200) do
		local path = vim.v.oldfiles[i]
		if vim.startswith(path, cwd) then
			cwd_mru[#cwd_mru+1] = path
		else
			global[#global+1] = path
		end

		if #cwd_mru >= max_cwd and #global >= max_global then
			break
		end
	end

	return cwd_mru, global
end

local function open_at_last_pos(path)
  local bufnr = vim.fn.bufadd(path)
  vim.fn.bufload(bufnr)
  vim.api.nvim_win_set_buf(0, bufnr)

  local mark = vim.api.nvim_buf_get_mark(bufnr, '"')
  local lcount = vim.api.nvim_buf_line_count(bufnr)

  if mark[1] > 0 and mark[1] <= lcount then
    pcall(vim.api.nvim_win_set_cursor, 0, mark)
  end

  return bufnr
end

local function draw()
	local text = {
		"[q]: Quit",
		"[e]: Edit (empty buffer)",
	}
	vim.keymap.set("n", "q", "<Cmd>q<CR>", {buffer = 0})
	vim.keymap.set("n", "e", "<Cmd>ene<CR>", {buffer = 0})

	-- home row left side then numbers (colemak layout)
	local cwd_keys = {'a','r','s','t','1','2','3','4','5'}
	-- home row right side then numbers (colemak layout)
	-- also my 6+1 key is broken so skip that lmao
	local global_keys = {'n','e','i','o','6','8','9','0'}

	text[#text+1] = ""
	text[#text+1] = "MRU current working dir"
	local cwd, global = most_recently_used(#cwd_keys, #global_keys)
	for i = 1, math.min(#cwd, #cwd_keys) do
		text[#text+1] = "["..cwd_keys[i].."]: "..cwd[i]
		vim.keymap.set("n", cwd_keys[i], function() open_at_last_pos(cwd[i]) end, {buffer = 0})
	end
	text[#text+1] = ""
	text[#text+1] = "MRU global"
	for i = 1, math.min(#global, #global_keys) do
		text[#text+1] = "["..global_keys[i].."]: "..global[i]
		vim.keymap.set("n", global_keys[i], function() open_at_last_pos(global[i]) end, {buffer = 0})
	end  

	vim.bo.modifiable = true
	vim.api.nvim_buf_set_lines(0, 0, -1, false, text)
	vim.bo.modifiable = false
end

if not should_skip_dashboard() then 
	setup_buffer()

	vim.api.nvim_create_autocmd("VimEnter", {
	  once = true,
	  callback = function()
		draw()
	  end,
	})
end

