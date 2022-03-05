--[[
    Map class. Defines a map and handles some other stuff (pathfinding, spawning, collision generation, etc)
]]

local Rect = require "Resources.lib.Rocket_Engine.Miscellaneous.Rect"
local Map={}
Map.__index=Map
local sti = require "Resources.lib.Rocket_Engine.Systems.sti"
local mathutils=require("Resources.lib.Rocket_Engine.Utils.MathUtils")
local mlib=require("Resources.lib.Rocket_Engine.Utils.mlib")

function Map.new(map_location,graphics)
    local m = setmetatable({},Map)
    m.graphics=sti("Resources/maps/Cannon_Room/Cannon_Room.lua")
    m.origin=map_location
    m.draw_offscreen_actors=false
    m.update_offscreen_actors=false
    m.actors=m:create_actors()
    m.size=vector.new(m.graphics.width*m.graphics.tilewidth,m.graphics.height*m.graphics.tileheight)
    m.collider_polygons={}
    m.pathfinding_grid={}
    m.pathfinder={}
    m.grid_channel=love.thread.newChannel()
    m.colliders=m:generate_colliders()
    m:generate_pathfinding_grid()
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
                ["Platypunk"]=function(spawn_pos) 
                    local platy = require("Resources.scripts.Platypunk"):new(vector.new(spawn_pos.x,spawn_pos.y),vector.new(0,0),vector.new(16,16))
                    return platy
                end,
                ["Player"]=function(spawn_pos) 
                    local plr = require("Resources.scripts.Player"):new(vector.new(spawn_pos.x,spawn_pos.y),vector.new(-1,1),vector.new(12,12))
                    return plr
                end,
                ["TankShell"]=function(spawn_pos) 
                    local shell = require("Resources.scripts.TankShell"):new(vector.new(spawn_pos.x,spawn_pos.y),vector.new(10,5),vector.new(12,12)) 
                    return shell
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
            table.insert(colliders,1,hc_poly)
        end
    end
    for idx, collider in ipairs(colliders) do
        self.collider_polygons[idx]={}
        for collider_idx, vertice in ipairs(collider._polygon.vertices) do
            table.insert(self.collider_polygons[idx],vertice)
        end
    end
    return colliders
end

--https://pastebin.com/mMPGMhfC

function Map:generate_pathfinding_grid()
    local points={}
    local elapsed=0
    local bounds=Rect.new(self.graphics.x,self.graphics.y,self.graphics.width*self.graphics.tilewidth,self.graphics.height*self.graphics.tileheight)
    local now = os.clock()
    local point_size=vector.new(self.graphics.tilewidth,self.graphics.tileheight)
    for x = 0, bounds.height,point_size.y do
        points[x/point_size.x]={}
        for y = 0, bounds.width,point_size.x do
            local inside_polygon=false
            local circle=collider_world:circle(y,x,self.graphics.tilewidth/2)
            for _, collider in pairs(self.colliders) do
                inside_polygon=circle:collidesWith(collider)
                if(inside_polygon) then
                    break
                end
            end
            if(inside_polygon)then
                points[x/point_size.x][y/point_size.y]=1
            elseif(not inside_polygon) then
                points[x/point_size.x][y/point_size.y]=0
            end
        end
    end
    print("Pathfinding grid generated in:",(os.clock() - now),"seconds")
    
    local Grid = require ("Resources.lib.Rocket_Engine.Systems.jumper.grid") -- The grid class
    local Pathfinder = require ("Resources.lib.Rocket_Engine.Systems.jumper.pathfinder") -- The pathfinder class
    
    local pathfinder_grid = Grid(points) 
    
    local myFinder = Pathfinder(pathfinder_grid, 'JPS', 0) 


    self.pathfinder=myFinder
    self.pathfinding_grid=points
end



function Map:draw(offset_x,offset_y,scale_x,scale_y)
    love.graphics.setColor(1, 1, 1)
    self.graphics.layers["Map"].draw(self.origin.x+offset_x,self.origin.y+offset_y,scale_x,scale_y)
    if(debug_mode) then
        love.graphics.setColor(1, 0, 0,1)
        for _, v in pairs(self.colliders) do
            v:draw('line')
        end
        if(self.pathfinding_grid) then
            for i_y, y in pairs(self.pathfinding_grid) do
                for i_x, x in pairs(y) do
                    love.graphics.setColor(255/255,0/255,255/255)
                    if(x==0) then
                        love.graphics.points(i_x*8,i_y*8)
                    end
                end
            end
        end
        love.graphics.setColor(1, 1, 1,1)
    end
end

return Map