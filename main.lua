floor,ceil,pi,sqrt,sin,cos=math.floor,math.ceil,math.pi,math.sqrt,math.sin,math.cos
local aspect=nil

--Define global modules
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

function love.load()
	tick.rate=.016
	
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

	aspect=require("Resources.lib.aspect_ratio")
	aspect:init(256, 384, 256, 384)
	canvasTop= love.graphics.newCanvas(aspect.dig_w, aspect.dig_h/2)
	canvasBottom= love.graphics.newCanvas(aspect.dig_w, aspect.dig_h/2)
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
	
	love.graphics.setBackgroundColor(72/255,72/255,72/255)
	love.graphics.setLineWidth(1)
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



function love.draw()
	local width,height,flags=love.window.getMode()
	--Put all major draw functions into separate function so I can easily disable them for debugging purposes
	draw_fn()
end

function draw_fn()
	love.graphics.draw(canvasBottom, aspect.x, aspect.y+(192*aspect.scale), 0, aspect.scale)
	love.graphics.draw(canvasTop, aspect.x, aspect.y, 0, aspect.scale)
end

function love.resize(w, h)
	aspect:resize(w,h)
end

function love.update(dt)
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
	canvasTop:renderTo(function()
		love.graphics.clear()
		if(debug) then
			--Debug/performance stats
			local stats = love.graphics.getStats()
			love.graphics.setColor(255,0,0)
			love.graphics.rectangle("line", 0, 0, 256, 192)
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

		gameCam:setPosition(math.floor(player.position.x-(gameCam.w/12)),math.floor(player.position.y+96))
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
end
