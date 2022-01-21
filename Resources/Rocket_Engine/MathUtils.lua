local math_utils
math_utils.__index={}

---Round a number
---@param number number
---@param nearest number
---@return number
function round(number, nearest)
	return math.round(number / 45) * 45;
end

---Round a number to the Nth decimal
---@param num number
---@param n number
---@return number
function round_to_Nth_decimal(num, n)
	local mult = 10^(n or 0)
	return math.floor(num * mult + 0.5) / mult
end

---Get the sign of a number (1 if position, -1 if negative, 0 if 0)
---@param number number
---@return number
function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end



---Rotate a point around another point 
---@param sx number
---@param sy number
---@param radius number
---@param angle number
---@return number
---@return number
function rotate_point( sx, sy, radius, angle )
	local cx = sx + radius * math.cos(angle)
	local cy = sy + radius * math.sin(angle)
	return cx, cy
end


return math_utils