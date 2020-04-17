Player={}
Player.__index=Player

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
	for index, file in pairs(files) do
		if(index>=startIndex) then
			if(index>endIndex) then
				print("Breaking")
				break
			end
			table.insert(images,love.graphics.newImage(directory.."/"..file))
		end
	end
	return images
end

local vector=require("Resources/lib/HUMP/vector")
local anim8=require("Resources/lib/anim8")
local Input=require("Resources/lib/Input")
local input;
function Player.load()
	input=Input()
	input:bind('a', 'left')
	input:bind('d', 'right')
	input:bind('w', 'up')
	input:bind('s', 'down')
	local pData=setmetatable({},Player)
	pData.animations={
		['idle']={
			anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,1,7),.5)
		}		
	}
	pData.moveVector=vector.new(0,0)
	pData.currentAnimation=currentAnimation
	pData.statemachine=require("Resources/StateMachine").new(pData)
	pData.statemachine:addState(require("Resources/states/Idle"))
	pData.statemachine:addState(require("Resources/states/Walk"))
	pData.statemachine:changeState("Idle")
	pData.speed=3;
	pData.position=vector.new(400,300)
	return pData
end

function Player:loadAnimation(animationName)
	self.currentAnimation=self.animations['idle'][1]
	self.currentAnimation:setLooping(true)
	
end

function compare(a,b)
	local num1 = tonumber(string.sub(a,0,-5))
	local num2 = tonumber(string.sub(b,0,-5))
	return num1<num2
end

function Player:draw()
	self.currentAnimation:draw(self.position.x,self.position.y,0,5,5,self.currentAnimation:getWidth()/2,self.currentAnimation:getHeight())
end

function Player:update(dt)
	print(self.statemachine.currentState)
	if(input:down("left"))then
		self.moveVector.x=-1*self.speed
	end
	if(input:down("right"))then
		self.moveVector.x=1*self.speed
	end
	if(input:down("up"))then
		self.moveVector.y=-1*self.speed
	end
	if(input:down("down"))then
		self.moveVector.y=1*self.speed
	end
	if(not input:down("down") and not input:down("up") and not input:down("left") and not input:down("right") ) then
		print("Nothing held down")
		self.moveVector.x=0
		self.moveVector.y=0
	end
	self.statemachine:update(dt)
	self.currentAnimation:update(8/60)
end


return Player