return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"saghen/blink.cmp", -- Para la integración con blink.cmp
		"williamboman/mason.nvim", -- Para instalar servidores LSP fácilmente
		"williamboman/mason-lspconfig.nvim", -- Para manejar la configuración con mason y lspconfig
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					{ path = "luvit-meta/library", words = { "vim%.uv" } },
				},
			},
		},
	},
	config = function()
		-- Configuración básica
		local lspconfig = require("lspconfig")
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		-- Configurar Mason para manejar instalaciones de servidores LSP
		mason.setup()
		mason_lspconfig.setup()

		-- Configuración de LSP para lenguajes específicos
		mason_lspconfig.setup_handlers({
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = capabilities,
				})
			end,
			["lua_ls"] = function()
				lspconfig.lua_ls.setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							runtime = {
								version = "LuaJIT",
							},
							diagnostics = {
								globals = { "vim" }, -- Reconocer 'vim' como global
							},
							workspace = {
								library = vim.api.nvim_get_runtime_file("", true),
							},
						},
					},
				})
			end,
			["pyright"] = function()
				lspconfig.pyright.setup({
					capabilities = capabilities,
				})
			end,
			["bashls"] = function()
				lspconfig.bashls.setup({
					capabilities = capabilities,
				})
			end,
			["sqls"] = function()
				lspconfig.sqls.setup({
					capabilities = capabilities,
				})
			end,
			["dockerls"] = function()
				lspconfig.sqls.setup({
					capabilities = capabilities,
				})
			end,
			-- ["shellcheck"] = function()
			-- 	lspconfig.sqls.setup({
			-- 		capabilities = capabilities,
			-- 	})
			-- end,
			["ansiblels"] = function()
				lspconfig.sqls.setup({
					capabilities = capabilities,
				})
			end,
			["yamlls"] = function()
				lspconfig.yamlls.setup({
					capabilities = capabilities,
					settings = {
						yaml = {
							schemas = {
								["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
								["https://json.schemastore.org/kustomization.json"] = "kustomization.yaml",
								-- Agrega más esquemas según sea necesario
							},
							format = {
								enable = true,
							},
							validate = true,
							completion = true,
							hover = true,
						},
					},
				})
			end,
			-- ["nil"] = function()
			-- 	lspconfig.sqls.setup({
			-- 		capabilities = capabilities,
			-- 	})
			-- end,
		})

		-- Diagnósticos: configuramos los íconos para errores, advertencias, etc.
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Mapear atajos básicos cuando el LSP está activo
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true, noremap = true }
				local map = vim.keymap.set

				map("n", "gd", vim.lsp.buf.definition, opts)
				map("n", "K", vim.lsp.buf.hover, opts)
				map("n", "gi", vim.lsp.buf.implementation, opts)
				map("n", "<leader>rn", vim.lsp.buf.rename, opts)
				map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
				map("n", "<leader>d", vim.diagnostic.open_float, opts)
				map("n", "[d", vim.diagnostic.goto_prev, opts)
				map("n", "]d", vim.diagnostic.goto_next, opts)
			end,
		})
	end,
}
