local debug = true;
--Define global modules
anim8=nil
Input=nil
vector=nil
blendtree=nil
entity=nil
camera=nil
artal=nil
--
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
	camera=require("Resources.lib.HUMP.camera")(player.position.x,player.position.y,1)
	debugInput=Input.new {
		
		controls = {
			timestep = {'key:n'},
			pauseplay={'key:p'}
		},
		pairs = {
		},
		joystick = love.joystick.getJoysticks()[1],
	}
	map=artal.newPSD("Resources/graphics/PSD/TankBottomFloor.psd")
end

--Use this for drawing objects
function love.draw()
	tlfres.beginRendering(256, 192)
	love.graphics.setBackgroundColor(64/255,234/255,248/255)
	if(debug) then
		love.graphics.setColor(0,0,0)
		love.graphics.print("FPS: "..tostring(love.timer.getFPS()),10,10)
		love.graphics.print("Player state: "..player.statemachine.currentState.Name,10,25)
		love.graphics.print("Player blendtree: "..player.currentTree.name,10,40)
		love.graphics.print("Player blendtree animation frame: "..player.currentTree.currentAnimation:getFrame(),10,55)
		love.graphics.setColor(255,255,255)
	end
	camera:attach()
	for i=1,#map do
		if(map[i].name~="CollisionMap") then
			love.graphics.draw(
			map[i].image,
			nil,
			nil,
			nil,
			nil,
			nil,
			map[i].ox,
			map[i].oy
			)
		end
	end
	player:draw()
	camera:detach()
	tlfres.endRendering()
end


--Use this for any code that should be ran each frame
function love.update(dt)
	if is_playing or do_step then
		--dostep=false;
		player:update(dt)
		camera:lockPosition(player.position.x, player.position.y)
	end
	if(debugInput:pressed("timestep")) then
		is_playing=false;
		do_step=true;
	end
	if(debugInput:pressed("pauseplay"))then
		is_playing=not is_playing
		do_step=false
	end
end
