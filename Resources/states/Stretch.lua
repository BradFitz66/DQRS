local State = require("Resources.scripts.State").new("Stretch")
local startScale=vector.new(1.1,.37);
local endScale=vector.new(1,1)
local angle;
State.Enter=function(owner)
    owner:loadTree("stretch",true)
    owner.scale=startScale
    local target= owner.position+owner.moveVector;
    local normalTar = (target - owner.position):normalized();
    angle = math.atan2(normalTar.y, normalTar.x) + math.rad(90) --* 1/(math.pi * 2 / 360);
    owner.rotation=angle
end

State.Update=function(owner,dt) 

    if (owner.moveVector ~= vector.zero) then
    
        owner.currentTree.vector = owner.moveVector
        local distance=owner.scale.dist(owner.scale,endScale);
        local newSpeed = 1.5;
        local finalSpeed = (distance / newSpeed);
        owner.scale = vector.Lerp(owner.scale, endScale, dt/finalSpeed);

        local target= owner.position+owner.moveVector;
        -- get the angle
        local normalTar = (target - owner.position):normalized();
        angle = math.atan2(normalTar.y, normalTar.x) + math.rad(90) --* 1/(math.pi * 2 / 360);
        -- rotate to angle
        owner.rotation = angle;
    
    else
    
        local distance = owner.scale.dist(owner.scale,startScale);
        local newSpeed = 1.5;
        local finalSpeed = (distance / newSpeed);
        owner.scale = vector.Lerp(owner.scale, startScale, dt / finalSpeed);

        if (owner.scale.dist(owner.scale,startScale)<=0.005) then
            owner.rotation=0
            owner.scale=vector.new(1,1)
            owner:changeState("Squished")
            
        end
    end
    if (owner.input:released("jump"))then
    
        --So rocket slime's full stretch elastoblast (not a charged one) moves the player 267 pixels roughly which translates to about 16 unity units (267/16) so that's what I'm basing this off of.

        --Scale the full power elastoblast by how much the player stretched
        --vec = Quaternion.Euler(new Vector3(0, 10, 0)) * vec
        local maxPower = vector.new(0, 9*16);
        local mag = maxPower:len();
        local maxPowerAligned=maxPower:rotated(owner.rotation);
        maxPowerAligned = -maxPowerAligned;
        owner.blastVelocity = vector.Lerp(vector.zero, maxPowerAligned, (owner.scale - startScale):len() / (endScale - startScale):len());
        --print("Blast velocity: "..tostring(owner.blastVelocity))
        owner:changeState("Blasting")
    end
end

State.Exit=function(owner) 
end


return State

--[[

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using StateStuff;
public class Stretching : State<Player>
{
    private static Stretching _Instance;
    public static Stretching Instance {
        get {
            if (_Instance == null)
                _Instance = new Stretching();
            return _Instance;
        }

    }
    local startScale=new local(1.1f,.37f,1);
    local endScale=new local(1,1,1);
    local angle;
    public override void EnterState(Player owner)
    {
        owner.scale = startScale;
    }

    public override void ExitState(Player owner)
    {
    }

    public override void UpdateState(Player owner)
    {
        if (owner.moveVector != local.zero)
        {
            owner.animator.SetFloat("VelX", owner.moveVector.x);
            owner.animator.SetFloat("VelY", owner.moveVector.y);
            local distance=local.Distance(owner.scale,endScale);
            local newSpeed = 2f;
            local finalSpeed = (distance / newSpeed);
            owner.scale = local.Lerp(owner.scale, endScale, dt/finalSpeed);

            local target= owner.sprite.localPosition+owner.moveVector;
            -- get the angle
            local normalTar = (target - owner.sprite.localPosition).normalized;
            angle = Mathf.Atan2(normalTar.y, normalTar.x) * Mathf.Rad2Deg;
            -- rotate to angle
            Quaternion rotation = new Quaternion();
            rotation.eulerAngles = new local(0, 0, angle - 90);
            owner.sprite.rotation = rotation;
        }
        else
        {
            local distance = local.Distance(owner.scale, startScale);
            local newSpeed = 2f;
            local finalSpeed = (distance / newSpeed);
            owner.scale = local.Lerp(owner.scale, startScale, dt / finalSpeed);

            if (local.Distance(owner.scale, startScale)<=0.005f)
            {
                owner.set_state(3);
            }
        }
        if (Input.GetButtonUp("Jump"))
        {
            --So rocket slime's full stretch elastoblast (not a charged one) moves the player 267 pixels roughly which translates to about 16 unity units (267/16) so that's what I'm basing this off of.

            --Scale the full power elastoblast by how much the player stretched
            --vec = Quaternion.Euler(new local(0, 10, 0)) * vec
            local maxPower = new local(0, 9, 0);
            local mag = maxPower.magnitude;
            local maxPowerAligned = Quaternion.Inverse(owner.sprite.rotation) * maxPower;
            maxPowerAligned.x = -maxPowerAligned.x;
            owner.blastVelocity = local.Lerp(new local(0, 0, 0), maxPowerAligned, (owner.scale - startScale).magnitude / (endScale - startScale).magnitude);
            owner.set_state(6);
        }
    }

    public override void UpdateStateFixed(Player owner)
    {
    }

    public override void LateUpdateState(Player owner)
    {
    }
}

]]