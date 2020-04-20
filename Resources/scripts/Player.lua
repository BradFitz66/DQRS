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
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,1,8),.08),vector.new(0,-1)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,9,16),.08),vector.new(.5,-.5)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,17,24),.08),vector.new(1,0)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,25,32),.08),vector.new(.5,.5)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,33,40),.08),vector.new(0,1)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,41,48),.08),vector.new(-.5,.5)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,49,56),.08),vector.new(-1,0)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,57,64),.08),vector.new(-.5,-.5)}, --upleft
			},
			vector.new(0,0),
			"idle",
			pData
		),
		['walk']=
		blendtree.new({
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,1,8),.08,function() pData.sprite:AddForce(1.5) end),vector.new(0,-1)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,9,16),.08,function() pData.sprite:AddForce(1.5) end),vector.new(.5,-.5)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,17,24),.08,function() pData.sprite:AddForce(1.5) end),vector.new(1,0)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,25,32),.08,function() pData.sprite:AddForce(1.5) end),vector.new(.5,.5)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,33,40),.08,function() pData.sprite:AddForce(1.5) end),vector.new(0,1)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,41,48),.08,function() pData.sprite:AddForce(1.5) end),vector.new(-.5,.5)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,49,56),.08,function() pData.sprite:AddForce(1.5) end),vector.new(-1,0)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,57,64),.08,function() pData.sprite:AddForce(1.5) end),vector.new(-.5,-.5)}, --upleft
			},
			vector.new(0,0),
			"walk",
			pData,
			function() pData.sprite:AddForce(1) end
			
		),
	}
	pData.sprite=entity.new()
	pData.sprite.parent=pData;
	pData.sprite.bounciness=0;
	pData.moveVector=vector.new(0,0)
	pData.currentTree=currentTree
	pData.statemachine=require("Resources.scripts.StateMachine").new(pData)
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

function Player:loadTree(animationName,keepVector, keepFrame)
	local oldVector=(keepVector and self.currentTree~=nil) and self.currentTree.vector or vector.zero
	local oldFrame=(keepVector and self.currentTree~=nil) and self.currentTree.currentAnimation:getFrame() or 1
	print("Old vector: "..tostring(oldVector))
	self.currentTree=self.animations[animationName]
	self.currentTree.vector=oldVector
	self.currentTree.currentAnimation:setFrame(#self.currentTree.currentAnimation.frames)
	--self.currentTree.currentAnimation:setOnPlay(self.currentTree.startEvent)
end

function compare(a,b)
	local num1 = tonumber(string.sub(a,0,-5))
	local num2 = tonumber(string.sub(b,0,-5))
	return num1<num2
end

function Player:draw()
	love.graphics.setColor(0,0,0,.5)
	love.graphics.circle("fill",self.position.x,self.position.y-5,10,10)
	love.graphics.setColor(1,1,1,1)
	self.currentTree.currentAnimation:draw(self.sprite.position.x,self.sprite.position.y,0,1,1,self.currentTree.currentAnimation:getWidth()/2,self.currentTree.currentAnimation:getHeight())
end

function Player:update(dt)
	self.input:update(dt)
	self.moveVector=(vector.new(self.input:get 'move')*self.speed):normalized()
	self.statemachine:update(dt)
	self.currentTree:update(dt)
	self.sprite:update(dt)
	if(self.input:released("jump")) then
		self.sprite:AddForce(5)
	end
end


return Player