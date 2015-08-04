require('nn')
require('optim')
require('image')
require('xlua')

_CUDA_ = true
if ( _CUDA_ ) then
  require('cunn')
end

local getSampleData = function(fileName)
  local img = image.loadPNG(fileName, 3):float();
  img = img * 256
  img = img - 128
  return img
end


torch.setdefaulttensortype('torch.FloatTensor')
model = torch.load('./model.dat')
if ( _CUDA_ ) then
  model:cuda()
end
model:evaluate()


local fout = io.open("result.csv", "w")
fout:write("id,label\n")


local sampleNumber = 12500
for i=1, sampleNumber do
  local fileName = "./test/" .. i .. ".png"
  local targetSample = getSampleData(fileName)

  if ( _CUDA_ ) then
      targetSample = targetSample:cuda()
  end
   
  local output = model:forward(targetSample)
  if ( output[1] < 0.5 ) then
    fout:write(i .. ",1\n")   
  else
    fout:write(i .. ",0\n")
  end

  xlua.progress(i, sampleNumber)
end

fout:close()

