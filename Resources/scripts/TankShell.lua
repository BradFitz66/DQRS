local tankshell={}
tankshell.__index=tankshell
local entity=require("Resources/scripts/Entity")
function tankshell.new()
    local ts=setmetatable({}, tankshell)
    ts.sprite=entity.new(10,5,10,10)
    ts.spriteImage=love.graphics.newImage("Resources/graphics/TankShell.png")
    ts.sprite.parent=ts
    ts.position=vector.new(256,300)
    ts.rotation=0
    ts.scale=vector.new(1,1)
    ts.name="tankshell"
    ts.wallHitDebounce=false
    return ts
end

--!AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
local validDiffs ={

}
local halfRotations={
	45,
	225,
	135
}

function tankshell:update(dt)
    self.sprite:update(dt,function()
        for shape, delta in pairs(colliderWorld:collisions(self.sprite.collider)) do
            for _, actor in pairs(actors) do
                if(actor.sprite.collider==shape) then
                end
            end
            if(contains(currentMap.map.colliderShapes,shape) and not self.wallHitDebounce) then
                self.position=self.position+vector.new(delta.x,delta.y)
                local collisionAngle=(math.round((math.deg(math.atan2(delta.y,delta.x)))))
                local headingAngle=math.round((math.deg(math.atan2(self.sprite.velocity.z,self.sprite.velocity.x))))
                local collisionHeadingDifference=math.abs(math.abs(headingAngle)-math.abs(collisionAngle))
                local isHalfRotation=contains(halfRotations,math.abs(headingAngle))
                --Here we check if there's a separation delta and if the angle of collision is divisible by 180 with no remainder or is within 10 degrees of it or 90 degrees (some flat wall aren't perfectly flat due to float precision)
                if(not isHalfRotation) then
                    if(contains(halfRotations,math.abs(collisionAngle))) then
                        break;
                    end
                    collisionAngle=round(collisionAngle,90)
                    self.wallHitDebounce=true
                    local y = -self.sprite.velocity.y;
                    local startingSpeed = -self.sprite.velocity
                    startingSpeed.y=y
                    self.sprite.inAir=false
					local wallHitNormal=vector.new(roundToNthDecimal(delta.y,1),roundToNthDecimal(delta.x,1))
                    self.sprite:AddForceXYZ(startingSpeed:mirrorOn(vector3(wallHitNormal.y,0,wallHitNormal.x)))
                    --self.position=self.position+vector.new(delta.x,delta.y)
                    timer.after(1,function()
                        self.wallHitDebounce=false;
                    end)

                else
                    self.wallHitDebounce=true
                    local y = -self.sprite.velocity.y;
                    local startingSpeed = -self.sprite.velocity
                    startingSpeed.y=y
                    self.sprite.inAir=false
					local wallHitNormal=vector.new(roundToNthDecimal(delta.y,1),roundToNthDecimal(delta.x,1))
                    self.sprite:AddForceXYZ(startingSpeed:mirrorOn(vector3(wallHitNormal.y,0,wallHitNormal.x)))
                    --self.position=self.position+vector.new(delta.x,delta.y)
                    timer.after(1,function()
                        self.wallHitDebounce=false;
                    end)
                end
            end
        end    
    end)
end

function tankshell:draw()
    love.graphics.draw(self.spriteImage,self.sprite.position.x,self.sprite.position.y,self.rotation,self.scale.x,self.scale.y,0,self.spriteImage:getHeight()/2)
    self.sprite:draw()
end

return tankshell