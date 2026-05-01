return {
	{
    "sindrets/diffview.nvim",
    dependencies = {
        { "nvim-tree/nvim-web-devicons", lazy = true },
    },
    keys = {
        {
            "<leader>e",
            function()
                local views = require("diffview.lib").views
                if next(views) ~= nil then
                    local cur_tab = vim.api.nvim_get_current_tabpage()
                    for _, view in pairs(views) do
                        if view.tabpage == cur_tab then
                            pcall(vim.cmd, "DiffviewClose")
                            return
                        end
                    end
                    for _, view in pairs(views) do
                        if vim.api.nvim_tabpage_is_valid(view.tabpage) then
                            vim.api.nvim_set_current_tabpage(view.tabpage)
                            return
                        end
                    end
                end
                vim.cmd("DiffviewOpen")
            end,
            desc = "Diffview: working tree vs HEAD (toggle)",
        },
        {
            "dv",
            function()
                local views = require("diffview.lib").views
                if next(views) ~= nil then
                    local cur_tab = vim.api.nvim_get_current_tabpage()
                    for _, view in pairs(views) do
                        if view.tabpage == cur_tab then
                            pcall(vim.cmd, "DiffviewClose")
                            return
                        end
                    end
                    -- diffview open in another tab → jump to it
                    for _, view in pairs(views) do
                        if vim.api.nvim_tabpage_is_valid(view.tabpage) then
                            vim.api.nvim_set_current_tabpage(view.tabpage)
                            return
                        end
                    end
                end

                local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]

                local default_base = "main"
                vim.fn.system("git rev-parse --verify --quiet origin/main")
                if vim.v.shell_error ~= 0 then
                    default_base = "master"
                end

                -- Case 1: on main/master → show last commit
                if branch == default_base or branch == "main" or branch == "master" then
                    local sha = vim.fn.systemlist("git rev-parse HEAD")[1]
                    vim.cmd("DiffviewOpen " .. sha .. "^!")
                    vim.notify("Diffview: last commit on " .. branch .. " (" .. sha:sub(1, 8) .. ")")
                    return
                end

                -- Cache setup (1 hour TTL)
                local CACHE_TTL = 20 * 60 -- seconds
                _G._dv_pr_base_cache = _G._dv_pr_base_cache or {}
                local cache = _G._dv_pr_base_cache

                local function open_with_base(base, source)
                    vim.cmd("DiffviewOpen origin/" .. base .. "...HEAD")
                    vim.notify(string.format("Diffview: %s vs origin/%s (%s)", branch, base, source))
                end

                -- Case 2a: cache hit and not expired
                local entry = cache[branch]
                if entry and (os.time() - entry.time) < CACHE_TTL then
                    open_with_base(entry.base, "cached")
                    return
                end

                -- Case 2b: async lookup via gh
                vim.notify("Looking up PR base for " .. branch .. "...")
                vim.system(
                    { "gh", "pr", "view", branch, "--json", "baseRefName", "--jq", ".baseRefName" },
                    { text = true },
                    function(result)
                        vim.schedule(function()
                            local base = result.stdout and result.stdout:gsub("%s+$", "") or ""
                            if result.code == 0 and base ~= "" then
                                cache[branch] = { base = base, time = os.time() }
                                open_with_base(base, "PR base")
                            else
                                open_with_base(default_base, "no PR found")
                            end
                        end)
                    end
                )
            end,
            desc = "Smart Diffview (PR scope)",
        },
        {
            "dV",
            function()
                vim.ui.input({ prompt = "PR number: " }, function(pr_number)
                    if not pr_number or pr_number == "" then
                        return
                    end

                    vim.notify("Fetching PR #" .. pr_number .. "...")
                    vim.system(
                        { "gh", "pr", "view", pr_number, "--json", "state,baseRefName,headRefName,mergeCommit" },
                        { text = true },
                        function(result)
                            vim.schedule(function()
                                if result.code ~= 0 then
                                    vim.notify("gh pr view failed for #" .. pr_number, vim.log.levels.ERROR)
                                    return
                                end

                                local ok, data = pcall(vim.fn.json_decode, result.stdout)
                                if not ok or not data then
                                    vim.notify("Could not parse gh output", vim.log.levels.ERROR)
                                    return
                                end

                                if next(require("diffview.lib").views) ~= nil then
                                    pcall(vim.cmd, "DiffviewClose")
                                end

                                if data.state == "MERGED" and data.mergeCommit and data.mergeCommit.oid then
                                    local sha = data.mergeCommit.oid
                                    vim.cmd("DiffviewOpen " .. sha .. "^!")
                                    vim.notify("Diffview: PR #" .. pr_number .. " (merged, " .. sha:sub(1, 8) .. ")")
                                else
                                    local range = string.format("origin/%s...origin/%s", data.baseRefName, data.headRefName)
                                    vim.cmd("DiffviewOpen " .. range)
                                    vim.notify(string.format("Diffview: PR #%s (%s -> %s)", pr_number, data.headRefName, data.baseRefName))
                                end
                            end)
                        end
                    )
                end)
            end,
            desc = "Diffview by PR number",
        },
        {
            "<leader>dc",
            function()
                _G._dv_pr_base_cache = {}
                vim.notify("Diffview PR cache cleared")
            end,
            desc = "Clear Diffview PR cache",
        },
    },
},
	{
		"lewis6991/gitsigns.nvim",
		-- keys = {
		-- 	{ "<leader>gl", "<cmd>Gitsigns blame_line<cr>", desc = "Git blame line" },
		-- 	{ "<leader>gd", "<cmd>Gitsigns diffthis<cr>",   desc = "Git Diff" },
		-- },

		config = function()
			vim.keymap.set("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", { silent = true })
			vim.keymap.set("n", "<leader>gl", "<cmd>Gitsigns blame_line<cr>", { silent = true })
			require("gitsigns").setup({})
		end,
	},
	{
		"pwntester/octo.nvim",
		cmd = "Octo",
		opts = {
			-- or "fzf-lua" or "snacks" or "default"
			picker = "telescope",
			-- bare Octo command opens picker of commands
			enable_builtin = true,
		},
		keys = {
			{
				"<leader>oi",
				"<CMD>tabnew | Octo issue list<CR>",
				desc = "List GitHub Issues",
			},
			{
				"<leader>op",
				"<CMD>tabnew | Octo pr list<CR>",
				desc = "List GitHub PullRequests",
			},
			{
				"<leader>od",
				"<CMD>tabnew | Octo discussion list<CR>",
				desc = "List GitHub Discussions",
			},
			{
				"<leader>on",
				"<CMD>tabnew | Octo notification list<CR>",
				desc = "List GitHub Notifications",
			},
			{
				"<leader>os",
				function()
					vim.cmd("tabnew")
					require("octo.utils").create_base_search_command({ include_current_repo = true })
				end,
				desc = "Search GitHub",
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"ibhagwan/fzf-lua",
			-- OR "folke/snacks.nvim",
			"nvim-tree/nvim-web-devicons",
		},
	},
}
