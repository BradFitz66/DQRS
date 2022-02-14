--[[
    A basic renderer/importer for a tilemaps
    
    Very limited features. Can load a tileset from an image, creating an atlas of tiles from it.

    Maps(made with the tileset) can then be imported by image and it will turn them from tiles to indexes in the atlas.

    No support for:
    Custom tile data (planned)
    Animated tiles
    Chunking (planned)
]]

local tilelove={}
local vector = require("Resources.lib.HUMP.vector")
local mathutils = require("Resources.lib.Rocket_Engine.Utils.MathUtils")
local RTA=require("Resources.lib.RTA")
tilelove.__index=tilelove
local testing_path={}

---Create a new tilemap
---@param tile_size_x number
---@param tile_size_y number
---@param tilemap_image userdata
---@param chunk_subdivisions number
---@return table
function tilelove.new_tilemap(tile_size_x,tile_size_y,tilemap_image)
    local tilemap = setmetatable(tilelove,{})
    tilemap.atlas=RTA.newFixedSize(tile_size_x,tile_size_y,0)
    tilemap.tile_width=tile_size_x
    tilemap.tile_height=tile_size_y
    local tiles=tilemap:split_image(tilemap_image,true)
    for id, tile in pairs(tiles) do
        tilemap.atlas:add(tile.image,id)
        if(tilemap.atlas.images[id]~=nil) then
            tilemap.atlas.images[id].data=tile.data
        end
    end
    
    tilemap.colliders={}
    tilemap.maps={}
    tilemap.is_baked=false
    return tilemap
end



local function isAllTransparent(img_data)
    for x = 0, img_data:getWidth() - 1 do
        for y = 0, img_data:getHeight() - 1 do
            local r,g,b,a = img_data:getPixel(x,y)
            if a > 0 then
                return false
            end
        end
    end
    --print("debug_mode: no visible pixels")
    return true
end


---Split image into individual tiles
---@param image_data userdata
---@return table
function tilelove:split_image(image_data,exclude_transparent)  
    local tiles = {}
    for tile_y = 0, (image_data:getHeight()/self.tile_height)-1 do
        for tile_x = 0, (image_data:getWidth()/self.tile_width)-1 do
            local tile_index = (tile_x + tile_y * (image_data:getWidth()/self.tile_width))+1
            local img_data=love.image.newImageData(self.tile_width,self.tile_height)
            img_data:paste(image_data,0, 0, tile_x*self.tile_width, tile_y*self.tile_height, self.tile_width, self.tile_height)
            tiles[tile_index]={data=img_data,x=tile_x,y=tile_y,index=tile_index,image=love.graphics.newImage(img_data)}
        end
    end
    
    return tiles
end
---Check if a rectangle is in bounds of another
---@param x1 number
---@param w1 number
---@param y1 number
---@param h1 number
---@param x2 number
---@param y2 number
---@param w2 number
---@param h2 number
---@return boolean
function is_in_bounds(x1,y1,w1,h1,x2,y2,w2,h2)
    return not (x1 + w1 < x2 or y1 + h1 < y2 or x1 > x2 + w2 or y1 > y2 + h2);
end
---Draw a specific map
---@param map_index string
---@param offset_x number
---@param offset_y number
function tilelove:draw_map(map_index,offset_x,offset_y)
    if(self.is_baked==false) then
        error("Tried to draw a unbaked tilemap. Please call tilemap:bake() AFTER you've added all maps and baked those as well")
    end
    local cam_x,cam_y,cam_w,cam_h=gameCam:getVisible() --camera bounds
    local map_bounds=self.maps[map_index]["bounds"]
    if(is_in_bounds(cam_x,cam_y,cam_w,cam_h,0,0,map_bounds.x,map_bounds.y)) then
        for _, layer in pairs(self.maps[map_index]["layers"]) do
            if(layer.visible and is_in_bounds(cam_x,cam_y,cam_w,cam_h,0,0,layer.bounds.x,layer.bounds.y)) then --second index of the layer table has a boolean which determines if layer is visible or not.
                for _, map_tile in pairs(layer.data) do
                    local tile_x,tile_y,tile_w,tile_h = 0+(map_tile.x*self.tile_width),0+(map_tile.y*self.tile_height),8,8
                    --Very naive culling. Don't render any tiles outside of the camera bounds.
                    if(is_in_bounds(cam_x,cam_y,cam_w,cam_h,tile_x,tile_y,tile_w,tile_h)) then
                        self.atlas:draw((map_tile.index), tile_x,tile_y)
                    end
                end
            end
        end
    end

    if(debug_mode==true) then
        for i_x, x in pairs(self.maps[map_index]["pathfinding_grid"]) do
            for i_y, y in pairs(x) do
                if(i_x==20 and i_y==20) then
                    love.graphics.setColor(255,0,0)
                else
                    love.graphics.setColor(255,255,255)
                end
                if(y==1) then
                    love.graphics.points(i_x*8,i_y*8)
                end
            end
        end

        love.graphics.setColor(255,0,0)
        self.maps[map_index]["collider"]:draw('line')
    end
    love.graphics.setColor(1,1,1)
end

---Load a map made with this tileset from an image of the map
---@param image_data userdata
---@return table
function tilelove:load_map_from_image(image_data)
    local map_tiles=self:split_image(image_data)
    return {
        map_tiles,
        vector.new(image_data:getWidth(),image_data:getHeight())
    }
end

function get_center_of_triangle(triangle) 
    local x_center=(triangle[1]+triangle[3]+triangle[5])/3
    local y_center=(triangle[2]+triangle[4]+triangle[6])/3
    return vector.new(x_center,y_center)
end

---Add a *BAKED* map to the map dictionary
---@param map_id string
---@param map_data_baked table
---@param bounds table
function tilelove:add_map(map_id,map_data_baked,bounds)
    if(self.maps[map_id]~=nil) then
        error("Tried to add a map with the ID "..map_id.." but one already exists with that ID. Did you mean to use :add_layer_to_map instead?")
    end
    self.maps[map_id]={}
    --Bounds of the entire map
    self.maps[map_id]["bounds"]=bounds
    self.maps[map_id]["layers"]={}
    self.maps[map_id]["layers"][1]={data=map_data_baked, visible=(is_visible~=nil and is_visible or true), metadata={}, bounds=bounds}
end

---Bake a map from it's tiles to the indexes of the tile in the tileset
---@param map_data table
---@return table
function tilelove:bake_map(map_data)
    local tile_indexes={}
    for _, map_tile in pairs(map_data[1]) do
        for _, set_tile in pairs(self.atlas.images) do
            if(set_tile.data~=nil) then
                if(map_tile.data:getString()==set_tile.data:getString()) then
                    table.insert(tile_indexes,1,{x=map_tile.x,y=map_tile.y,index=set_tile.id})
                    --Ugly goto 
                    goto continue
                end
            end
        end
        ::continue::
    end
    --! TODO: CHUNKING
    return tile_indexes
end

function tilelove:bake_pathfinding(map_id,extend)
    local bounds=self.maps[map_id]["bounds"]
    local grid={}
    for x = 0, bounds.x,8 do
        grid[x/8]={}
        for y = 0, bounds.y,8 do
            local circle = collider_world:circle(x,y,4)
            if(circle:collidesWith(self.maps[map_id]["collider"])) then
                grid[x/8][y/8]=0
            else
                grid[x/8][y/8]=1
            end
            collider_world:hash():remove(circle)
        end
    end
    self.maps[map_id]["pathfinding_grid"]=grid

    local Grid = require "Resources.lib.jumper.grid" -- The grid class
    local Pathfinder = require "Resources.lib.jumper.pathfinder" -- The pathfinder class
    local astar_grid = Grid(grid) 
    local start_x = 20
    local start_y = 20
    local end_x = 25
    local end_y= 40
    local myFinder = Pathfinder(astar_grid, 'JPS', 1) 
    local path = myFinder:getPath(start_x, start_y, end_x, end_y)
    if path then
        print(('Path found! Length: %.2f'):format(path:getLength()))
        testing_path=path
        for node, count in path:nodes() do
            print(node.x,node.y)
        end
    end
end

---Bake the tileset
function tilelove:bake()
    self.atlas:hardBake();
    collectgarbage("collect")
    self.is_baked=true;
end


--[[
Add a layer to a map. 
Bewarned that if the tileset has already been baked and this contains tiles not in the tileset, you will probably get errors

This won't be a problem if you're using is_collision_layer, because that is just used to define areas where Hardon Collider
will place colliders

Metadata is a table for adding extra 'data' to colliders that can be retrieved when colliding (for example, making triggers)

Offset x and y are for offsetting the layer to make it line up with the rest of the layers if it isn't already lined up.
These offsets are in tiles, not pixels (i.e. and offset_y of 1 will move the layer down by 1 tile)
]]
---@param map_id string
---@param layer_data table
---@param is_collision_layer boolean
---@param metadata table
---@param offset_x number
---@param offset_y number
function tilelove:add_layer_to_map(map_id,layer_data,is_collision_layer,metadata,offset_x,offset_y,is_visible)
    local map = self.maps[map_id]
    local layer_tile_data=self:load_map_from_image(layer_data)
    local layer_data = self:bake_map(layer_tile_data)
    --Apply offset
    if(offset_x~=nil or offset_y~=nil) then
        offset_x=offset_x~=nil and offset_x or 0
        offset_y=offset_y~=nil and offset_y or 0

        for _, tile in pairs(layer_data) do
            tile.x=math.ceil(math.round((tile.x + (offset_x * self.tile_width))*self.tile_width)/self.tile_width)
            tile.y=math.ceil(math.round((tile.y + (offset_y * self.tile_height))*self.tile_height)/self.tile_height)
        end
    end
    local layer_table = {data=layer_data, visible=is_visible, metadata= (metadata~=nil and metadata or {}), bounds=self.maps[map_id]["bounds"]}
    self.maps[map_id].layers[#self.maps[map_id].layers+1]=layer_table
    --[[

        If collision layer, create a polygon collider using the clipper library by creating
        square colliders for each tile in the layer and then unioning them into one polygon
        collider.

        I probably need to make something more robust than this so I can have better angles for
        collisions rather than just right angles.
    ]]
    
    if(is_collision_layer) then
        local clipped_polygon_buffer;
        local clipper_instance = clipper.new()
        local clipper_to_hc_polygon={}
        for tile_index = 1, #layer_data do
            local tile = layer_data[tile_index]
            if(not isAllTransparent(self.atlas.images[tile.index].data)) then
                local tile_collider=collider_world:rectangle(
                    tile.x*(self.tile_width),
                    tile.y*(self.tile_height),
                    self.tile_width+1,
                    self.tile_height+1
                )
                local clipper_poly = clipper.polygon(0)
                --Add the vertices from the tile_collider to the clipper polygon
                for _, vertex in pairs(tile_collider._polygon.vertices) do
                    clipper_poly:add(vertex.x,vertex.y)
                end

                --Remove square collider after
                collider_world:hash():remove(
                    tile_collider
                )
                --self:negate_from_navmesh(tile_collider._polygon.vertices,map_id)
                
                --[[
                    If there's currently no clipper_polygon_buffer, we add the new empty clipper poly to it. 
                    Otherwise, we add the polygon buffer as the clip subject and add the new clipper polygon as the clipper and then union them
                ]]
                if(clipped_polygon_buffer~=nil) then
                    clipper_instance:add_subject(clipped_polygon_buffer)
                    clipper_instance:add_clip(clipper_poly)
                    clipped_polygon_buffer=clipper_instance:execute('union','negative','positive')
                else
                    clipped_polygon_buffer=clipper_poly
                end
            end
        end
        result=clipped_polygon_buffer
        result:simplify()
        for i = 1, result:size() do
			for j = 1, result:get(i):size() do
				local point = result:get(i):get(j)
				table.insert(clipper_to_hc_polygon,1,tonumber(point.y))
				table.insert(clipper_to_hc_polygon,1,tonumber(point.x))
			end
		end

		result=collider_world:polygon(unpack(clipper_to_hc_polygon))
		result.flags={bouncy=false,trigger=false,canCollide=true}
        self.maps[map_id]["collider"]=result
        table.insert(self.colliders,1,result)
        clipped_polygon_buffer=nil
        collectgarbage("collect")
    end
    
end

return tilelove