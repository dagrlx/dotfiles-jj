local colors = {
	black = 0xff181819,
	white = 0xffe2e2e3,
	red = 0xfffc5d7c,
	green = 0xff9ed072,
	blue = 0xff76cce0,
	yellow = 0xffe7c664,
	orange = 0xfff39660,
	magenta = 0xffb39df3,
	purple = 0xffc29df1,
	grey = 0xff7f8490,
	dirtywhite = 0xc8cad3f5,
	lightblack = 0x8a262323,
	transparent = 0x00000000,

	bar = {
		bg = 0x00000000,
		border = 0xff2c2e34,
	},
	popup = {
		bg = 0xc02c2e34,
		border = 0xff7f8490,
	},
	bg1 = 0xff363944,
	bg2 = 0xff414550,
}

-- Función para ajustar la transparencia de un color
function colors.with_alpha(color, alpha)
	-- Si el color es nil, devolver transparente
	if not color then
		return colors.transparent
	end

	-- Si alpha está fuera del rango, devolver el color original
	if alpha > 1.0 or alpha < 0.0 then
		return color
	end

	-- Extraer los componentes RGB del color
	local r = (color >> 16) & 0xff
	local g = (color >> 8) & 0xff
	local b = color & 0xff

	-- Calcular el nuevo valor de alpha
	local a = math.floor(alpha * 255)

	-- Combinar los componentes en un nuevo color con transparencia
	return (a << 24) | (r << 16) | (g << 8) | b
end

return colors
