local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("Squished")
State.Enter=function(owner)
    local org_pos=owner.position
	owner.physics_data.in_air=false;
    owner.position.y=0    
    owner:load_tree("squished",true)
    local t = true
    timer.script(function(wait)
        for i=1,5 do
            if(owner.current_tree.name~="squished")then
                break;
            end
            t=not t
            wait(.025)
            local treeVec =owner.current_tree.vector
            owner.position.x = t and org_pos.x + 2*treeVec.x or org_pos.x + -2*treeVec.x
            owner.position.z = t and org_pos.z + 2*treeVec.y or org_pos.z + -2*treeVec.y
        end
        owner.position.x = org_pos.x
        owner.position.z  = org_pos.z
    end)
    --owner.current_tree.current_animation:setPaused(true)
end

State.Update=function(owner,dt) 
	if(owner.move_vector~=vector.new(0,0))then
		owner:change_state("Stretch")
	end
end

State.Exit=function(owner) 
end


return State