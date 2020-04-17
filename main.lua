local timer = require("Resources.lib.HUMP.timer")
local animTimer=timer.new()
local anim8=require("Resources.lib.anim8")
local player;
Input=require("Resources.lib.Input")
--Use this for initialization
function love.load()
	love.graphics.setDefaultFilter("nearest","nearest",3)
	player=require("Resources.Player").load()
	player:loadAnimation("idle")
	input = Input()
end

--Use this for drawing objects
function love.draw()
	player:draw()
end


--Use this for any code that should be ran each frame
function love.update(dt)
	player:update(dt)
end
