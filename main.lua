debug = true;
--Define global modules
anim8=nil
Input=nil
vector=nil
blendtree=nil
entity=nil
camera=nil
artal=nil
HC=nil
timer=nil

--
local player=nil;
currentMap=nil;
colliderWorld=nil;
local tlfres=require("Resources.lib.TLfres")
local aspectRatio=require("Resources.lib.aspect_ratio")
local gameCam;
local canvas;
--Use this for initialization
function love.load()
	love.graphics.setDefaultFilter("nearest","nearest",0)
	canvas= love.graphics.newCanvas(256, 192)
	anim8=require("Resources.lib.anim8")
	Input=require("Resources.lib.Input")
	vector=require("Resources.lib.HUMP.vector")
	blendtree=require("Resources.lib.blendtree")
	entity=require("Resources.scripts.Entity")
	artal=require("Resources.lib.artal")
	timer=require("Resources.lib.HUMP.timer")
	camera=require("Resources.lib.gamera")
	HC=require("Resources.lib.HC-master")
	colliderWorld=HC.new(50)
	player=require("Resources.scripts.Player").load()
	player:loadTree("idle")
	currentMap=require("Resources.scripts.TankInterior").Load()
    table.insert(currentMap.map.collidees,player.sprite.collider)
	gameCam=camera.new(0,0,8000,8000)
	love.graphics.setBackgroundColor(72/255,72/255,72/255)
	love.graphics.setLineWidth(1)
	--aspectRatio:init(800, 600, 256, 192) 
end

--Use this for drawing objects
function love.draw()
	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("line", 0, 0, 256, 192)
	love.graphics.setColor(255,255,255)
	love.graphics.draw(canvas,0,192)
	if(debug) then
		love.graphics.setColor(255,255,255)
		love.graphics.print("FPS: "..tostring(love.timer.getFPS()),10,10)
		love.graphics.print("Player state: "..player.statemachine.currentState.Name,10,25)
		love.graphics.print("Player blendtree: "..player.currentTree.name,10,40)
		love.graphics.print("Player blendtree animation frame: "..player.currentTree.currentAnimation:getFrame(),10,55)
		love.graphics.print("Player in air: "..tostring(player.sprite.inAir),10,70)
		love.graphics.setColor(255,255,255)
	end
end


--Use this for any code that should be ran each frame
function love.update(dt)
	canvas:renderTo(function()
		love.graphics.clear()
		gameCam:draw(function(l,t,w,h) 
			currentMap.map:draw()
			player:draw()
		end)
	end)	
	gameCam:setPosition(player.position.x,(player.position.y+86))
	player:update(dt)
	timer.update(dt)
end
