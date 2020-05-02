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

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
	
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0
 
	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end
 
		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())
 
			if love.draw then love.draw() end
 
			love.graphics.present()
		end
 
		--if love.timer then love.timer.sleep(0.01) end
	end
end

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
	colliderWorld=HC.new(50)
	player=require("Resources.scripts.Player").load()
	player:loadTree("idle")
	currentMap=require("Resources.scripts.TankInterior").Load()
    table.insert(currentMap.map.collidees,player.sprite.collider)
	gameCam=camera.new(0,0,8000,8000)
	love.graphics.setBackgroundColor(72/255,72/255,72/255)
	love.graphics.setLineWidth(1)
	for i = 1, 10 do 
		local shell = require("Resources.scripts.TankShell").new()
		table.insert(actors,shell)
		shell.position=shell.position
	end
	table.insert(actors,player)
end
function round(number, nearest)
	return math.round(number / 45) * 45;
end


function roundToNthDecimal(num, n)
	local mult = 10^(n or 0)
	return math.floor(num * mult + 0.5) / mult
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
	gameCam:setPosition(player.position.x,(player.position.y+86))
	for _, actor in pairs(actors) do
		actor:update(dt)
	end
	timer.update(dt)
end
