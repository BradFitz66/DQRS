--Thread for creating pathfinding grid
local channelMain,data=...
local polygons=data.polygons
local bounds=data.bounds
local tilewidth,tileheight=data.tilewidth,data.tileheight
--Return data 

function isPointInPolygon(x, y, poly)
    local x1, y1, x2, y2
    local len = #poly
    x2, y2 = poly[len - 1], poly[len]
    local wn = 0
    for idx = 1, len, 2 do
        x1, y1 = x2, y2
        x2, y2 = poly[idx], poly[idx + 1]

        if y1 > y then
            if (y2 <= y) and (x1 - x) * (y2 - y) < (x2 - x) * (y1 - y) then
                wn = wn + 1
            end
        else
            if (y2 > y) and (x1 - x) * (y2 - y) > (x2 - x) * (y1 - y) then
                wn = wn - 1
            end
        end
    end
    return wn % 2 ~= 0 -- even/odd rule
end


local points={}
for x = 0, bounds.width-1,tilewidth do
    points[x/tileheight]={}
    for y = 0, bounds.height-1,tileheight do
        local inside_polygon=false
        for _, polygon in pairs(polygons) do
            inside_polygon=isPointInPolygon(x,y,polygon)
        end
        if(inside_polygon)then
            points[x/tilewidth][y/tileheight]=1
        else
            points[x/tilewidth][y/tileheight]=0
        end 
    end
end

channelMain:push({points=points,bounds=bounds})