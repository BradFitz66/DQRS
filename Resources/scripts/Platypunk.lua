local Platypunk={}
local anim8=require("Resources.lib.anim8")
local blendtree=require("Resources.lib.blendtree")

Platypunk.__index=Platypunk

local entity=require("Resources.scripts.Entity")
function Platypunk.new()
	local punkData=setmetatable({},Platypunk)
	punkData.sprite=entity.new(0,0,15,15)
	punkData.sprite.parent=punkData;
	punkData.sprite.name="NPC"
	
	punkData.sprite.maxBounces=2;
	local idleFrames=loadImagesFromDirectory("Resources/graphics/Platypunk/Idle",true,compare,1,9)
	local walkFrames=loadImagesFromDirectory("Resources/graphics/Platypunk/Walk",true,compare,1,36)
	local stretchFrames=loadImagesFromDirectory("Resources/graphics/Platypunk/Stretch",true,compare,1,36)
	local walkDelays={0.03,0.03,0.07,0.13,0.03,0.03,0.03,0.03,0.07,0.13,0.03,0.03}
	local stretchDelays={0.16,0.16,0.16,0.16,0.16,0.16,0.16,0.04,0.04,0.04,0.04,0.16}
	local idleDelays={0.27,0.13,0.13,0.03}
	punkData.animations={
		['idle']=
		blendtree.new({
			{anim8.newAnimation({idleFrames[1],idleFrames[2],idleFrames[3],idleFrames[2]},idleDelays),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation({idleFrames[7],idleFrames[8],idleFrames[9],idleFrames[8]},idleDelays),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation({idleFrames[4],idleFrames[5],idleFrames[6],idleFrames[5]},idleDelays),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation({idleFrames[7],idleFrames[8],idleFrames[9],idleFrames[8]},idleDelays,nil,nil,true),vector.new(-1,0),vector.new(.5,.8)}, --left
			},
			vector.new(0,0),
			"idle",
			punkData,
			nil,
			nil,
			true
		),
		['walk']=
		blendtree.new({
			{anim8.newAnimation(table.range(walkFrames,1,12),walkDelays,nil),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.range(walkFrames,13,24),walkDelays,nil),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.range(walkFrames,25,36),walkDelays,nil),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.range(walkFrames,13,24),walkDelays,nil,nil,true),vector.new(-1,0),vector.new(.5,.8)}, --left
			},
			vector.new(0,0),
			"walk",
			punkData,
			function() end,
			nil,
			true
		),
		['stretch']=
		blendtree.new({
			{anim8.newAnimation(table.range(stretchFrames,12,1),stretchDelays,nil),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.range(stretchFrames,24,13),stretchDelays,nil),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.range(stretchFrames,36,25),stretchDelays,nil),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.range(stretchFrames,24,13),stretchDelays,nil,nil,true),vector.new(-1,0),vector.new(.5,.8)}, --left
			},
			vector.new(0,0),
			"stretch",
			punkData,
			function() end,
			nil,
			false
		),

		['held']=
		blendtree.new({
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Platypunk/Held",true,compare,3,4),.18,nil),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Platypunk/Held",true,compare,1,2),.18,nil),vector.new(1,0),vector.new(.6,.5)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Platypunk/Held",true,compare,5,6),.18,nil),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Platypunk/Held",true,compare,1,2),.18,nil,nil,true),vector.new(-1,0),vector.new(.6,.5)}, --left
			},
			vector.new(0,0),
			"held",
			punkData,
			function() end,
			nil,
			true
		),
		['hurt']=
		blendtree.new({
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Platypunk/Hurt",true,compare,2,2),.18,nil),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Platypunk/Hurt",true,compare,1,1),.18,nil,nil,true),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Platypunk/Hurt",true,compare,3,3),.18,nil),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Platypunk/Hurt",true,compare,1,1),.18,nil),vector.new(-1,0),vector.new(.5,.8)}, --left
			},
			vector.new(0,0),
			"hurt",
			punkData,
			function() end,
			nil,
			true
		),
	}
	
	punkData.moveVector=vector.new(0,0)
	punkData.currentTree=currentTree
	punkData.statemachine=require("Resources.scripts.StateMachine").new(punkData)
	--This contains the Platypunks states. It stores the actual state module + a table of the states that can't transition to it
	punkData.states={
		["Idle"]={punkData.statemachine:addState(require("Resources.states.Platypunk.Idle")),{}},
		["Walk"]={punkData.statemachine:addState(require("Resources.states.Platypunk.Walk")),{}},
		["Stretch"]={punkData.statemachine:addState(require("Resources.states.Platypunk.Stretch")),{}},
		["Held"]={punkData.statemachine:addState(require("Resources.states.Held")),{}},
		["Hurt"]={punkData.statemachine:addState(require("Resources.states.Hurt")),{}}
	}
	
	punkData.statemachine:changeState("Idle")
	punkData.speed=32;
	punkData.scale=vector.new(1,1)
	punkData.position=vector.new(200,200)
	punkData.image=love.graphics.newImage("Resources/graphics/Platypunk/Idle/1.png")
    punkData.walkDest=vector.new(0,0)
	punkData.sprite.position=vector.new(200,200)
	punkData.rotation=0
	return punkData
end

function Platypunk:loadTree(animationName,keepVector,frame,pausedAtStart)
	local oldVector=(keepVector and self.currentTree~=nil) and self.currentTree.vector or vector.new(0,0)
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
	
end

function Platypunk:draw()
	self.sprite:draw()
	if(self.currentTree.currentAnimation:isActive()) then
		local offset=vector.new(self.currentTree.currentAnimation:getWidth()*self.currentTree.frameOffset.x,self.currentTree.currentAnimation:getHeight()*self.currentTree.frameOffset.y):round()
		self.currentTree.currentAnimation:draw(math.round(self.sprite.position.x),math.round(self.sprite.position.y),self.rotation,self.scale.x,self.scale.y,offset.x,offset.y)
	end
end

function Platypunk:changeState(newState)
	local currentState=self.statemachine.currentState.Name
	if(newState==currentState)then
		--!print("Can't switch to new state because it's already the current state")
		return
	end
	if(table.index_of(self.states[newState][2],currentState))then
		--!print("Can't switch to new state because the current state is not allowed to switch to it ("..currentState.." to "..newState..")")
		return
	end
	self.statemachine:changeState(newState)
end

function Platypunk:update(dt)
	self.statemachine:update(dt)
	self.currentTree:update(dt)
	self.sprite:update(dt,nil)
	if(self.sprite.inAir==true and self.statemachine.currentState.Name~="Hurt") then
		self:changeState("Hurt")
	end
end


return Platypunk