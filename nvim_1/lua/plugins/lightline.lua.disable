-- ~/.config/nvim/lua/plugins/lightline.lua

return {
	"itchyny/lightline.vim",
	config = function()
		-- Configuración de lightline
		vim.g.lightline = {
			colorscheme = "catppuccin", -- usa tu propio esquema de colores
			active = {
				left = { { "mode", "paste" }, { "readonly", "filename", "modified" } },
				right = {
					{ "lineinfo" },
					{ "percent" },
					{ "fileformat", "fileencoding", "filetype", "codeium_status", "maximize_status" },
				},
			},
			component_function = {
				maximize_status = "MaximizeStatus",
				codeium_status = "CodeiumStatus",
				-- Otros componentes que ya tienes configurados
			},
		}

		-- Función para lightline para mostrar si una pestaña tiene una ventana
		-- maximizada
		vim.cmd([[
		    function! MaximizeStatus()
		      return luaeval('vim.t.maximized and "   " or ""')
		    endfunction
		    ]])

		-- Función para lightline para mostrar el estado de Codeium
		vim.cmd([[
            function! CodeiumStatus()
              let status = luaeval('vim.api.nvim_call_function("codeium#GetStatusString", {})')
              if status == 'ON'
                return 'CodeiS: ON'
              elseif status == 'OFF'
                return 'CodeiS: OFF'
              else
                return 'Codeium Status: ' . status
              endif
            endfunction
        ]])
	end,
}
