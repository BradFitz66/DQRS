--Player controller script. This contains animation handling and state handling. Due to the complex nature of this character controller, a state machine is used to handle different stuff such as walking, idling, jumping, etc.
Player={}
Player.__index=Player

local RTA=require("Resources.lib.RTA")

local entity=require("Resources.scripts.Entity")

--Helper function to return a table of quads from the sprite atlas
local function get_sprite_quads(spriteprefix,index_start, index_end,atlas)
	local quads={}
	if index_start ~= index_end then
		for i=index_start,index_end do
			table.insert(quads,1,atlas.quads[spriteprefix..tostring(i)])
		end
	else 
		table.insert(quads,1,atlas.quads[spriteprefix..tostring(index_start)])
	end
	return quads
end
local function countDictionary(dictionary)
    local count=0;
    for _, value in pairs(dictionary) do
        count=count+1
    end
    return count;
end
function Player.load()
	local pData=setmetatable({},Player)
	pData.sprite=entity.new(0,1,12,12)
	pData.sprite.parent=pData;
	pData.sprite.bounciness=0;
	pData.sprite.maxBounces=1;
	pData.sprites=RTA.newDynamicSize()
	pData.sprites:setFilter("nearest")
	local sprites={
		['idle']=loadImagesFromDirectory("Resources/graphics/Rocket/IdleFrames",true,compare,1,64),
		['walk']=loadImagesFromDirectory("Resources/graphics/Rocket/WalkFrames",true,compare,1,55),
		['throw']=loadImagesFromDirectory("Resources/graphics/Rocket/ThrowFrames",true,compare,1,64),
		['jump']=loadImagesFromDirectory("Resources/graphics/Rocket/JumpFrames",true,compare,1,80),
		['squish']=loadImagesFromDirectory("Resources/graphics/Rocket/SquishFrames",true,compare,1,40),
		['stretch']=loadImagesFromDirectory("Resources/graphics/Rocket/StretchFrames",true,compare,1,4),
		['wallhit']=loadImagesFromDirectory("Resources/graphics/Rocket/WallHitFrames",true,compare,1,32)
		--64 + 55 + 64 + 80 + 40 + 4 + 32 = 339 textures
	}
	local prefixes={
		"idle",
		"walk",
		"throw",
		"jump",
		"squish",
		"stretch",
		"wallhit"
	}
	pData.sprites:setBakeAsPow2(false)
	for _, prefix in pairs(prefixes) do
		for i, sprite in ipairs(sprites[prefix]) do
			pData.sprites:add(sprite,prefix..tostring(i))
		end
	end
	
	pData.sprites:hardBake()
	print(countDictionary(pData.sprites.quads))
	prefixes=nil
	sprites=nil;
	print(pData.sprites.image:getWidth(),pData.sprites.image:getHeight())
	collectgarbage("collect")
	--List of all animations. Blendtree is a module that lets me "blend" between multiple directional animations based on a vector
	pData.animations={
		['idle']=
		blendtree.new(
			{
			{anim8.newAnimation(table.reverse(get_sprite_quads("idle",1,8,pData.sprites)),.06,nil,pData.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.reverse(get_sprite_quads("idle",9,16,pData.sprites)),.06,nil,pData.sprites.image),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(table.reverse(get_sprite_quads("idle",17,24,pData.sprites)),.06,nil,pData.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.reverse(get_sprite_quads("idle",25,32,pData.sprites)),.06,nil,pData.sprites.image),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(table.reverse(get_sprite_quads("idle",33,40,pData.sprites)),.06,nil,pData.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.reverse(get_sprite_quads("idle",41,48,pData.sprites)),.06,nil,pData.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(table.reverse(get_sprite_quads("idle",49,56,pData.sprites)),.06,nil,pData.sprites.image),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(table.reverse(get_sprite_quads("idle",57,64,pData.sprites)),.06,nil,pData.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
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
			{anim8.newAnimation(table.reverse(get_sprite_quads("throw",1,8,pData.sprites)),.06,nil,pData.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.reverse(get_sprite_quads("throw",9,16,pData.sprites)),.06,nil,pData.sprites.image),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(table.reverse(get_sprite_quads("throw",17,24,pData.sprites)),.06,nil,pData.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.reverse(get_sprite_quads("throw",25,32,pData.sprites)),.06,nil,pData.sprites.image),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(table.reverse(get_sprite_quads("throw",33,40,pData.sprites)),.06,nil,pData.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.reverse(get_sprite_quads("throw",41,48,pData.sprites)),.06,nil,pData.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(table.reverse(get_sprite_quads("throw",49,56,pData.sprites)),.06,nil,pData.sprites.image),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(table.reverse(get_sprite_quads("throw",57,64,pData.sprites)),.06,nil,pData.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
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
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",1,11,pData.sprites)),.06,nil,pData.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",12,22,pData.sprites)),.06,nil,pData.sprites.image,true),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",23,33,pData.sprites)),.06,nil,pData.sprites.image,true),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",34,44,pData.sprites)),.06,nil,pData.sprites.image,true),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",45,55,pData.sprites)),.06,nil,pData.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",34,44,pData.sprites)),.06,nil,pData.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",23,33,pData.sprites)),.06,nil,pData.sprites.image),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",12,22,pData.sprites)),.06,nil,pData.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
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
			--Not entirely sure why, but some of the tables are loaded in reverse which is strange. I just use table.reverse (from the tablex module) to reverse it again.
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",1,10,pData.sprites)),.03,nil,pData.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",11,20,pData.sprites)),.03,nil,pData.sprites.image),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",21,30,pData.sprites)),.03,nil,pData.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",31,40,pData.sprites)),.03,nil,pData.sprites.image),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",41,50,pData.sprites)),.03,nil,pData.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",51,60,pData.sprites)),.03,nil,pData.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",61,70,pData.sprites)),.03,nil,pData.sprites.image),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",71,80,pData.sprites)),.03,nil,pData.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
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
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",1,10,pData.sprites)),.03,nil,pData.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",11,20,pData.sprites)),.03,nil,pData.sprites.image),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",21,30,pData.sprites)),.03,nil,pData.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",31,40,pData.sprites)),.03,nil,pData.sprites.image),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",41,50,pData.sprites)),.03,nil,pData.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",51,60,pData.sprites)),.03,nil,pData.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",61,70,pData.sprites)),.03,nil,pData.sprites.image),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",71,80,pData.sprites)),.03,nil,pData.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
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
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",1,5,pData.sprites)),.05,nil,pData.sprites.image) ,vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",6,10,pData.sprites)),.05,nil,pData.sprites.image),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",11,15,pData.sprites)),.05,nil,pData.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",16,20,pData.sprites)),.05,nil,pData.sprites.image),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",21,25,pData.sprites)),.05,nil,pData.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",26,30,pData.sprites)),.05,nil,pData.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",31,35,pData.sprites)),.05,nil,pData.sprites.image),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",36,40,pData.sprites)),.05,nil,pData.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
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
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",5,5,pData.sprites)),.05,nil,pData.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",10,10,pData.sprites)),.05,nil,pData.sprites.image),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",15,15,pData.sprites)),.05,nil,pData.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",20,20,pData.sprites)),.05,nil,pData.sprites.image),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",25,25,pData.sprites)),.05,nil,pData.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",30,30,pData.sprites)),.05,nil,pData.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",35,35,pData.sprites)),.05,nil,pData.sprites.image),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",40,40,pData.sprites)),.05,nil,pData.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
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
				{anim8.newAnimation(table.reverse(get_sprite_quads("stretch",1,1,pData.sprites)),0,nil,pData.sprites.image),vector.new(0,-1),vector.new(.5,.9)}, --up
				{anim8.newAnimation(table.reverse(get_sprite_quads("stretch",1,1,pData.sprites)),0,nil,pData.sprites.image),vector.new(.5,-.5),vector.new(.5,.9)}, --upright
				{anim8.newAnimation(table.reverse(get_sprite_quads("stretch",2,2,pData.sprites)),0,nil,pData.sprites.image),vector.new(1,0),vector.new(.7,.9)}, --right
				{anim8.newAnimation(table.reverse(get_sprite_quads("stretch",3,3,pData.sprites)),0,nil,pData.sprites.image),vector.new(.5,.5),vector.new(.5,.9)}, --downright
				{anim8.newAnimation(table.reverse(get_sprite_quads("stretch",3,3,pData.sprites)),0,nil,pData.sprites.image),vector.new(0,1),vector.new(.5,.9)}, --down
				{anim8.newAnimation(table.reverse(get_sprite_quads("stretch",3,3,pData.sprites)),0,nil,pData.sprites.image),vector.new(-.5,.5),vector.new(.5,.9)}, --downleft
				{anim8.newAnimation(table.reverse(get_sprite_quads("stretch",4,4,pData.sprites)),0,nil,pData.sprites.image),vector.new(-1,0),vector.new(0.3,.9)}, --left
				{anim8.newAnimation(table.reverse(get_sprite_quads("stretch",1,1,pData.sprites)),0,nil,pData.sprites.image),vector.new(-.5,-.5),vector.new(.5,.9)}, --upleft
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
				{anim8.newAnimation(table.reverse(get_sprite_quads("wallhit",1,4,pData.sprites)),.1,nil,pData.sprites.image),vector.new(0,-1),vector.new(.5,0)}, --up
				{anim8.newAnimation(table.reverse(get_sprite_quads("wallhit",5,8,pData.sprites)),.1,nil,pData.sprites.image),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
				{anim8.newAnimation(table.reverse(get_sprite_quads("wallhit",9,12,pData.sprites)),.1,nil,pData.sprites.image),vector.new(1,0),vector.new(1,.8)}, --right
				{anim8.newAnimation(table.reverse(get_sprite_quads("wallhit",13,16,pData.sprites)),.1,nil,pData.sprites.image),vector.new(.5,.7),vector.new(.5,.8)}, --downright
				{anim8.newAnimation(table.reverse(get_sprite_quads("wallhit",17,20,pData.sprites)),.1,nil,pData.sprites.image),vector.new(0,1),vector.new(.5,1)}, -- down
				{anim8.newAnimation(table.reverse(get_sprite_quads("wallhit",21,24,pData.sprites)),.1,nil,pData.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
				{anim8.newAnimation(table.reverse(get_sprite_quads("wallhit",25,28,pData.sprites)),.1,nil,pData.sprites.image),vector.new(-1,0),vector.new(0,.8)}, --left
				{anim8.newAnimation(table.reverse(get_sprite_quads("wallhit",29,32,pData.sprites)),.1,nil,pData.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
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
	self.statemachine:update(dt)
	self.currentTree:update(dt)
	self.input:update(dt)
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