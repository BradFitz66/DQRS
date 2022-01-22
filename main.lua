local floor,ceil,pi,sqrt=math.floor,math.ceil,math.pi,math.sqrt
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

--

currentMap=nil;
collider_world=nil;
actors={}

local player=nil;
local platy=nil;
local debugKeys=nil;
local playing=true;
local tick=require 'Resources.lib.tick'


function love.load()
	tick.rate=.016
	
	local width, height, flags = love.window.getMode()
	love.graphics.setDefaultFilter("nearest","nearest",0)

	aspect=require("Resources.lib.aspect_ratio")
	aspect:init(256, 384, 256, 384)
	canvasTop= love.graphics.newCanvas(aspect.dig_w, aspect.dig_h/2)
	canvasBottom= love.graphics.newCanvas(aspect.dig_w, aspect.dig_h/2)
	--Load modules
	gameCam=require("Resources.lib.gamera").new(0,0,8000,8000)
	--
	
	collider_world=HC.new(25)
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
end

function love.draw()
	local width,height,flags=love.window.getMode()
	--Put all major draw functions into separate function so I can easily disable them for debugging purposes
	draw_fn()
end

function draw_fn()
	love.graphics.draw(canvasBottom, aspect.x, aspect.y+(192*aspect.scale), 0, aspect.scale)
	love.graphics.draw(canvasTop, aspect.x, aspect.y, 0, aspect.scale)
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
		end)
		canvasTop:renderTo(function()
			love.graphics.clear()
			if(debug) then
				--Debug/performance stats
				local stats = love.graphics.getStats()
				love.graphics.setColor(255,0,0)
				love.graphics.rectangle("line", 0, 0, 256, 192)
				love.graphics.setColor(255,255,255)
				love.graphics.print("FPS: "..tostring(love.timer.getFPS()),10,10)
				love.graphics.print("Player state: "..player.statemachine.current_state.Name,10,25)
				love.graphics.print("Player blendtree: "..player.current_tree.name,10,40)
				love.graphics.print("Player blendtree animation frame: "..player.current_tree.current_animation:getFrame(),10,55)
				love.graphics.print("Player blendtree vector: "..tostring(player.current_tree.vector).."\nPlayer move vector: "..tostring(player.move_vector),10,85)
				love.graphics.print("Player in air: "..tostring(player.sprite.in_air),10,70)
				love.graphics.print("Draw calls: "..tostring(stats.drawcalls),10,115)
				love.graphics.print("Images loaded: "..tostring(stats.images),10,130)
				love.graphics.print("Texture memory: "..tostring(math.floor(stats.texturememory/1000000)).."MB",10,145)
				love.graphics.print("Batched drawcalls: "..tostring(stats.drawcallsbatched),10,160)
			end	
		end)
	end)
end

function love.resize(w, h)
	aspect:resize(w,h)
end

function love.update(dt)
	
	if playing or timestep then
		timestep=false
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
