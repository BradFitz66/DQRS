local Blendtree={}
Blendtree.__index=Blendtree

function Blendtree.new(BlendTreeAnimations,BlendTreeVector,Name,owner,StartEvent,EndEvent,loop,persistFrame)
    local bT=setmetatable({},Blendtree)
    bT.animations=BlendTreeAnimations
    bT.name=Name
    bT.persistFrame = persistFrame --Persist frame means that when we switch between two animations in the blendtree, the animation frame should stay the same (eg: if we switch between two walk animation directions at frame 4, the animation we switch to will be at frame 4)
    bT.vector=vector.new(0,1)
    bT.lastvector=bT.vector
    bT.currentAnimation=bT.animations[1][1]
    bT.currentAnimation:setPauseAtEnd(not loop)
    bT.currentAnimation:setLooping(loop)
    bT.startEvent=StartEvent and StartEvent or function() end
    bT.owner=owner
    bT.endEvent= function() end
    bT.currentAnimation:setOnAnimationEnd(bT.endEvent)
    bT.loopAnim=loop;
    bT.frameOffset=bT.animations[1][3]
    bT.switchAnimationFlag=false
    return bT
end

function Blendtree:setVector(newVector)
    if(newVector~=vector.new(0,0) and newVector~=self.vector) then
        self.lastvector=self.vector
        self.vector=newVector
        self.switchAnimationFlag=true;
    end
end

function Blendtree:update(dt)
    self.lastvector=self.lastvector:normalized()
    self.vector=self.vector:normalized()
    if(self.switchAnimationFlag) then
        self.switchAnimationFlag=false
        self.lastvector=self.vector
        local VectorTable={}
        for _, v in pairs(self.animations) do
            table.insert(VectorTable,v);
        end
        table.sort(VectorTable,function(a,b)
            return (a[2].dist2(a[2],self.vector))<(b[2].dist2(b[2],self.vector)) 
        end)
        

        local frames = #self.currentAnimation.frames
        local frame = self.currentAnimation:getFrame()
        local delayTimer = self.currentAnimation.delayTimer
        local prevAnim=self.currentAnimation;
        --Switch to new animation
        self.currentAnimation=VectorTable[1][1]
        --Offset from the origin of the sprite when drawing 
        self.frameOffset=VectorTable[1][3]
        self.currentAnimation:setLooping(self.loopAnim)
        self.currentAnimation:setPauseAtEnd(not self.loopAnim)
        self.currentAnimation:setOnAnimationEnd(self.endEvent)
        if(frame==1)then
            self.currentAnimation:onLoop()
        end
        self.currentAnimation:setFrame(frame)
        self.currentAnimation.delayTimer=delayTimer
    end
    self.currentAnimation:update(dt)
end

function CosineSim(a, b)
    local dotProduct = vector.dot(a, b);
    local norm1 = math.sqrt(vector.dot(a, a));
    local norm2 = math.sqrt(vector.dot(b, b));

    return dotProduct / (norm1 * norm2);
end

return Blendtree