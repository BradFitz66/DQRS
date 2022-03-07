local S={}

local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("Idle")
State.Enter=function(owner)
    owner:load_tree("idle",true,true)
    State.wait_time=0
    State.time_to_wait=math.random(5,15)
    owner.walkDest=1
    owner.current_tree:set_vector(owner.move_vector)
end

State.Update=function(owner,dt)
    State.wait_time=State.wait_time+1*dt
    if(State.wait_time>=State.time_to_wait) then
        local end_pos=owner.wander_pos+vector.randomInsideUnitCircle(math.random(50,75))
        local map=owner.map
        local map_graphics=owner.map.graphics
        local path = map.pathfinder:getPath(math.floor(owner.position.x/map_graphics.tilewidth),
                                            math.floor(owner.position.z/map_graphics.tileheight), 
                                            math.floor(end_pos.x/map_graphics.tilewidth), 
                                            math.floor(end_pos.y/map_graphics.tileheight)
                                           )
        
        if path then                
            owner.current_path={}
            for node, count in path:nodes() do
                table.insert(owner.current_path,vector.new(node.x*map_graphics.tilewidth,node.y*map_graphics.tileheight))
            end
            owner:change_state("Walk")
            return
        else
            print("No path found")
        end
        State.wait_time=0
    end
end

State.Exit=function(owner) 
end


return State
