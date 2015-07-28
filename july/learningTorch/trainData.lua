local trainSamples = {}
trainSamples.x = {}
trainSamples.y = {}

for i = 1, 32 do
  -- 构造随机坐标，-2.5, +2.5
  local x = torch.rand(2)
  x = (x - 0.5) * 3
  local y = torch.Tensor(1)

  -- 对训练样本进行分类
  y[1] = 1
  if ( (math.cos(x[1] - 0.5) - 0.5)< x[2] ) then
    y[1] = 0
  end

  trainSamples.x[#trainSamples.x+1] = x
  trainSamples.y[#trainSamples.y+1] = y
end

return trainSamples
