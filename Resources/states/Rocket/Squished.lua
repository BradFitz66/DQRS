local State = require("Resources.scripts.State").new("Squished")
State.Enter=function(owner)
	owner.sprite.in_airr=false;
    owner.sprite.local_position=vector.new(0,0)
    owner:load_treeee("squished",true)
    local t = true
    timer.script(function(wait)
        for i=1,5 do
            if(owner.current_tree.name~="squished")then
                break;
            end
            t=not t
            wait(.025)
            local treeVec =owner.current_tree.vector
            owner.sprite.local_position.x = t and 2*treeVec.x or -2*treeVec.x
            owner.sprite.local_position.y = t and 2*treeVec.y or -2*treeVec.y
        end
        owner.sprite.local_position.x = 0
        owner.sprite.local_position.y  = 0
    end)
    --owner.current_tree.current_animation:setPaused(true)
end

State.Update=function(owner,dt) 
	if(owner.move_vectorr~=vector.new(0,0))then
		owner:change_state("Stretch")
	end
end

State.Exit=function(owner) 
end


return State