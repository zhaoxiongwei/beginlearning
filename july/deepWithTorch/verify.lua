require('image')
require('nn')

model = torch.load('./net.bin')
meta = torch.load('./meta.bin')
meta.mean = meta.mean:sub(1,3,1,256,1,256)

local fc = io.open("image-net-2012.words")
local classText = {}
while true do
  local line = fc:read()
  if line == nil then break end
  table.insert(classText, line)
end
fc:close()

meta.classText = classText

img = image.loadPNG(arg[1], 3):float()
img = img * 256
img = img - meta.mean

img = img:sub(1,3,1,225,1,225)

scores = model:forward(img)

_, results = torch.sort(scores, true)

for i = 1, 5 do
  print(i .. "==> " .. meta.classText[ results[i] ] )
end

