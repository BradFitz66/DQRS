local rect = require("Resources.lib.Rocket_Engine.Miscellaneous.Rect")
local sub_window={}
sub_window.__index=sub_window

function sub_window.new(canvas, start_pos, size, window_info, canvas_offset)
    local window=setmetatable({},sub_window)
    window.canvas=canvas
    window.rect=rect.new(start_pos.x,start_pos.y,size.x,size.y)
    window.info=window_info or {}
    window.canvas_offset=canvas_offset or vector.new(0,0)
    return window
end

function sub_window:display_window()
    imgui.SetNextWindowSize(imgui.ImVec2_Float(self.rect.width,self.rect.height))
    if imgui.Begin(self.info.title or "Window") then
		local imgui_rect = imgui.GetWindowContentRegionMin();
		self.rect.x = imgui_rect.x + imgui.GetWindowPos().x;
		self.rect.y = imgui_rect.y + imgui.GetWindowPos().y;
    end
    imgui.End()
end

--Avoid window drawing over canvas
function sub_window:display_canvas()
    love.graphics.draw(self.canvas, self.rect.x + self.canvas_offset.x, self.rect.y + self.canvas_offset.y, 0, 1)
end

return sub_window