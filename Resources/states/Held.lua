--Generic state for all NPC types to use for when they're held by a player
local State = require("Resources.lib.Rocket_Engine.State").new("Held")
State.Enter=function(owner)
	owner:load_tree("held",false,false)
	owner.move_vector=vector.new(0,1)
end

State.Update=function(owner,dt)
    if(owner.sprite.in_air)then
        owner:change_state("Hurt")
    end
    if(owner.move_vector~=vector.new(0,0)) then
        owner.current_tree:set_vector(owner.move_vector)
    end
end

State.Exit=function(owner)
end


return State