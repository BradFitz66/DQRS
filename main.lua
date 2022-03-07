floor,ceil,pi,sqrt,sin,cos=math.floor,math.ceil,math.pi,math.sqrt,math.sin,math.cos
--	.flags={bouncy=false,trigger=false,canCollide=true}
--   ^ flags for colliders, so I don't forget

local lib_path = love.filesystem.getWorkingDirectory().."/Resources/lib"
love.filesystem.setCRequirePath(lib_path)
debug_mode=true
--#region Global modules
Input=require("Resources.lib.Input")
HC=require("Resources.lib.HC-master")
timer = require("Resources.lib.HUMP.timer")
vector=require("Resources.lib.HUMP.vector")
math=require("Resources.lib.mathx")
signal=require("Resources.lib.HUMP.signal")
string=require("Resources.lib.stringx")
table=require("Resources.lib.tablex")
flux=require("Resources.lib.Rocket_Engine.Utils.flux")
vector3=require("Resources.lib.brinevector3D")
mlib=require("Resources.lib.Rocket_Engine.Utils.mlib")
debug_draw=true
tank_manager_blue=nil
signal=require("Resources.lib.HUMP.signal").new()
gameCam=nil;
rect = nil;
world=require("Resources.lib.bump").newWorld(24);
control_scheme=nil;
input_provider=require("Resources.lib.Rocket_Engine.Systems.Input.InputProvider")
imgui = require "Resources.lib.cimgui" -- cimgui is the folder containing the Lua module (the "src" folder in the github repository)
path=nil
saved_dt=0
--#endregion
--#region global variables
currentArea=nil;
collider_world=nil;
actors={}
elapsed_time=0;
clipper_to_hc_polygon={}
player=nil;
result=nil;

local debugKeys=nil;
local playing=true;
local tick=require 'Resources.lib.tick'
local test_trigger;
local sub_window=require("Resources.lib.Rocket_Engine.Miscellaneous.Subwindow")
local windows={}
--#endregion

function love.load(args)
	imgui.Init()
	input_provider:add_state(require("Resources.lib.Rocket_Engine.Systems.Input.PlayerInput"))
	tick.rate=.016
	love.graphics.setDefaultFilter("nearest")
	tick.sleep=0.001
	control_scheme=Input.new {
		controls = {
			left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
			right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
			up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
			down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'},
			jump = {"key:space"},
			action = {'key:lshift', 'button:a'},
		},
		pairs = {
			move = {'left', 'right', 'up', 'down'}
		},
		joystick = love.joystick.getJoysticks()[1],
	}
		love.graphics.setDefaultFilter("nearest","nearest",0)

	canvasDebug= love.graphics.newCanvas(256, 192)
	canvasBottom= love.graphics.newCanvas(256, 192)
	--Load modules
	gameCam=require("Resources.lib.gamera").new(0,0,8000,8000)
	gameCam:setScale(1)
	--
	collider_world=HC.new(12)
	currentArea=require("Resources.scripts.TankInterior").Load();	
	--love.graphics.setLineWidth(1)
	debugKeys=Input.new{
		controls={
			timestep = {'key:n'},
			pause = {'key:p'}
		},
		pairs={},
		joystick = love.joystick.getJoysticks()[1],
	}


	debug_draw=require("Resources.lib.Rocket_Engine.Utils.debug_draw"):initialize()
	--Test for a trigger collider. Trigger colliders can be walked through and run a function when something enters it.
	test_trigger=collider_world:rectangle(600,150,65,40)
	test_trigger.flags={bouncy=false,trigger=true,canCollide=true,
	trigger_function=function(this_trigger,entity) 
		if(entity.type=="ammo" and entity.going_into_cannon==false) then
		end
	end}
	love.graphics.setPointSize(2)
	tank_manager_blue=require("Resources.lib.Rocket_Engine.Systems.TankManager"):initialize(currentArea)
end


function love.update(dt)
	control_scheme:update()
	flux.update(dt)
	--#region canvas drawing
	canvasBottom:renderTo(function()
		love.graphics.clear()
		gameCam:draw(function(l,t,w,h) 
			currentArea.map:draw((-gameCam.x),(-gameCam.y),gameCam.sx,gameCam.sy)
			table.sort(currentArea.map.actors,function(a,b)
				return a.z_value<b.z_value
			end)
			for _, actor in pairs(currentArea.map.actors) do
				actor:draw()
			end
			if(debug_mode) then
				
				love.graphics.setColor(1,1,0,1)
				test_trigger:draw()
				debug_draw:draw()
			end
			love.graphics.setColor(255,255,0)
			love.graphics.setColor(255,255,255)
		end)
		love.graphics.setBackgroundColor(74/255,74/255,74/255)
	end)
	
	if(debug_mode) then
		canvasDebug:renderTo(function()
			love.graphics.clear()
			if(debug_mode) then
				--Debug/performance stats
				local stats = love.graphics.getStats()
				love.graphics.setColor(255,0,0)
				love.graphics.setColor(255,255,255)
				love.graphics.print("FPS: "..tostring(love.timer.getFPS()),10,0)
				if(player) then

					love.graphics.print("Player position: "..tostring(floor(player.position.x))..", "..tostring(floor(player.position.z)),70,0)
					love.graphics.print("Player state: "..player.statemachine.current_state.Name,10,15)
					love.graphics.print("Player blendtree: "..player.current_tree.name,10,30)
					love.graphics.print("Player blendtree animation frame: "..player.current_tree.current_animation:getFrame(),10,45)
					love.graphics.print("Player blendtree vector: "..tostring(player.current_tree.vector).."\nPlayer move vector: "..tostring(player.move_vector),10,75)
					love.graphics.print("Player in air: "..tostring(player.physics_data.in_air),10,60)
				end
				love.graphics.print("Draw calls: "..tostring(stats.drawcalls),10,105)
				love.graphics.print("Images loaded: "..tostring(stats.images),10,120)
				love.graphics.print("Texture memory: "..tostring(math.floor(stats.texturememory/1000000)).."MB",10,135)
				love.graphics.print("Batched drawcalls: "..tostring(stats.drawcallsbatched),10,150)
				love.graphics.print("Elapsed time: "..tostring(elapsed_time),10,165)
			end	
		end)
	end
	
	--#endregion
	if playing or timestep then	
		timestep=false
		elapsed_time=elapsed_time + 1
		if(player) then
			gameCam:setPosition(math.floor(player.planar_position.x+384),math.floor(player.planar_position.y+256))
		end
		timer.update(dt)
		for _, actor in pairs(currentArea.map.actors) do
			actor:update(dt)
		end
		tank_manager_blue:update(dt)
	end
	if(debug_mode)then
		debugKeys:update(dt)
		if(debugKeys:pressed'timestep')then
			timestep=true
			playing=false
		end
		if(debugKeys:pressed'pause')then
			playing=not playing
		end
	end
end

function love.draw()
	local width,height,flags=love.window.getMode()
	love.graphics.draw(canvasDebug,400,100)
	love.graphics.draw(canvasBottom,100,100)
end
--#endregion