---A tilemap loader that tries to be agnostic to whichever editor you use.

local function countDictionary(dictionary)
    local count=0;
    for _, value in pairs(dictionary) do
        count=count+1
    end
    return count;
end
local tilelove={}
local RTA=require("Resources.lib.RTA")
tilelove.__index=tilelove

function tilelove.new_tilemap(tile_size_x,tile_size_y,tilemap_image,chunk_size_x,chunk_size_y)
    local tilemap = setmetatable(tilelove,{})
    if(not chunk_size_x and not chunk_size_y) then
        chunk_size_x=tile_size_x*4
        chunk_size_y=tile_size_y*4
    end
    tilemap.atlas=RTA.newDynamicSize()
    tilemap.tile_width=tile_size_x
    tilemap.tile_height=tile_size_y
    tilemap.tiles=tilemap:split_image(tilemap_image,true)
    tilemap.maps={}
    tilemap.is_baked=false
    return tilemap
end

---Split the tilemap into separate tiles. We use this for comparison when loading maps made with the tileset.
--@image_data The image data of the image
--@dedupe Whether or not we remove duplicate tiles 
function tilelove:split_image(image_data,dedupe)
     
    local tiles = {}
    for tile_y = 0, (image_data:getHeight()/self.tile_height)-1 do
        for tile_x = 0, (image_data:getWidth()/self.tile_width)-1 do
            tile_index = (tile_x + tile_y * (image_data:getWidth()/self.tile_width))+1
            local img_data=love.image.newImageData(self.tile_width,self.tile_height)
            img_data:paste(image_data,0, 0, tile_x*self.tile_width, tile_y*self.tile_height, 8, 8)
            tiles[tile_index]={img_data,tile_x,tile_y,tile_index,love.graphics.newImage(img_data)}
        end
    end
    collectgarbage('collect') 
    return tiles
end

 
function tilelove:draw(map_index,offset_x,offset_y)
    if(self.is_baked==false) then
        error("Tried to draw a unbaked tilemap. Please call tilemap:bake() AFTER you've added all maps and baked those as well")
    end
    for _, map_tile in pairs(self.maps[map_index]) do
        self.atlas:draw((map_tile[3]), 0+(map_tile[1]*self.tile_width),0+(map_tile[2]*self.tile_height))
    end
end

---Loads a map from an image of it. This will split the image into tiles and then compare them to the tileset tiles.
function tilelove:load_map_from_image(image_data)
    local map_tiles=self:split_image(image_data,false)
    return map_tiles
end

function tilelove:add_map(map_id,map_data)
    self.maps[map_id]=map_data
end

--This bakes a map from individual tile images to indexes referring to the tiles in the tile atlas.
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

function tilelove:bake()
    for id, tile in pairs(self.tiles) do
        self.atlas:add(tile[5],(id))
    end
    self.tiles=nil
    self.atlas:hardBake();
    collectgarbage("collect")
    self.is_baked=true;
end

return tilelove