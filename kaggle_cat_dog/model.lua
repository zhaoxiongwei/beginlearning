require('nn')

-- Model Container
local model = nn.Sequential()

model:add(nn.SpatialConvolution(3, 32, 3, 3, 1, 1, 1))    
model:add(nn.ReLU())
model:add(nn.SpatialMaxPooling(2, 2))
model:add(nn.SpatialConvolution(32, 64, 3, 3, 1, 1, 1))    
model:add(nn.ReLU())
model:add(nn.SpatialMaxPooling(2, 2))
model:add(nn.SpatialConvolution(64, 64, 3, 3, 1, 1, 1))
model:add(nn.ReLU())
model:add(nn.SpatialMaxPooling(2, 2))
model:add(nn.SpatialConvolution(64, 128, 3, 3, 1, 1, 1))
model:add(nn.ReLU())
model:add(nn.SpatialMaxPooling(2, 2))
model:add(nn.SpatialConvolution(128, 128, 3, 3, 1, 1, 1))
model:add(nn.ReLU())
model:add(nn.SpatialMaxPooling(2, 2))
model:add(nn.Reshape(128*4*4))
model:add(nn.Dropout(0.5))
model:add(nn.Linear(128*4*4, 2048))
model:add(nn.ReLU())
model:add(nn.Linear(2048, 2048))
model:add(nn.Dropout(0.5))
model:add(nn.ReLU())
model:add(nn.Linear(2048, 1))
model:add(nn.Sigmoid())

return model


