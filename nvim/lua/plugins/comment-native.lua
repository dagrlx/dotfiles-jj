-- Integración de -ts-context-commentstring al sistema de comentario de neovim
-- https://github.com/JoosepAlviste/nvim-ts-context-commentstring/wiki/Integrations#commentnvim

return {
	"JoosepAlviste/nvim-ts-context-commentstring",
	enabled = true,
	event = { "BufReadPre", "BufNewFile" },

	config = function()
		-- Deshabilitar el autocomando CursorHold
		require("ts_context_commentstring").setup({
			enable_autocmd = false,
		})

		-- Anular la función interna get_option de Neovim
		local get_option = vim.filetype.get_option
		vim.filetype.get_option = function(filetype, option)
			if option == "commentstring" then
				-- Calcula el commentstring para Treesitter si está disponible
				local ts_commentstring = require("ts_context_commentstring.internal").calculate_commentstring()
				if ts_commentstring ~= nil and ts_commentstring ~= "" then
					return ts_commentstring
				end

				-- Configuración manual para archivos Nushell si no está definida por Treesitter
				-- if filetype == "nu" or filetype == "text" then
				-- 	return "# %s"
				-- end
			end
			return get_option(filetype, option)
		end
	end,
}
