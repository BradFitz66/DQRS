--[[
    Debug drawing class. Lets me quickly and easily create debug visuals without having to add extra code to existing classes.
]]
local debug_draw=class("Debug")

function debug_draw:initialize()
    --List of all draws
    self._draws={}
    self._draw_types={
        ["Line"]=function(x1,x2,y1,y2) 
            local draw_func=function() 
                love.graphics.line(x1,y1,x2,y2)
            end
            table.insert(self._draws,draw_func)
            return draw_func 
        end,
        ["Raycast"]=function (start_pos,end_pos) 
            local draw_func=function()
                love.graphics.setColor(1,0,0,1)
                love.graphics.line(start_pos.x,start_pos.y,end_pos.x,end_pos.y)
            end
            table.insert(self._draws,draw_func) 
            return draw_func 
        end,
        ["Circle"]=function (x,y,radius) 
            local draw_func=function()
                love.graphics.setColor(1,0,0,.25)
                love.graphics.circle("fill",x,y,radius)
            end
            table.insert(self._draws,draw_func) 
            return draw_func 
        end
    }
    return self
end

function debug_draw:draw_circle(x,y,radius,time)
    local to_draw=self._draw_types["Circle"](x,y,radius)
    if(time) then
        timer.after(time,function() 
            for i, draw_func in ipairs(self._draws) do
                if(draw_func==to_draw) then
                    table.remove(self._draws,i)
                end
            end
        end)
    end
end

function debug_draw:draw_line(x1,x2,y1,y2,time)
    local to_draw=self._draw_types["Line"](x1,x2,y1,y2)
    if(time) then
        timer.after(time,function() 
            for i, draw_func in ipairs(self._draws) do
                if(draw_func==to_draw) then
                    table.remove(self._draws,i)
                end
            end
        end)
    end
end

function debug_draw:draw_ray(start_pos,end_pos,time)
    local to_draw=self._draw_types["Raycast"](start_pos,end_pos)
    if(time) then
        timer.after(time,function() 
            for i, draw_func in ipairs(self._draws) do
                if(draw_func==to_draw) then
                    table.remove(self._draws,i)
                end
            end
        end)
    end
end

function debug_draw:draw()
    for _, to_draw in pairs(self._draws) do
        to_draw()
    end
end

return debug_draw