sc = softcut

function softcut.init()
  
  audio.level_cut(1)
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  
  sc.event_phase(update_positions)
  sc.poll_start_phase()
  
  for i=1,2 do
    sc.enable(i,1)
    sc.buffer(i,i)
    sc.level(i,1.0)
    sc.rec_level(i,1)
    sc.loop(i,1)
    sc.loop_start(i,set[loaded()].loop_start)
    sc.loop_end(i,set[loaded()].loop_end)
    sc.position(i,1)
    sc.play(i,1)
    sc.fade_time(i,0.25)
    sc.pre_level(i,0.5)
    sc.rec(i,1)
    sc.pan(1,0.5)
    sc.pan(2,-0.5)
    sc.rate(i,1)
    sc.phase_quant(i,0.05)
    sc.rate_slew_time(i,0.01)
    sc.level_slew_time(i,0.10)
    sc.pre_filter_dry(i, 1)
    sc.pre_filter_lp(i, 0)
    sc.pre_filter_hp(i, 0)
    sc.pre_filter_bp(i, 0)
    sc.pre_filter_br(i, 0)
  end
  stereo()
end

function stereo()
  -- set sc to stereo inputs
  sc.level_input_cut(1, 1, 1)
  sc.level_input_cut(2, 1, 0)
  sc.level_input_cut(1, 2, 0)
  sc.level_input_cut(2, 2, 1)
end

function mono()
  --set sc to mono input
  sc.level_input_cut(1, 1, 0.5)
  sc.level_input_cut(2, 1, 0)
  sc.level_input_cut(1, 2, 0.5)
  sc.level_input_cut(2, 2, 0)
end

function set_input(n)
  if n == 1 then
    stereo()
    print("Stereo")
  else
    mono()
    print("Mono")
  end
end

function toggle_rec()
  recLevel = 1 - recLevel
  return recLevel
end

function toggle_playback(x)
  for i=1,2 do
    sc.rate(i,x)
  end
  toggle_clock(x)
end

function reset_buffers()
  for i=1,2 do
    sc.position(i,set[loaded()].loop_start)
    sc.rate(i,1)
  end
  sc.buffer_clear()
end

function update_pan(voice,delta)
  local pp;
  pp = delta * params:get("Spread")
  sc.pan(voice, pp)
end

function update_positions(i,x)
  -- grid_redraw()
  positions[i] = util.clamp(x,0.1,set[loaded()].loop_end)
  for i=1,2 do
    sc.recpre_slew_time(i,0.15)
    if   recLevel == 0 then sc.pre_level(i,1)
    else sc.pre_level(i,params:get("Overdub"))
    end
    sc.level(i,1)
    sc.rate_slew_time(i,params:get("Rate (slew)"))
    sc.rec_level(i,recLevel)
    sc.loop_start(i,set[loaded()].loop_start)
    sc.loop_end(i,set[loaded()].loop_end)
  end
  redraw()
end
