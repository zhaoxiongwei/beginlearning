require('nn')
require('optim')
require('xlua')
require('gnuplot')

torch.setdefaulttensortype('torch.FloatTensor')

model = require('./model.lua')
criterion = nn.BCECriterion() 
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
  for i=trainNumber+1, #allSamples do
    table.insert(valSamples, allSamples[ shuffer[i] ]);
  end
end

-- 设计训练函数，每个epoch进行一次volidation操作
optimMethod = optim.asgd
optimState = {
  eta0 = 0.02,
  t0 = #trainSamples
}


doTrain = function(batchSize)

  model:training()
  parameters,gradParameters = model:getParameters() -- 记录参数指针
  local itemIndex = 1

  local feval = function(x)
    -- get new parameters
    if x ~= parameters then
      parameters:copy(x)
    end
    -- reset gradients
    gradParameters:zero()

    local y1 = torch.Tensor(1)
    y1[1] = 0
    local y2 = torch.Tensor(1)
    y2[1] = 1

    local f = 0 --error均值
    for i=itemIndex, itemIndex+batchSize-1 do
      local targetIndex = i % #trainSamples + 1
      local targetSample = getSampleData( trainSamples[targetIndex].fileName )
      local y = nil
      if ( trainSamples[targetIndex].y == 1) then
        y = y1
      elseif ( trainSamples[targetIndex].y == 2) then
        y = y2
      end

      -- 前向计算
      local output = model:forward(targetSample)
      local err = criterion:forward(output, y)
      f = f + err

      -- 后向计算估计 df/dw
      local df_do = criterion:backward(output, y)
      model:backward(targetSample, df_do)

    end

    gradParameters:div(batchSize)
    f = f/batchSize

    return f, gradParameters
  end

  local maxLoop = math.floor(#trainSamples/batchSize) + 1
  local errLog =  {}
  for j = 1, maxLoop do
    local _, err = optimMethod(feval, parameters, optimState)

    itemIndex = itemIndex + batchSize
    if (itemIndex > #trainSamples) then
      itemIndex = 1
    end

    errLog[j] = err[1]

    collectgarbage();
    xlua.progress(j, maxLoop)
  end

  return errLog
end

function TableConcat(t1,t2)
  for i=1,#t2 do
    t1[#t1+1] = t2[i]
  end
  return t1
end

function Table2Tensor(t1) 
  local t2 = torch.Tensor(#t1)
  for i=1,#t1 do
    t2[i] = t1[i]
  end
  return t2
end

local allLog = {}
for i=1,10 do
  local errLog = doTrain(32)
  TableConcat(allLog, errLog)
  gnuplot.plot( Table2Tensor(allLog) )
end


