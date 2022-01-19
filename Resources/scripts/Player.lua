--Player controller script. This contains animation handling and state handling. Due to the complex nature of this character controller, a state machine is used to handle different stuff such as walking, idling, jumping, etc.
Player={}
Player.__index=Player


local entity=require("Resources.scripts.Entity")
function Player.load()
	local pData=setmetatable({},Player)
	pData.sprite=entity.new(0,1,12,12)
	pData.sprite.parent=pData;
	pData.sprite.bounciness=0;
	pData.sprite.maxBounces=1;
	--List of all animations. Blendtree is a module that lets me "blend" between multiple directional animations based on a vector
	pData.animations={
		['idle']=
		blendtree.new(
			{
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,1,8),.06),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,9,16),.06),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,17,24),.06),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,25,32),.06),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,33,40),.06),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,41,48),.06),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,49,56),.06),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,57,64),.06),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
			},
			vector.new(0,0),
			"idle",
			pData,
			nil,
			nil,
			true
		),
		['throw']=
		blendtree.new({
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/ThrowFrames",true,compare,1,8),.06),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/ThrowFrames",true,compare,9,16),.06),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/ThrowFrames",true,compare,17,24),.06),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/ThrowFrames",true,compare,25,32),.06),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/ThrowFrames",true,compare,33,40),.06),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/ThrowFrames",true,compare,41,48),.06),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/ThrowFrames",true,compare,49,56),.06),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/ThrowFrames",true,compare,57,64),.06),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
			},
			vector.new(0,0),
			"throw",
			pData,
			nil,
			nil,
			false
		),
		['walk']=
		blendtree.new({
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,1,8),.06,nil),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,9,16),.06,nil),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,17,24),.06,nil),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,25,32),.06,nil),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,33,40),.06,nil),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,41,48),.06,nil),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,49,56),.06,nil),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,57,64),.06,nil),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
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
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,1,10),.03,function()  end),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,11,20),.03,function() end),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,21,30),.03,function() end),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,31,40),.03,function() end),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,41,50),.03,function() end),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,51,60),.03,function() end),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,61,70),.03,function() end),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,71,80),.03,function() end),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
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
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,1,10),.03,function()  end),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,11,20),.03,function() end),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,21,30),.03,function() end),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,31,40),.03,function() end),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,41,50),.03,function() end),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,51,60),.03,function() end),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,61,70),.03,function() end),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,71,80),.03,function() end),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
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
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,1,5),.05,function()  end),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,6,10),.05,function() end),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,11,15),.05,function() end),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,16,20),.05,function() end),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,21,25),.05,function() end),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,26,30),.05,function() end),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,31,35),.05,function() end),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,36,40),.05,function() end),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
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
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,5),.05,function()  end),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,10),.05,function() end),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,15),.05,function() end),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,20),.05,function() end),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,25),.05,function() end),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,30),.05,function() end),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,35),.05,function() end),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,40),.05,function() end),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
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
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/StretchFrames",true,compare,1),0,function()end),vector.new(0,-1),vector.new(.5,.9)}, --up
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/StretchFrames",true,compare,1),0,function()end),vector.new(.5,-.5),vector.new(.5,.9)}, --upright
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/StretchFrames",true,compare,2),0,function()end),vector.new(1,0),vector.new(.7,.9)}, --right
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/StretchFrames",true,compare,3),0,function()end),vector.new(.5,.5),vector.new(.5,.9)}, --downright
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/StretchFrames",true,compare,3),0,function()end),vector.new(0,1),vector.new(.5,.9)}, --down
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/StretchFrames",true,compare,3),0,function()end),vector.new(-.5,.5),vector.new(.5,.9)}, --downleft
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/StretchFrames",true,compare,4),0,function()end),vector.new(-1,0),vector.new(0.3,.9)}, --left
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/StretchFrames",true,compare,1),0,function()end),vector.new(-.5,-.5),vector.new(.5,.9)}, --upleft
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
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/WallHitFrames",true,compare,1,4),.1,function()  end),vector.new(0,-1),vector.new(.5,0)}, --up
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/WallHitFrames",true,compare,5,8),.1,function() end),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/WallHitFrames",true,compare,9,12),.1,function() end),vector.new(1,0),vector.new(1,.8)}, --right
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/WallHitFrames",true,compare,13,16),.1,function() end),vector.new(.5,.7),vector.new(.5,.8)}, --downright
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/WallHitFrames",true,compare,17,20),.1,function() end),vector.new(0,1),vector.new(.5,1)}, -- down
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/WallHitFrames",true,compare,21,24),.1,function() end),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/WallHitFrames",true,compare,25,28),.1,function() end),vector.new(-1,0),vector.new(0,.8)}, --left
				{anim8.newAnimation(loadImagesFromDirectory("Resources/graphics/Rocket/WallHitFrames",true,compare,29,32),.1,function() end),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
				},
			vector.new(0,0),
			"wallhit",
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
		["Idle"]={pData.statemachine:addState(require("Resources.states.Rocket.Idle")),{}},
		["Walk"]={pData.statemachine:addState(require("Resources.states.Rocket.Walk")),{}},
		["Jump"]={pData.statemachine:addState(require("Resources.states.Rocket.Jump")),{"Blasting","Stretch","WallHit"}}, -- Blasting, Stretch and WallHit cannot transition into the jump state.
		["Squish"]={pData.statemachine:addState(require("Resources.states.Rocket.Squish")),{"Jump","Stretch","Squished","Blasting","WallHit"}},
		["Stretch"]={pData.statemachine:addState(require("Resources.states.Rocket.Stretch")),{}},
		["Squished"]={pData.statemachine:addState(require("Resources.states.Rocket.Squished")),{}},
		["Blasting"]={pData.statemachine:addState(require("Resources.states.Rocket.Blasting")),{}},
		["WallHit"]={pData.statemachine:addState(require("Resources.states.Rocket.WallHit")),{"Throw"}},
		["Throw"]={pData.statemachine:addState(require("Resources.states.Rocket.Throw")),{"WallHit"}}
	}
	pData.statemachine:changeState("Idle")
	pData.speed=96;
	pData.holding={}
	pData.scale=vector.new(1,1)
	pData.position=vector.new(200,200)
	pData.wallHitNormal=vector.new(0,0)
	pData.blastVelocity=vector.new(0,0)
	pData.canThrow=true;
	pData.superThrow=false;
	pData.hitWall=false;
	pData.wallHitDebounce=false --Sometimes player can get stuck in an infinite loop of collision. Adding a debounce fixes this.
	--Players input. ToDo: Major refactor of entire input system.
	pData.input = Input.new {
		controls = {
			left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
			right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
			up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
			down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'},
			jump = {"key:space"},
			action = {'key:lshift', 'button:a'},
		},
		pairs = {
			move = {'left', 'right', 'up', 'down'}
		},
		joystick = love.joystick.getJoysticks()[1],
	}
	--Head collider is for making sure player can't stretch their body through colliders.
	pData.headCollider=colliderWorld:circle(-100,-100,5)
	pData.headPosition=vector.new(0,0)
	
	pData.rotation=0
	return pData
end
--Load a new blendtree.
function Player:loadTree(animationName,keepVector,frame,pausedAtStart)
	if(self.currentTree~=nil) then		
		if(keepVector) then
			self.animations[animationName]:setVector(self.currentTree.vector); 
		end
	end
	self.currentTree=self.animations[animationName]
	if(frame and pausedAtStart) then
		self.currentTree.currentAnimation:setPaused(true)
		self.currentTree.currentAnimation:setFrame(frame)
	end
	self.currentTree.currentAnimation:setFrame(1)
	if(not self.currentTree.currentAnimation:getLooping()) then
		self.currentTree.currentAnimation:setActive(true)
		self.currentTree.currentAnimation:setPaused(false)
	end
end

--Draw the player
function Player:draw()
	self.sprite:draw()
	if(self.currentTree.currentAnimation:isActive()) then
		local offset=vector.new(self.currentTree.currentAnimation:getWidth()*self.currentTree.frameOffset.x,self.currentTree.currentAnimation:getHeight()*self.currentTree.frameOffset.y):round()

		self.currentTree.currentAnimation:draw(math.floor(self.sprite.position.x),math.floor(self.sprite.position.y),self.rotation,self.scale.x,self.scale.y,offset.x,offset.y)
	end
	if(debug) then
		self.headCollider:draw("fill")
	end
end

function Player:changeState(newState)
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


function Player:update(dt)
	
	for i, held in pairs(self.holding) do
		if(held~=nil) then
			local posDiff=(self.position-self.sprite.localPosition)
			local offset=vector.new(held[1].sprite.holdOffset.x,(held[1].sprite.holdOffset.y-(16*i)))
			local endPoint= self.statemachine.currentState.Name=="Stretch" and (self.headPosition)+offset or posDiff+offset
			local heldSprite=held[1].sprite
			local heldVelocity=held[2]
			heldVelocity.x=math.lerp(held[1].position.x,(endPoint.x),.1*dt);
			heldVelocity.z=math.lerp(held[1].position.y,(endPoint.y),.1*dt);
			held[1].position.y=held[1].position.y+(endPoint.y-held[1].position.y)*.5/i;
			held[1].position.x=held[1].position.x+(endPoint.x-held[1].position.x)*.5/i;
			if(held[1].sprite.name=="NPC") then
				held[1].moveVector=self.moveVector
			end
		end
	end
	self.sprite:update(dt,function()
		for shape, delta in pairs(colliderWorld:collisions(self.sprite.collider)) do
			local absoluteDelta=vector.new(math.abs(delta.x),math.abs(delta.y))
			local fixedDelta=vector.new(delta.x,delta.y)-(self.moveVector*self.speed):normalized()
			for _, actor in pairs(actors) do
				if(actor.sprite.collider==shape and not actor.sprite.pickedUp) then
					--Handle collision with actor while in the blasting state.
					if(self.statemachine.currentState.Name=="Blasting")then
						local normalizedBlast=self.blastVelocity:normalized()
						local initialVel = (vector3(self.blastVelocity.x,self.blastVelocity.y,0))
						initialVel.z=initialVel.y;
						initialVel.y=0;
						initialVel=initialVel+vector3(0,3,0)
						actor.sprite:AddForceXYZ(initialVel)
					else
						if(actor.sprite.inAir and actor.sprite.canPickup and #self.holding<3)then
							local heightDifference=actor.sprite.localPosition.y - self.sprite.localPosition.y
							if(heightDifference < 20) then
								actor.sprite.inAir=false
								--Picking up
								actor.sprite.pickedUp=true;
								
								actor.sprite.ZValue=10000*(#self.holding+1)
								table.insert(self.holding,{actor,vector3(0,0,0)})
								startPos=actor.sprite.localPosition
								if(actor.sprite.name=="NPC") then
									actor:changeState("Held")
								end
								timer.script(function(wait)
									self:changeState("Squish")
									wait(.2)
									self:changeState("Idle")
								end)
							end
						end
					end
				end
			end
			--Handle collisions with the collider of the currently loaded map
			if(table.index_of(currentMap.map.colliderShapes,shape)~=nil) then
				self.position=self.position+vector.new(fixedDelta.x,fixedDelta.y)
				if(self.statemachine.currentState.Name=="Blasting")then
					if(not (delta.x==0 and delta.y==0) and not self.wallHitDebounce) then
						
						--Angle we hit the wall at
						local collisionAngle=math.abs((math.round((math.deg(math.atan2(absoluteDelta.y,absoluteDelta.x))))))

						--Angle of the wall we hit
						local hitAngle=math.abs(math.round((math.deg(math.atan2(math.abs(self.blastVelocity.y),math.abs(self.blastVelocity.x))))))
						
						local rounded=round(collisionAngle)
						
						--Very ugly. This is the 'bounce rules' that determine whether the player cann bounce or not
						local canBounce = (rounded==90 and hitAngle<=90) or (rounded==45 and hitAngle== 45) or (rounded==0 and hitAngle<=45)
						
						collisionAngle= collisionAngle==45 and -collisionAngle or collisionAngle

						--Here we check if there's a separation delta and if the angle of collision is divisible by 180 with no remainder or is within 10 degrees of it or 90 degrees (some flat wall aren't perfectly flat due to float precision)
						if(not canBounce) then
							return
						end

						self.position=self.position+vector.new(absoluteDelta.x,absoluteDelta.y)
						self.wallHitDebounce=true;
						local newDelta = vector.new(math.cos(math.rad(collisionAngle)),math.sin(math.rad(collisionAngle)))
						self.wallHitNormal=vector.new(roundToNthDecimal(newDelta.y,1),roundToNthDecimal(newDelta.x,1))
						self:changeState("WallHit")
						self.hitWall=true;
						timer.after(10,function()
							self.hitWall=false;
						end)
						self.currentTree.vector=self.blastVelocity:mirrorOn(self.wallHitNormal)
						timer.after(.025,function()
							self.wallHitDebounce=false;
						end)
					end
				else
					if(self.statemachine.currentState.Name=="Blasting")then
						self:changeState("Idle")
					end
				end

			end
		end
	end)
	local hori,vert=self.input:get 'move'

	if(vector.new(hori,vert)~=vector.new(0,0)) then
		self.moveVector=(vector.new(hori,vert)):normalized()
	else
		self.moveVector=vector.new(0,0)
	end
	self.input:update(dt)
	self.statemachine:update(dt)
	self.currentTree:update(dt)
	if(self.statemachine.currentState.Name~="Stretch") then
		self.headPosition=self.position
	end
	if(self.input:down("jump")) then
		self:changeState("Squish")
	end
	if(self.input:released("jump")) then
		self:changeState("Jump")
	end
	if(self.input:pressed("action")) then
		if(#self.holding>0 and self.canThrow) then
			if(self.statemachine.currentState.Name~="Blasting") then
				self:changeState("Throw")
			else
				--Hack to bypass the change state function so we can stay in the blasting state while throwing
				self.states["Throw"][1].Enter(self)
				timer.after(.5,function() self.states["Throw"][1].Exit(self)	end)
			end
		end
	end
end


return Player