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
	-- TODO redo this but then in a callback set them up again or something?
	-- seems a lot of effort for no real gain though
	
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

local function most_recently_used(target_cwd, target_home, target_system)
	local cwd = vim.fn.getcwd();
	local cwd_mru = {}
	local home = vim.env.HOME
	local home_mru = {}
	local system_mru = {}

	local oldfiles = vim.tbl_map(function(path)
	  local stat = vim.uv.fs_stat(path)
	  return { 
		  path = path, 
		  mtime = stat and stat.mtime.sec or 0 
	  }
	end, vim.v.oldfiles)
	table.sort(oldfiles, function (a, b)
		return a.mtime > b.mtime
	end)

	print(home)
	for i=1, math.min(#oldfiles, 200) do
		local path = oldfiles[i].path
		if path == "health://" then
			goto continue
		end

		if vim.startswith(path, cwd .. "/") then
			cwd_mru[#cwd_mru+1] = path:sub(#cwd + 2)
		elseif vim.startswith(path, home .. "/") then
			home_mru[#home_mru+1] = path:sub(#home + 2)
		else
			system_mru[#system_mru+1] = path
		end

		if #cwd_mru >= target_cwd 
			and #home_mru >= target_home 
			and #system_mru >= target_system then
			break
		end

		::continue::
	end

	return cwd_mru, home_mru, system_mru
end

local function open_at_last_pos(path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  local pos = vim.api.nvim_buf_get_mark(0, '"')

  if pos[1] > 0 and pos[1] <= vim.api.nvim_buf_line_count(0) then
    vim.api.nvim_win_set_cursor(0, pos)
  end
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
	local home_keys = {'n','e','i','o','6','8','9','0'}
	-- row above home row
	local system_keys = {'q','w','f','p','l','u','y','/'}

	text[#text+1] = ""
	text[#text+1] = "MRU current working dir"
	local cwd_mru, home_mru, system_mru = most_recently_used(#cwd_keys, #home_keys, #system_keys)
	for i = 1, math.min(#cwd_mru, #cwd_keys) do
		text[#text+1] = "["..cwd_keys[i].."]: "..cwd_mru[i]
		vim.keymap.set("n", cwd_keys[i], function() open_at_last_pos(cwd_mru[i]) end, {buffer = 0})
	end

	if #home_mru > 0 then 
		text[#text+1] = ""
		text[#text+1] = "MRU home"
		for i = 1, math.min(#home_mru, #home_keys) do
			text[#text+1] = "["..home_keys[i].."]: "..home_mru[i]
			vim.keymap.set("n", home_keys[i], function() open_at_last_pos(home_mru[i]) end, {buffer = 0})
		end  
	end

	if #system_mru > 0 then
		text[#text+1] = ""
		text[#text+1] = "MRU system"
		for i = 1, math.min(#system_mru, #system_keys) do
			text[#text+1] = "["..system_keys[i].."]: "..system_mru[i]
			vim.keymap.set("n", system_keys[i], function() open_at_last_pos(system_mru[i]) end, {buffer = 0})
		end  
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

