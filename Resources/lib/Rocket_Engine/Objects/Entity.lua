class = require 'Resources.lib.Rocket_Engine.Systems.middleclass'

local entity=class("Entity")
local vector3 = require("Resources.lib.brinevector3D")

function entity:initialize(start_pos,collider_pos,collider_size)
    print(collider_size)
    --Base amount of data needed for an entity
    self.position=vector3(0,0,0)
    if(start_pos and start_pos.isVector) then
        self.position=start_pos -- The Y component is used to offset the sprite from it's origin to add a feeling of depth/a third dimension
    elseif not start_pos then
        self.position=vector3(0,0,0)
    elseif not start_pos.isVector and vector.isvector(start_pos) then
        print(start_pos)
        self.position=vector3(start_pos.x,0,start_pos.y)
    end
    --"Traditional" 2D coordinates for the player
    self.planar_position=vector.new(0,0) 
    self.picked_up=false
    self.physics_data={
        bounciness=0.9,
        velocity=vector3(0,0,0),
        starting_velocity=vector3(0,0,0),
        collider=collider_world:rectangle(collider_pos.x,collider_pos.y,collider_size.x,collider_size.y),
        collider_offset=collider_pos,
        max_bounces=3,
        bounces_left=3,
        in_air=false
    }
    self.physics_data.collider.flags={
        bouncy=false;
        canCollide=false;
        trigger=false;
        
    }
    print()
    self.z_value=0
end

--Set the position of the player from a planar (2D) vector
function entity:set_position_planar(planar_postion)
    self.position.x=planar_postion.x
    self.position.z=planar_postion.y
end

function entity:handle_collision(dt)
    for shape, delta in pairs(collider_world:collisions(self.physics_data.collider)) do            
        if(not shape.flags or shape.flags.canCollide==false) then
            return
        end
        if(shape.flags and shape.flags.trigger) then
            shape.flags.trigger_function(shape,self)
            return
        end
        self:set_position_planar(vector.new(self.position.x + delta.x,self.position.z + delta.y))
    end
end

function entity:add_force(force)
    if(self.physics_data.in_air)then
        return;
    end
    self.physics_data.in_air = true;

    if(type(force)~="number" and force.isVector) then
        self.physics_data.velocity=force
        self.physics_data.starting_velocity=force
    else
        self.physics_data.velocity.y=force
        self.physics_data.starting_velocity.y=force
    end
    
    self.physics_data.bounces_left=self.physics_data.max_bounces
end
function entity:update(dt)
    
    self:handle_collision(dt)
    --Update planar positions. I update the components of the vector directly to avoid having to use vector.new and creatin a new vector every frame.
    self.planar_position.x=self.position.x
    self.planar_position.y=self.position.z
    self.physics_data.collider:moveTo(
        self.planar_position.x+self.physics_data.collider_offset.x,
        self.planar_position.y+self.physics_data.collider_offset.y
    )
    self.z_value=self.position.z+self.position.y
    --#region Bounce physics
    if(self.physics_data.in_air and (self.physics_data.bounces_left > 0 and self.physics_data.velocity.y ~= 0)) then
        self.physics_data.velocity = self.physics_data.velocity + vector3(0, -9.81, 0) * dt;
        self.position = self.position + vector3(self.physics_data.velocity.x*dt,self.physics_data.velocity.y,self.physics_data.velocity.z*dt);
        if ((self.position).y <= 0) then
            
            --we hit the ground
            self.physics_data.velocity.y = -self.physics_data.velocity.y * self.physics_data.bounciness;
            self.physics_data.velocity.x = self.physics_data.velocity.x - (self.physics_data.starting_velocity.x / self.physics_data.max_bounces)
            self.physics_data.velocity.z = self.physics_data.velocity.z - (self.physics_data.starting_velocity.z / self.physics_data.max_bounces)

            self.physics_data.bounces_left = self.physics_data.bounces_left - 1;
        end
    else
        if(self.going_into_cannon) then
            table.remove_value(actors,self.parent)
            return
        end
        if(self.physics_data.in_air) then
            self.physics_data.in_air=false
        end
        self.physics_data.velocity=vector3(0,0,0)
        if(not self.going_into_cannon and self.position.y~=0) then
            self.position.y=0
        end
    end
    --#endregion
end


return entity