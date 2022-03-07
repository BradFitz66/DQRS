local Tank=class("Tank",entity)
local pool=require("Resources.lib.Rocket_Engine.Utils.pool")

function Tank:initialize(map)
    self.map=map.map
    self.ammo_pool=pool.new(
        function()
            local shell = require("Resources.scripts.TankShell"):new(vector.new(0,0),vector.new(10,5),vector.new(12,12)) 
            return shell
        end
    )
    self.ammo_pool:generate(30)
    self.tank_hp=100
    self.team="Blue"
    self.ammo_spawn_time=10
    self.ammo_spawn_timer=0
    self.ammo_spawns={
    }
    for _, object in pairs(self.map.graphics.objects) do
        if(object.name=="Ammo_Spawn") then
            table.insert(self.ammo_spawns,vector.new(object.x,object.y))
        end
    end
    return self
end

function Tank:update(dt)
    self.ammo_spawn_timer=self.ammo_spawn_timer+1*dt
    if(self.ammo_spawn_timer>=self.ammo_spawn_time) then
        self.ammo_spawn_timer=0

        local random_piece=self.ammo_pool:pop()
        local random_pos=self.ammo_spawns[math.random(1,#self.ammo_spawns)]
        random_piece.position.x=random_pos.x
        random_piece.position.z=random_pos.y
        random_piece.map=self.map
        random_piece.pool=self.ammo_pool
        table.insert(self.map.actors,1,random_piece)
    end
end


return Tank