require('torch')

easySVM = function (options)
  svm = {}
  options = options or {}

  function svm:_init()
    -- 设置默认参数
    self.C = options.C or 1.0
    self.tol = options.tol or 1e-5
    self.sigma = options.sigma or 0.5

    local kernel = options.kernel or 'linear'
    if ( kernel == 'linear' ) then
      self.kernel = self._linear
    elseif (kernel == 'rbf' ) then
      self.kernel = self._rbf
    else
      self.kernel = self._linear
    end
  end

  -- 训练函数
  function svm:train(samples, labels, maxIterate)
    local i, j

    local targetHistory = {}

    -- 向量初始化
    self.x = {}
    self.y = {}
    self.alphas = {}
    self.b = 0.0

    for i = 1, #samples do
      self.alphas[i] = 0.0
      self.x[i] = samples[i]
      if ( labels[i][1] == 1) then
        self.y[i] = 1
      else
        self.y[i] = -1
      end
    end

    -- for SMO algorithm
    local Ei, Ej
    local ai, aj, ai_, aj_
    local b1, b2
    local L, H
    local eta

    maxIterate = maxIterate or 200
    local iter = 0
    local passes = 0
    local alphaChaned = 0

    -- SMO 算法实现
    while (passes < 10 and iter < maxIterate ) do
      alphaChaned = 0
      for i = 1, #self.alphas do
        -- 选择对应的alpha_1
        Ei = (self:pred(self.x[i]) - self.y[i]) * self.y[i]
        if (  (Ei < -1 * self.tol and self.alphas[i] < self.C)
            or (Ei > self.tol and self.alphas[i] > 0) ) then

          Ei = Ei * self.y[i]

          j = i
          while(j == i) do
            j = math.floor( math.random() * #self.alphas + 1)
          end
          Ej = self:pred(self.x[j]) - self.y[j]

          ai = self.alphas[i]
          aj = self.alphas[j]

          if ( self.y[i] == self.y[j] ) then
            L = math.max(0, ai + aj - self.C)
            H = math.min(self.C , ai + aj)
          else
            L = math.max(0, aj - ai)
            H = math.min(self.C, self.C + aj - ai)
          end

          eta = 2 * self:kernel(self.x[i], self.x[j]) - self:kernel(self.x[i], self.x[i]) - self:kernel(self.x[j], self.x[j])
          aj_ = aj - self.y[j] * (Ei - Ej) / eta
          if ( aj_  > H ) then
            aj_ = H
          end
          if ( aj_ < L ) then
            aj_ = L
          end


          -- 更新 alpha_i alpha_j b
          if ( math.abs(L-H) > 1e-4 and eta < 0 and math.abs(aj - aj_) > 1e-4) then

            self.alphas[j] = aj_
            ai_ = ai + self.y[i] * self.y[j] * ( aj - aj_)
            self.alphas[i] = ai_

            --update b
            b1 = self.b - Ei - self.y[i]*(ai_ - ai)*self:kernel(self.x[i], self.x[i])
                 - self.y[j]*(aj_ - aj)*self:kernel(self.x[i], self.x[j])

            b2 = self.b - Ej - self.y[j]*(aj_ - aj)*self:kernel(self.x[i], self.x[j])
                 - self.y[j]*(aj_ - aj)*self:kernel(self.x[j], self.x[j])

            self.b = (b1+b2)/2
            if ( ai_ > 0 and ai_ < self.C) then
              self.b = b1
            end
            if ( aj_ > 0 and aj_ < self.C) then
              self.b = b2
            end
            alphaChaned = alphaChaned + 1

          end  -- end of i and j is OK
        end -- end of selected i
     end -- end of all i

     iter = iter + 1
     if(alphaChaned == 0) then
       passes = passes + 1
     else
       passes = 0;
     end

     local targetValue = self:minTarget()
     targetHistory[#targetHistory+1] = targetValue

   end -- end of iterator

   print("SVM training is done, total iterator number:" .. iter)

   return targetHistory
  end

  -- 分类函数
  function svm:pred(x)
    local ret = 0.0;
    for i=1, #self.alphas do
      ret = ret + self.alphas[i] * self.y[i] * self:kernel(x, self.x[i])
    end
     ret = ret + self.b
     return ret
  end

  function svm:minTarget()
    local targetValue = 0.0
    for i = 1, #self.alphas do
      for j = 1, #self.alphas do
        targetValue = targetValue + self.alphas[i]*self.alphas[j]*self.y[i]*self.y[j]*self:kernel(self.x[i], self.x[j])
      end
    end

    for i = 1, #self.alphas do
      targetValue = targetValue - self.alphas[i]
    end

    return targetValue
  end

  -- 内置核函数
  function svm:_rbf(v1, v2)
    local s = 0;
    for i=1, v1:size()[1] do
      s = s + (v1[i] - v2[i]) * (v1[i] - v2[i])
    end
    s = torch.exp( -1 * s / (2.0 * self.sigma * self.sigma ) )
    return s
  end

  function svm:_linear(v1, v2)
    local s = 0;
    for i=1, v1:size()[1] do
      s = s + v1[i] * v2[i]
    end
    return s
  end


  svm:_init()
  return svm

end

return easySVM
