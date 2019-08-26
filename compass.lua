-- Compass

rate = 1
rec = 1
pre = 1
pos = 1
edit = 1

loopStart = 1
loopEnd = 65
loopLength = 64

fade = 0.1
panL = 0.3
panR = 0.7
sel = 1
last = 1
pageNum = 1
rateSlew = 0.1
-- inputs = 2

down_time = 0
KEYDOWN1 = 0
KEYDOWN2 = 0

pages = {"EDIT", "COMMANDS"}
controls = {"REC", "PRE", "FADE"}
positions = {0,0}
rates = {-2,-1,-0.5,0.5,1,2}
-- ends = {5,9,17,33,65}

STEPS = 16
step = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}

mklk = midi.connect(1)

mklk.event = function(data)
  local d = midi.to_msg(data)
  -- print something for various data types
  -- ignore clock for the moment but look at other types
  if d.type ~= "clock" then
    if d.type == "cc" then
        print("ch:".. d.ch .. " " .. d.type .. ":".. d.cc.. " ".. d.val)
    elseif d.type=="note_on" or d.type=="note_off" then
        --print("ch:".. d.ch .. " " .. d.type .. " note:".. d.note .. " vel:" .. d.vel)
    elseif d.type=="channel_pressure" or d.type=="pitchbend" then
        print("ch:".. d.ch .. " " .. d.type .. " val:" .. d.val)

    elseif d.type=="start" then
        print("start")
    elseif d.type=="stop" then
        print("stop")
    elseif d.type=="continue" then
        print("continue")
    else
        tab.print(d)
    end
  end
end

function update_positions(i,x)
  positions[i] = util.clamp(x,0.1,loopEnd)
  for i=1,2 do
    softcut.pre_level(i,pre)
    softcut.rate_slew_time(i,rateSlew)
    softcut.rec(i,rec)
    softcut.loop_start(i,loopStart)
    softcut.loop_end(i,loopEnd)
    softcut.fade_time(i,fade)
    softcut.pan(1,panR)
    softcut.pan(2,panL)
  end
  redraw()
  -- print(loopStart .. " - " .. loopEnd)
end

-- INPUT ROUTING

function stereo()
  -- set softcut to stereo inputs
  softcut.level_input_cut(1, 1, 1)
  softcut.level_input_cut(2, 1, 0)
  softcut.level_input_cut(1, 2, 0)
  softcut.level_input_cut(2, 2, 1)
end

function mono()
  --set softcut to mono input
  softcut.level_input_cut(1, 1, 1)
  softcut.level_input_cut(2, 1, 0)
  softcut.level_input_cut(1, 2, 1)
  softcut.level_input_cut(2, 2, 0)
end

function set_input(n)
  if n == 1 then
    stereo()
  else
    mono()
  end
end

-- COMMANDS

-- function rateP() params:set("rate12",rates[math.random(5,8)]) end
function rateP() for i=1,2 do softcut.rate(i,rates[math.random(4,6)]) end end
function rateN() for i=1,2 do softcut.rate(i,rates[math.random(1,3)]) end end
function seqPosC() pos = math.random(1,#step) end
function panC() softcut.pan(1,(math.random(2,5)/10)) ; softcut.pan(2,(math.random(5,8)/10)) end
function metroDec() m.time = util.clamp(m.time * 2, 0.25,2) end
function metroInc() m.time = util.clamp(m.time / 2, 0.25,2) end
function sPosRnd() for i=1,2 do softcut.position(i,1+math.random(loopStart,loopEnd)) end end
function sPosStart() for i=1,2 do softcut.position(i,loopStart) end end
function loopRnd() loopStart = math.random(1,loopEnd-1) ; loopEnd = math.random(loopStart+1,loopLength) end
-- function panR() for i=1,2 do softcut.pan(i,(math.random(2,8)/10)) end end

act = {metroDec,metroInc,seqPosC,rateP,rateN,sPosStart,sPosRnd,loopRnd}
COMMANDS = 8
label = {"<", ">", "?", "+", "-", "S", "R", "L"}

function init()
  
  -- PARAMS
  
  params:add_option("input", "INPUT", {"STEREO", "MONO (L)"}, 1)
  params:set_action("input", function(x) set_input(x) end)
  
  params:add_separator()
  
  params:add_control("REC","RECORD LEVEL",controlspec.new(0,1,'lin',0.01,1))
  params:set_action("REC", function(x) rec = x  end)
  params:add_control("PRE","OVERDUB",controlspec.new(0,1,'lin',0.01,1))
  params:set_action("PRE", function(x) pre = x  end)
  params:add{id="rate12", name="RATE (COARSE)", type="control",
    controlspec=controlspec.new(-2,2,'lin',0.5,1,""),
    action=function(x)
      softcut.rate(1,x)
      softcut.rate(2,x)
    end}
  params:add_control("RATE_SLEW", "RATE (SLEW)", controlspec.new(0,2,'lin',0.01,0.1))
  params:set_action("RATE_SLEW", function(x) rateSlew = x end)
  params:add_control("FADE","FADE",controlspec.new(0,1,'lin',0.01,0.05))
  params:set_action("FADE", function(x) fade = x  end)
  params:add_control("PAN_R", "PAN(R)", controlspec.new(0,1,'lin',0.05,0.7))
  params:set_action("PAN_R", function(x) panR = x end)
  params:add_control("PAN_L", "PAN(L)", controlspec.new(0,1,'lin',0.05,0.3))
  params:set_action("PAN_L", function(x) panL = x end)
  params:add_control("LOOP START","LOOP START",controlspec.new(1,loopEnd-1,'lin',1,1))
  params:set_action("LOOP START", function(x) loopStart = util.clamp(x,1,loopEnd-1) end)
  params:add_control("LOOP END","LOOP END",controlspec.new(loopStart+1,65,'lin',1,65))
  params:set_action("LOOP END", function(x) loopEnd = util.clamp(x,loopStart+1,65) end)
  
  
  -- send audio input to softcut input + adjust cut volume
  
  audio.level_cut(1.0)
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  
  -- METROS
  
  m = metro.init(count,1,-1)
  m:start()
  mklk:start() -- midi clock out
  
  -- POSITION POLL
  
  softcut.event_phase(update_positions)
  softcut.poll_start_phase()
  
	-- SOFTCUT 
	
	softcut.buffer_clear()
	
  for i=1,2 do
    softcut.enable(i,1)
    softcut.buffer(i,i)
    softcut.level(i,1.0)
    softcut.loop(i,1)
    softcut.loop_start(i,1)
    softcut.loop_end(i,loopEnd)
    softcut.position(i,1)
    softcut.play(i,1)
    softcut.fade_time(i,fade)
    softcut.rec_level(i,rec)
    softcut.pre_level(i,pre)
    softcut.rec(i,1)
    softcut.pan(1,panR)
    softcut.pan(2,panL)
    softcut.rate(i,1)
    softcut.phase_quant(i,0.03)
    softcut.rate_slew_time(i,rateSlew)
  end
  -- set PRE filter
  for i=1,2 do
    softcut.pre_filter_dry(i,0)
    softcut.pre_filter_lp(i,1)
    softcut.pre_filter_hp(i,0)
    softcut.pre_filter_bp(i,0)
    softcut.pre_filter_br(i,0)
    softcut.pre_filter_fc(i,18000)
    softcut.pre_filter_rq(i,5)
    softcut.pre_filter_fc_mod(i,1)
  end
  -- input routing (DOUBLE-CHECK!)
  
  stereo()
  
  -- softcut.level_input_cut(1,1,1.0)
  -- softcut.level_input_cut(2,2,1.0)
  
  
  
  -- if inputs == 2 then
  --   softcut.level_input_cut(1,1,1.0)
  --   softcut.level_input_cut(2,2,1.0)
  --   -- softcut.level_input_cut(2,1,1.0)
  --   -- softcut.level_input_cut(1,2,1.0)
  -- else
  --   softcut.level_input_cut(1,1,1.0)
  --   softcut.level_input_cut(1,2,1.0)
  -- end
end

--------------------------------------------------

function count()
  pos = (pos % #step) + 1
  act[step[pos]]()
  redraw()
  mklk:clock()
  -- print(loopStart .. " - " .. loopEnd)
end

function cutReset()
  for i=1,2 do
    softcut.position(i,loopStart)
    softcut.rate(i,1)
  end
  softcut.buffer_clear()
  for i=1,#step do
    step[i] = 1
  end
end

function randomize_steps()
  for i=1,#step do
    step[i] = math.random(COMMANDS)
  end
end

function enc(n,d)
  if n==1 then
    pageNum = util.clamp(pageNum+d,1,#pages)
    print(pageNum)
  elseif n==2 then
    if KEYDOWN1 == 1 then
      -- loopStart = util.clamp(loopStart+d,1,loopEnd)
      -- params:delta("LOOP START",util.clamp(d,1,loopEnd-1))
      params:delta("LOOP START",d)
      print(loopStart)
    else
      if pageNum == 1 then
        edit = util.clamp(edit+d,1,#step)
        print(edit)
      elseif pageNum == 2 then
        sel = util.clamp(sel+d,1,#controls)
        print(sel)
      end
    end
  elseif n==3 then
    if KEYDOWN1 == 1 then
      -- loopEnd = util.clamp(loopEnd+d,loopStart+1,loopLength+1)
      -- params:delta("LOOP END",util.clamp(d,loopStart+1,65))
      params:delta("LOOP END",d)
      print(loopEnd)
    else
      if pageNum == 1 then
        step[edit] = util.clamp(step[edit]+d, 1, COMMANDS)
      elseif pageNum == 2 then
        if sel == 1 then
          params:delta("REC",d)
          --rec = util.clamp(rec+d/100,0,1)
        elseif sel == 2 then
          params:delta("PRE",d)
          -- pre = util.clamp(pre+d/100,0,1)
        elseif sel == 3 then
          params:delta("FADE",d)
          --fade = util.clamp(fade+d/10,0,1)
        end
      end
    end
  end
  redraw()
end

function key(n,z)
  if n == 1 then
    KEYDOWN1 = z
  elseif n == 2 then
    if z == 1 then
      down_time = util.time()
    else
      hold_time = util.time() - down_time
      if hold_time < 1 then
        for i=1,#step do
          step[i] = 1
        end
        for i=1,2 do
          softcut.position(i,loopStart)
          softcut.rate(i,1)
        end
        -- update_positions()
      elseif hold_time > 1 then
        randomize_steps()
      end
    end
  elseif n==3 then
    if z == 1 then
      down_time = util.time()
    else
      hold_time = util.time() - down_time
      if hold_time < 1 then
        rec = 1 - rec
      elseif hold_time > 1 then
        for i=1,#step do
          cutReset()
        end
        -- update_positions()
      end
    end
  end
  redraw()
end

function drawMenu()
  -- for i=1,#pages do
  --   screen.move(i*4+108,8)
  --   screen.line_rel(1,0)
  --   if i == pageNum then
  --     screen.level(15)
  --   else
  --     screen.level(2)
  --   end
  --   screen.stroke()
  -- end
  screen.move(2,10)
  screen.level(2)
  screen.text(pages[pageNum])
end

function drawEdit()
  screen.move(2,20)
  if rec >= 0.01 then
    screen.level(15)
    screen.rect(121,6,4,4)
    screen.fill()
  else
    screen.level(2)
  end
  screen.rect(121,6,4,4)
  screen.stroke()
  --screen.text("REC")
  drawLoop()
  drawCommands()
end

function drawCommands()
  for i=1,#step do
    -- screen.level((i == edit) and 15 or 1)
    screen.move(i*8-8+2,58)
    if i == edit then
      screen.level(15)
    elseif i == pos then
      screen.level(3)
    else
      screen.level(1)
    end
    screen.text(label[step[i]])
  end
end

function drawLoop()
  screen.level(2)
  -- voice 1
  screen.move(2,(1*9)+27)
  screen.line(126,(1*9)+27)
  screen.stroke()
  screen.level(5)
  screen.move((loopStart*124)/loopLength-(124/loopLength)+2,(1*9)+27)
  screen.line((loopEnd*124)/loopLength-(124/loopLength)+2,(1*9)+27)
  screen.stroke()
  screen.level(15)
  screen.move((positions[1]-1)*(124/(loopLength))+2,(1*9)+25)
  screen.line_rel(0,3)
  screen.stroke()
  -- voice 2
  screen.level(2)
  screen.move(2,(2*9)+27)
  screen.line(126,(2*9)+27)
  screen.stroke()
  screen.level(5)
  screen.move((loopStart*124)/loopLength-(124/loopLength)+2,(2*9)+27)
  screen.line((loopEnd*124)/loopLength-(124/loopLength)+2,(2*9)+27)
  screen.stroke()
  screen.level(15)
  screen.move((positions[2]-1)*(124/(loopLength))+2,(2*9)+25)
  screen.line_rel(0,3)
  screen.stroke()
  -- screen.level(2)
  -- screen.move(2,(2*9)+27)
  -- screen.line(126,(2*9)+27)
  -- screen.stroke()
  -- screen.level(15)
  -- screen.move(positions[2]*(124/(loopEnd-1))+2,(2*9)+25)
  -- screen.line_rel(0,3)
  -- screen.stroke()
end

function drawControls()
  for i=1,#controls do
    screen.move(2,i*10+18)
    if i == sel then
      screen.level(15)
    else
      screen.level(3)
    end
    screen.text(controls[i])
  end
  screen.move(123,28)
  if sel == 1 then
    screen.level(15)
    screen.text_right(string.format("%.2f",rec))
  else
    screen.level(3)
    screen.text_right(string.format("%.2f",rec))
  end
  screen.move(123,38)
  if sel == 2 then
    screen.level(15)
    screen.text_right(string.format("%.2f",pre))
  else
    screen.level(3)
    screen.text_right(string.format("%.2f",pre))
  end
  screen.move(123,48)
  if sel == 3 then
    screen.level(15)
    screen.text_right(string.format("%.2f",fade))
  else
    screen.level(3)
    screen.text_right(string.format("%.2f",fade))
  end
  screen.move(123,58)
end

function redraw()
  screen.clear()
  drawMenu()
  if pageNum == 1 then
    drawEdit()
  elseif pageNum == 2 then
    -- drawControls()
  end
  -- drawCommands()
  -- drawLoop(1)
  -- drawLoop(2)
  screen.stroke()
  screen.update()
end

-- softcut.buffer_clear()
--   softcut.enable(1,1)
--   softcut.buffer(1,1)
--   softcut.level(1,1.0)
--   softcut.loop(1,1)
--   softcut.loop_start(1,1)
--   softcut.loop_end(1,1.5)
--   softcut.position(1,1)
--   softcut.play(1,1)
--   softcut.level_input_cut(1,1,1.0)
--   softcut.level_input_cut(2,1,1.0)
--   softcut.rec_level(1,rec)
--   softcut.pre_level(1,pre)
--   softcut.rec(1,1)

--     softcut.enable(i,1)
--     softcut.buffer(i,1)
--     softcut.level(i,1)
--     softcut.loop(i,1)
--     softcut.loop_start(i,1)
--     softcut.loop_end(i,1.5)
--     softcut.position(i,1)
--     softcut.play(i,1)
--     softcut.level_input_cut(1,i,1.0)
--     softcut.level_input_cut(1,i,1.0)
--     softcut.rec_level(i,rec)
--     softcut.pre_level(i,pre)
--     softcut.rec(i,1)

-- screen.move(10,40)
--   for i=1,#step do
--     screen.move(i*8,40)
--     if i == pos then
--       screen.level(15)
--     else
--       screen.level(3)
--     end
--     screen.line_rel(5,0)
--     screen.stroke()
--   end
