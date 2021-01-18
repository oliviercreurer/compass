timing = {}

function timing.init()
  clk_gen = lattice:new()
  clk = clk_gen:new_pattern{
    action = function() count() end,
    division = 1
  }
  clk_gen:start()
end

function toggle_app_state(x)
  for i=1,2 do softcut.rate(i,x) end
  if x == 0 then clk:stop() else clk:start() end
end




return timing