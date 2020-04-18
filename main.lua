
--Define global modules
anim8=nil
Input=nil
vector=nil
blendtree=nil
--performance test
local players={}
local player;
--Use this for initialization
function love.load()
	love.graphics.setDefaultFilter("nearest","nearest",3)
	anim8=require("Resources.lib.anim8")
	Input=require("Resources.lib.Input")
	vector=require("Resources.lib.HUMP.vector")
	blendtree=require("Resources.lib.blendtree")
	print(vector.dot)

	player=require("Resources.scripts.Player").load()
	player:loadTree("idle")

end

--Use this for drawing objects
function love.draw()
	love.graphics.setBackgroundColor(64/255,234/255,248/255)
	love.graphics.print("FPS: "..tostring(love.timer.getFPS()),10,10)
	player:draw()
end


--Use this for any code that should be ran each frame
function love.update(dt)
	player:update(dt)
end
