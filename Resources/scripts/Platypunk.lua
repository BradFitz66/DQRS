local Platypunk={}

local anim8=require("Resources.lib.anim8")
local RTA=require("Resources.lib.RTA")
local blendtree=require("Resources.lib.Rocket_Engine.Animation.blendtree")
local image_utils = require("Resources.lib.Rocket_Engine.Utils.ImageUtils")
local entity=require("Resources.lib.Rocket_Engine.Objects.Entity")

Platypunk.__index=Platypunk

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

function Platypunk.new()
	local punkData=setmetatable({},Platypunk)
	punkData.sprite=entity.new(0,0,15,15)
	punkData.sprite.parent=punkData;
	punkData.sprite.name="NPC"
	punkData.sprites=RTA.newDynamicSize(0,0,0)
	punkData.sprites:setFilter("nearest")
	local sprites={
		['idle']=image_utils.load_images_from_directory("Resources/graphics/Platypunk/Idle",true,image_utils.compare,1,9),
		['walk']=image_utils.load_images_from_directory("Resources/graphics/Platypunk/Walk",true,image_utils.compare,1,55),
		['stretch']=image_utils.load_images_from_directory("Resources/graphics/Platypunk/Stretch",true,image_utils.compare,1,36),
		['hurt']=image_utils.load_images_from_directory("Resources/graphics/Platypunk/Hurt",true,image_utils.compare,1,3)
	}
	local prefixes={
		"idle",
		"walk",
		"stretch",
		"hurt"
	}
	punkData.sprites:setBakeAsPow2(true)
	for _, prefix in pairs(prefixes) do
		for i, sprite in ipairs(sprites[prefix]) do
			punkData.sprites:add(sprite,prefix..tostring(i),true,"area")
		end
	end
	punkData.sprites:hardBake()

	prefixes=nil
	sprites=nil;
	collectgarbage("collect")

	punkData.sprite.max_bounces=2;
	local idleFrames = table.reverse(get_sprite_quads("idle",1,9,punkData.sprites))
	local walkFrames = table.reverse(get_sprite_quads("walk",1,36,punkData.sprites))
	local stretchFrames = table.reverse(get_sprite_quads("stretch",1,36,punkData.sprites))
	--hardcoded delay tables for some of the animations to improve how they look.
	local walkDelays={0.03,0.03,0.07,0.13,0.03,0.03,0.03,0.03,0.07,0.13,0.03,0.03}
	local stretchDelays={0.16,0.16,0.16,0.16,0.16,0.16,0.16,0.04,0.04,0.04,0.04,0.16}
	local idleDelays={0.27,0.13,0.13,0.03}
	punkData.animations={
		['idle']=
		blendtree.new({
			{anim8.newAnimation({idleFrames[1],idleFrames[2],idleFrames[3],idleFrames[2]},idleDelays,nil,punkData.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation({idleFrames[4],idleFrames[5],idleFrames[6],idleFrames[5]},idleDelays,nil,punkData.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation({idleFrames[7],idleFrames[8],idleFrames[9],idleFrames[8]},idleDelays,nil,punkData.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation({idleFrames[4],idleFrames[5],idleFrames[6],idleFrames[5]},idleDelays,nil,punkData.sprites.image,true),vector.new(-1,0),vector.new(.5,.8)}, --left
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
			{anim8.newAnimation(table.range(walkFrames,1,12),walkDelays,nil,punkData.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.range(walkFrames,13,24),walkDelays,nil,punkData.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.range(walkFrames,25,36),walkDelays,nil,punkData.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.range(walkFrames,13,24),walkDelays,nil,punkData.sprites.image,true),vector.new(-1,0),vector.new(.5,.8)}, --left
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
			{anim8.newAnimation(table.range(stretchFrames,12,1),stretchDelays,nil,punkData.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.range(stretchFrames,24,13),stretchDelays,nil,punkData.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.range(stretchFrames,36,25),stretchDelays,nil,punkData.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.range(stretchFrames,24,13),stretchDelays,nil,punkData.sprites.image,true),vector.new(-1,0),vector.new(.5,.8)}, --left
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
			{anim8.newAnimation(image_utils.load_images_from_directory("Resources/graphics/Platypunk/Held",true,image_utils.compare,3,4),.18,nil),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(image_utils.load_images_from_directory("Resources/graphics/Platypunk/Held",true,image_utils.compare,1,2),.18,nil),vector.new(1,0),vector.new(.6,.5)}, --right
			{anim8.newAnimation(image_utils.load_images_from_directory("Resources/graphics/Platypunk/Held",true,image_utils.compare,5,6),.18,nil),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(image_utils.load_images_from_directory("Resources/graphics/Platypunk/Held",true,image_utils.compare,1,2),.18,nil,nil,true),vector.new(-1,0),vector.new(.6,.5)}, --left
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
			{anim8.newAnimation(image_utils.load_images_from_directory("Resources/graphics/Platypunk/Hurt",true,image_utils.compare,2,2),.18,nil),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(image_utils.load_images_from_directory("Resources/graphics/Platypunk/Hurt",true,image_utils.compare,1,1),.18,nil,nil,true),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(image_utils.load_images_from_directory("Resources/graphics/Platypunk/Hurt",true,image_utils.compare,3,3),.18,nil),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(image_utils.load_images_from_directory("Resources/graphics/Platypunk/Hurt",true,image_utils.compare,1,1),.18,nil),vector.new(-1,0),vector.new(.5,.8)}, --left
			},
			vector.new(0,0),
			"hurt",
			punkData,
			function() end,
			nil,
			true
		),
	}
	
	punkData.move_vector=vector.new(0,0)
	punkData.current_tree=current_tree
	punkData.statemachine=require("Resources.lib.Rocket_Engine.State Machine.StateMachine").new(punkData)
	--This contains the Platypunks states. It stores the actual state module + a table of the states that can't transition to it
	punkData.states={
		["Idle"]={punkData.statemachine:add_state(require("Resources.states.Platypunk.Idle")),{}},
		["Walk"]={punkData.statemachine:add_state(require("Resources.states.Platypunk.Walk")),{}},
		["Stretch"]={punkData.statemachine:add_state(require("Resources.states.Platypunk.Stretch")),{}},
		["Held"]={punkData.statemachine:add_state(require("Resources.states.Held")),{}},
		["Hurt"]={punkData.statemachine:add_state(require("Resources.states.Hurt")),{}}
	}
	punkData.map=nil
	punkData.statemachine:change_state("Idle")
	punkData.speed=32;
	punkData.scale=vector.new(1,1)
	punkData.image=love.graphics.newImage("Resources/graphics/Platypunk/Idle/1.png")
	punkData.current_path={}
    punkData.walkDest=0 -- refers to index in current_path
	punkData.sprite.position=vector.new(400,400)
	punkData.rotation=0
	return punkData
end

function Platypunk:load_tree(animation_name,keep_vector,frame,pause_at_start)
	local oldVector=(keep_vector and self.current_tree~=nil) and self.current_tree.vector or vector.new(0,0)
	self.animations[animation_name].vector=oldVector; --set vector to old vector before we load the animation
	self.current_tree=self.animations[animation_name]
	if(frame and pause_at_start) then
		self.current_tree.current_animation:setPaused(true)
		self.current_tree.current_animation:setFrame(frame)
	end
	if(self.current_tree.current_animation:getLooping()) then
		--Gives better looping result on looping animations
		self.current_tree.current_animation:setFrame(#self.current_tree.current_animation.frames)
	else
		--!print("Setting animation active again")
		self.current_tree.current_animation:setActive(true)
		self.current_tree.current_animation:setPaused(false)
		self.current_tree.current_animation:setFrame(1)
	end
	
end

function Platypunk:draw()
	self.sprite:draw()
	if(self.current_tree.current_animation:isActive()) then
		local offset=vector.new(
			self.current_tree.current_animation:getWidth()*self.current_tree.frame_offset.x,
			self.current_tree.current_animation:getHeight()*self.current_tree.frame_offset.y
		):round()
		self.current_tree.current_animation:draw(
			math.round(self.sprite.position.x),
			math.round(self.sprite.position.y),
			self.rotation,
			self.scale.x,
			self.scale.y,
			offset.x,
			offset.y
		)
	end
	if(debug_mode) then
		if(self.current_path~=nil and #self.current_path>0) then
			for i = 1, #self.current_path do
				love.graphics.setColor(0,0,0)
				love.graphics.print(i,self.current_path[i].x,self.current_path[i].y)
			end
			for i = 1, #self.current_path-1 do
				love.graphics.setColor(0,255,0)
				love.graphics.line(self.current_path[i].x,self.current_path[i].y,self.current_path[i+1].x,self.current_path[i+1].y)
			end
			love.graphics.setColor(255,255,255)
		end
	end
end

function Platypunk:change_state(new_state)
	local current_state=self.statemachine.current_state.Name
	if(new_state==current_state)then
		--!print("Can't switch to new state because it's already the current state")
		return
	end
	if(table.index_of(self.states[new_state][2],current_state))then
		--!print("Can't switch to new state because the current state is not allowed to switch to it ("..current_state.." to "..newState..")")
		return
	end
	self.statemachine:change_state(new_state)
end

function Platypunk:update(dt)
	self.statemachine:update(dt)
	self.current_tree:update(dt)
	self.sprite:update(dt,nil)
	if(self.sprite.physics_data.in_air==true and self.statemachine.current_state.Name~="Hurt") then
		self:change_state("Hurt")
	end
end


return Platypunk