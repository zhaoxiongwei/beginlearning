require('nn')
require('optim')
require('xlua')
--require('gnuplot')

_CUDA_ = true

if ( _CUDA_ ) then
  require('cunn')
end


torch.setdefaulttensortype('torch.FloatTensor')

model = require('./model.lua')

criterion = nn.BCECriterion() 


if ( _CUDA_ ) then
  model:cuda()
  criterion:cuda()
end

allSamples, getSampleData = require('./samples.lua')
trainSamples = {}
valSamples = {}

-- 分配训练样本和验证样本
do
  local shuffer = torch.randperm(#allSamples)
  local trainNumber = math.floor( #allSamples * 0.90)
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
  eta0 = 0.05,
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

    if ( _CUDA_ ) then
      y1 = y1:cuda()
      y2 = y2:cuda()
    end

    local f = 0 --error均值
    for i=itemIndex, itemIndex+batchSize-1 do
      local targetIndex = i % #trainSamples + 1
      local targetSample = getSampleData( trainSamples[targetIndex] )
      if ( _CUDA_ ) then
        targetSample = targetSample:cuda()
      end
      
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

doVerify = function() 
  model:evaluate()
  
  local pred = 0
  for i=1,#valSamples do
    local targetSample = getSampleData( valSamples[i] )
    if ( _CUDA_ ) then
      targetSample = targetSample:cuda()
    end
   
    local output = model:forward(targetSample)

    if ( output[1] < 0.5 and valSamples[i].y == 1) then
      pred = pred + 1
    elseif ( output[1] > 0.5 and valSamples[i].y == 2) then
      pred = pred + 1
    end
  end

  return pred / #valSamples
end

function main(loop)
  local function Table2Tensor(t1) 
    local t2 = torch.Tensor(#t1)
    for i=1,#t1 do
      t2[i] = t1[i]
    end
    return t2
  end

  local allLog = {}
  local bestScore = 0
  for i= 1, loop do
    local errLog = doTrain(32)
    table.insert(allLog, errLog[#errLog])
    local score = doVerify()
    if ( score > bestScore ) then
      bestScore = score
      torch.save('model.dat', model)
    end
    print("====> Pred = " .. score .. " BestScore = " .. bestScore)
  end
  torch.save('allLog.dat',  Table2Tensor(allLog))
end 


