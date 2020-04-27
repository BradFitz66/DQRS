local State = require("Resources.scripts.State").new("Squished")
State.Enter=function(owner)
	owner.sprite.inAir=false;
    owner.sprite.localPosition=vector.new(0,0)
    owner:loadTree("squished",true)
    local t = true
    timer.script(function(wait)
        for i=1,5 do
            if(owner.currentTree.name~="squished")then
                break;
            end
            t=not t
            wait(.025)
            local treeVec =owner.currentTree.vector
            owner.sprite.localPosition.x = t and 2*treeVec.x or -2*treeVec.x
            owner.sprite.localPosition.y = t and 2*treeVec.y or -2*treeVec.y
        end
        owner.sprite.localPosition.x = 0
        owner.sprite.localPosition.y  = 0
    end)
    --owner.currentTree.currentAnimation:setPaused(true)
end

State.Update=function(owner,dt) 
	if(owner.moveVector~=vector.new(0,0))then
		owner:changeState("Stretch")
	end
end

State.Exit=function(owner) 
end


return State