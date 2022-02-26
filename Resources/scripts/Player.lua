--Player controller script. This contains animation handling and state handling. Due to the complex nature of this character controller, a state machine is used to handle different stuff such as walking, idling, jumping, etc.
local RTA=require("Resources.lib.RTA")
local entity=require("Resources.lib.Rocket_Engine.Objects.Entity")
local image_utils=require("Resources.lib.Rocket_Engine.Utils.ImageUtils")
local blendtree=require("Resources.lib.Rocket_Engine.Animation.blendtree")
local anim8=require("Resources.lib.anim8")
local class = require 'Resources.lib.Rocket_Engine.Systems.middleclass'
local entity=require("Resources.lib.Rocket_Engine.Objects.Entity")
local Player=class("Player",entity)
player=Player
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

function Player:initialize(start_pos,collider_pos,collider_size)
	entity.initialize(self,start_pos,collider_pos,collider_size)
	
	self.sprites=RTA.newDynamicSize()
	self.sprites:setFilter("nearest")
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
		['fullcharge']=image_utils.load_images_from_directory("Resources/graphics/Rocket/ChargedBlastFrames",true,image_utils.compare,1,54),
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
		"charge",
		"fullcharge"
	}
	self.sprites:setBakeAsPow2(false)
	for _, prefix in pairs(prefixes) do
		for i, sprite in ipairs(sprites[prefix]) do
			self.sprites:add(sprite,prefix..tostring(i))
		end
	end
	
	self.sprites:hardBake("width")
	prefixes=nil
	sprites=nil;
	collectgarbage("collect")

	--List of all animations. Blendtree is a module that lets me "blend" between multiple directional animations based on a vector
	self.animations={
		['idle']=
		blendtree.new(
			{
			{anim8.newAnimation(table.reverse(get_sprite_quads("idle",1,8,self.sprites)),.06,nil,self.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.reverse(get_sprite_quads("idle",9,16,self.sprites)),.06,nil,self.sprites.image),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(table.reverse(get_sprite_quads("idle",17,24,self.sprites)),.06,nil,self.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.reverse(get_sprite_quads("idle",25,32,self.sprites)),.06,nil,self.sprites.image),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(table.reverse(get_sprite_quads("idle",33,40,self.sprites)),.06,nil,self.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.reverse(get_sprite_quads("idle",41,48,self.sprites)),.06,nil,self.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(table.reverse(get_sprite_quads("idle",49,56,self.sprites)),.06,nil,self.sprites.image),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(table.reverse(get_sprite_quads("idle",57,64,self.sprites)),.06,nil,self.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
			},
			vector.new(0,0),
			"idle",
			self,
			nil,
			nil,
			true
		),
		['throw']=
		blendtree.new({
			{anim8.newAnimation(table.reverse(get_sprite_quads("throw",1,8,self.sprites)),.06,nil,self.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.reverse(get_sprite_quads("throw",9,16,self.sprites)),.06,nil,self.sprites.image),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(table.reverse(get_sprite_quads("throw",17,24,self.sprites)),.06,nil,self.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.reverse(get_sprite_quads("throw",25,32,self.sprites)),.06,nil,self.sprites.image),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(table.reverse(get_sprite_quads("throw",33,40,self.sprites)),.06,nil,self.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.reverse(get_sprite_quads("throw",41,48,self.sprites)),.06,nil,self.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(table.reverse(get_sprite_quads("throw",49,56,self.sprites)),.06,nil,self.sprites.image),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(table.reverse(get_sprite_quads("throw",57,64,self.sprites)),.06,nil,self.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
			},
			vector.new(0,0),
			"throw",
			self,
			nil,
			nil,
			false
		),
		['walk']=
		blendtree.new({
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",1,11,self.sprites)), {0.04,0.04,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.06},nil,self.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",12,22,self.sprites)),{0.04,0.04,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.06},nil,self.sprites.image,true),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",23,33,self.sprites)),{0.04,0.04,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.06},nil,self.sprites.image,true),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",34,44,self.sprites)),{0.04,0.04,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.06},nil,self.sprites.image,true),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",45,55,self.sprites)),{0.04,0.04,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.06},nil,self.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",34,44,self.sprites)),{0.04,0.04,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.06},nil,self.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",23,33,self.sprites)),{0.04,0.04,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.06},nil,self.sprites.image),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(table.reverse(get_sprite_quads("walk",12,22,self.sprites)),{0.04,0.04,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.06},nil,self.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
			},
			vector.new(0,0),
			"walk",
			self,
			function() self.sprite:add_force(1) end,
			nil,
			true
		),
		['jump']=
		blendtree.new({
			--Not entirely sure why, but some of the tables are loaded in reverse which is strange. I just use table.reverse (from the tablex module) to reverse it again.
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",1,10,self.sprites)),.03,nil,self.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",11,20,self.sprites)),.03,nil,self.sprites.image),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",21,30,self.sprites)),.03,nil,self.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",31,40,self.sprites)),.03,nil,self.sprites.image),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",41,50,self.sprites)),.03,nil,self.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",51,60,self.sprites)),.03,nil,self.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",61,70,self.sprites)),.03,nil,self.sprites.image),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",71,80,self.sprites)),.03,nil,self.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
			},
			vector.new(0,0),
			"jump",
			self,
			nil,
			function() end,
			true
		),
		['blasting']=
		blendtree.new({
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",1,10,self.sprites)),.03,nil,self.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",11,20,self.sprites)),.03,nil,self.sprites.image),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",21,30,self.sprites)),.03,nil,self.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",31,40,self.sprites)),.03,nil,self.sprites.image),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",41,50,self.sprites)),.03,nil,self.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",51,60,self.sprites)),.03,nil,self.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",61,70,self.sprites)),.03,nil,self.sprites.image),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(table.reverse(get_sprite_quads("jump",71,80,self.sprites)),.03,nil,self.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
			},
			vector.new(0,0),
			"blasting",
			self,
			nil,
			function() end,
			true
		),
		
		['squish']=
		blendtree.new({
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",1,5,self.sprites)),.05,nil,self.sprites.image) ,vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",6,10,self.sprites)),.05,nil,self.sprites.image),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",11,15,self.sprites)),.05,nil,self.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",16,20,self.sprites)),.05,nil,self.sprites.image),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",21,25,self.sprites)),.05,nil,self.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",26,30,self.sprites)),.05,nil,self.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",31,35,self.sprites)),.05,nil,self.sprites.image),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",36,40,self.sprites)),.05,nil,self.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
			},
			vector.new(0,0),
			"squish",
			self,
			nil,
			function() end,
			false
		),
		['squished']=
		blendtree.new({
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",5,5,self.sprites)),.05,nil,self.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",10,10,self.sprites)),.05,nil,self.sprites.image),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",15,15,self.sprites)),.05,nil,self.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",20,20,self.sprites)),.05,nil,self.sprites.image),vector.new(.5,.7),vector.new(.5,.8)}, --downright
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",25,25,self.sprites)),.05,nil,self.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",30,30,self.sprites)),.05,nil,self.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",35,35,self.sprites)),.05,nil,self.sprites.image),vector.new(-1,0),vector.new(.5,.8)}, --left
			{anim8.newAnimation(table.reverse(get_sprite_quads("squish",40,40,self.sprites)),.05,nil,self.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
			},
			vector.new(0,0),
			"squished",
			self,
			nil,
			function() end,
			false
		),
		['stretch']=
		blendtree.new(
			{
				{anim8.newAnimation(table.reverse(get_sprite_quads("stretch",1,1,self.sprites)),0,nil,self.sprites.image),vector.new(0,-1),vector.new(.5,.9)}, --up
				{anim8.newAnimation(table.reverse(get_sprite_quads("stretch",1,1,self.sprites)),0,nil,self.sprites.image),vector.new(.5,-.5),vector.new(.5,.9)}, --upright
				{anim8.newAnimation(table.reverse(get_sprite_quads("stretch",2,2,self.sprites)),0,nil,self.sprites.image),vector.new(1,0),vector.new(.7,.9)}, --right
				{anim8.newAnimation(table.reverse(get_sprite_quads("stretch",3,3,self.sprites)),0,nil,self.sprites.image),vector.new(.5,.5),vector.new(.5,.9)}, --downright
				{anim8.newAnimation(table.reverse(get_sprite_quads("stretch",3,3,self.sprites)),0,nil,self.sprites.image),vector.new(0,1),vector.new(.5,.9)}, --down
				{anim8.newAnimation(table.reverse(get_sprite_quads("stretch",3,3,self.sprites)),0,nil,self.sprites.image),vector.new(-.5,.5),vector.new(.5,.9)}, --downleft
				{anim8.newAnimation(table.reverse(get_sprite_quads("stretch",4,4,self.sprites)),0,nil,self.sprites.image),vector.new(-1,0),vector.new(0.3,.9)}, --left
				{anim8.newAnimation(table.reverse(get_sprite_quads("stretch",1,1,self.sprites)),0,nil,self.sprites.image),vector.new(-.5,-.5),vector.new(.5,.9)}, --upleft
			},
			vector.new(0,0),
			"stretch",
			self,
			nil,
			function() end,
			false
		),
		['wallhit']=
		blendtree.new(
			{
				{anim8.newAnimation(table.reverse(get_sprite_quads("wallhit",1,4,self.sprites)),.1,nil,self.sprites.image),vector.new(0,-1),vector.new(.5,0)}, --up
				{anim8.newAnimation(table.reverse(get_sprite_quads("wallhit",5,8,self.sprites)),.1,nil,self.sprites.image),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
				{anim8.newAnimation(table.reverse(get_sprite_quads("wallhit",9,12,self.sprites)),.1,nil,self.sprites.image),vector.new(1,0),vector.new(1,.8)}, --right
				{anim8.newAnimation(table.reverse(get_sprite_quads("wallhit",13,16,self.sprites)),.1,nil,self.sprites.image),vector.new(.5,.7),vector.new(.5,.8)}, --downright
				{anim8.newAnimation(table.reverse(get_sprite_quads("wallhit",17,20,self.sprites)),.1,nil,self.sprites.image),vector.new(0,1),vector.new(.5,1)}, -- down
				{anim8.newAnimation(table.reverse(get_sprite_quads("wallhit",21,24,self.sprites)),.1,nil,self.sprites.image),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
				{anim8.newAnimation(table.reverse(get_sprite_quads("wallhit",25,28,self.sprites)),.1,nil,self.sprites.image),vector.new(-1,0),vector.new(0,.8)}, --left
				{anim8.newAnimation(table.reverse(get_sprite_quads("wallhit",29,32,self.sprites)),.1,nil,self.sprites.image),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
				},
			vector.new(0,0),
			"wallhit",
			self,
			nil,
			function() end,
			false
		),
		['float']=
		blendtree.new(
			{
				{anim8.newAnimation(table.reverse(get_sprite_quads("float",1,3,self.sprites)),.1,nil,self.sprites.image),vector.new(0,-1),vector.new(.5,.8)}, --up
				{anim8.newAnimation(table.reverse(get_sprite_quads("float",4,6,self.sprites)),.1,nil,self.sprites.image),vector.new(.5,-.5),vector.new(.5,.8)}, --upright
				{anim8.newAnimation(table.reverse(get_sprite_quads("float",7,9,self.sprites)),.1,nil,self.sprites.image),vector.new(1,0),vector.new(.5,.8)}, --right
				{anim8.newAnimation(table.reverse(get_sprite_quads("float",10,12,self.sprites)),.1,nil,self.sprites.image),vector.new(.5,.7),vector.new(.5,.8)}, --downright
				{anim8.newAnimation(table.reverse(get_sprite_quads("float",13,15,self.sprites)),.1,nil,self.sprites.image),vector.new(0,1),vector.new(.5,.8)}, -- down
				{anim8.newAnimation(table.reverse(get_sprite_quads("float",10,12,self.sprites)),.1,nil,self.sprites.image,true),vector.new(-.5,.7),vector.new(.5,.8)}, --downleft
				{anim8.newAnimation(table.reverse(get_sprite_quads("float",7,9,self.sprites)),.1,nil,self.sprites.image,true),vector.new(-1,0),vector.new(.5,.8)}, --left
				{anim8.newAnimation(table.reverse(get_sprite_quads("float",4,6,self.sprites)),.1,nil,self.sprites.image,true),vector.new(-.5,-.5),vector.new(.5,.8)}, --upleft
				},
			vector.new(0,0),
			"float",
			self,
			nil,
			function() end,
			true
		),
		['elastoblast']=
		blendtree.new(
			{
				{anim8.newAnimation(table.reverse(get_sprite_quads("charge",1,3,self.sprites)),0,nil,self.sprites.image),vector.new(0,-1),vector.new(.5,.9)}, --up
				{anim8.newAnimation(table.reverse(get_sprite_quads("charge",1,3,self.sprites)),0,nil,self.sprites.image),vector.new(.5,-.5),vector.new(.5,.9)}, --upright
				{anim8.newAnimation(table.reverse(get_sprite_quads("charge",1,3,self.sprites)),0,nil,self.sprites.image),vector.new(1,0),vector.new(.7,.9)}, --right
				{anim8.newAnimation(table.reverse(get_sprite_quads("charge",1,3,self.sprites)),0,nil,self.sprites.image),vector.new(.5,.5),vector.new(.5,.9)}, --downright
				{anim8.newAnimation(table.reverse(get_sprite_quads("charge",1,3,self.sprites)),0,nil,self.sprites.image),vector.new(0,1),vector.new(.5,.9)}, --down
				{anim8.newAnimation(table.reverse(get_sprite_quads("charge",1,3,self.sprites)),0,nil,self.sprites.image),vector.new(-.5,.5),vector.new(.5,.9)}, --downleft
				{anim8.newAnimation(table.reverse(get_sprite_quads("charge",1,3,self.sprites)),0,nil,self.sprites.image),vector.new(-1,0),vector.new(0.3,.9)}, --left
				{anim8.newAnimation(table.reverse(get_sprite_quads("charge",1,3,self.sprites)),0,nil,self.sprites.image),vector.new(-.5,-.5),vector.new(.5,.9)}, --upleft
			},
			vector.new(0,0),
			"elastoblast",
			self,
			nil,
			function() end,
			true
		),
		['fullblast']=
		blendtree.new(
			{
				{anim8.newAnimation(table.reverse(get_sprite_quads("fullcharge",46,54,self.sprites)),0.016,nil,self.sprites.image),vector.new(0,-1),vector.new(.5,.9)}, --up
				{anim8.newAnimation(table.reverse(get_sprite_quads("fullcharge",19,27,self.sprites)),0.016,nil,self.sprites.image),vector.new(.5,-.5),vector.new(.5,.9)}, --upright
				{anim8.newAnimation(table.reverse(get_sprite_quads("fullcharge",37,45,self.sprites)),0.016,nil,self.sprites.image,true),vector.new(1,0),vector.new(.7,.9)}, --right
				{anim8.newAnimation(table.reverse(get_sprite_quads("fullcharge",10,18,self.sprites)),0.016,nil,self.sprites.image),vector.new(.5,.5),vector.new(.5,.9)}, --downright
				{anim8.newAnimation(table.reverse(get_sprite_quads("fullcharge",28,36,self.sprites)),0.016,nil,self.sprites.image),vector.new(0,1),vector.new(.5,.9)}, --down
				{anim8.newAnimation(table.reverse(get_sprite_quads("fullcharge",10,18,self.sprites)),0.016,nil,self.sprites.image,true),vector.new(-.5,.5),vector.new(.5,.9)}, --downleft
				{anim8.newAnimation(table.reverse(get_sprite_quads("fullcharge",37,45,self.sprites)),0.016,nil,self.sprites.image),vector.new(-1,0),vector.new(0.3,.9)}, --left
				{anim8.newAnimation(table.reverse(get_sprite_quads("fullcharge",19,27,self.sprites)),0.016,nil,self.sprites.image,true),vector.new(-.5,-.5),vector.new(.5,.9)}, --upleft
			},
			vector.new(0,0),
			"elastoblast",
			self,
			nil,
			function() end,
			true
		)
	}
	
	self.move_vector=vector.new(0,0)
	self.current_tree=current_tree
	self.statemachine=require("Resources.lib.Rocket_Engine.State Machine.StateMachine").new(self.static)
	--This contains the players states. It stores the actual state module + a table of the states that can't transition to it
	self.states={
		["Idle"]={self.statemachine:add_state(require("Resources.states.Rocket.Idle")),{}},
		["Walk"]={self.statemachine:add_state(require("Resources.states.Rocket.Walk")),{}},
		["Jump"]={self.statemachine:add_state(require("Resources.states.Rocket.Jump")),{"Blasting","Stretch","WallHit","Elastoblast"}}, -- Blasting, Stretch and WallHit cannot transition into the jump state.
		["Squish"]={self.statemachine:add_state(require("Resources.states.Rocket.Squish")),{"Jump","Stretch","Squished","Blasting","WallHit","Elastoblast"}},
		["Stretch"]={self.statemachine:add_state(require("Resources.states.Rocket.Stretch")),{}},
		["Squished"]={self.statemachine:add_state(require("Resources.states.Rocket.Squished")),{}},
		["Blasting"]={self.statemachine:add_state(require("Resources.states.Rocket.Blasting")),{}},
		["WallHit"]={self.statemachine:add_state(require("Resources.states.Rocket.WallHit")),{"Throw"}},
		["Throw"]={self.statemachine:add_state(require("Resources.states.Rocket.Throw")),{"WallHit"}},
		["Float"]={self.statemachine:add_state(require("Resources.states.Rocket.Float")),{""}},
	}
	self.statemachine:change_state("Idle")
	self.speed=96;
	self.holding={}
	self.scale=vector.new(1,1)
	self.wall_hit_normal=vector.new(0,0)
	self.blast_velocity=vector.new(0,0)
	self.can_throw=true;
	self.can_float=true;
	self.map=nil
	self.super_throw=false;
	self.inside_bouncy=false;
	self.name="Player"
	self.physics_data.collider.name="Player_Collider"
	self.hit_wall=false;
	self.full_charge_elastoblast=false;
	self.wall_hit_debounce=false --Sometimes player can get stuck in an infinite loop of collision. Adding a debounce fixes this.
	--Players input. ToDo: Major refactor of entire input system.
	self.input=control_scheme
	--Head collider is for making sure player can't stretch their body through colliders.
	self.head_collider=collider_world:circle(-100,-100,5)
	self.head_position=vector.new(0,0)
	self.input_state=nil
	self.rotation=0
	self.physics_data.max_bounces=1
	self.physics_data.bounces_left=1
	self.last_hit_pos=vector.new(0,0)
	self.actor_collision_debounce=false
	--Ugly, but it's easier than trying to figure out the maths. A hardcoded lookup table that returns the correct vector for a wallhit
	return self
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
	if(debug_mode) then
		love.graphics.setColor(0,1,0,.5)
		self.physics_data.collider:draw("fill")
	end
	love.graphics.setColor(1,1,1,1)
	if(self.current_tree.current_animation:isActive()) then
		local offset=vector.new(
			self.current_tree.current_animation:getWidth()*self.current_tree.frame_offset.x,
			self.current_tree.current_animation:getHeight()*self.current_tree.frame_offset.y
		):round()
		self.current_tree.current_animation:draw(
			math.floor(self.planar_position.x),
			math.floor(self.planar_position.y)-math.floor(self.position.y),
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

function Player:handle_collision(dt)
	for shape, delta in pairs(collider_world:collisions(self.physics_data.collider)) do
		if(delta==nil or delta.x==nil or delta.y==nil) then
			return
		end
		local absoluteDelta=vector.new(math.abs(delta.x),math.abs(delta.y))
		local m_vector=self.move_vector
		local fixedDelta=vector.new(delta.x,delta.y)-(m_vector*self.speed):normalized()
		if(self.map~=nil) then
			for i, actor in pairs(self.map.actors) do
				if(actor.physics_data.collider==shape and not actor.picked_up) then
					if(actor.physics_data.in_air and actor.can_pickup and #self.holding<3)then
						local heightDifference=actor.position.y - self.position.y
						if(heightDifference < 20) then
							actor.physics_data.in_air=false
							--Picking up
							actor.picked_up=true;
							actor.z_value=10000*(#self.holding+1)
							table.insert(self.holding,{self.map.actors[i],vector3(0,0,0)})
							startPos=actor.planar_position
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
			self:set_position_planar(vector.new(self.position.x+delta.x,self.position.z+delta.y))
			if(self.statemachine.current_state.Name=="Blasting")then
				--[[Sometimes when we hit a wall while bouncing, delta returns as 0,0 which it shouldn't. 
					We need to wait until it gives us something we can work with]]
				if(not self.wall_hit_debounce and not(vector.new(delta.x,delta.y)==vector.new(0,0))) then
					if(self.last_hit_pos.dist(self.planar_position,self.last_hit_pos)<=5) then
						print("Too close to last hit point")
						return
					end
					local normal = vector.new(
						delta.x,
						delta.y
					):normalized():round()
					self:set_position_planar(vector.new(self.position.x+normal.x,self.position.z+normal.y*2))
					local wall_angle=math.deg(math.atan2(normal.y,normal.x))
					local blast_angle=math.deg(math.atan2(self.blast_velocity.y,self.blast_velocity.x))
					local absolute_difference=math.abs(math.abs(wall_angle)-math.abs(blast_angle))
					print("Wall angle:",wall_angle,"Hit angle (angle we hit it at):",blast_angle,"Absolute difference:",absolute_difference)		
					
					if(absolute_difference==135) then
						return
					end

					self.last_hit_pos=vector.new(self.planar_position.x,self.planar_position.y)

					
					self.wall_hit_debounce=true;
					self.wall_hit_normal=normal
					self:change_state("WallHit")
					self.current_tree:set_vector(vector.Reflect(self.blast_velocity,self.wall_hit_normal))
					timer.after(.025,function()
						self.wall_hit_debounce=false;
					end)
				end
			end
		end
	end
end

function Player:update(dt)
	self.inside_bouncy=false
	entity.update(self,dt)
	self.current_tree:update(dt)
	self.input_state = input_provider:get_current_input_state()
	self.statemachine:update(dt)
	if(self.input_state.move_vector~=vector.new(0,0)) then
		self.move_vector=self.input_state.move_vector
	else
		self.move_vector=vector.new(0,0)
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



	for i, held in pairs(self.holding) do
		if(held~=nil) then
			local posDiff=vector.new(self.position.x,(self.position.z-self.position.y))
			local offset=vector.new(held[1].hold_offset.x,(held[1].hold_offset.y-(16*i)))
			local endPoint= self.statemachine.current_state.Name=="Stretch" and (self.head_position)+offset or posDiff+offset
			local heldSprite=held[1]
			-- local heldVelocity=held[2]
			-- heldVelocity.x=math.lerp(held[1].position.x,(endPoint.x),.1*dt);
			-- heldVelocity.z=math.lerp(held[1].position.z,(endPoint.y),.1*dt);
			held[1].position.z=held[1].position.z+(endPoint.y-held[1].position.z)*.5/i;
			held[1].position.x=held[1].position.x+(endPoint.x-held[1].position.x)*.5/i;
			
			if(held[1].name=="NPC") then
				held[1].move_vector=self.move_vector
			end
		end
	end
	

	self.inside_bouncy=false
	-- if(self.statemachine.current_state.Name~="Stretch") then
	-- 	self.head_position=self.planar_position
	-- end
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