local Rect = require "Resources.lib.Rocket_Engine.Miscellaneous.Rect"
local Map={}
Map.__index=Map
local sti = require "Resources.lib.Rocket_Engine.Systems.sti"
function Map.new(map_location,graphics)
    local m = setmetatable({},Map)
    m.graphics=sti("Resources/maps/Cannon_Room/Cannon_Room.lua")
    m.origin=map_location
    m.draw_offscreen_actors=false
    m.update_offscreen_actors=false
    m.actors=m:create_actors()
    m.size=vector.new(m.graphics.width*m.graphics.tilewidth,m.graphics.height*m.graphics.tileheight)
    m.colliders=m:generate_colliders()
    m.pathfinding_grid= {}--m:generate_pathfinding_grid()
    return m
end

--Maps may contain spawns for actors 
function Map:create_actors()
    local objects=self.graphics.objects
    local actors={}
    for _, object in pairs(objects) do
        --Check name to see if it's a spawn 
        if(string.find(object.name,"(Spawn)")~=nil) then
            local types={
                --["Platypunk"]=function() return require("Resources.scripts.Platypunk").new() end,
                ["Player"]=function(spawn_pos) 
                    local p = require("Resources.scripts.Player") 

                    p:initialize(vector.new(spawn_pos.x,spawn_pos.y),vector.new(-1,1),vector.new(12,12))  
                    return p.static
                end,
                ["TankShell"]=function(spawn_pos) 
                    local shell = require("Resources.scripts.TankShell") 

                    shell:initialize(vector.new(spawn_pos.x,spawn_pos.y),vector.new(10,5),vector.new(12,12))  
                    return shell.static
                end,
            }
            local spawn_type=object.properties["Spawn_Type"]
            if(spawn_type and types[spawn_type]~=nil) then
                local spawn_amount=object.properties["Spawn_Amount"] or 1
                for i = 1, spawn_amount do
                    local spawned_entity=types[spawn_type](vector.new(object.x,object.y))
                    spawned_entity.map=self
                    table.insert(actors,spawned_entity)
                end
            end
        end
    end
    return actors
end

function Map:generate_colliders(o_x,o_y)
    local objects=self.graphics.objects
    local colliders={}
    for _, object in pairs(objects) do
        if(object.polygon and string.find(object.name,"(Collider)")~=nil) then
            local collider={}
            local flags={
                bouncy=false,
                trigger=false,
                canCollide=true
            }        
            for _, vertice in pairs(object.polygon) do
                local v = vector.new(vertice.x,vertice.y)
                table.insert(collider,1,v.y+object.y)
                table.insert(collider,1,v.x+object.x)
            end
            flags.bouncy=string.find(object.name,"(Bouncy)")~=nil
            flags.trigger=string.find(object.name,"(Trigger)")~=nil
            local hc_poly=collider_world:polygon(unpack(collider))
            hc_poly.flags=flags
            hc_poly:move(-object.x,-object.y)
            hc_poly.name=object.name
            table.insert(colliders,1,hc_poly)
        end
    end
    return colliders
end

function Map:generate_pathfinding_grid()
    local bounds=Rect.new(self.graphics.x,self.graphics.y,self.graphics.width*self.graphics.tilewidth,self.graphics.height*self.graphics.tileheight)
    local grid={}
    local elapsed=0
    local now = os.clock()
    for x = 0, bounds.width,self.graphics.tilewidth do
        grid[x/self.graphics.tilewidth]={}
        for y = 0, bounds.height,self.graphics.tileheight do
            local circle = collider_world:circle(x,y,4)
            local colliding_with=0
            for _, map_collider in pairs(self.colliders) do
                if(circle:collidesWith(map_collider)) then
                    colliding_with=colliding_with+1
                end
            end
            if(colliding_with>0)then
                grid[x/self.graphics.tilewidth][y/self.graphics.tileheight]=0
            else
                grid[x/self.graphics.tilewidth][y/self.graphics.tileheight]=1
            end
            
            collider_world:hash():remove(circle)
        end
    end
    elapsed = elapsed + (os.clock() - now)
    print("Pathfinding grid generated in:",elapsed,"seconds")
    return grid
end



function Map:draw(offset_x,offset_y,scale_x,scale_y)
    love.graphics.setColor(1, 1, 1)
    self.graphics.layers["Map"].draw(self.origin.x+offset_x,self.origin.y+offset_y,scale_x,scale_y)
    if(debug_mode) then
        love.graphics.setColor(1, 0, 0,1)
        for _, v in pairs(self.colliders) do
            v:draw('line')
        end
        love.graphics.setColor(1, 1, 1,1)

        for i_x, x in pairs(self.pathfinding_grid) do
            for i_y, y in pairs(x) do
                love.graphics.setColor(255/255,0/255,255/255)
                if(y==1) then
                    love.graphics.points(i_x*8,i_y*8)
                end
            end
        end
    end
end

return Map