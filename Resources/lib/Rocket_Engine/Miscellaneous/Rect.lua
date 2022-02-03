--[[
    https://raw.githubusercontent.com/monolifed/lua-modules/main/rect.lua
]]

local Rect = {}

Rect.new = function(x, y, width, height)
	return {x = x or 0, y = y or 0, width = width or 0, height = height or 0}
end

Rect.clone = function(rect)
	return {x = rect.x, y = rect.y, width = rect.width, height = rect.height}
end

Rect.set_pos = function(rect, x, y)
	rect.x, rect.y = x, y
	return rect
end

Rect.set_size = function(rect, width, height)
	rect.width, rect.height = width, height
	return rect
end

Rect.set = function(rect, x, y, width, height)
	rect.x, rect.y, rect.width, rect.height = x, y, width, height
	return rect
end

Rect.copy = function(a, b) -- a = b
	a.x, a.y, a.width, a.height = b.x, b.y, b.width, b.height
	return a
end

Rect.includes_point = function(rect, x, y)
	local dx, dy = x - rect.x, y - rect.y
	return dx >= 0 and dx < rect.width and
	       dy >= 0 and dy < rect.height
end

Rect.includes_circle = function(rect, x, y, r)
	r = r or 0
	local dx, dy = x - rect.x, y - rect.y
	return dx >= r and dx + r < rect.width and
	       dy >= r and dy + r < rect.height
end

Rect.includes_rect = function(a, b)
	local dx, dy = b.x - a.x, b.y - a.y
	return dx >= 0 and dx + b.width  < a.width and
	       dy >= 0 and dy + b.height < a.height
end

Rect.intersects = function(rect, x, y, width, height)
	local dx, dy = x - rect.x, y - rect.y
	return dx + width  > 0 and dx < rect.width and
	       dy + height > 0 and dy < rect.height
end

Rect.intersects_rect = function(a, b)
	local dx, dy = b.x - a.x, b.y - a.y
	return dx + b.width  > 0 and dx < a.width and
	       dy + b.height > 0 and dy < a.height
end

return Rect
