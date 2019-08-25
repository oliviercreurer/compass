--
-- Compass
-- Looper & Softcut sequencer
-- @olivier
-- [lines link]
--

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
inputs = 2

down_time = 0
KEYDOWN1 = 0
KEYDOWN2 = 0

pages = {"EDIT", "CONTROLS", "COMMANDS"}
controls = {"REC", "PRE", "FADE", "LENGTH"}
positions = {0,0}
ratesP = {0.5,1,2}
ratesN = {-0.5,-1,-2}
ends = {5,9,17,33,65}

STEPS = 16
step = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}

function update_positions(i,x)
  positions[i] = util.clamp(x,0.1,loopEnd)
  -- print(positions[i])
  for i=1,2 do
    if rate ~= 0 then
      softcut.rate(i,rate)
    end
    softcut.pre_level(i,pre)
    softcut.rate_slew_time(i,0.1)
    softcut.rec(i,rec)
    softcut.loop_start(i,loopStart)
    softcut.loop_end(i,loopEnd)
    softcut.fade_time(i,fade)
  end
  redraw()
end

-- COMMANDS

function rateP() for i=1,2 do softcut.rate(i,ratesP[math.random(#ratesP)]) end end
function rateN() for i=1,2 do softcut.rate(i,ratesN[math.random(#ratesN)]) end end
function seqPosC() pos = math.random(1,#step) end
function panC() softcut.pan(1,(math.random(2,5)/10)) ; softcut.pan(2,(math.random(5,8)/10)) end
function metroDec() m.time = util.clamp(m.time * 2, 0.25,2) end
function metroInc() m.time = util.clamp(m.time / 2, 0.25,2) end
function sPosRnd() for i=1,2 do softcut.position(i,1+math.random(loopStart,loopEnd)) end end
function sPosStart() for i=1,2 do softcut.position(i,loopStart) end end
-- function panR() for i=1,2 do softcut.pan(i,(math.random(2,8)/10)) end end

act = {metroDec,metroInc,seqPosC,rateP,rateN,sPosStart,sPosRnd}
COMMANDS = 7
label = {"<", ">", "?", "+", "-", "S", "R"}

-- function rate() for i=1,2 do softcut.rate(i,2) end end
-- function posL() pos = math.random(#step) end

function init()
  -- Params
  params:add_control("REC","REC",controlspec.new(0,1,'lin',0.01,1))
  params:set_action("REC", function(x) rec = x  end)
  params:add_control("PRE","PRE",controlspec.new(0,1,'lin',0.01,1))
  params:set_action("PRE", function(x) pre = x  end)
  params:add_control("RATE","RATE",controlspec.new(-4,4,'lin',0.5,1))
  params:set_action("RATE", function(x) rate = x  end)
  -- params:add_control("LOOP START","LOOP START",controlspec.new(1,loopEnd-2,'lin',1,1))
  -- params:set_action("LOOP START", function(x) loopStart = x  end)
  -- params:add_control("LOOP END","LOOP END",controlspec.new(loopStart+2,65,'lin',1,65))
  -- params:set_action("LOOP END", function(x) loopEnd = x  end)
  params:add_control("FADE","FADE",controlspec.new(0,1,'lin',0.01,0.1))
  params:set_action("FADE", function(x) fade = x  end)
  -- send audio input to softcut input + adjust cut volume
  audio.level_adc_cut(1)
  -- metro
  m = metro.init(count,1,-1)
  m:start()
  -- position poll
  softcut.event_phase(update_positions)
  softcut.poll_start_phase()
	--
	softcut.buffer_clear()
  -- set up 2 voices
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
    softcut.pan(1,panL)
    softcut.pan(2,panR)
    softcut.rate(i,1)
    softcut.phase_quant(i,0.03)
    softcut.rate_slew_time(i,0)
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
  if inputs == 2 then
    softcut.level_input_cut(1,1,1.0)
    softcut.level_input_cut(2,2,1.0)
    -- softcut.level_input_cut(2,1,1.0)
    -- softcut.level_input_cut(1,2,1.0)
  else
    softcut.level_input_cut(1,1,1.0)
    softcut.level_input_cut(1,2,1.0)
  end
end

function count()
  pos = (pos % #step) + 1
  act[step[pos]]()
  -- for i=1,2 do
  --   softcut.pre_level(i,pre)
  --   softcut.rate_slew_time(i,0.1)
  --   softcut.rec(i,rec)
  -- end
  redraw()
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
      loopStart = util.clamp(loopStart+d,1,loopEnd)
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
      loopEnd = util.clamp(loopEnd+d,loopStart+1,loopLength+1)
      print(loopEnd)
    else
      if pageNum == 1 then
        step[edit] = util.clamp(step[edit]+d, 1, COMMANDS)
      elseif pageNum == 2 then
        if sel == 1 then
          rec = util.clamp(rec+d/100,0,1)
        elseif sel == 2 then
          pre = util.clamp(pre+d/100,0,1)
        elseif sel == 3 then
          fade = util.clamp(fade+d/10,0,1)
        elseif sel == 4 then
          last = util.clamp(last+d,1,#ends)
          loopEnd = ends[last]
          print(loopEnd)
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
  for i=1,#pages do
    screen.move(i*4+108,8)
    screen.line_rel(1,0)
    if i == pageNum then
      screen.level(15)
    else
      screen.level(1)
    end
    screen.stroke()
  end
  screen.move(2,10)
  screen.level(1)
  screen.text(pages[pageNum])
end

function drawEdit()
  screen.move(2,20)
  if rec >= 0.01 then
    screen.level(15)
  else
    screen.level(1)
  end
  screen.text("REC")
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
  if sel == 4 then
    screen.level(15)
    screen.text_right(loopEnd-1 .. "s")
  else
    screen.level(3)
    screen.text_right(loopEnd-1 .. "s")
  end
end

function redraw()
  screen.clear()
  drawMenu()
  if pageNum == 1 then
    drawEdit()
  elseif pageNum == 2 then
    drawControls()
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
