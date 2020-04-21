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
local player;
local is_playing=true;
local do_step=false;
local debugInput;
local map;



--Use this for initialization
function love.load()
	print(tlfres)
	love.graphics.setDefaultFilter("nearest","nearest",3)
	anim8=require("Resources.lib.anim8")
	Input=require("Resources.lib.Input")
	vector=require("Resources.lib.HUMP.vector")
	blendtree=require("Resources.lib.blendtree")
	entity=require("Resources.scripts.Entity")
	artal=require("Resources.lib.artal")
	player=require("Resources.scripts.Player").load()
	player:loadTree("idle")
	camera=require("Resources.lib.HUMP.camera")(player.position.x,player.position.y,2)
	HC=require("Resources.lib.HC-master")
	map= require("Resources.Map").new("Resources/graphics/PSD/TankBottomFloor.psd")
	map.colliders={
		{407.5, 134.0,
		241.5, 134.0,
		236.5, 138.0,
		229.5, 153.0,
		229.5, 190.0,
		-86.5, 190.0,
		-86.5, 118.0,
		-87.5, 116.0,
		-89.5, 115.0,
		-93.5, 106.0,
		-98.5, 102.0,
		-102.5, 102.0,
		-102.5, 88.0,
		-104.5, 86.0,
		-359.5, 86.0,
		-359.5, 81.0,
		-358.5, 80.0,
		-358.5, 55.0,
		-361.5, 51.0,
		-365.5, 42.0,
		-370.5, 38.0,
		-390.5, 38.0,
		-390.5, -22.0,
		-363.5, -22.0,
		-359.5, -25.0,
		-358.5, -28.0,
		-358.5, -134.0,
		-162.5, -134.0,
		-162.5, -116.0,
		-161.5, -113.0,
		-157.5, -110.0,
		-111.5, -110.0,
		-48.5, -173.0,
		-21.5, -173.0,
		-19.5, -175.0,
		-20.5, -178.0,
		-29.5, -178.0,
		-29.5, -210.0,
		-33.4, -210.0,
		-111.6, -156.7,
		-110.5, -167.0,
		-112.5, -169.0,
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
		407.5, 156.0},
		
		{-2.5, 56.0,
		-0.5, 58.0,
		23.5, 58.0,
		25.5, 56.0,
		25.5, 42.0,
		84.5, 42.0,
		88.5, 39.0,
		89.5, 36.0,
		89.5, -119.0,
		87.5, -121.0,
		63.5, -121.0,
		61.5, -119.0,
		61.5, 13.0,
		-149.5, 13.0,
		-149.5, -23.0,
		-118.5, -23.0,
		-51.5, -90.0,
		-32.5, -90.0,
		-30.5, -92.0,
		-30.5, -104.0,
		-32.5, -106.0,
		-57.5, -106.0,
		-121.5, -42.0,
		-150.5, -42.0,
		-155.5, -38.0,
		-162.5, -23.0,
		-162.5, 36.0,
		-161.5, 39.0,
		-157.5, 42.0,
		-58.5, 42.0,
		-58.5, 56.0,
		-56.5, 58.0,
		-32.5, 58.0,
		-30.5, 56.0,
		-30.5, 42.0,
		-2.5, 42.0},
		
		{177.5, -119.0,
		175.5, -121.0,
		151.5, -121.0,
		149.5, -119.0,
		149.5, 20.0,
		150.5, 23.0,
		154.5, 26.0,
		166.5, 26.0,
		166.5, 40.0,
		168.5, 42.0,
		407.5, 42.0,
		407.5, 22.0,
		177.5, 22.0}
	}
	map:createColliders()
end

--Use this for drawing objects
function love.draw()
	camera:attach()
	--tlfres.beginRendering(256, 192)
	love.graphics.setBackgroundColor(72/255,72/255,72/255)
	map:draw()
	player:draw()
	--tlfres.endRendering()
	camera:detach()

	if(debug) then
		love.graphics.setColor(0,0,0)
		love.graphics.print("FPS: "..tostring(love.timer.getFPS()),10,10)
		love.graphics.print("Player state: "..player.statemachine.currentState.Name,10,25)
		love.graphics.print("Player blendtree: "..player.currentTree.name,10,40)
		love.graphics.print("Player blendtree animation frame: "..player.currentTree.currentAnimation:getFrame(),10,55)
		love.graphics.setColor(255,255,255)
	end
end


--Use this for any code that should be ran each frame
function love.update(dt)
	if is_playing or do_step then
		--dostep=false;
		camera:lockPosition(player.position.x, player.position.y)
		player:update(dt)
	end
end
