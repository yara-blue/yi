-- test using :luafile %

local util = require("util")

local M = {
	file_ignore_patterns = {}
}

-- largest chunk of changes that a single author worked on
function jj_commits_for_author_in_last_n_commits(n) 
	-- also trim trailing \n from system
	local user_name = vim.fn.system("jj config get user.name")
	local user_name = string.sub(user_name, 0, string.len(user_name) - 1) 
	local user_email = vim.fn.system("jj config get user.email")
	local user_email = string.sub(user_email, 0, string.len(user_email) - 1)

	local template = [['stringify(self.commit_id()) ++ "\t" ++ self.author().name() ++ "\t" ++ self.author().email()']]

	local lines = vim.fn.system("jj log -r 'ancestors(@, "..n..") | @' --template " .. template)

	local res = {}
	for line in vim.gsplit(lines, "\n") do
		-- limit lines we'll check
		if n == 0 then break else n = n - 1 end

		local line = vim.split(line, "\t")
		if user_name ~= line[2] or user_email ~= line[3] then
			break
		end

		-- chop off: `@  ` and `◆  `
		local without_header = string.match(line[1], "%w+")
		if without_header then
			res[without_header] = true
		end
	end
	
	return res
end

function jj_commits_for_author() 
	-- we could do this with jj -r 'reachable(@, mine())'
	-- however that gets slow on large repos, even if we limit it to a small
	-- number of ancestors of `@`
	--
	-- instead we limit number of changes to return and check ourselves
	local check_back = {20, 100, 500, 9999999}

	for _, max_commits in ipairs(check_back) do
		local commits = jj_commits_for_author_in_last_n_commits(max_commits)
		if table_len(commits) < max_commits then
			return commits
		end
	end
end

function jj_changes_for_last_n(n) 
	local n = n or 1

	local template = [['stringify(self.change_id())']]
	local lines = vim.fn.system("jj log -r 'ancestors(@, "..n..") | @' --template " .. template)

	local res = {}
	for change in vim.gsplit(lines, "\n") do
		if n == 0 then break else n = n - 1 end
		-- chop off: `@  ` and `◆  `
		local without_header = vim.split(change, "  ")[2]
		res[without_header] = true
	end
	
	return res
end

function table_len(tbl)
	count = 0
	for _ in pairs(tbl) do count = count + 1 end
	return count
end

function to_revset_string(set)
	local t = {}
	for k,_ in pairs(set) do
		t[#t+1] = k
	end
	return table.concat(t, "|")
end

-- lines in the current file that where modified in the 
-- last n commits
--
-- @ignored_file_pattern: list of paths that should be ignored (lua patterns)
--
-- returns a table of lines with keys: path, linenumber, line
function jj_diff(file_ignore_patterns) 
	local res = {}
	local allowed_commits = jj_commits_for_author()
	local revset = to_revset_string(allowed_commits)

	local template = [['stringify(self.commit().commit_id()) ++ "\t" ++ self.line_number() ++ "\t" ++ self.content()']]
	local ancestors = math.max(0, table_len(allowed_commits) - 1)
	local files = vim.fn.system("jj diff --name-only -r \'".. revset .. "\'")

	if string.len(files) > 1000 then
		error("too many files to inspect, would freeze nvim!")
	end

	-- uncommitted work is shown under this commit in git blame
	allowed_commits["0000000000000000000000000000000000000000"] = true

	for file in vim.gsplit(files, "\n") do
		if string.len(file) == 0 then -- trailing \n
			break -- at the end of input we are done
		end

		for _, pattern in ipairs(file_ignore_patterns) do 
			if string.match(file, pattern) then
				goto continue
			end
		end

		local lines = vim.fn.system("git blame -l ".. file)
		for line in vim.gsplit(lines, "\n") do
			local commit_id = vim.split(line, " ")[1]
			if allowed_commits[commit_id] then 
				local meta_and_content = vim.split(line, ") ")
				local meta = meta_and_content[1]
				local content = meta_and_content[2]
				local unindented = content:gsub("^%s*(.-)%s*$", "%1")
				local row = string.match(meta, "%d+$")

				res[#res+1] = {
					["path"] = file, 
					["lnum"] = tonumber(row), 
					["content"] = unindented
				}
			end -- if
		end --for line
		::continue::
	end -- for file
	return res
end

function shorten_path(path, max_len)
	local res = ""
	local components_left = vim.split(path, "/")
	local max_len = math.max(max_len, 
		math.min(0, #components_left - 1) * 2 -- slashes and one char per path
		+ string.len(components_left[#components_left]) -- full file name
	)

	while #components_left > 0 do
		local last = table.remove(components_left, #components_left)

		local chars_available = math.max(1, max_len - string.len(res))
		local chars_to_take = math.min(chars_available, string.len(last))
		local component = string.sub(last, 0, chars_available)

		if res == "" then
			res = component
		else 
			res = component .. "/" .. res
		end
	end

	return res
end

-- call this after setting up telescope so it can inherit should
function M.setup(file_ignore_patterns) 
	for _, pattern in ipairs(file_ignore_patterns) do
		M.file_ignore_patterns[#M.file_ignore_patterns] = pattern
	end
end

-- Search for string added in last "..n.." changes"
function M.scope()
	local from_telescope = require('telescope.config').values.file_ignore_patterns;
	for _, pattern in ipairs(from_telescope) do
		M.file_ignore_patterns[#M.file_ignore_patterns] = pattern
	end

	local diff = jj_diff(M.file_ignore_patterns)
	local conf = require('telescope.config').values;

	-- pretty good telescope custom picker guide
	-- https://www.jonashietala.se/blog/2024/05/08/browse_posts_with_telescopenvim/
	require('telescope.pickers').new(opts, {
		prompt_title = "Search for string added by the current author",
		finder = require('telescope.finders').new_table({
			results = diff,
			entry_maker = function(entry) 
				return {
					display = shorten_path(entry.path, 20) .. ":  " .. entry.content,
					ordinal = entry.content,
					-- Needed by the preview: vim_buffer_vimgrep
					lnum = entry.lnum,    
					filename = vim.fs.basename(entry.path),
					path = entry.path,
				}
			end,
		}),
		sorter = conf.generic_sorter({}),
		previewer = conf.grep_previewer({}),
	}):find()
end

return M
