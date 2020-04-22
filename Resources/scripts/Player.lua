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
	pData.sprite=entity.new(20,10)
	pData.sprite.parent=pData;
	pData.sprite.bounciness=0;
	pData.animations={
		['idle']=
		blendtree.new({
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,1,8),.06),vector.new(0,-1)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,9,16),.06),vector.new(.5,-.5)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,17,24),.06),vector.new(1,0)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,25,32),.06),vector.new(.5,.5)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,33,40),.06),vector.new(0,1)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,41,48),.06),vector.new(-.5,.5)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,49,56),.06),vector.new(-1,0)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,57,64),.06),vector.new(-.5,-.5)}, --upleft
			},
			vector.new(0,0),
			"idle",
			pData,
			nil,
			nil,
			true
		),
		['walk']=
		blendtree.new({
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,1,8),.06,nil),vector.new(0,-1)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,9,16),.06,nil),vector.new(.5,-.5)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,17,24),.06,nil),vector.new(1,0)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,25,32),.06,nil),vector.new(.5,.5)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,33,40),.06,nil),vector.new(0,1)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,41,48),.06,nil),vector.new(-.5,.5)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,49,56),.06,nil),vector.new(-1,0)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,57,64),.06,nil),vector.new(-.5,-.5)}, --upleft
			},
			vector.new(0,0),
			"walk",
			pData,
			function() pData.sprite:AddForce(1) end,
			nil,
			true
		),
		['jump']=
		blendtree.new({
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,1,10),.03,function()  end),vector.new(0,-1)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,11,20),.03,function() end),vector.new(.5,-.5)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,21,30),.03,function() end),vector.new(1,0)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,31,40),.03,function() end),vector.new(.5,.5)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,41,50),.03,function() end),vector.new(0,1)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,51,60),.03,function() end),vector.new(-.5,.5)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,61,70),.03,function() end),vector.new(-1,0)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,71,80),.03,function() end),vector.new(-.5,-.5)}, --upleft
			},
			vector.new(0,0),
			"jump",
			pData,
			nil,
			function() end,
			true
		),
		['squish']=
		blendtree.new({
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,1,5),.05,function()  end),vector.new(0,-1)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,6,10),.05,function() end),vector.new(.5,-.5)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,11,15),.05,function() end),vector.new(1,0)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,16,20),.05,function() end),vector.new(.5,.5)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,21,25),.05,function() end),vector.new(0,1)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,26,30),.05,function() end),vector.new(-.5,.5)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,31,35),.05,function() end),vector.new(-1,0)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,36,40),.05,function() end),vector.new(-.5,-.5)}, --upleft
			},
			vector.new(0,0),
			"jump",
			pData,
			nil,
			function() end,
			false
		),
	}
	pData.moveVector=vector.new(0,0)
	pData.currentTree=currentTree
	pData.statemachine=require("Resources.scripts.StateMachine").new(pData)
	pData.statemachine:addState(require("Resources.states.Idle"))
	pData.statemachine:addState(require("Resources.states.Walk"))
	pData.statemachine:addState(require("Resources.states.Jump"))
	pData.statemachine:addState(require("Resources.states.Squish"))
	pData.statemachine:changeState("Idle")
	pData.speed=2;
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
	self.animations[animationName].vector=oldVector; --set vector to old vector before we load the animation
	self.currentTree=self.animations[animationName]
	if(self.currentTree.currentAnimation:getLooping()) then
		--Gives better looping result on looping animations
		self.currentTree.currentAnimation:setFrame(#self.currentTree.currentAnimation.frames)
	else
		print("Setting animation active again")
		self.currentTree.currentAnimation:setActive(true)
		self.currentTree.currentAnimation:setPaused(false)
		self.currentTree.currentAnimation:setFrame(1)
	end
	--self.currentTree.currentAnimation:setOnPlay(self.currentTree.startEvent)
end

function compare(a,b)
	local num1 = tonumber(string.sub(a,0,-5))
	local num2 = tonumber(string.sub(b,0,-5))
	return num1<num2
end

function Player:draw()
	love.graphics.setColor(0,0,0,.5)
	love.graphics.circle("fill",self.position.x,self.position.y-5,10,250)
	love.graphics.setColor(1,1,1,1)
	self.sprite:draw()
	if(self.currentTree.currentAnimation:isActive()) then
		self.currentTree.currentAnimation:draw(self.sprite.position.x,self.sprite.position.y,0,1,1,self.currentTree.currentAnimation:getWidth()/2,self.currentTree.currentAnimation:getHeight())
	end
end

function Player:update(dt)
	self.input:update(dt)
	self.statemachine:update(dt)
	self.currentTree:update(dt)
	self.moveVector=(vector.new(self.input:get 'move')*self.speed):normalized()
	self.sprite:update(dt)
	if(self.input:down("jump")) then
		if(self.statemachine.currentState.Name~="Jump")then
			self.statemachine:changeState("Squish")
		end
	end
	if(self.input:released("jump")) then
		if(self.statemachine.currentState.Name~="Jump")then
			self.statemachine:changeState("Jump")
		end
	end
	for shape, delta in pairs(colliderWorld:collisions(self.sprite.collider)) do
		if(vector.new(delta.x,delta.y)~=vector.zero)then
			print("!")
			self.position=self.position+vector.new(delta.x,delta.y)
		end
		--shape:move(delta.x, delta.y)
	end
end


return Player