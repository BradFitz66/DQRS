--Player controller script. This contains animation handling and state handling. Due to the complex nature of this character controller, a state machine is used to handle different stuff such as walking, idling, jumping, etc.
Player={}
Player.__index=Player
local RTA=require("Resources.lib.RTA")
local entity=require("Resources.lib.Rocket_Engine.Objects.Entity")
local image_utils=require("Resources.lib.Rocket_Engine.Utils.ImageUtils")
local blendtree=require("Resources.lib.Rocket_Engine.Animation.blendtree")
local anim8=require("Resources.lib.anim8")

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

function Player.load()
	local pData=setmetatable({},Player)
	pData.sprite=entity.new(0,1,12,12)
	pData.sprite.name="Player"
	pData.sprite.parent=pData;
	pData.sprite.bounciness=0;
	pData.sprite.max_bounces=1;
	pData.sprites=RTA.newDynamicSize()
	pData.sprites:setFilter("nearest")
	local sprites={
		['idle']=image_utils.load_images_from_directory("Resources/graphics/Rocket/IdleFrames",true,image_utils.compare,1,64),
		['walk']=image_utils.load_images_from_directory("Resources/graphics/Rocket/WalkFrames",true,image_utils.compare,1,55),
		['throw']=image_utils.load_images_from_directory("Resources/graphics/Rocket/ThrowFrames",true,image_utils.compare,1,64),
		['jump']=image_utils.load_images_from_directory("Resources/graphics/Rocket/JumpFrames",true,image_utils.compare,1,80),
		['squish']=image_utils.load_images_from_directory("Resources/graphics/Rocket/SquishFrames",true,image_utils.compare,1,40),
		['stretch']=image_utils.load_images_from_directory("Resources/graphics/Rocket/StretchFrames",true,image_utils.compare,1,4),
		['wallhit']=image_utils.load_images_from_directory("Resources/graphics/Rocket/WallHitFrames",true,image_utils.compare,1,32),
		['float']=image_utils.load_images_from_directory("Resources/graphics/Rocket/FloatFrames",true,image_utils.compare,1,15),
		['charge']=image_utils.load_images_from_directory("Resources/graphics/Rocket/ChargeFrames",true,image_utils.compare,1,15),
	}
	local prefixes={
		"idle",
		"walk",
		"throw",
		"jump",
		"squish",
		"stretch",
		"wallhit",
		"float",
		"charge"
	}
	pData.sprites:setBakeAsPow2(false)
	for _, prefix in pairs(prefixes) do
		for i, sprite in ipairs(sprites[prefix]) do
			pData.sprites:add(sprite,prefix..tostring(i))
		end
	end
	
	pData.sprites:hardBake("width")
	prefixes=nil
	sprites=nil;
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
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",1,11,pData.sprites)), {0.04,0.04,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.06},nil,pData.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",12,22,pData.sprites)),{0.04,0.04,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.06},nil,pData.sprites.image,true),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",23,33,pData.sprites)),{0.04,0.04,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.06},nil,pData.sprites.image,true),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",34,44,pData.sprites)),{0.04,0.04,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.06},nil,pData.sprites.image,true),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",45,55,pData.sprites)),{0.04,0.04,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.06},nil,pData.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",34,44,pData.sprites)),{0.04,0.04,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.06},nil,pData.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",23,33,pData.sprites)),{0.04,0.04,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.06},nil,pData.sprites.image),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",12,22,pData.sprites)),{0.04,0.04,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.06},nil,pData.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
			},
			vector.new(0,0),
			"walk",
			pData,
			function() pData.sprite:add_force(1) end,
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
		),
		['float']=
		blendtree.new(
			{
				{anim8.newAnimation(table.reverse(get_sprite_quads("float",1,3,pData.sprites)),.1,nil,pData.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
				{anim8.newAnimation(table.reverse(get_sprite_quads("float",4,6,pData.sprites)),.1,nil,pData.sprites.image),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
				{anim8.newAnimation(table.reverse(get_sprite_quads("float",7,9,pData.sprites)),.1,nil,pData.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
				{anim8.newAnimation(table.reverse(get_sprite_quads("float",10,12,pData.sprites)),.1,nil,pData.sprites.image),vector.new(.5,.7),vector.new(.5,.8)}, --downright
				{anim8.newAnimation(table.reverse(get_sprite_quads("float",13,15,pData.sprites)),.1,nil,pData.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
				{anim8.newAnimation(table.reverse(get_sprite_quads("float",10,12,pData.sprites)),.1,nil,pData.sprites.image,true),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
				{anim8.newAnimation(table.reverse(get_sprite_quads("float",7,9,pData.sprites)),.1,nil,pData.sprites.image,true),vector.new(-1,0),vector.new(.5,.8)}, --left
				{anim8.newAnimation(table.reverse(get_sprite_quads("float",4,6,pData.sprites)),.1,nil,pData.sprites.image,true),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
				},
			vector.new(0,0),
			"float",
			pData,
			nil,
			function() end,
			true
		),
		['elastoblast']=
		blendtree.new(
			{
				{anim8.newAnimation(table.reverse(get_sprite_quads("charge",1,3,pData.sprites)),0,nil,pData.sprites.image),vector.new(0,-1),vector.new(.5,.9)}, --up
				{anim8.newAnimation(table.reverse(get_sprite_quads("charge",1,3,pData.sprites)),0,nil,pData.sprites.image),vector.new(.5,-.5),vector.new(.5,.9)}, --upright
				{anim8.newAnimation(table.reverse(get_sprite_quads("charge",1,3,pData.sprites)),0,nil,pData.sprites.image),vector.new(1,0),vector.new(.7,.9)}, --right
				{anim8.newAnimation(table.reverse(get_sprite_quads("charge",1,3,pData.sprites)),0,nil,pData.sprites.image),vector.new(.5,.5),vector.new(.5,.9)}, --downright
				{anim8.newAnimation(table.reverse(get_sprite_quads("charge",1,3,pData.sprites)),0,nil,pData.sprites.image),vector.new(0,1),vector.new(.5,.9)}, --down
				{anim8.newAnimation(table.reverse(get_sprite_quads("charge",1,3,pData.sprites)),0,nil,pData.sprites.image),vector.new(-.5,.5),vector.new(.5,.9)}, --downleft
				{anim8.newAnimation(table.reverse(get_sprite_quads("charge",1,3,pData.sprites)),0,nil,pData.sprites.image),vector.new(-1,0),vector.new(0.3,.9)}, --left
				{anim8.newAnimation(table.reverse(get_sprite_quads("charge",1,3,pData.sprites)),0,nil,pData.sprites.image),vector.new(-.5,-.5),vector.new(.5,.9)}, --upleft
			},
			vector.new(0,0),
			"elastoblast",
			pData,
			nil,
			function() end,
			true
		)
	}
	
	pData.move_vector=vector.new(0,0)
	pData.current_tree=current_tree
	pData.statemachine=require("Resources.lib.Rocket_Engine.State Machine.StateMachine").new(pData)
	--This contains the players states. It stores the actual state module + a table of the states that can't transition to it
	pData.states={
		["Idle"]={pData.statemachine:add_state(require("Resources.states.Rocket.Idle")),{}},
		["Walk"]={pData.statemachine:add_state(require("Resources.states.Rocket.Walk")),{}},
		["Jump"]={pData.statemachine:add_state(require("Resources.states.Rocket.Jump")),{"Blasting","Stretch","WallHit","Elastoblast"}}, -- Blasting, Stretch and WallHit cannot transition into the jump state.
		["Squish"]={pData.statemachine:add_state(require("Resources.states.Rocket.Squish")),{"Jump","Stretch","Squished","Blasting","WallHit","Elastoblast"}},
		["Stretch"]={pData.statemachine:add_state(require("Resources.states.Rocket.Stretch")),{}},
		["Squished"]={pData.statemachine:add_state(require("Resources.states.Rocket.Squished")),{}},
		["Blasting"]={pData.statemachine:add_state(require("Resources.states.Rocket.Blasting")),{}},
		["WallHit"]={pData.statemachine:add_state(require("Resources.states.Rocket.WallHit")),{"Throw"}},
		["Throw"]={pData.statemachine:add_state(require("Resources.states.Rocket.Throw")),{"WallHit"}},
		["Float"]={pData.statemachine:add_state(require("Resources.states.Rocket.Float")),{""}},
	}
	pData.statemachine:change_state("Idle")
	pData.speed=96;
	pData.holding={}
	pData.scale=vector.new(1,1)
	pData.position=vector.new(200,200)
	pData.wall_hit_normal=vector.new(0,0)
	pData.blast_velocity=vector.new(0,0)
	pData.can_throw=true;
	pData.can_float=true;
	pData.super_throw=false;
	pData.inside_bouncy=false;
	pData.hit_wall=false;
	pData.full_charge_elastoblast=false;
	pData.wall_hit_debounce=false --Sometimes player can get stuck in an infinite loop of collision. Adding a debounce fixes this.
	--Players input. ToDo: Major refactor of entire input system.
	pData.input=control_scheme
	--Head collider is for making sure player can't stretch their body through colliders.
	pData.head_collider=collider_world:circle(-100,-100,5)
	pData.head_position=vector.new(0,0)
	pData.input_state=nil
	pData.rotation=0
	return pData
end



--Load a new blendtree.
function Player:load_tree(animationName,keepVector,frame,pausedAtStart)
	if(self.current_tree~=nil) then		
		if(keepVector) then
			self.animations[animationName]:set_vector(self.current_tree.vector); 
		end
	end
	self.current_tree=self.animations[animationName]
	if(frame and pausedAtStart) then
		self.current_tree.current_animation:setPaused(true)
		self.current_tree.current_animation:setFrame(frame)
	end
	self.current_tree.current_animation:setFrame(1)
	if(not self.current_tree.current_animation:getLooping()) then
		self.current_tree.current_animation:setActive(true)
		self.current_tree.current_animation:setPaused(false)
	end
end

--Draw the player
function Player:draw()
	self.sprite:draw()
	if(self.current_tree.current_animation:isActive()) then
		local offset=vector.new(
			self.current_tree.current_animation:getWidth()*self.current_tree.frame_offset.x,
			self.current_tree.current_animation:getHeight()*self.current_tree.frame_offset.y
		):round()
		self.current_tree.current_animation:draw(
			math.floor(self.sprite.position.x),
			math.floor(self.sprite.position.y),
			self.rotation,
			self.scale.x,
			self.scale.y,
			offset.x,
			offset.y
		)
	end
	if(debug_mode) then
		self.head_collider:draw("fill")
	end
end

function Player:change_state(new_state)
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


function Player:update(dt)
	self.input_state = input_provider:get_current_input_state()
	for i, held in pairs(self.holding) do
		if(held~=nil) then
			local posDiff=(self.position-self.sprite.local_position)
			local offset=vector.new(held[1].sprite.hold_offset.x,(held[1].sprite.hold_offset.y-(16*i)))
			local endPoint= self.statemachine.current_state.Name=="Stretch" and (self.head_position)+offset or posDiff+offset
			local heldSprite=held[1].sprite
			local heldVelocity=held[2]
			heldVelocity.x=math.lerp(held[1].position.x,(endPoint.x),.1*dt);
			heldVelocity.z=math.lerp(held[1].position.y,(endPoint.y),.1*dt);
			held[1].position.y=held[1].position.y+(endPoint.y-held[1].position.y)*.5/i;
			held[1].position.x=held[1].position.x+(endPoint.x-held[1].position.x)*.5/i;
			if(held[1].sprite.name=="NPC") then
				held[1].move_vector=self.move_vector
			end
		end
	end
	self.sprite:update(dt,function()
		for shape, delta in pairs(collider_world:collisions(self.sprite.collider)) do
			local absoluteDelta=vector.new(math.abs(delta.x),math.abs(delta.y))
			local m_vector=self.move_vector
			local fixedDelta=vector.new(delta.x,delta.y)-(m_vector*self.speed):normalized()
			for _, actor in pairs(actors) do
				if(actor.sprite.collider==shape and not actor.sprite.picked_up) then
					--Handle collision with actor while in the blasting state.
					if(self.statemachine.current_state.Name=="Blasting")then
						local normalizedBlast=self.blast_velocity:normalized()
						local initialVel = (vector3(self.blast_velocity.x,self.blast_velocity.y,0))
						initialVel.z=initialVel.y;
						initialVel.y=0;
						initialVel=initialVel+vector3(0,3,0)
						actor.sprite:add_force_xyz(initialVel)
					else
						if(actor.sprite.in_air and actor.sprite.can_pickup and #self.holding<3)then
							local heightDifference=actor.sprite.local_position.y - self.sprite.local_position.y
							if(heightDifference < 20) then
								actor.sprite.in_air=false
								--Picking up
								actor.sprite.picked_up=true;
								
								actor.sprite.z_value=10000*(#self.holding+1)
								table.insert(self.holding,{actor,vector3(0,0,0)})
								startPos=actor.sprite.local_position
								if(actor.sprite.name=="NPC") then
									actor:change_state("Held")
								end
								timer.script(function(wait)
									self:change_state("Squish")
									wait(.2)
									self:change_state("Idle")
								end)
							end
						end
					end
				end
			end
			--Handle collisions with the collider of the currently loaded map
			if(shape.flags~=nil and shape.flags.canCollide) then
				if(self.statemachine.current_state.Name=="Jump" or self.statemachine.current_state.Name=="Float") then
					if(shape.flags.bouncy) then
						self.inside_bouncy=true
						return
					end
				end
				self.position=self.position+vector.new(delta.x,delta.y)
				if(self.statemachine.current_state.Name=="Blasting")then
					--[[Sometimes when we hit a wall while bouncing, delta returns as 0,0 which it shouldn't. 
						We need to wait until it gives us something we can work with]]
					if(not self.wall_hit_debounce and not(vector.new(delta.x,delta.y)==vector.new(0,0))) then
						local normal = vector.new(
							delta.x+(self.blast_velocity.x*math.sign(delta.x)),
							delta.y+(self.blast_velocity.y*math.sign(delta.y))
						):normalized():round()

						self.wall_hit_debounce=true;
						self.wall_hit_normal=normal

						self:change_state("WallHit")
						self.hit_wall=true;
						timer.after(10,function()
							self.hit_wall=false;
						end)
						self.current_tree:set_vector(vector.Reflect(self.blast_velocity,self.wall_hit_normal))
						timer.after(.025,function()
							self.wall_hit_debounce=false;
						end)
					end
				end
			end
		end
	end)

	if(self.input_state.move_vector~=vector.new(0,0)) then
		self.move_vector=self.input_state.move_vector
	else
		self.move_vector=vector.new(0,0)
	end
	self.statemachine:update(dt)
	self.current_tree:update(dt)
	self.inside_bouncy=false
	if(self.statemachine.current_state.Name~="Stretch") then
		self.head_position=self.position
	end
	if(self.input_state.space_down) then
		if(self.statemachine.current_state.Name~="Jump" and self.statemachine.current_state.Name~="Float") then
			self:change_state("Squish")
		else
			if(self.can_float) then
				self:change_state("Float")
			end
		end
	end
	if(self.input_state.space_up) then
		self:change_state("Jump")
	end
	if(self.input_state.action_down) then
		if(#self.holding>0 and self.can_throw) then
			if(self.statemachine.current_state.Name~="Blasting" and self.statemachine.current_state.Name~="Float") then
				self:change_state("Throw")
			elseif self.statemachine.current_state.Name=="Blasting" or self.statemachine.current_state.Name=="Float" then
				--Hack to bypass the change state function so we can stay in the blasting state while throwing
				self.states["Throw"][1].Enter(self)
				timer.after(.5,function() self.states["Throw"][1].Exit(self) end)
			end
		end
	end
end


return Player