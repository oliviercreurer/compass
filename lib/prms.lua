-- TO DO:
-- Add record midi-mappable "binary" param for recording

prms = {}

function prms.init()
  params:set("clock_tempo",120)
  
  params:add_group("COMPASS",19)

  params:add_separator("Recording")

  params:add_option("Input", "Input", {"Stereo", "Mono (L)"}, 1)
  params:set_action("Input", function(x) set_input(x) end)

  params:add_control("Record Level","Record level",controlspec.new(0,1,'lin',0.01,1))
  params:set_action("Record Level", function(x) for i=1,2 do sc.rec_level(i,x) end  end)

  params:add_control("Overdub","Overdub",controlspec.new(0,1,'lin',0.01,1))
  params:set_action("Overdub", function(x) end)

  params:add_binary("Record Toggle", "Record Toggle")
  params:set_action("Record Toggle", function() recLevel = 1 - recLevel end)

  params:add_separator("Buffers")

  params:add_control("Start point","Start point",controlspec.new(1,set[loaded()].tail - 1,'lin',1,1))
  params:set_action("Start point", function(x) set[loaded()].head = util.clamp(x,1,set[loaded()].tail - 1) ; set[loaded()].loop_start = set[loaded()].head ;  end)

  params:add_control("End point","End point",controlspec.new(set[loaded()].head + 1,61,'lin',1,61))
  params:set_action("End point", function(x) set[loaded()].tail = util.clamp(x,set[loaded()].head + 1,61) ; set[loaded()].loop_end = set[loaded()].tail ;  end)

  params:add{id="Rate", name="Rate", type="control",
    controlspec=controlspec.new(-16,16,'lin',1,1),
    action=function(x)
      sc.rate(1,x)
      sc.rate(2,x)
    end}

  params:add_control("Rate (slew)", "Rate (slew)", controlspec.new(0,2,'lin',0.01,0.1))
  params:set_action("Rate (slew)", function(x) for i=1,2 do sc.rate_slew_time(i,x) end end)

  params:add_control("Fade","Fade",controlspec.new(0,1,'lin',0.01,0.05))
  params:set_action("Fade", function(x) for i=1,2 do sc.fade_time(i,x) end  end)

  params:add_binary("Clear Buffers", "Clear Buffers")
  params:set_action("Clear Buffers", function()
    for i=1,2 do sc.position(i,set[loaded()].loop_start);
      sc.rate(i,1)
    end
    sc.buffer_clear()
  end)

  params:add_separator("Panning")

  params:add_control("Spread", "Spread", controlspec.new(0,1,'lin', 0.01,1))
  params:set_action("Spread", function(x) end)

  params:add_control("Pan (R)", "Pan (R)", controlspec.new(-1,1,'lin',0.01,0.5))
  params:set_action("Pan (R)", function(x) update_pan(1,x) end)

  params:add_control("Pan (L)", "Pan (L)", controlspec.new(-1,1,'lin',0.01,-0.5))
  params:set_action("Pan (L)", function(x) update_pan(2,x) end)

  params:add_control("Pan slew", "Pan (slew)", controlspec.new(0,2,'lin', 0.01,0.25))
  params:set_action("Pan slew", function(x) for i=1,2 do sc.pan_slew_time(i,x) end end)
  
  params:add_separator("Clock")
  
  params:add_binary("Toggle clock", "Toggle clock")
  params:set_action("Toggle clock", function() clk:toggle() end)
  
  

end

return prms
