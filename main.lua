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
--
math=require("Resources.lib.mathx")
actors={}
local player=nil;
local ammo;
currentMap=nil;
colliderWorld=nil;
local gameCam;
local canvas;
--Use this for initialization
function love.load()
	love.graphics.setDefaultFilter("nearest","nearest",0)
	canvas= love.graphics.newCanvas(256, 192)
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
	ammo=require("Resources.scripts.TankShell").new()
	table.insert(actors,player)
	table.insert(actors,ammo)
end
function round(number, nearest)
	return math.floor(number / nearest + 0.5) * nearest
end

function roundToNthDecimal(num, n)
	local mult = 10^(n or 0)
	return math.floor(num * mult + 0.5) / mult
end
--Use this for drawing objects
function love.draw()
	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("line", 0, 0, 256, 192)
	love.graphics.setColor(255,255,255)
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
			currentMap.map:draw()
			table.sort(actors,function(a,b)
				return a.position.y<b.position.y
			end)		
			for _, actor in pairs(actors) do
				actor:draw()
			end
		end)
	end)	
	gameCam:setPosition(player.position.x,(player.position.y+86))
	for _, actor in pairs(actors) do
		actor:update(dt)
	end
	timer.update(dt)
end
