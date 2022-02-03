floor,ceil,pi,sqrt,sin,cos=math.floor,math.ceil,math.pi,math.sqrt,math.sin,math.cos
--#region variables and modules
Input=require("Resources.lib.Input")
HC=require("Resources.lib.HC-master")
timer = require("Resources.lib.HUMP.timer")
vector=require("Resources.lib.HUMP.vector")
math=require("Resources.lib.mathx")
string=require("Resources.lib.stringx")
table=require("Resources.lib.tablex")
vector3=require("Resources.lib.brinevector3D")
gameCam=nil;
rect = nil;
world=require("Resources.lib.bump").newWorld(24);
clipper = require 'Resources.lib.clipper.clipper'
control_scheme=nil;
input_provider=require("Resources.lib.Rocket_Engine.Systems.Input.InputProvider")
input_provider:add_state(require("Resources.lib.Rocket_Engine.Systems.Input.PlayerInput"))
local lib_path = love.filesystem.getSaveDirectory() .. "/libraries"
local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
package.cpath = string.format("%s;%s/?.%s", package.cpath, lib_path, extension)
local imgui = require "Resources.lib.cimgui" -- cimgui is the folder containing the Lua module (the "src" folder in the github repository)
--
--	.flags={bouncy=false,trigger=false,canCollide=true}
--global variables
currentMap=nil;
collider_world=nil;
actors={}
elapsed_time=0;
clipper_to_hc_polygon={}
local player=nil;
local platy=nil;
local debugKeys=nil;
local playing=true;
local tick=require 'Resources.lib.tick'
result=nil;
local test_trigger;
local test_bouncy;
--#endregion
function love.load(args)
	imgui.Init()
	tick.rate=.016
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
	
	local width, height, flags = love.window.getMode()
	love.graphics.setDefaultFilter("nearest","nearest",0)

	canvasDebug= love.graphics.newCanvas(256, 192)
	canvasBottom= love.graphics.newCanvas(256, 192)
	--Load modules
	gameCam=require("Resources.lib.gamera").new(0,0,8000,8000)
	--

	collider_world=HC.new(64)
	print(collider_world:hash())
	currentMap=require("Resources.scripts.TankInterior").Load();

	player=require("Resources.scripts.Player").load()
	player:load_tree("idle")
	platy=require("Resources.scripts.Platypunk").new()
	
	platy:load_tree("idle")
	
	--love.graphics.setBackgroundColor(72/255,72/255,72/255)
	--love.graphics.setLineWidth(1)
	debugKeys=Input.new{
		controls={
			timestep = {'key:n'},
			pause = {'key:p'}
		},
		pairs={},
		joystick = love.joystick.getJoysticks()[1],
	}
	for i = 1, 10 do 
		local shell = require("Resources.scripts.TankShell").new()
		shell.position=shell.position
		table.insert(actors,shell)
	end
	table.insert(actors,player)
	table.insert(actors,platy)

	
	--Test for a trigger collider. Trigger colliders can be walked through and run a function when something enters it.
	test_trigger=collider_world:rectangle(340,230,75,40)
	test_trigger.flags={bouncy=false,trigger=true,canCollide=true,
	trigger_function=function(this_trigger,entity) 
		if(entity.type=="ammo" and entity.going_into_cannon==false) then
			--Center of collider
			local height=2
			local targ_x,targ_y=this_trigger._polygon.centroid.x+10,this_trigger._polygon.centroid.y-10
			entity.going_into_cannon=true
			entity.in_air=false
			local x_vel=(targ_x - entity.parent.position.x) / (math.sqrt(-3*height/-9.81));
			local z_vel=(targ_y - entity.parent.position.y) / (math.sqrt(-3*height/-9.81));
			entity:add_force_xyz(vector3(x_vel,height,z_vel))
			entity.bounces_left=1
			
		end
	end}
	--[[Bouncy colliders are colliders that can't be walked through but can be jumped over. 
	The player cannot land on them and will instead bounce on them until they exit the collider]]
	
	test_bouncy=collider_world:rectangle(220,200,50,50)
	test_bouncy.flags={bouncy=true,trigger=false,canCollide=true}
end


function love.update(dt)
	control_scheme:update(dt)
	--#region canvas drawing
	canvasBottom:renderTo(function()
		love.graphics.clear()
		gameCam:draw(function(l,t,w,h) 
			currentMap.map:draw((-gameCam.x),(-gameCam.y),gameCam.sx,gameCam.sy)
			table.sort(actors,function(a,b)
				return a.sprite.z_value<b.sprite.z_value
			end)
			for _, actor in pairs(actors) do
				actor:draw()
			end
			if(result~=nil) then
				love.graphics.setColor(1,1,0,1)
				result:draw()
				love.graphics.setColor(1,1,1,1)
				love.graphics.setColor(0,1,0,1)
				test_trigger:draw()
				test_bouncy:draw()
				love.graphics.setColor(1,1,1,1)
			end		
		end)
	end)
	canvasDebug:renderTo(function()
		love.graphics.clear()
		if(debug) then
			--Debug/performance stats
			local stats = love.graphics.getStats()
			love.graphics.setColor(255,0,0)
			love.graphics.setColor(255,255,255)
			love.graphics.print("FPS: "..tostring(love.timer.getFPS()),10,0)
			love.graphics.print("Player state: "..player.statemachine.current_state.Name,10,15)
			love.graphics.print("Player blendtree: "..player.current_tree.name,10,30)
			love.graphics.print("Player blendtree animation frame: "..player.current_tree.current_animation:getFrame(),10,45)
			love.graphics.print("Player blendtree vector: "..tostring(player.current_tree.vector).."\nPlayer move vector: "..tostring(player.move_vector),10,75)
			love.graphics.print("Player in air: "..tostring(player.sprite.in_air),10,60)
			love.graphics.print("Draw calls: "..tostring(stats.drawcalls),10,105)
			love.graphics.print("Images loaded: "..tostring(stats.images),10,120)
			love.graphics.print("Texture memory: "..tostring(math.floor(stats.texturememory/1000000)).."MB",10,135)
			love.graphics.print("Batched drawcalls: "..tostring(stats.drawcallsbatched),10,150)
			love.graphics.print("Elapsed time: "..tostring(elapsed_time),10,165)
		end	
	end)
	--#endregion
	if playing or timestep then
	
		timestep=false
		elapsed_time=elapsed_time + 1

		gameCam:setPosition(math.floor(player.position.x+384),math.floor(player.position.y+256))
		timer.update(dt)
		for _, actor in pairs(actors) do
			actor:update(dt)
		end
	end
	if(debug)then
		debugKeys:update(dt)
		if(debugKeys:pressed'timestep')then
			timestep=true
			playing=false
		end
		if(debugKeys:pressed'pause')then
			playing=not playing
		end
	end
	imgui.Update(dt)
    imgui.NewFrame()
end

function love.draw()
	local width,height,flags=love.window.getMode()
	--Put all major draw functions into separate function so I can easily disable them for debugging purposes
	draw_fn()
end

local game_window_pos
local debug_window_pos
function draw_fn()
	
	imgui.WindowFlags("NoTitleBar", "NoBackground", "HorizontalScrollbar","NoResize","NoCollapse")
	imgui.SetNextWindowSize(imgui.ImVec2_Float(258,192+16))
	if imgui.Begin("Game window") then
		game_window_pos = imgui.GetWindowContentRegionMin();
		game_window_pos.x = game_window_pos.x + imgui.GetWindowPos().x;
		game_window_pos.y = game_window_pos.y + imgui.GetWindowPos().y;
    end
	imgui.SetNextWindowSize(imgui.ImVec2_Float(258,192+16))
	if imgui.Begin("Debug window") then
		debug_window_pos = imgui.GetWindowContentRegionMin();
		debug_window_pos.x = debug_window_pos.x + imgui.GetWindowPos().x;
		debug_window_pos.y = debug_window_pos.y + imgui.GetWindowPos().y;
    end
    imgui.End()

	imgui.Render()
    imgui.RenderDrawLists()
	love.graphics.draw(canvasDebug, debug_window_pos.x-7, debug_window_pos.y-7, 0, 1)
	love.graphics.draw(canvasBottom, game_window_pos.x-7, game_window_pos.y-7, 0, 1)
end

function love.resize(w, h)
end

--#region imgui stuff
love.mousemoved = function(x, y, ...)
    imgui.MouseMoved(x, y)
    if not imgui.GetWantCaptureMouse() then
        -- your code here
    end
end

love.mousepressed = function(x, y, button, ...)
    imgui.MousePressed(button)
    if not imgui.GetWantCaptureMouse() then
        -- your code here 
    end
end

love.mousereleased = function(x, y, button, ...)
    imgui.MouseReleased(button)
    if not imgui.GetWantCaptureMouse() then
        -- your code here 
    end
end

love.wheelmoved = function(x, y)
    imgui.WheelMoved(x, y)
    if not imgui.GetWantCaptureMouse() then
        -- your code here 
    end
end

love.keypressed = function(key, ...)
    imgui.KeyPressed(key)
    if not imgui.GetWantCaptureKeyboard() then
        -- your code here 
    end
end

love.keyreleased = function(key, ...)
    imgui.KeyReleased(key)
    if not imgui.GetWantCaptureKeyboard() then
        -- your code here 
    end
end

love.textinput = function(t)
    imgui.TextInput(t)
    if not imgui.GetWantCaptureKeyboard() then
        -- your code here 
    end
end

love.quit = function()
    return imgui.Shutdown()
end

-- for gamepad support also add the following:

love.joystickadded = function(joystick)
    imgui.JoystickAdded(joystick)
    -- your code here 
end

love.joystickremoved = function(joystick)
    imgui.JoystickRemoved()
    -- your code here 
end

love.gamepadpressed = function(joystick, button)
    imgui.GamepadPressed(button)
    -- your code here 
end

love.gamepadreleased = function(joystick, button)
    imgui.GamepadReleased(button)
    -- your code here 
end

-- choose threshold for considering analog controllers active, defaults to 0 if unspecified
local threshold = 0.2 

love.gamepadaxis = function(joystick, axis, value)
    imgui.GamepadAxis(axis, value, threshold)
    -- your code here 
end
--#endregion