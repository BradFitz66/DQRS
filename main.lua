floor,ceil,pi,sqrt=math.floor,math.ceil,math.pi,math.sqrt
debug = true;
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
--
math=require("Resources.lib.mathx")
string=require("Resources.lib.stringx")
table=require("Resources.lib.tablex")
actors={}
local player=nil;
local ammo;
currentMap=nil;
colliderWorld=nil;
local gameCam;
local canvas;
local debugKeys=nil;
local playing=true;
local timestep=false;

local tickPeriod = 0 -- seconds per tick
local accumulator = 0.0
--Use this for initialization
function love.load()
	local width, height, flags = love.window.getMode()
	
	love.graphics.setDefaultFilter("nearest","nearest",0)

	aspect=require("Resources.lib.aspect_ratio")
	aspect:init(256, 384, 256, 384)
	canvasTop= love.graphics.newCanvas(aspect.dig_w, aspect.dig_h/2)
	canvasBottom= love.graphics.newCanvas(aspect.dig_w, aspect.dig_h/2)
	vector=require("Resources.lib.HUMP.vector")
	anim8=require("Resources.lib.anim8")
	Input=require("Resources.lib.Input")
	blendtree=require("Resources.lib.blendtree")
	artal=require("Resources.lib.artal")
	timer=require("Resources.lib.HUMP.timer")
	camera=require("Resources.lib.gamera")
	vector3=require("Resources.lib.brinevector3D")
	HC=require("Resources.lib.HC-master")
	colliderWorld=HC.new(25)
	player=require("Resources.scripts.Player").load()
	player:loadTree("idle")
	currentMap=require("Resources.scripts.TankInterior").Load()
    table.insert(currentMap.map.collidees,player.collider)
	gameCam=camera.new(0,0,8000,8000)
	love.graphics.setBackgroundColor(72/255,72/255,72/255)
	love.graphics.setLineWidth(1)
	for i = 1, 10 do 
		local shell = require("Resources.scripts.TankShell").new()
		table.insert(actors,shell)
		shell.position=shell.position
	end
	table.insert(actors,player)
	debugKeys=Input.new{
		controls={
			timestep = {'key:n'},
			pause = {'key:p'}
		},
		pairs={},
		joystick = love.joystick.getJoysticks()[1],
	}
end
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
--Use this for drawing objects
function love.draw()
	local width,height,flags=love.window.getMode()
	love.graphics.draw(canvasBottom, aspect.x, aspect.y+(192*aspect.scale), 0, aspect.scale)
	love.graphics.draw(canvasTop, aspect.x, aspect.y, 0, aspect.scale)
end

function love.resize(w, h)
	aspect:resize(w,h)
end
--Use this for any code that should be ran each frame
function love.update(dt)
	love.timer.sleep((1/33)-dt)
	accumulator = accumulator + dt
	if accumulator >= tickPeriod then
	  accumulator = accumulator - tickPeriod
	  if playing or timestep then
		canvasBottom:renderTo(function()
			love.graphics.clear()
			gameCam:draw(function(l,t,w,h) 
				currentMap.map:draw()
				table.sort(actors,function(a,b)
					return a.sprite.ZValue<b.sprite.ZValue
				end)		
				for _, actor in pairs(actors) do
					actor:draw()
				end
			end)
		end)	
		canvasTop:renderTo(function()
			love.graphics.clear()
			if(debug) then
				love.graphics.setColor(255,0,0)
				love.graphics.rectangle("line", 0, 0, 256, 192)
				love.graphics.setColor(255,255,255)
				love.graphics.print("FPS: "..tostring(love.timer.getFPS()),10,10)
				love.graphics.print("Player state: "..player.statemachine.currentState.Name,10,25)
				love.graphics.print("Player blendtree: "..player.currentTree.name,10,40)
				love.graphics.print("Player blendtree animation frame: "..player.currentTree.currentAnimation:getFrame(),10,55)
				love.graphics.print("Player in air: "..tostring(player.sprite.inAir),10,70)
			end	
		end)
		timestep=false
		gameCam:setPosition(player.position.x,(player.position.y+86))
		for _, actor in pairs(actors) do
			actor:update(dt)
		end
		timer.update(dt)
	end
	if(debug)then
		debugKeys:update(dt)
		if(debugKeys:pressed'timestep')then
			print("Timestep!")
			timestep=true
			playing=false
		end
		if(debugKeys:pressed'pause')then
			playing=not playing
		end
	end
	end
	
end
