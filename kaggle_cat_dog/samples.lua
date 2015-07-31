require('image')

local allSamples = {}

for i = 0, 12499 do
  local sample = {}
  sample.y = 1
  sample.fileName = "./samples/dog_" .. i .. ".png"
  table.insert(allSamples, sample)
  
  sample = {}
  sample.y = 2
  sample.fileName = "./samples/cat_" .. i .. ".png"
  table.insert(allSamples, sample)
end

local getSampleData = function(fileName) 
  local img = image.loadPNG(fileName, 3):float();
  img = img * 256
  img = img - 128
  return img
end

return allSamples, getSampleData
