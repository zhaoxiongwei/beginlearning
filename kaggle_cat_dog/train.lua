require('nn')
require('optim')
require('xlua')
require('gnuplot')

torch.setdefaulttensortype('torch.FloatTensor')

model = require('./model.lua')
criterion = nn.ClassNLLCriterion() 
allSamples, getSampleData = require('./samples.lua')
trainSamples = {}
valSamples = {}

-- 分配训练样本和验证样本
do
  local shuffer = torch.randperm(#allSamples)
  local trainNumber = math.floor( #allSamples * 0.8)
  for i=1, trainNumber do
    trainSamples[i] = allSamples[ shuffer[i] ];
  end
  for i=trainNumber, #allSamples do
    table.insert(valSamples, allSamples[ shuffer[i] ]);
  end
end

-- 设计训练函数，每个epoch进行一次volidation操作
optimMethod = optim.adadelta
optimState = {}

doTrain = function(batchSize)

  local itemIndex = 1
  model:training()
  local parameters,gradParameters = model:getParameters() -- 记录参数指针

  local feval = function(x)
    -- get new parameters
    if x ~= parameters then
      parameters:copy(x)
    end
    -- reset gradients
    gradParameters:zero()

    local f = 0 --error均值
    for i=0,batchSize-1 do
      local targetIndex = (itemIndex + i) % #trainSamples + 1
      local targetSample = getSampleData( trainSamples[targetIndex].fileName )

      -- 前向计算
      local output = model:forward(targetSample)
      local err = criterion:forward(output, trainSamples[targetIndex].y)
      f = f + err

      -- 后向计算估计 df/dw
      local df_do = criterion:backward(output, trainSamples[targetIndex].y)
      model:backward(targetSample, df_do)
    end

    gradParameters:div(batchSize)
    f = f/batchSize

    return f, gradParameters
  end


  --local maxLoop = math.floor(#trainSamples/batchSize) + 1
  maxLoop = 50
  local errLog = torch.Tensor(maxLoop)
  for i = 1, maxLoop do
    local _, err = optimMethod(feval, parameters, optimState)

    itemIndex = itemIndex + batchSize
    if (itemIndex > #trainSamples) then
      itemIndex = 1
    end

    collectgarbage();
    xlua.progress(i, maxLoop)
  end

  return errLog
end

local errLog = doTrain(32)
gnuplot.plot(errLog)
