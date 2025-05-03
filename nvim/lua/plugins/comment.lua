return {
	"numToStr/Comment.nvim",
	enabled = false,
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		-- Configuración de ts_context_commentstring
		require("ts_context_commentstring").setup({
			enable_autocmd = false,
		})

		-- Importar el plugin de comentarios de forma segura
		local comment = require("Comment")
		local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

		-- Habilitar comentarios
		comment.setup({
			-- Para comentar archivos tsx, jsx, svelte, html
			pre_hook = ts_context_commentstring.create_pre_hook(),
		})
	end,
}
