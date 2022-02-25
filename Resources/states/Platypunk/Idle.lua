local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("Idle")
State.Enter=function(owner)
    owner:load_tree("idle",true)
    timer.after(5,function() 
        if(owner.statemachine.current_state.Name=="Idle") then
            owner.walkDest=1
            owner.current_path=(signal:emit_with_return("Request_Path","Cannon room",owner.planar_position,vector.new(200,200)+vector.randomInsideUnitCircle(50)))
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
