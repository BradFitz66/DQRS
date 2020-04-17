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
				break
			end
			table.insert(images,love.graphics.newImage(directory.."/"..file))
		end
	end
	return images
end


function Player.load()
	local pData=setmetatable({},Player)
	pData.animations={
		['idle']=
		blendtree.new({
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,1,8),.1),vector.new(0,-1)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,9,16),.1),vector.new(.5,-.5)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,17,24),.1),vector.new(1,0)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,25,32),.1),vector.new(.5,.5)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,33,40),.1),vector.new(0,1)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,41,48),.1),vector.new(-.5,.5)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,49,56),.1),vector.new(-1,0)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,57,64),.1),vector.new(-.5,-.5)}, --upleft
			},
			vector.new(0,0),
			"idle"
		)
	}
	pData.moveVector=vector.new(0,0)
	pData.currentTree=currentTree
	pData.statemachine=require("Resources.StateMachine").new(pData)
	pData.statemachine:addState(require("Resources.states.Idle"))
	pData.statemachine:addState(require("Resources.states.Walk"))
	pData.statemachine:changeState("Idle")
	pData.speed=3;
	pData.position=vector.new(400,300)
	pData.input = Input.new {
		controls = {
			left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
			right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
			up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
			down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'},
			jump = {"key:space"},
			action = {'key:x', 'button:a'},
		},
		pairs = {
			move = {'left', 'right', 'up', 'down'}
		},
		joystick = love.joystick.getJoysticks()[1],
	}
	return pData
end

function Player:loadTree(animationName)
	self.currentTree=self.animations[animationName]
end

function compare(a,b)
	local num1 = tonumber(string.sub(a,0,-5))
	local num2 = tonumber(string.sub(b,0,-5))
	return num1<num2
end

function Player:draw()
	self.currentTree.currentAnimation:draw(self.position.x,self.position.y,0,1,1,self.currentTree.currentAnimation:getWidth()/2,self.currentTree.currentAnimation:getHeight())
end

function Player:update(dt)
	self.input:update(dt)
	self.moveVector=(vector.new(self.input:get 'move')*self.speed):normalized()
	self.statemachine:update(dt)
	self.currentTree:update(dt)
end


return Player