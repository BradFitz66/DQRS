---A tilemap loader that tries to be agnostic to whichever editor you use.

local tilelove={}
local RTA=require("Resources.lib.RTA")
tilelove.__index=tilelove

---Create a new tilemap
---@param tile_size_x number
---@param tile_size_y number
---@param tilemap_image userdata
---@param chunk_size_x number
---@param chunk_size_y number
---@return table
function tilelove.new_tilemap(tile_size_x,tile_size_y,tilemap_image,chunk_size_x,chunk_size_y)
    local tilemap = setmetatable(tilelove,{})
    if(not chunk_size_x and not chunk_size_y) then
        chunk_size_x=tile_size_x*4
        chunk_size_y=tile_size_y*4
    end
    tilemap.atlas=RTA.newFixedSize(8,8,0)
    tilemap.tile_width=tile_size_x
    tilemap.tile_height=tile_size_y
    tilemap.tiles=tilemap:split_image(tilemap_image)
    tilemap.maps={}
    tilemap.is_baked=false
    return tilemap
end
---Split image into individual tiles
---@param image_data userdata
---@return table
function tilelove:split_image(image_data)
     
    local tiles = {}
    for tile_y = 0, (image_data:getHeight()/self.tile_height)-1 do
        for tile_x = 0, (image_data:getWidth()/self.tile_width)-1 do
            local tile_index = (tile_x + tile_y * (image_data:getWidth()/self.tile_width))+1
            local img_data=love.image.newImageData(self.tile_width,self.tile_height)
            img_data:paste(image_data,0, 0, tile_x*self.tile_width, tile_y*self.tile_height, 8, 8)
            tiles[tile_index]={img_data,tile_x,tile_y,tile_index,love.graphics.newImage(img_data)}
        end
    end
    collectgarbage('collect') 
    return tiles
end
---Check if a rectangle is in bounds of the other
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
            if(layer[2]) then --second index of the layer table has a boolean which determines if layer is visible or not.
                for _, map_tile in pairs(layer[1]) do
                    local tile_x,tile_y,tile_w,tile_h = 0+(map_tile[1]*self.tile_width),0+(map_tile[2]*self.tile_height),8,8
                    --Very naive culling. Don't render any tiles outside of the camera bounds.
                    if(is_in_bounds(cam_x,cam_y,cam_w,cam_h,tile_x,tile_y,tile_w,tile_h)) then
                        self.atlas:draw((map_tile[3]), tile_x,tile_y)
                    end
                end
            end
        end
    end
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

---Add a *BAKED* map to the map dictionary
---@param map_id string
---@param map_data_baked table
---@param bounds table
function tilelove:add_map(map_id,map_data_baked,bounds)
    if(self.maps[map_id]~=nil) then
        error("Tried to add a map with the ID "..map_id.." but one already exists with that ID. Did you mean to use :add_layer_to_map instead?")
    end
    print(bounds)
    self.maps[map_id]={}
    self.maps[map_id]["bounds"]=bounds

    self.maps[map_id]["layers"]={}
    self.maps[map_id]["layers"][1]={map_data_baked,is_visible~=nil and is_visible or true}
end

---Bake a map from it's tiles to the indexes of the tile in the tileset
---@param map_data table
---@return table
function tilelove:bake_map(map_data)
    local tile_indexes={}
    for _, map_tile in pairs(map_data) do
        for _, set_tile in pairs(self.tiles) do
            if(map_tile[1]:getString()==set_tile[1]:getString()) then
                                           --x           y           index
                table.insert(tile_indexes,1,{map_tile[2],map_tile[3],set_tile[4]})
                goto continue
            end
        end
        ::continue::
    end
    --! TODO: CHUNKING
    -- for x=1,self.chunk_size_x do
    --     for y = 1, self.chunk_size_y do

    --     end
    -- end

    return tile_indexes
end

---Bake the tileset
function tilelove:bake()
    for id, tile in pairs(self.tiles) do
        self.atlas:add(tile[5],(id))
    end
    self.tiles=nil --Since all the tiles are now in the atlas, we don't need this table anymore.
    self.atlas:hardBake();
    collectgarbage("collect")
    self.is_baked=true;
end


---!(TODO) Add a layer to a map (this assumes layer image is the same width/height as the map it's being added to)
---@param map_id string
---@param layer_data table
---@param is_collision_layer boolean
function tilelove:add_layer_to_map(map_id,layer_data, is_collision_layer)

end

return tilelove