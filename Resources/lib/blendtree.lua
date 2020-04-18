local Blendtree={}
Blendtree.__index=Blendtree

function Blendtree.new(BlendTreeAnimations,BlendTreeVector,Name)
    local bT=setmetatable({},Blendtree)
    bT.animations=BlendTreeAnimations
    bT.name=Name
    bT.vector=vector.new(0,0)
    bT.lastvector=bT.vector
    bT.currentAnimation=bT.animations[1][1]
    bT.currentAnimation:setLooping(true)
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
        --Increase the frame count by 1 if we're not at the last frame, otherwise set the frame back to 1.
        local frame = self.currentAnimation:getFrame()+1 < frames and self.currentAnimation:getFrame()+1 or 1
        self.currentAnimation=VectorTable[1][1]
        self.currentAnimation:setFrame( frame)
        self.currentAnimation:setLooping(true)
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