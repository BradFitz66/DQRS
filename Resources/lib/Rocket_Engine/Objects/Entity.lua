--Base module for entities (players, ammo, enemies, etc)
local Entity={}
local vector = require("Resources.lib.HUMP.vector")
local vector3 = require("Resources.lib.brinevector3D")

Entity.__index=Entity
---Create a new entity
---@param collider_position_x number
---@param collider_position_y number
---@param collider_width number
---@param collider_height number
---@return table
function Entity.new(collider_position_x,collider_position_y,collider_width,collider_height)
    local e=setmetatable({},Entity)
    e.position=vector.new(0,0)
    e.local_position=vector.new(0,0) --Position relative to the parent
    e.ground_pos=vector.new(0,0) --for keeping the relative ground position when the player is in the air
    e.velocity=vector3(0,0,0)
    e.starting_velocity=vector3(0,0,0)
    e.in_air=false -- is the entity in the air?
    e.bounciness=.7
    e.collider_size=(collider_width and collider_height) and vector.new(collider_width,collider_height) or vector.new(0,0)
    e.collider_pos=vector.new(collider_position_x or 0,collider_position_y or 0)
    e.collider=collider_world:rectangle(0,0,collider_width or 20,collider_height or 20)
    e.collider.attached_to=e
    e.max_bounces=0;
    e.bounces_left=0;
    e.parent=nil
    e.name=""
    e.z_value=0
    e.hold_offset=vector.new(0,0)
    e.picked_up=false;
    e.can_pickup=true;
    return e
end

function Entity:add_force(y)
    if(self.in_air)then
        return;
    end
    self.in_air = true;
    self.starting_velocity =vector3(0,y,0)
    self.velocity=vector3(0,y,0)
    self.bounces_left=self.max_bounces
end

function Entity:add_force_xyz(vec)
    if(self.in_air)then
        return;
    end
    self.in_air = true;
    self.starting_velocity=vec
    self.velocity=vec
    self.bounces_left=self.max_bounces
end

function math.Clamp(val, lower, upper)
    assert(val and lower and upper, "not very useful error message here")
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function Entity:draw()
    if(debug_mode) then
        love.graphics.setColor(0,255,0)
        self.collider:draw("line")
        love.graphics.setColor(255,255,255)
    end
end



function Entity:update(dt,collision_override)
    if(self.parent==nil) then
        self.position = self.position + self.velocity * dt;
        self.collider:moveTo(self.position.x,self.position.y)
    else
        self.position=(self.parent.position+-self.local_position)
        self.local_position=(self.local_position+vector.new(0,self.velocity.y));
        self.collider:moveTo(((math.round(self.parent.position.x+self.collider_pos.x))),((math.round(self.parent.position.y+self.collider_pos.y))))
        --self.collider:setRotation((self.parent.rotation))
    end
    --Update the faux physics
    if(self.in_air and not self.picked_up) then
        if(self.velocity.y~=0 and self.local_position.y~=0) then
            self.velocity.y=(self.velocity.y - 9.81*dt)
            if(self.local_position.y<0) then
                if(math.abs(-self.velocity.y*self.bounciness)<0.25) then
                    self.in_air=false
                    self.local_position.y=0
                    return       
                end
                self.velocity.y=-self.velocity.y*self.bounciness
            end
        end
    else
        self.velocity=vector.zero
        self.local_position.y=0
    end

    if(self.picked_up) then
        return
    end
    self.z_value=self.position.y+self.local_position.y
    if(collision_override~=nil) then
        for shape, delta in pairs(collider_world:collisions(self.collider)) do            
            if(shape.flags and shape.flags.trigger) then
				shape.flags.trigger_function(shape,self)
                return
            end
        end
        collision_override()
    else
        for shape, delta in pairs(collider_world:collisions(self.collider)) do
            
            if(shape.flags~=nil and shape.flags.canCollide) then
                if(shape.flags and shape.flags.trigger) then
                    shape.flags.trigger_function(shape,self)
                    return
                end    
                self.parent.position=self.parent.position+vector.new(delta.x,delta.y)
            end
        end
    end
end

return Entity