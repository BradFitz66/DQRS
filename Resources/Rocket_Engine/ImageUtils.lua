local image_utils={}
image_utils.__index={}


---Loads all images in a directory given
---@param directory string
---@param sort boolean
---@param sort_function function
---@param start_index integer
---@param end_index integer
---@return table
image_utils.load_images_from_directory = function(directory, sort,sort_function,start_index,end_index)
	local images={}
	
	local files = love.filesystem.getDirectoryItems(directory)
	if(not start_index and not end_index) then
		start_index=1
		end_index=#files
	end
	if(sort) then
		if(sort_function) then
			table.sort(files,sort_function)
		else
			table.sort(files)
		end
	end
	if(start_index and not end_index) then
		table.insert(images,love.graphics.newImage(directory.."/"..files[start_index]))
		return images;
	end

	for index, file in pairs(files) do
		if(index>=start_index) then
			if(index>end_index) then
				break
			end
			table.insert(images,love.graphics.newImage(directory.."/"..file))
		end
	end
	return images
end

image_utils.compare = function (a,b)
	local num1 = tonumber(string.sub(a,0,-5))
	local num2 = tonumber(string.sub(b,0,-5))
	
	return num1<num2
end


return image_utils