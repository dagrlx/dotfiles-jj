return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "pylint" },
			nix = { "nix" },
			bash = { "shellcheck" },
			yaml = { "yamllint" },
			sql = { "sqlfluff" },
			lua = { "luacheck" },
			markdown = { "markdownlint" },
			terraform = { "tflint" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {

			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>ll", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })

		-- Configuración opcional para evitar errores molestos si un linter no está instalado
		lint.on_config_done = function()
			-- Elimina los linters que no están instalados
			local available_linters = lint.get_available_linters()
			for ft, linters in pairs(lint.linters_by_ft) do
				local filtered_linters = {}
				for _, linter in ipairs(linters) do
					if vim.tbl_contains(available_linters, linter) then
						table.insert(filtered_linters, linter)
					else
						print(string.format("Linter '%s' for filetype '%s' is not installed.", linter, ft)) -- Imprime un mensaje informativo
					end
				end
				lint.linters_by_ft[ft] = filtered_linters
			end
		end
	end,
}
