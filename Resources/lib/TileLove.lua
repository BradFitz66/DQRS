---A tilemap loader that tries to be agnostic to whichever editor you use.

local tilelove={}
tilelove.__index=tilelove

function tilelove.new_tilemap(tile_size_x,tile_size_y,tilemap_image)
    local tilemap = setmetatable(tilelove,{})
    tilemap.image=tilemap_image
    tilemap.tile_width=tile_size_x
    tilemap.tile_height=tile_size_y
    tilemap.tiles={}
    tilemap.maps={}
end

---Split the tilemap into separate tiles. We use this for comparison when loading maps made with the tileset.
function tilelove:split_tilemap()
    for tile_y = 0, (self.image:getHeight()/self.tile_height)-1 do
        for tile_x = 0, (self.image:getWidth()/self.tile_width)-1 do
            tile_index = (tile_x + tile_y * (tileset:getWidth()/self.tile_width))+1
            local img_data=love.image.newImageData(self.tile_width,self.tile_height)
            img_data:paste(self.image,0, 0, tile_x*self.tile_width, tile_y*self.tile_height, 8, 8)
            self.tiles[tile_index]=img_data
        end
    end
end

function tilelove:load_map_from_tilesetter_json(jsonstring)

end

function tilelove:load_map_from_image()

end

return tilelove