local Blendtree={}
Blendtree.__index=Blendtree

function Blendtree.new(BlendTreeAnimations,BlendTreeVector,Name,owner,StartEvent,EndEvent)
    local bT=setmetatable({},Blendtree)
    bT.animations=BlendTreeAnimations
    bT.name=Name
    bT.vector=vector.new(0,0)
    bT.lastvector=bT.vector
    bT.currentAnimation=bT.animations[1][1]
    bT.currentAnimation:setLooping(true)
    bT.startEvent=StartEvent and StartEvent or nil
    bT.owner=owner
    --bT.endEvent= and StartEvent or nil
    return bT
end

function Blendtree:draw()

end

function Blendtree:update(dt)
    if(self.lastvector~=self.vector) then
        self.lastvector=self.vector
        local VectorTable={}
        for _, v in pairs(self.animations) do
            table.insert(VectorTable,v);
        end
        table.sort(VectorTable,function(a,b)
            return (a[2].dist2(a[2],self.vector))<(b[2].dist2(b[2],self.vector)) 
        end)
        local frames = #self.currentAnimation.frames
        local frame = self.currentAnimation:getFrame()+1 < frames and self.currentAnimation:getFrame()+1 or 1
        self.currentAnimation=VectorTable[1][1]
        if(frame==1)then
            self.currentAnimation:onLoop()
        end
        self.currentAnimation:setFrame(frame)
        self.currentAnimation:setLooping(true)
    end
    if(self.name=="walk")then
        print(self.currentAnimation:getFrame())
    end
    if(self.currentAnimation:getFrame()==1 and self.name=="walk")then
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        self.currentAnimation:onLoop()
    end
    self.currentAnimation:update(dt)
end
--Not needed in this case since just checking the distance normally using
function CosineSim(a, b)
    local sqrt=math.sqrt;
    local dotProduct = vector.dot(a, b);
    local norm1 = sqrt(vector.dot(a, a));
    local norm2 = sqrt(vector.dot(b, b));
    return dotProduct / (norm1 * norm2);
end


return Blendtree