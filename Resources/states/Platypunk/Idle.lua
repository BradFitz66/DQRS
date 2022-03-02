local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("Idle")
local wander_pos=nil
State.Enter=function(owner)
    owner:load_tree("idle",true)
    if(wander_pos==nil) then
        wander_pos=vector.new(owner.planar_position.x,owner.planar_position.y)
    end
    owner.current_tree:set_vector(owner.move_vector)
    timer.after(5,function() 
        if(owner.statemachine.current_state.Name=="Idle") then
            owner.walkDest=1
            local end_pos=wander_pos+vector.randomInsideUnitCircle(50)
            local map=owner.map
            local map_graphics=owner.map.graphics
            local path = pcall(map.pathfinder:getPath(math.floor(owner.position.x/map_graphics.tilewidth),
                                                math.floor(owner.position.z/map_graphics.tileheight), 
                                                math.floor(end_pos.x/map_graphics.tilewidth), 
                                                math.floor(end_pos.y/map_graphics.tileheight)))
            if path then
                owner.current_path={}
                for node, count in path:nodes() do
                    table.insert(owner.current_path,node.x*map_graphics.tilewidth)
                    table.insert(owner.current_path,node.y*map_graphics.tileheight)
                end
            else
                return
            end        
            if(owner.current_path~=nil) then
                owner:change_state("Walk")
            end
        end    
    end)
end

State.Update=function(owner,dt)
end

State.Exit=function(owner) 
end


return State
