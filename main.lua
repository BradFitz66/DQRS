floor,ceil,pi,sqrt=math.floor,math.ceil,math.pi,math.sqrt
--Define global modules
anim8=nil
Input=nil
blendtree=nil
camera=nil
artal=nil
HC=nil
timer=nil
lovepixels=nil
vector=nil
aspect=nil
math=require("Resources.lib.mathx")
string=require("Resources.lib.stringx")
table=require("Resources.lib.tablex")
tank_tileset=nil;
--
currentMap=nil;
colliderWorld=nil;
gameCam=nil;
actors={}

local player=nil;
local platy=nil;
local canvas;
local debugKeys=nil;
local playing=true;
local tick=require 'Resources.lib.tick'
local screen
local tilelove = require "Resources.lib.tilelove"

function round(number, nearest)
	return math.round(number / 45) * 45;
end

function roundToNthDecimal(num, n)
	local mult = 10^(n or 0)
	return math.floor(num * mult + 0.5) / mult
end

function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end

function compare(a,b)
	local num1 = tonumber(string.sub(a,0,-5))
	local num2 = tonumber(string.sub(b,0,-5))
	
	return num1<num2
end

function loadImagesFromDirectory(directory, sort,sortFunction,startIndex,endIndex)
	local images={}
	
	local files = love.filesystem.getDirectoryItems(directory)
	if(not startIndex and not endIndex) then
		startIndex=1
		endIndex=#files
	end
	if(sort) then
		if(sortFunction) then
			table.sort(files,sortFunction)
		else
			table.sort(files)
		end
	end
	if(startIndex and not endIndex) then
		table.insert(images,love.graphics.newImage(directory.."/"..files[startIndex]))
		return images;
	end

	for index, file in pairs(files) do
		if(index>=startIndex) then
			if(index>endIndex) then
				break
			end
			table.insert(images,love.graphics.newImage(directory.."/"..file))
		end
	end
	return images
end

function rotate_point( sx, sy, radius, angle )
	local cx = sx + radius * math.cos(angle)
	local cy = sy + radius * math.sin(angle)
	return cx, cy
end

function love.load()
	--tick.framerate = 60 -- Limit framerate to 60 frames per second.
	tick.rate=.016
	
	local width, height, flags = love.window.getMode()
	love.graphics.setDefaultFilter("nearest","nearest",0)

	aspect=require("Resources.lib.aspect_ratio")
	aspect:init(256, 384, 256, 384)
	canvasTop= love.graphics.newCanvas(aspect.dig_w, aspect.dig_h/2)
	canvasBottom= love.graphics.newCanvas(aspect.dig_w, aspect.dig_h/2)
	--Load global modules
	vector=require("Resources.lib.HUMP.vector")
	anim8=require("Resources.lib.anim8")
	Input=require("Resources.lib.Input")
	blendtree=require("Resources.lib.blendtree")
	artal=require("Resources.lib.artal")
	timer=require("Resources.lib.HUMP.timer")
	camera=require("Resources.lib.gamera")
	vector3=require("Resources.lib.brinevector3D")
	HC=require("Resources.lib.HC-master")
	gameCam=camera.new(0,0,8000,8000)
	tank_tileset=tilelove.new_tilemap(8,8,love.image.newImageData("Resources/graphics/Tilemaps/CannonRoom/Tilemap_V1.png"))
	--
	colliderWorld=HC.new(25)
	currentMap=require("Resources.scripts.TankInterior").Load();
	player=require("Resources.scripts.Player").load()
	player:loadTree("idle")
	platy=require("Resources.scripts.Platypunk").new()
	platy:loadTree("idle")
	
    table.insert(currentMap.map.collidees,player.collider)
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
	drawFn()
end

function drawFn()
	love.graphics.draw(canvasBottom, aspect.x, aspect.y+(192*aspect.scale), 0, aspect.scale)
	love.graphics.draw(canvasTop, aspect.x, aspect.y, 0, aspect.scale)
	canvasBottom:renderTo(function()
		love.graphics.clear()
		gameCam:draw(function(l,t,w,h) 
			currentMap.map:draw((-gameCam.x),(-gameCam.y),gameCam.sx,gameCam.sy)
			table.sort(actors,function(a,b)
				return a.sprite.ZValue<b.sprite.ZValue
			end)
			for _, actor in pairs(actors) do
				actor:draw()
			end
		end)
		canvasTop:renderTo(function()
			love.graphics.clear()
			if(debug) then
				local stats = love.graphics.getStats()
				love.graphics.setColor(255,0,0)
				love.graphics.rectangle("line", 0, 0, 256, 192)
				love.graphics.setColor(255,255,255)
				love.graphics.print("FPS: "..tostring(love.timer.getFPS()),10,10)
				love.graphics.print("Player state: "..player.statemachine.currentState.Name,10,25)
				love.graphics.print("Player blendtree: "..player.currentTree.name,10,40)
				love.graphics.print("Player blendtree animation frame: "..player.currentTree.currentAnimation:getFrame(),10,55)
				love.graphics.print("Player blendtree vector: "..tostring(player.currentTree.vector).."\nPlayer move vector: "..tostring(player.moveVector),10,85)
				love.graphics.print("Player in air: "..tostring(player.sprite.inAir),10,70)
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

--Use this for any code that should be ran each frame
function love.update(dt)
	
	if playing or timestep then
		timestep=false
		gameCam:setPosition(math.floor(player.position.x-(gameCam.w/12)),math.floor(player.position.y+96))
		timer.update(dt)
		for _, actor in pairs(actors) do
			actor:update(dt)
		end
		--currentMap.map.graphics:update(dt)
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
