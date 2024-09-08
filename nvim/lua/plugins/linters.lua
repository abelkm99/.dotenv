return {
	{
		"mfussenegger/nvim-lint",
		config = function()
			local lint = require("lint")
			-- Add Clippy for Rust
			-- lint.linters.clippy = {
			-- 	name = "clippy",
			-- 	cmd = "cargo",
			-- 	args = { "clippy", "--message-format=json" },
			-- 	stdin = false,
			-- 	append_fname = false,
			-- 	stream = "both", -- Use both stdout and stderr
			-- 	ignore_exitcode = true,
			-- 	parser = function(output, bufnr)
			-- 		local diagnostics = {}
			-- 		local buffer_path = vim.api.nvim_buf_get_name(bufnr)

			-- 		-- Iterate through each line in the output
			-- 		for line in vim.gsplit(output, "\n") do
			-- 			local decoded = vim.json.decode(line)

			-- 			-- Check if the line contains a "compiler-message"
			-- 			if decoded and decoded.reason == "compiler-message" then
			-- 				local message = decoded.message
			-- 				local primary_span = message.spans and message.spans[1]

			-- 				-- Ensure primary_span and file_name are valid
			-- 				if primary_span and primary_span.file_name == buffer_path then
			-- 					table.insert(diagnostics, {
			-- 						lnum = primary_span.line_start - 1,
			-- 						col = primary_span.column_start - 1,
			-- 						end_lnum = primary_span.line_end - 1,
			-- 						end_col = primary_span.column_end - 1,
			-- 						severity = (message.level == "error" and 1)
			-- 							or (message.level == "warning" and 2)
			-- 							or 3,
			-- 						source = "clippy",
			-- 						message = message.message,
			-- 					})
			-- 				end
			-- 			end
			-- 		end

			-- 		return diagnostics
			-- 	end,
			-- }
			-- Define golangci-lint
			lint.linters.golangci_lint = {
				name = "golangci_lint",
				cmd = "golangci-lint",
				args = { "run", "--out-format", "json" },
				parser = function(output, bufnr)
					local diagnostics = {}
					if output and output ~= "" then
						local decoded = vim.json.decode(output)
						for _, issue in ipairs(decoded.Issues or {}) do
							table.insert(diagnostics, {
								lnum = issue.Pos.Line - 1,
								col = issue.Pos.Column - 1,
								end_lnum = issue.Pos.Line - 1,
								end_col = issue.Pos.Column - 1,
								severity = 1, -- You might want to map this based on issue.Severity
								source = issue.FromLinter,
								message = issue.Text,
							})
						end
					end
					return diagnostics
				end,
			}

			-- Define the linters you want to use for different file types
			lint.linters_by_ft = {
				python = { "ruff", "mypy" },
				javascript = { "eslint" },
				typescript = { "eslint" },
				-- lua = { "luacheck" },
				-- go = { "golangci_lint" },
				-- Add more file types and their corresponding linters here
			}

			-- Create an autocmd to trigger linting
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
				callback = function()
					lint.try_lint()
				end,
			})

			-- Optional: Set up a keymap to trigger linting manually
			vim.keymap.set("n", "<leader>cl", function()
				lint.try_lint()
			end, { desc = "Trigger linting for current file" })
		end,
	},
}
