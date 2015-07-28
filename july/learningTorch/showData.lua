Plot = require('itorch.Plot')

local showData = function(samples, lables)

  local l0_x = {}
  local l0_y = {}
  local l1_x = {}
  local l1_y = {}
  for i=1, #samples do
    if ( lables[i][1] == 0) then
      table.insert(l0_x, samples[i][1])
      table.insert(l0_y, samples[i][2])    
    else
      table.insert(l1_x, samples[i][1])
      table.insert(l1_y, samples[i][2])            
    end
  end

  plot = Plot():circle(l0_x, l0_y, 'red', 'hi'):circle(l1_x, l1_y, 'blue', 'bye'):draw()

  plot:title('样本分布'):redraw()
  
  return plot
end

return showData

