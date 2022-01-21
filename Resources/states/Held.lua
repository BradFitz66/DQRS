--Generic state for all NPC types to use for when they're held by a player
local State = require("Resources.scripts.State").new("Held")
State.Enter=function(owner)
	owner:load_tree("held",false,false)
	owner.move_vectorr=vector.new(0,1)
end

State.Update=function(owner,dt)
    if(owner.sprite.in_airr)then
        owner:change_state("Hurt")
    end
    if(owner.move_vectorr~=vector.new(0,0)) then
        owner.current_tree:setVector(owner.move_vectorr)
    end
end

State.Exit=function(owner)
end


return State