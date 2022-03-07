local entity = require("Resources.lib.Rocket_Engine.Objects.Entity")
local ammo=class("Ammo",entity)
local vector3 = require("Resources.lib.brinevector3D")

--Base class for ammo
function ammo:initialize(start_pos,collider_pos,collider_size)
    entity.initialize(self,start_pos,collider_pos,collider_size)
    self.damage=3
    self.speed=3
    self.pool=nil
    self.explodes=false --does it explode on contact with another ammo piece or simply just fall out of the air (difference is only visual)
    self.rank=0 --[[
        if higher than 0, it becomes a 'ranked' ammo. Carrying 3 pieces of ammo of the same rank and type will give you the piece of ammo
        1 rank above (if exists). 
        example: 
        3 wooden arrows (rank 1) = 1 iron arrow(rank 2)
        3 iron arrows(rank 2) = 1 steel arrow(rank 3)
    ]]
    self.ranks={
        [1]=nil,
        [2]=nil,
        [3]=nil
    }
    self.map=nil
    self.life_time=60
    self.life_timer=0
end

function ammo:destroy()
    print("Destroying")
    self.held_by=nil
    self.can_pickup=false
    if(self.pool~=nil) then
        --Add self back to the tank's pool of ammo
        self.pool.push(self)
    end
    local actor_idx=table.index_of(self.map.actors,self)
    if(actor_idx~=nil) then
        print("Found self in map actors")
        table.remove(self.map.actors,actor_idx)
    end
end

function ammo:update(dt)
    entity.update(self,dt)
    if(self.picked_up) then
        self.life_timer=0
    end
    self.life_timer=self.life_timer+1*dt
    if(self.life_timer>=self.life_time) then
        self:destroy()
    end
end

return ammo