local State = require("Resources.lib.Rocket_Engine.State").new("Stretch")
local startScale=vector.new(1.1,.37);
local endScale=vector.new(1,1)
local angle,normamlTar,target,finalSpeed,newSpeed,distance,rX,rY
local obstruction=false;
local math_utils=require("Resources.lib.Rocket_Engine.MathUtils")
local charge_timer=0;
local curScale=startScale
local fully_charged=false
State.Enter=function(owner)
    owner:load_tree("stretch",false)
    owner.scale=startScale
    local target= owner.position+owner.move_vector;
    local normalTar = (target - owner.position):normalized();
    angle = math.atan2(normalTar.y, normalTar.x) + math.rad(90) --! 1/(math.pi * 2 / 360);
    owner.rotation=angle
end

State.Update=function(owner,dt)
    if(owner.scale==endScale and charge_timer<2) then
        charge_timer=charge_timer+dt
    elseif owner.scale==endScale and charge_timer>=2 and not fully_charged then
        owner:load_tree("elastoblast")
        fully_charged=true;
    elseif owner.scale~=endScale and fully_charged==true then
        fully_charged=false
        owner:load_tree("stretch")
    end
    if (owner.move_vector ~= vector.new(0,0)) then
        owner.current_tree:set_vector(owner.move_vector)

        scaleProper=vector.new(owner.scale.x,(owner.scale.y+.5)*32)
        distance=owner.scale.dist(owner.scale,endScale);
        newSpeed = 1.5;
        finalSpeed = (distance / newSpeed);
        target= owner.position+owner.move_vector;
        -- get the angle
        normalTar = (target - owner.position):normalized();
        angle = math.atan2(normalTar.y, normalTar.x) + math.rad(90) --* 1/(math.pi * 2 / 360);
        rX,rY=math_utils.rotate_point(owner.position.x,owner.position.y,40*owner.scale.y,(angle-math.rad(90)))
    

        owner.head_position=vector.new(owner.position.x,(owner.position.y + 40*owner.scale.y))
        --rotate the head_collider and check for obstruction before rotating the actual player. This avoids the player being able to rotate into walls
        owner.head_position.x=rX
        owner.head_position.y=rY
        owner.head_collider:moveTo(owner.head_position.x,owner.head_position.y)
    
        obstruction=false

        for _, v in pairs(currentMap.map.collider_shapes) do
            if(owner.head_collider:collidesWith(v))then
                obstruction=true;
            end
        end

        if(not obstruction) then
            owner.scale = vector.Lerp(owner.scale, endScale, dt/finalSpeed);
            -- rotate to angle
            owner.rotation = angle;
        end

    else
        --Shrink player sprite
        local distance = owner.scale.dist(owner.scale,startScale);
        local newSpeed = 1.5;
        local finalSpeed = (distance / newSpeed);
        
        angle = math.atan2(normalTar.y, normalTar.x) + math.rad(90) --* 1/(math.pi * 2 / 360);
        rX,rY=math_utils.rotate_point(owner.position.x,owner.position.y,40*owner.scale.y,(angle-math.rad(90)))

        owner.head_position=vector.new(owner.position.x,(owner.position.y + 40*owner.scale.y))
        --rotate the head_collider and check for obstruction before rotating the actual player. This avoids the player being able to rotate into walls
        owner.head_position.x=rX
        owner.head_position.y=rY
        owner.head_collider:moveTo(owner.head_position.x,owner.head_position.y)
        
        owner.scale = vector.Lerp(owner.scale, startScale, dt / finalSpeed);
        head_position=owner.position-scaleProper:rotated(owner.rotation);
        --State.collider:moveTo(head_position.x,head_position.y)

        if (owner.scale.dist(owner.scale,startScale)<=0.005) then
            owner.rotation=0
            owner.scale=vector.new(1,1)
            owner:change_state("Squished")
        end
    end
    if (owner.input:released("jump"))then
    
        --So rocket slime's full stretch elastoblast (not a charged one) moves the player 150 pixels roughly and 230 pixels for a charged one so that's what I'm basing this off of.

        --Scale the full power elastoblast by how much the player stretched
        local charge_power = (fully_charged and 1.53 or 1);
        --the magic numbers here are me just tinkering so 
        local maxPower = vector.new(0, math.ceil((150*charge_power)))
        local mag = maxPower:len();
        local maxPowerAligned=maxPower:rotated(owner.rotation);
        maxPowerAligned = -maxPowerAligned;
        owner.full_charge_elastoblast=fully_charged
        owner.blast_velocity = vector.Lerp(vector.new(0,0), maxPowerAligned, (owner.scale - startScale):len() / (endScale - startScale):len());
        --print("Blast velocity: "..tostring(owner.blast_velocity))
        owner:change_state("Blasting")
        
    end
end

State.Exit=function(owner)
    if(not changing_to_charge) then
        --Don't reset rotation and scale if we're charging full power elastoblast
        owner.rotation=0
        owner.scale=vector.new(1,1)
    end
    charge_timer=0
    owner.head_collider:moveTo(-1000000,-10000000)

    --State.collider:moveTo(-1000000,-10000000)
end


return State