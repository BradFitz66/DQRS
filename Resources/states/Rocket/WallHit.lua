local State = require("Resources.lib.Rocket_Engine.State").new("WallHit")
local debounce = false
State.Enter=function(owner)
    owner:load_tree("wallhit")
end

State.Update=function(owner,dt)
    if(owner.current_tree.current_animation:getFrame()==4)then
        timer.after(.1,function()
            if(debounce==true) then
                return
            end
            debounce=true
            local newVel=owner.blast_velocity*owner.wall_hit_normal;
            
            owner.blast_velocity=vector.Reflect(-owner.blast_velocity,owner.wall_hit_normal)
            
            owner.hit_wall=true;
            owner:change_state("Blasting")
        end)
        debounce=false
    end
end

State.Exit=function(owner)
end


return State

--[[

]]