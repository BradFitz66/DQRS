--Some extra math stuff

local math_utils={}
math_utils.__index=math

---Round a number
---@param number number
---@param nearest number
---@return number
function math_utils.round(number, nearest)
	return math.round(number / 45) * 45;
end

---Round a number to the Nth decimal
---@param num number
---@param n number
---@return number
function math_utils.round_to_Nth_decimal(num, n)
	local mult = 10^(n or 0)
	return math.floor(num * mult + 0.5) / mult
end

---Get the sign of a number (1 if position, -1 if negative, 0 if 0)
---@param number number
---@return number
function math_utils.sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end
---Check if two triangles share an edge
---@param t1 table
---@param t2 table
---@return boolean
function math_utils.share_edge(t1, t2)
	local v1 = t1[1] == t2[1] or t1[1] == t2[2] or t1[1] == t2[3]
	local v2 = t1[2] == t2[1] or t1[2] == t2[2] or t1[2] == t2[3]
	local v3 = t1[3] == t2[1] or t1[3] == t2[2] or t1[3] == t2[3]
	return (v1 and v2) or (v1 and v3) or (v2 and v3)
end

---Rotate a point around another point 
---@param sx number
---@param sy number
---@param radius number
---@param angle number
---@return number
---@return number
function math_utils.rotate_point( sx, sy, radius, angle )
	local cx = sx + radius * math.cos(angle)
	local cy = sy + radius * math.sin(angle)
	return cx, cy
end


return math_utils