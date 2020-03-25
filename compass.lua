--
-- Compass (2.2)
-- Command-based looper
-- @olivier
-- llllllll.co/t/compass/25192
-- w/ contributions from
-- @justmat + @gonecaving
--
-- E1: Scroll pages
-- E2: Navigate to step
-- E3: Select command
-- K1 + K2: Reset commands
-- K1 + K3: Randomize commands
-- K3 (short): Rec ON/OFF
-- K3 (long): Clear buffers
-- K1 + E1 : sequence length
-- K1 + E2 : set loop start
-- K1 + E3 : set loop end

engine.name = "Decimatec"

sc = softcut

local rate = 1
local ratePos = 5
local rec = 0
local recLevel = 0
local pre = 1
local pos = 1
local edit = 1
local clkSpd = 1

local loopStart = 1
local sPoint = 1
local loopEnd = 65
local ePoint = 65
local loopLength = 64

local fade = 0.05
local panL = -0.5
local panR = 0.5
local last = 1
local pageNum = 1
local rateSlew = 0.1

local down_time = 0
local KEYDOWN1 = 0
local KEYDOWN2 = 0

local pages = {"EDIT", "COMMANDS/SEQUENCE", "COMMANDS/SEQUENCE", "COMMANDS/SOFTCUT", "COMMANDS/SOFTCUT", "COMMANDS/SOFTCUT", "COMMANDS/CROW"}
local positions = {0,0}
local rates = {-2,-1,-0.5,0.5,1,2}

local STEPS = 16
local step = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}

local Arcify = include("lib/arcify")
local arcify = Arcify.new()

function update_positions(i,x)
  redraw()
  positions[i] = util.clamp(x,0.1,loopEnd)
  for i=1,2 do
    sc.recpre_slew_time(i,2)
    if recLevel == 0 then
      sc.pre_level(i,1)
    else
      sc.pre_level(i,pre)
    end
    sc.level(i,1)
    sc.rate_slew_time(i,rateSlew)
    sc.rec_level(i,recLevel)
    sc.loop_start(i,loopStart)
    sc.loop_end(i,loopEnd)
    sc.fade_time(i,fade)
    sc.pan(1,panR)
    sc.pan(2,panL)
  end
  setn(step,STEPS)
end

-- INPUT ROUTING

function stereo()
  -- set sc to stereo inputs
  sc.level_input_cut(1, 1, 1)
  sc.level_input_cut(2, 1, 0)
  sc.level_input_cut(1, 2, 0)
  sc.level_input_cut(2, 2, 1)
end

function mono()
  --set sc to mono input
  sc.level_input_cut(1, 1, 1)
  sc.level_input_cut(2, 1, 0)
  sc.level_input_cut(1, 2, 1)
  sc.level_input_cut(2, 2, 0)
end

function set_input(n)
  if n == 1 then
    stereo()
  else
    mono()
  end
end

function set_clock(x)
  if x == 1 then
    m:start()
    crow.input[1].mode("none")
  else
    m:stop()
    crow.input[1].mode("change", 2.0, 0.25, "rising")
  end
  for i=1,#step do
    step[i] = 1
  end
  count()
  redraw()
end

function set_crowIn2(x)
  if x == 1 then
    audio.level_cut(1)
    crow.input[2].mode("none")
    print("^^ in 2: OFF")
  else
    crow.input[2].mode("stream", 0.05)
    if x == 2 then
      crow.input[2].stream = scLevel
      print("^^ in 2: sc LEVEL")
    elseif x == 3 then
      crow.input[2].stream = scRate
      print("^^ in 2: sc RATE")
    end
  end
end

function scLevel(x)
  x = util.clamp(x,0,5)
  audio.level_cut((x*2)/10)
end

function scRate(x)
  x = util.clamp(x,-4,4)
  for i=1,2 do
    sc.rate(i,x)
  end
end

-- SEQUENCE LENGTH

function setn(t,n)
  setmetatable(t,{__len=function() return n end})
end

-- COMMANDS

-- Sequence
function metroSteady() m.time = clkSpd end
function metroDec() m.time = util.clamp(clkSpd * 2, clkSpd/16, clkSpd*4) end
function metroInc() m.time = util.clamp(clkSpd / 2, clkSpd/16, clkSpd*4) end
function metroTop() m.time = clkSpd/16 end
function metroBottom() m.time = clkSpd*4 end
function stepRnd() pos = math.random(1,#step) end

-- sc
function rateForward() for i=1,2 do sc.rate(i,rates[5]) end end
function rateReverse() for i=1,2 do sc.rate(i,rates[2]) end end
function rateInc() for i=1,2 do sc.rate(i,rates[math.random(4,6)]) end end
function rateDec() for i=1,2 do sc.rate(i,rates[math.random(1,3)]) end end
function rateRnd() for i=1,2 do sc.rate(i,rates[math.random(1,6)]) end end
function sPosStart() for i=1,2 do sc.position(i,loopStart) end end
function sPosRnd() for i=1,2 do sc.position(i,math.random(loopStart,loopEnd)) end end
function loopRnd() loopStart = math.random(sPoint,loopEnd-1) ; loopEnd = math.random(loopStart+1,ePoint) end
function rndPanL() panL = math.random(0,8)/-10 end
function rndPanR() panR = math.random(0,8)/10 end
function toggleRec() recLevel = 1 - recLevel end

-- Crow
function crowTrig() crow.output[1].execute() end
function crowRnd() crow.output[2].volts = math.random(10) end

local act = {metroSteady,metroDec,metroInc,metroBottom,metroTop,stepRnd,rateForward,rateReverse,rateInc,rateDec,rateRnd,sPosStart,sPosRnd,loopRnd,rndPanL,rndPanR,toggleRec,crowTrig,crowRnd}
local actCrow = {stepRnd,rateForward,rateReverse,rateInc,rateDec,rateRnd,sPosStart,sPosRnd,loopRnd,rndPanL,rndPanR,toggleRec,crowTrig,crowRnd}
local COMMANDS = 19
local COMMANDScrow = 14
local label = {"C", "<", ">", "[", "]", "?", "F", "R", "+", "-", "!", "1", "P", "L", "(", ")", "::", "T", "V"}
local labelCrow = {"?", "F", "R", "+", "-", "!", "1", "P", "L", "(", ")", "::", "T", "V" }
local description = {"- Steady clock", "- / clock speed by 2", "- * clock speed by 2", "- Bottom speed", "- Top speed", "- Jump to random step", "- Forward rate (1x)", "- Reverse rate (1x)", "- Increase rate", "- Decrease rate", "- Random rate", "- Loop start", "- Random position", "- Random loop start/end", "- Random pan pos (L)", "- Random pan pos (R)", "- Toggle record", "- Pulse (crow out 1)", "- Rnd voltage (crow out 2)"}

function init()

  -- PARAMS

  params:add_group("COMPASS",30)
  params:add_separator("RECORDING")
  params:add_option("Input", "Input", {"Stereo", "Mono (L)"}, 1)
  params:set_action("Input", function(x) set_input(x) end)
  params:add_control("Record Level","Record level",controlspec.new(0,1,'lin',0.01,1))
  params:set_action("Record Level", function(x) for i=1,2 do sc.rec_level(i,x) end  end)
  params:add_control("Overdub","Overdub",controlspec.new(0,1,'lin',0.01,1))
  params:set_action("Overdub", function(x) pre = x  end)
  params:add_control("Bit depth", "Bit depth", controlspec.new(4, 31, "lin", 0, 31, ''))
  params:set_action("Bit depth", function(x) engine.sdepth(x) end)

  params:add_separator("BUFFERS")
  -- params:add_group("BUFFERS",8)
  params:add{id="Rate (coarse)", name="Rate (coarse)", type="control",
    controlspec=controlspec.new(-2,2,'lin',0.25,1,""),
    action=function(x)
      sc.rate(1,x)
      sc.rate(2,x)
    end}
  params:add_control("Rate (slew)", "Rate (slew)", controlspec.new(0,2,'lin',0.01,0.1))
  params:set_action("Rate (slew)", function(x) rateSlew = x end)
  params:add_control("Fade","Fade",controlspec.new(0,1,'lin',0.01,0.05))
  params:set_action("Fade", function(x) fade = x  end)
  params:add_control("Pan (R)", "Pan (R)", controlspec.new(-1,1,'lin',0.01,0.5))
  params:set_action("Pan (R)", function(x) panR = x end)
  params:add_control("Pan (L)", "Pan (L)", controlspec.new(-1,1,'lin',0.01,-0.5))
  params:set_action("Pan (L)", function(x) panL = x end)
  params:add_control("Pan slew", "Pan (slew)", controlspec.new(0,2,'lin', 0.01,0.25))
  params:set_action("Pan slew", function(x) for i=1,2 do sc.pan_slew_time(i,x) end end)
  params:add_control("Start point","Start point",controlspec.new(1,ePoint-1,'lin',1,1))
  params:set_action("Start point", function(x) sPoint = util.clamp(x,1,ePoint-1); loopStart = sPoint end)
  params:add_control("End point","End point",controlspec.new(sPoint+1,65,'lin',1,65))
  params:set_action("End point", function(x) ePoint = util.clamp(x,sPoint+1,65); loopEnd = ePoint end)

  params:add_separator("CLOCKING")
  params:add_option("Clock", "Clock", {"Internal", "crow in 1"},1)
  params:set_action("Clock", function(x) set_clock(x) end)
  params:add_number("Clock speed","Int. Clock speed",1,4,1)
  params:set_action("Clock speed", function(x) clkSpd = x end)

  params:add_separator("CROW")
  params:add_option("Mode (input 2)", "Mode (input 2)", {"Off", "SC Level", "SC Rate"}, 1)
  params:set_action("Mode (input 2)", function(x) set_crowIn2(x) end)

  -- Arc control over loop start & end
  params:add_separator("ARC")
  arcify:register("Start point",1)
  arcify:register("End point",1)
  arcify:add_params()

  -- send audio input to sc input + adjust cut volume
  audio.level_cut(0.75)
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)

  -- METROS

  m = metro.init(count,clkSpd,-1)
  m:start()

  -- POSITION POLL

  sc.event_phase(update_positions)
  sc.poll_start_phase()

  -- CROW

  crow.input[1].change = count
  crow.output[1].action = "pulse(0.01,7,1)"
  crow.input[2].mode("none")

	-- softcut

	sc.buffer_clear()

  for i=1,2 do
    sc.enable(i,1)
    sc.buffer(i,i)
    sc.level(i,1.0)
    sc.rec_level(i,recLevel)
    sc.loop(i,1)
    sc.loop_start(i,1)
    sc.loop_end(i,loopEnd)
    sc.position(i,1)
    sc.play(i,1)
    sc.fade_time(i,fade)
    -- sc.rec_level(i,1)
    sc.pre_level(i,pre)
    sc.rec(i,1)
    sc.pan(1,panR)
    sc.pan(2,panL)
    sc.rate(i,1)
    sc.phase_quant(i,0.03)
    sc.rate_slew_time(i,rateSlew)
  end
  -- set PRE filter
  for i=1,2 do
    sc.pre_filter_dry(i,0)
    sc.pre_filter_lp(i,1)
    sc.pre_filter_hp(i,0)
    sc.pre_filter_bp(i,0)
    sc.pre_filter_br(i,0)
    sc.pre_filter_fc(i,18000)
    sc.pre_filter_rq(i,5)
    sc.pre_filter_fc_mod(i,1)
  end
  stereo()
end

--------------------------------------------------

function count()
  pos = (pos % #step) + 1
  if params:get("Clock") == 1 then
    if edit == pos and KEYDOWN2 == 1 then
      print("Ignored")
    else
      act[step[pos]]()
    end
  else
    if edit == pos and KEYDOWN2 == 1 then
      print("Ignored")
    else
      actCrow[step[pos]]()
    end
  end
  redraw()
end

-- Reset functions

function commReset()
  ratePos = 5
  for i=1,#step do
    step[i] = 1
  end
  for i=1,2 do
    sc.position(i,loopStart)
    sc.rate(i,1)
  end
end

function cutReset()
  for i=1,2 do
    sc.position(i,loopStart)
    sc.rate(i,1)
  end
  sc.buffer_clear()
end

--

function randomize_steps()
  for i=1,#step do
    if params:get("Clock") == 1 then
      step[i] = math.random(COMMANDS)
    else
      step[i] = math.random(COMMANDS-5)
    end
  end
end

-- ENCODERS & KEYS

function enc(n,d)
  if n==1 then
    if KEYDOWN1 == 1 then
      STEPS = util.clamp(STEPS+d,2,16)
    else
      pageNum = util.clamp(pageNum+d,1,#pages)
    end
  elseif n==2 then
    if KEYDOWN1 == 1 then
      params:delta("Start point",d)
      loopStart = sPoint
    else
      if pageNum == 1 then
        edit = util.clamp(edit+d,1,#step)
      end
    end
  elseif n==3 then
    if KEYDOWN1 == 1 then
      params:delta("End point",d)
      loopEnd = ePoint
    else
      if pageNum == 1 then
        if params:get("Clock") == 1 then
          step[edit] = util.clamp(step[edit]+d, 1, COMMANDS)
        else
          step[edit] = util.clamp(step[edit]+d, 1, COMMANDS-5)
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
    KEYDOWN2 = z
    if KEYDOWN1 == 1 then
      commReset()
    end
  elseif n == 3 then
    if z == 1 then
      down_time = util.time()
      if KEYDOWN1 == 1 then
        randomize_steps()
      end
    else
      hold_time = util.time() - down_time
      if hold_time < 1 and KEYDOWN1 == 0 then
        recLevel = 1 - recLevel
      elseif hold_time > 1 then
        for i=1,#step do
          cutReset()
        end
      end
    end
  end
  redraw()
end

-- SCREEN -------------------------------------------

function drawMenu()
  screen.move(2,10)
  screen.level(2)
  screen.text(pages[pageNum])
end

function drawEdit()
  screen.move(2,20)
  if recLevel >= 0.01 then
    screen.level(15)
    screen.rect(121,6,4,4)
    screen.fill()
  else
    screen.level(2)
  end
  screen.rect(121,6,4,4)
  screen.stroke()
  drawLoop()
  drawCommands()
end

function drawCommands()
  for i=1,#step do
    screen.move(i*8-8+2,58)
    if i == edit then
      screen.level(15)
    elseif i == pos then
      screen.level(3)
    else
      screen.level(1)
    end
    if params:get("Clock") == 1 then
      screen.text(label[step[i]])
    else
      screen.text(labelCrow[step[i]])
    end
  end
end

function drawLoop()
  screen.level(2)
  -- voice 1
  screen.move(2,(1*9)+27)
  screen.line(126,(1*9)+27)
  screen.stroke()
  screen.level(4)
  screen.move((loopStart*124)/loopLength-(124/loopLength)+2,(1*9)+27)
  screen.line((loopEnd*124)/loopLength-(124/loopLength)+2,(1*9)+27)

  screen.stroke()
  --
  screen.level(15)
  screen.move((sPoint*124)/loopLength-(124/loopLength)+2,(1*9)+26)
  screen.line_rel(0,1)
  screen.stroke()
  screen.level(15)
  screen.move((ePoint*124)/loopLength-(124/loopLength)+2,(1*9)+26)
  screen.line_rel(0,1)
  screen.stroke()
  --
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
  ---
  screen.level(15)
  screen.move((sPoint*124)/loopLength-(124/loopLength)+2,(2*9)+26)
  screen.line_rel(0,1)
  screen.level(15)
  screen.move((ePoint*124)/loopLength-(124/loopLength)+2,(2*9)+26)
  screen.line_rel(0,1)
  screen.stroke()
  ---
  screen.level(15)
  screen.move((positions[2]-1)*(124/(loopLength))+2,(2*9)+25)
  screen.line_rel(0,3)
  screen.stroke()
end

function drawHelp()
  if pageNum == 2 then
    screen.level(2)
    screen.move(126,10)
    screen.text_right("1/6")
    screen.level(15)
    for i=1,3 do
      screen.move(2,i*10+16)
      screen.text(label[i])
    end
    screen.level(4)
    for i=1,3 do
      screen.move(10,i*10+16)
      screen.text(description[i])
    end
    screen.level(2)
      screen.move(2,58)
  elseif pageNum == 3 then
    screen.level(2)
    screen.move(126,10)
    screen.text_right("2/6")
    screen.level(15)
    screen.level(15)
    for i=4,6 do
      screen.move(2,((i-3)*10)+16)
      screen.text(label[i])
    end
    screen.level(4)
    for i=4,6 do
      screen.move(10,((i-3)*10)+16)
      screen.text(description[i])
    end
  elseif pageNum == 4 then
    screen.level(2)
    screen.move(126,10)
    screen.text_right("3/6")
    screen.level(15)
    screen.level(15)
    for i=7,10 do
      screen.move(2,((i-6)*10)+16)
      screen.text(label[i])
    end
    screen.level(4)
    for i=7,10 do
      screen.move(10,((i-6)*10)+16)
      screen.text(description[i])
    end
  elseif pageNum == 5 then
    screen.level(2)
    screen.move(126,10)
    screen.text_right("4/6")
    screen.level(15)
    screen.level(15)
    for i=11,14 do
      screen.move(2,((i-10)*10)+16)
      screen.text(label[i])
    end
    screen.level(4)
    for i=11,14 do
      screen.move(10,((i-10)*10)+16)
      screen.text(description[i])
    end
  elseif pageNum == 6 then
    screen.level(2)
    screen.move(126,10)
    screen.text_right("5/6")
    screen.level(15)
    for i=15,17 do
      screen.move(2,((i-14)*10)+16)
      screen.text(label[i])
    end
    screen.level(4)
    for i=15,17 do
      screen.move(10,((i-14)*10)+16)
      screen.text(description[i])
    end
  elseif pageNum == 7 then
    screen.level(2)
    screen.move(126,10)
    screen.text_right("6/6")
    screen.level(15)
    for i=18,19 do
      screen.move(2,((i-17)*10)+16)
      screen.text(label[i])
    end
    screen.level(4)
    for i=18,19 do
      screen.move(10,((i-17)*10)+16)
      screen.text(description[i])
    end
  end
end

function redraw()
  screen.clear()
  drawMenu()
  if pageNum == 1 then
    drawEdit()
  else
    drawHelp()
  end
  screen.stroke()
  screen.update()
end
