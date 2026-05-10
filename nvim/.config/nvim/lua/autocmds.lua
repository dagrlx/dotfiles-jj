-- Ventana flotante para mostrar los msj de diagnostic lsp

vim.o.updatetime = 250

vim.api.nvim_create_augroup("DiagnosticFloat", { clear = true })

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	group = "DiagnosticFloat",
	callback = function()
		vim.diagnostic.open_float(nil, { focus = false })
	end,
})

-- vim.api.nvim_create_autocmd("LspAttach", {
-- 	callback = function(args)
-- 		local client = vim.lsp.get_client_by_id(args.data.client_id)
-- 		local bufname = vim.api.nvim_buf_get_name(0)
-- 		if client.name == "emmylua_ls" and bufname:match(vim.fn.stdpath("config")) then
-- 			vim.lsp.stop_client(client.id)
-- 		end
-- 	end,
-- })
