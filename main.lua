local debug = true;
--Define global modules
anim8=nil
Input=nil
vector=nil
blendtree=nil
entity=nil
camera=nil
artal=nil
HC=nil
--

colliderWorld=nil;
local tlfres=require("Resources.lib.TLfres")
local aspectRatio=require("Resources.lib.aspect_ratio")
local player;
local map;
local gameCam;
local canvas = love.graphics.newCanvas(256, 192)
--Use this for initialization
function love.load()
	love.graphics.setDefaultFilter("nearest","nearest",3)
	anim8=require("Resources.lib.anim8")
	Input=require("Resources.lib.Input")
	vector=require("Resources.lib.HUMP.vector")
	blendtree=require("Resources.lib.blendtree")
	entity=require("Resources.scripts.Entity")
	artal=require("Resources.lib.artal")
	camera=require("Resources.lib.gamera")
	HC=require("Resources.lib.HC-master")
	colliderWorld=HC.new(100)
	player=require("Resources.scripts.Player").load()
	player:loadTree("idle")
	map= require("Resources.Map").new("Resources/graphics/PSD/TankBottomFloor.psd")
	map.colliders={{
		407.5, 22.0,
		177.5, 22.0,
		177.5, -119.0,
		175.5, -121.0,
		151.5, -119.0,
		151.5, 20.0,
		154.5, 24.0,
		168.5, 24.0,
		168.5, 40.0,
		405.5, 40.0,
		405.5, 136.0,
		241.5, 136.0,
		231.5, 153.0,
		231.5, 192.0,
		-88.5, 192.0,
		-88.5, 118.0,
		-98.5, 104.0,
		-104.5, 104.0,
		-104.5, 88.0,
		-360.5, 88.0,
		-360.5, 55.0,
		-371.5, 40.0,
		-392.5, 40.0,
		-392.5, -24.0,
		-363.5, -24.0,
		-360.5, -28.0,
		-360.5, -136.0,
		-160.5, -136.0,
		-160.5, -116.0,
		-157.5, -112.0,
		-111.5, -112.0,
		-48.5, -175.0,
		-32.5, -175.0,
		-32.5, -210.0,
		-72.5, -210.0,
		-113.5, -169.0,
		-397.5, -169.0,
		-399.5, -167.0,
		-399.5, -50.0,
		-402.5, -49.0,
		-402.5, 38.0,
		-407.5, 38.0,
		-407.5, 56.0,
		-371.5, 56.0,
		-371.5, 102.0,
		-383.5, 102.0,
		-385.5, 104.0,
		-385.5, 121.0,
		-383.5, 123.0,
		-99.5, 123.0,
		-99.5, 208.0,
		-97.5, 210.0,
		242.5, 210.0,
		242.5, 156.0,
		407.5, 156.0,},{
		-0.5, 56.0,
		23.5, 56.0,
		23.5, 40.0,
		84.5, 40.0,
		87.5, 36.0,
		87.5, -119.0,
		63.5, -119.0,
		63.5, 15.0,
		-151.5, 15.0,
		-151.5, -25.0,
		-118.5, -25.0,
		-51.5, -92.0,
		-32.5, -92.0,
		-32.5, -104.0,
		-57.5, -104.0,
		-121.5, -40.0,
		-149.5, -40.0,
		-160.5, -23.0,
		-160.5, 36.0,
		-157.5, 40.0,
		-56.5, 40.0,
		-56.5, 56.0,
		-32.5, 56.0,
		-32.5, 40.0,
		-0.5, 40.0,}}
		
	table.insert(map.collidees,player.sprite.collider)
	gameCam=camera.new(0,0,8000,8000)
	map.colliderOffset=vector.new(513,224)
	map:createColliders()
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
			map:draw()
			player:draw()
		end)
	end)	
	gameCam:setPosition(player.position.x,(player.position.y+86))
	player:update(dt)
end
