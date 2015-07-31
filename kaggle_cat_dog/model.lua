require('nn')

-- Model Container
local model = nn.Sequential()

model:add(nn.SpatialConvolution(3, 8, 3, 3, 1, 1, 1))    
model:add(nn.ReLU())
model:add(nn.SpatialMaxPooling(2, 2))
model:add(nn.SpatialConvolution(8, 16, 3, 3, 1, 1, 1))    
model:add(nn.ReLU())
model:add(nn.SpatialMaxPooling(2, 2))
model:add(nn.SpatialConvolution(16, 16, 3, 3, 1, 1, 1))
model:add(nn.ReLU())
model:add(nn.SpatialMaxPooling(2, 2))
model:add(nn.SpatialConvolution(16, 32, 3, 3, 1, 1, 1))
model:add(nn.ReLU())
model:add(nn.SpatialMaxPooling(2, 2))
model:add(nn.Reshape(32*8*8))
model:add(nn.Linear(32*8*8, 256))
model:add(nn.Linear(256, 2))
model:add(nn.LogSoftMax())

return model


