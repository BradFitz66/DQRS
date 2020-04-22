--Base module for entities (players, ammo, enemies, etc)
local Entity={}
Entity.__index=Entity
function Entity.new(colliderSX,colliderSY)
    local e=setmetatable({},Entity)
    e.position=vector.new(0,0)
    e.localPosition=vector.new(0,0) --position when we have a parent
    e.groundPos=vector.new(0,0) --for keeping the relative ground position when the player is in the air
    e.velocity=vector.new(0,0)
    e.startingVelocity=vector.new(0,0)
    e.inAir=false -- is the entity in the air?
    e.bounciness=.7
    e.colliderSize=(colliderSX and colliderSY) and vector.new(colliderSX,colliderSY) or vector.zero
    e.collider=colliderWorld:rectangle(0,0,colliderSX or 20,colliderSY or 20)
    e.maxBounces=0;
    e.parent=nil
    return e
end

function Entity:AddForce(y)
    if(self.inAir)then
        return;
    end
    self.inAir = true;
    self.velocity=vector.new(0,y)
    self.maxBounces=3;
end

function math.Clamp(val, lower, upper)
    assert(val and lower and upper, "not very useful error message here")
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function Entity:draw()
    if(debug) then
        love.graphics.setColor(0,255,0)
        self.collider:draw("fill")
        love.graphics.setColor(255,255,255)
    end
end


function Entity:update(dt)
    if(self.parent==nil) then
        self.position = self.position + self.velocity * dt;
        self.collider:moveTo(self.position.x,self.position.y)
    else
        self.position=self.parent.position+-self.localPosition
        self.localPosition=self.localPosition+self.velocity;
        self.collider:moveTo(self.parent.position.x,self.parent.position.y-self.colliderSize.y/2)
    end

    if(self.inAir and (self.maxBounces > 0 and self.velocity.y ~= 0)) then
        self.velocity = self.velocity + vector.new(0, -9.81) * dt;
        local BounceDelta = vector.new(0,1) * self.velocity.y * dt;
        --local Xdelta = ((vector.new(1,0) * self.velocity.x) + (vector.new(0,1) * self.velocity.y)) * dt;
        if ((self.localPosition + BounceDelta).y <= 0) then
            --we hit the ground
            self.velocity.y = self.velocity.y * -1
            self.velocity.y = self.velocity.y*self.bounciness;
            self.velocity.x = self.velocity.x - (self.startingVelocity.x / 3);
            --pos += Vector3.up * self.velocity * Time.deltaTime;
            self.maxBounces = self.maxBounces - 1;
        end
        local spritePos = self.localPosition + BounceDelta;
        spritePos.y = math.Clamp(spritePos.y, 0, math.huge);
        --local mainPos = self.parent.position + Xdelta;
        self.localPosition = spritePos;
        --self.parent.position = mainPos;
    else
        self.inAir=false
        self.velocity=vector.zero
    end
end

return Entity