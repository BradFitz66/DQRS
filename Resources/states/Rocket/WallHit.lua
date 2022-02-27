local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("WallHit")
local debounce = false
State.Enter=function(owner)
    owner:load_tree("wallhit")
end

State.Update=function(owner,dt)
    if(owner.current_tree.current_animation:getFrame()==4)then
        timer.after(.1,function()
            owner.full_charge_elastoblast=false
            if(debounce==true) then
                return
            end
            debounce=true
            owner.blast_velocity=vector.Reflect(owner.blast_velocity,owner.wall_hit_normal:normalized())
            local pos=vector.new(owner.planar_position.x,owner.planar_position.y)
            debug_draw:draw_ray(pos,pos+(owner.blast_velocity),1)
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