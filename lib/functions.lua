functions = {}

local rate_pos = 5
local rates = {-2,-1,-0.5,0.5,1,2}

function functions.init()
  
  function clk_min() division = 1 end
  function clk_inc() division = util.clamp(division / 2, 1, 32) end
  function clk_dec() division = util.clamp(division * 2, 1, 32) end
  function clk_max() division = 32 end
  function rnd_step() pos = math.random(1,#set[loaded()].step) end


  function forward_rate() for i=1,2 do sc.rate(i,rates[5]) end end
  function reverse_rate() for i=1,2 do sc.rate(i,rates[2]) end end
  function rate_inc() rate_pos = util.clamp(rate_pos+1,1,6) ; for i=1,2 do sc.rate(i,rates[rate_pos]) end end
  function rate_dec() rate_pos = util.clamp(rate_pos-1,1,6) ; for i=1,2 do sc.rate(i,rates[rate_pos]) end end
  function rnd_rate() for i=1,2 do sc.rate(i,rates[math.random(1,6)]) end end
  function start_pos() for i=1,2 do sc.position(i,set[loaded()].loop_start) end end
  function rnd_pos() for i=1,2 do sc.position(i,math.random(set[loaded()].loop_start,set[loaded()].loop_end)) end end
  function rnd_loop() set[loaded()].loop_start = math.random(set[loaded()].head,set[loaded()].loop_end-1) ; set[loaded()].loop_end = math.random(set[loaded()].loop_start+1,set[loaded()].tail) end
  function rnd_overdub() params:set("Overdub",math.random(1,100)/100) end
  function rnd_pan_l() params:set("Pan (L)",math.random(0,8)/-10) end
  function rnd_pan_r() params:set("Pan (R)",math.random(0,8)/10) end
  function toggle_rec() recLevel = 1 - recLevel end
  
  -- Crow
  function crow_trig() crow.output[1].execute() end
  function crow_rnd() crow.output[2].volts = math.random(10) end
  
end

return functions