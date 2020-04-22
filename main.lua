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
local is_playing=true;
local do_step=false;
local debugInput;
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
	player=require("Resources.scripts.Player").load()
	player:loadTree("idle")
	camera=require("Resources.lib.gamera")
	HC=require("Resources.lib.HC-master")
	map= require("Resources.Map").new("Resources/graphics/PSD/TankBottomFloor.psd")
	map.colliders={{
		407.5, 22.0,
		177.5, 22.0,
		177.5, -119.0,
		175.5, -121.0,
		63.5, -121.0,
		61.5, -119.0,
		61.5, 13.0,
		-149.5, 13.0,
		-149.5, -23.0,
		-118.5, -23.0,
		-51.5, -90.0,
		-32.5, -90.0,
		-30.5, -92.0,
		-30.5, -210.0,
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
		407.5, 156.0,},
		{
		-85.5, 118.0,
		-88.5, 115.0,
		-92.5, 106.0,
		-98.5, 101.0,
		-101.5, 101.0,
		-101.5, 88.0,
		-104.5, 85.0,
		-358.5, 85.0,
		-357.5, 80.0,
		-357.5, 55.0,
		-360.5, 51.0,
		-364.5, 42.0,
		-370.5, 37.0,
		-389.5, 37.0,
		-389.5, -21.0,
		-363.5, -21.0,
		-358.5, -25.0,
		-357.5, -28.0,
		-357.5, -133.0,
		-163.5, -133.0,
		-163.5, -116.0,
		-162.5, -113.0,
		-157.5, -109.0,
		-111.5, -109.0,
		-48.5, -172.0,
		-37.5, -172.0,
		-37.5, -107.0,
		-57.5, -107.0,
		-121.5, -43.0,
		-150.5, -43.0,
		-156.5, -38.0,
		-163.5, -23.0,
		-163.5, 36.0,
		-162.5, 39.0,
		-157.5, 43.0,
		-59.5, 43.0,
		-59.5, 56.0,
		-56.5, 59.0,
		-32.5, 59.0,
		-29.5, 56.0,
		-29.5, 43.0,
		-3.5, 43.0,
		-3.5, 56.0,
		-0.5, 59.0,
		23.5, 59.0,
		26.5, 56.0,
		26.5, 43.0,
		84.5, 43.0,
		89.5, 39.0,
		90.5, 36.0,
		90.5, -114.0,
		148.5, -114.0,
		148.5, 20.0,
		149.5, 23.0,
		154.5, 27.0,
		165.5, 27.0,
		165.5, 40.0,
		168.5, 43.0,
		402.5, 43.0,
		402.5, 133.0,
		241.5, 133.0,
		235.5, 138.0,
		228.5, 153.0,
		228.5, 189.0,
		-85.5, 189.0,}
	}
	gameCam=camera.new(0,0,8000,8000)
	map.colliderOffset=vector.new(515,225)
	map:createColliders()
	love.graphics.setBackgroundColor(72/255,72/255,72/255)
	love.graphics.setLineWidth(1)
	--aspectRatio:init(800, 600, 256, 192) 
end

--Use this for drawing objects
function love.draw()
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
	if is_playing or do_step then
		--dostep=false;
		gameCam:setPosition(player.position.x,player.position.y+86)
		player:update(dt)
	end
end
