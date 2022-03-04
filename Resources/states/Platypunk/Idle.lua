local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("Idle")
local wander_pos=nil
State.Enter=function(owner)
    owner:load_tree("idle",true,true)
    if(wander_pos==nil) then
        print(owner.walkDest)
        wander_pos=vector.new(owner.position.x,owner.position.z)
    end
    owner.current_tree:set_vector(owner.move_vector)
    timer.after(math.random(5,10),function() 
        if(owner.statemachine.current_state.Name=="Idle") then
            owner.walkDest=1
            local end_pos=wander_pos+vector.randomInsideUnitCircle(math.random(50,75))
            local map=owner.map
            local map_graphics=owner.map.graphics
            local start = os.time()
            local path = map.pathfinder:getPath(math.floor(owner.position.x/map_graphics.tilewidth),
                                                math.floor(owner.position.z/map_graphics.tileheight), 
                                                math.floor(end_pos.x/map_graphics.tilewidth), 
                                                math.floor(end_pos.y/map_graphics.tileheight),
                                                false
                                            )
            
            if path then
                print("Path (("..tostring(owner.planar_position)..") to ".."("..tostring(end_pos)..")".." ) generated in",os.time()-start,"seconds")
                
                owner.current_path={}
                for node, count in path:nodes() do
                    table.insert(owner.current_path,vector.new(node.x*map_graphics.tilewidth,node.y*map_graphics.tileheight))
                end
                owner:change_state("Walk")
                return
            end
            State.Enter(owner)        
        end    
    end)
end

State.Update=function(owner,dt)
end

State.Exit=function(owner) 
end


return State
