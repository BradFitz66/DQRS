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



function Player.load()
	local pData=setmetatable({},Player)
	pData.sprite=entity.new(0,1,20,12)
	pData.sprite.parent=pData;
	pData.sprite.bounciness=0;
	pData.animations={
		['idle']=
		blendtree.new({
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,1,8),.06),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,9,16),.06),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,17,24),.06),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,25,32),.06),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,33,40),.06),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,41,48),.06),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,49,56),.06),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,57,64),.06),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
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
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,1,8),.06,nil),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,9,16),.06,nil),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,17,24),.06,nil),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,25,32),.06,nil),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,33,40),.06,nil),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,41,48),.06,nil),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,49,56),.06,nil),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/IdleFrames",true,compare,57,64),.06,nil),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
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
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,1,10),.03,function()  end),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,11,20),.03,function() end),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,21,30),.03,function() end),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,31,40),.03,function() end),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,41,50),.03,function() end),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,51,60),.03,function() end),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,61,70),.03,function() end),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,71,80),.03,function() end),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
			},
			vector.new(0,0),
			"jump",
			pData,
			nil,
			function() end,
			true
		),
		['blasting']=
		blendtree.new({
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,1,10),.03,function()  end),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,11,20),.03,function() end),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,21,30),.03,function() end),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,31,40),.03,function() end),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,41,50),.03,function() end),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,51,60),.03,function() end),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,61,70),.03,function() end),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/JumpFrames",true,compare,71,80),.03,function() end),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
			},
			vector.new(0,0),
			"blasting",
			pData,
			nil,
			function() end,
			true
		),
		
		['squish']=
		blendtree.new({
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,1,5),.05,function()  end),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,6,10),.05,function() end),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,11,15),.05,function() end),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,16,20),.05,function() end),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,21,25),.05,function() end),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,26,30),.05,function() end),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,31,35),.05,function() end),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,36,40),.05,function() end),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
			},
			vector.new(0,0),
			"squish",
			pData,
			nil,
			function() end,
			false
		),
		['squished']=
		blendtree.new({
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,5),.05,function()  end),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,10),.05,function() end),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,15),.05,function() end),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,20),.05,function() end),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,25),.05,function() end),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,30),.05,function() end),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,35),.05,function() end),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/SquishFrames",true,compare,40),.05,function() end),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
			},
			vector.new(0,0),
			"squished",
			pData,
			nil,
			function() end,
			false
		),
		['stretch']=
		blendtree.new(
			{
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/StretchFrames",true,compare,1),0,function()end),vector.new(0,-1),vector.new(.5,.9)}, --up
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/StretchFrames",true,compare,1),0,function()end),vector.new(.5,-.5),vector.new(.5,.9)}, --upright
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/StretchFrames",true,compare,2),0,function()end),vector.new(1,0),vector.new(.8,.8)}, --right
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/StretchFrames",true,compare,3),0,function()end),vector.new(.5,.5),vector.new(.8,.8)}, --downright
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/StretchFrames",true,compare,3),0,function()end),vector.new(0,1),vector.new(.5,.7)}, --down
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/StretchFrames",true,compare,3),0,function()end),vector.new(-.5,.5),vector.new(.2,.8)}, --downleft
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/StretchFrames",true,compare,4),0,function()end),vector.new(-1,0),vector.new(0.2,.8)}, --left
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/StretchFrames",true,compare,1),0,function()end),vector.new(-.5,-.5),vector.new(.5,.9)}, --upleft
			},
			vector.new(0,0),
			"stretch",
			pData,
			nil,
			function() end,
			false
		),
		['wallhit']=
		blendtree.new(
			{
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/WallHitFrames",true,compare,1,4),.1,function()  end),vector.new(0,-1),vector.new(.5,.8)}, --up
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/WallHitFrames",true,compare,5,8),.1,function() end),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/WallHitFrames",true,compare,9,12),.1,function() end),vector.new(1,0),vector.new(.5,.8)}, --right
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/WallHitFrames",true,compare,13,16),.1,function() end),vector.new(.5,.7),vector.new(.5,.8)}, --downright
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/WallHitFrames",true,compare,17,20),.1,function() end),vector.new(0,1),vector.new(.5,.8)}, -- down
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/WallHitFrames",true,compare,21,24),.1,function() end),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/WallHitFrames",true,compare,25,28),.1,function() end),vector.new(-1,0),vector.new(.5,.8)}, --left
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/WallHitFrames",true,compare,29,32),.1,function() end),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
				},
			vector.new(0,0),
			"stretch",
			pData,
			nil,
			function() end,
			false
		)
	}
	
	pData.moveVector=vector.new(0,0)
	pData.currentTree=currentTree
	pData.statemachine=require("Resources.scripts.StateMachine").new(pData)
	--This contains the players states. It stores the actual state module + a table of the states that can't transition to it
	pData.states={
		["Idle"]={pData.statemachine:addState(require("Resources.states.Idle")),{}},
		["Walk"]={pData.statemachine:addState(require("Resources.states.Walk")),{}},
		["Jump"]={pData.statemachine:addState(require("Resources.states.Jump")),{"Blasting","Stretch","WallHit"}},
		["Squish"]={pData.statemachine:addState(require("Resources.states.Squish")),{"Jump","Stretch","Squished","Blasting","WallHit"}},
		["Stretch"]={pData.statemachine:addState(require("Resources.states.Stretch")),{}},
		["Squished"]={pData.statemachine:addState(require("Resources.states.Squished")),{}},
		["Blasting"]={pData.statemachine:addState(require("Resources.states.Blasting")),{}},
		["WallHit"]={pData.statemachine:addState(require("Resources.states.WallHit")),{}}
	}
	
	pData.statemachine:changeState("Idle")
	pData.speed=96;
	pData.scale=vector.new(1,1)
	pData.position=vector.new(400,300)
	pData.wallHitNormal=vector.zero
	pData.blastVelocity=vector.zero
	pData.wallHitDebounce=false --* I don't want to do this, but it seems like the easiest solution to stop the player from being stuck in a wallhit loop
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
	pData.rotation=0
	return pData
end

function Player:loadTree(animationName,keepVector,frame,pausedAtStart)
	local oldVector=(keepVector and self.currentTree~=nil) and self.currentTree.vector or vector.zero
	self.animations[animationName].vector=oldVector; --set vector to old vector before we load the animation
	self.currentTree=self.animations[animationName]
	if(frame and pausedAtStart) then
		self.currentTree.currentAnimation:setPaused(true)
		self.currentTree.currentAnimation:setFrame(frame)
	end
	if(self.currentTree.currentAnimation:getLooping()) then
		--Gives better looping result on looping animations
		self.currentTree.currentAnimation:setFrame(#self.currentTree.currentAnimation.frames)
	else
		--!print("Setting animation active again")
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
		local offset=vector.new(self.currentTree.currentAnimation:getWidth()*self.currentTree.frameOffset.x,self.currentTree.currentAnimation:getHeight()*self.currentTree.frameOffset.y)
		self.currentTree.currentAnimation:draw(self.sprite.position.x,self.sprite.position.y,self.rotation,self.scale.x,self.scale.y,offset.x,offset.y)
	end
end

function Player:changeState(newState)
	local currentState=self.statemachine.currentState.Name
	if(newState==currentState)then
		--!print("Can't switch to new state because it's already the current state")
		return
	end
	if(contains(self.states[newState][2],currentState))then
		--!print("Can't switch to new state because the current state is not allowed to switch to it ("..currentState.." to "..newState..")")
		return
	end
	self.statemachine:changeState(newState)
end

function contains(table, element)
	for _, value in pairs(table) do
	  if value == element then
		return true
	  end
	end
	return false
  end

function Player:update(dt)

	for shape, delta in pairs(colliderWorld:collisions(self.sprite.collider)) do
		
		if(self.statemachine.currentState.Name=="Blasting")then
			--Only continue if there's a separation delta (meaning we're actually colliding into something, not just touching it) and if we're not currently in debounce mode
			if(not (delta.x==0 and delta.y==0) and not self.wallHitDebounce) then
				self.wallHitDebounce=true;
				self.wallHitNormal=vector.new(math.floor(delta.y),math.floor(delta.x))
				self:changeState("WallHit")
				self.currentTree.vector=vector.new(delta.x,delta.y)
				timer.after(.1,function()
					self.wallHitDebounce=false;
				end)
			end
		else
			if(self.statemachine.currentState.Name=="Blasting")then
				self:changeState("Idle")
			end
		end
		self.position=self.position+vector.new(delta.x,delta.y)
	end

	self.input:update(dt)
	self.statemachine:update(dt)
	self.currentTree:update(dt)
	self.moveVector=(vector.new(self.input:get 'move')*self.speed):normalized()
	self.sprite:update(dt)
	if(self.input:down("jump")) then
		self:changeState("Squish")
	end
	if(self.input:released("jump")) then
		self:changeState("Jump")
	end
	
end


return Player