local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("Float")
--Height we started the hover at
local height=0
local float_time=0
State.Enter=function(owner)
    height=owner.position.y
    owner:load_tree("float",true)
    float_time=0
    --Set owner can_float flag to false. This stops us from being able to float again until we land on the ground (to avoid being able to spam float to stay in the air forever)
    owner.can_float=false
end

State.Update=function(owner,dt)
    owner.physics_data.in_air=true;
    owner.current_tree:set_vector(owner.move_vector)
    if(owner.move_vector~=vector.new(0,0)) then
		owner:set_position_planar(vector.new(
			owner.position.x+((owner.move_vector.x*owner.speed)*dt),
			owner.position.z+((owner.move_vector.y*owner.speed)*dt))
		);
    end
    float_time=float_time+1

    if(owner.position.y>0) then
        --gross magic numbers
        local magic_formulae=(height/80)+(sin(float_time*0.1))-(love.math.random(1,10)/10)
        --[[For the hovering effect in DQRS, it seems the player is being pulled down while a random force is being applied upwards. 
            Unsure if this is a sine wave, or some sort of noise.]] 
        owner.physics_data.velocity.y = magic_formulae
    else
        if(owner.inside_bouncy) then
            owner:change_state("Jump")
            timer.after(1,function() owner.can_float=true end)
        else
            owner:change_state("Squish")
            owner.can_float=true
        end
    end
end

State.Exit=function(owner)
end


return State

--[[

]]