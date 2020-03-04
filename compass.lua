--
-- Compass (2.1)
-- Command-based looper
-- @olivier
-- llllllll.co/t/compass/25192
-- w/ contributions from
-- @justmat + @gonecaving
--
-- E1: Scroll pages
-- E2: Navigate to step
-- E3: Select command
-- K2(short): Reset commands
-- K2(long): Randomize commands
-- K3(short): Rec ON/OFF
-- K3(long): Clear buffers
-- K1(hold) + E1 : sequence length
-- K1(hold) + E2 : set loop start
-- K1(hold) + E3 : set loop end

engine.name = "Decimatec"

local rate = 1
local ratePos = 5
local rec = 0
local recLevel = 1
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
    softcut.pre_level(i,pre)
    softcut.level(i,1)
    softcut.rate_slew_time(i,rateSlew)
    softcut.rec(i,rec)
    softcut.loop_start(i,loopStart)
    softcut.loop_end(i,loopEnd)
    softcut.fade_time(i,fade)
    softcut.pan(1,panR)
    softcut.pan(2,panL)
  end
  setn(step,STEPS)
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
      print("^^ in 2: SOFTCUT LEVEL")
    elseif x == 3 then
      crow.input[2].stream = scRate
      print("^^ in 2: SOFTCUT RATE")
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
    softcut.rate(i,x)
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


-- Softcut
function rateForward() for i=1,2 do softcut.rate(i,rates[5]) end end
function rateReverse() for i=1,2 do softcut.rate(i,rates[2]) end end
-- function rateInc() ratePos = util.clamp(ratePos+1,1,6) for i=1,2 do softcut.rate(i,rates[ratePos]) end end
-- function rateDec() ratePos = util.clamp(ratePos-1,1,6) for i=1,2 do softcut.rate(i,rates[ratePos]) end end
function rateInc() for i=1,2 do softcut.rate(i,rates[math.random(4,6)]) end end
function rateDec() for i=1,2 do softcut.rate(i,rates[math.random(1,3)]) end end
function rateRnd() for i=1,2 do softcut.rate(i,rates[math.random(1,6)]) end end
function sPosStart() for i=1,2 do softcut.position(i,loopStart) end end
function sPosRnd() for i=1,2 do softcut.position(i,math.random(loopStart,loopEnd)) end end
function loopRnd() loopStart = math.random(sPoint,loopEnd-1) ; loopEnd = math.random(loopStart+1,ePoint) end
function rndPanL() panL = math.random(0,9)/-10 end
function rndPanR() panR = math.random(0,9)/10 end
function toggleRec() rec = 1 - rec end

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
  
  params:add_option("input", "Input", {"Stereo", "Mono (L)"}, 1)
  params:set_action("input", function(x) set_input(x) end)
  params:add_option("clock", "Clock", {"Internal", "crow in 1"},1)
  params:set_action("clock", function(x) set_clock(x) end)
  params:add_number("clockSpeed","Int. Clock Speed",1,4,1)
  params:set_action("clockSpeed", function(x) clkSpd = x end)
  params:add_option("cutlevel", "Crow in 2", {"Off", "SC Level", "SC Rate"}, 1)
  params:set_action("cutlevel", function(x) set_crowIn2(x) end)
  
  params:add_separator()
  
  params:add_control("REC","Record level",controlspec.new(0,1,'lin',0.01,1))
  params:set_action("REC", function(x) for i=1,2 do softcut.rec_level(i,x) end  end)
  params:add_control("PRE","Overdub",controlspec.new(0,1,'lin',0.01,1))
  params:set_action("PRE", function(x) pre = x  end)
  params:add{id="rate12", name="Rate (coarse)", type="control",
    controlspec=controlspec.new(-2,2,'lin',0.25,1,""),
    action=function(x)
      softcut.rate(1,x)
      softcut.rate(2,x)
    end}
  params:add_control("RATE_SLEW", "Rate (slew)", controlspec.new(0,2,'lin',0.01,0.1))
  params:set_action("RATE_SLEW", function(x) rateSlew = x end)
  params:add_control("FADE","Fade",controlspec.new(0,1,'lin',0.01,0.05))
  params:set_action("FADE", function(x) fade = x  end)
  params:add_control("PAN_R", "Pan (R)", controlspec.new(-1,1,'lin',0.01,0.5))
  params:set_action("PAN_R", function(x) panR = x end)
  params:add_control("PAN_L", "Pan (L)", controlspec.new(-1,1,'lin',0.01,-0.5))
  params:set_action("PAN_L", function(x) panL = x end)
  params:add_control("PAN_SLEW", "Pan (slew)", controlspec.new(0,2,'lin', 0.01,0.25))
  params:set_action("PAN_SLEW", function(x) for i=1,2 do softcut.pan_slew_time(i,x) end end)
  params:add_control("START POINT","Start Point",controlspec.new(1,ePoint-1,'lin',1,1))
  params:set_action("START POINT", function(x) sPoint = util.clamp(x,1,ePoint-1); loopStart = sPoint end)
  params:add_control("END POINT","End Point",controlspec.new(sPoint+1,65,'lin',1,65))
  params:set_action("END POINT", function(x) ePoint = util.clamp(x,sPoint+1,65); loopEnd = ePoint end)
  -- params:add_control("LOOP START","Loop Start",controlspec.new(sPoint,ePoint,'lin',1,1))
  -- params:set_action("LOOP START", function(x) loopStart = util.clamp(x,sPoint,ePoint-1) end)
  -- params:add_control("LOOP END","Loop End",controlspec.new(sPoint,ePoint,'lin',1,65))
  -- params:set_action("LOOP END", function(x) loopEnd = util.clamp(x,sPoint+1,ePoint) end)
  
  params:add_separator()
  
  params:add_control("bit_depth", "bit depth", controlspec.new(4, 31, "lin", 0, 31, ''))
  params:set_action("bit_depth", function(x) engine.sdepth(x) end)
  params:add_control("CUT_LEVEL", "Cut level", controlspec.new(0,1,'lin',0.01,1))
  params:set_action("CUT_LEVEL", function(x) audio.level_cut(x) end)
  params:add_control("IN_LEVEL", "Input level", controlspec.new(0,1,'lin',0.01,1))
  params:set_action("IN_LEVEL", function(x) audio.level_adc(x) end)

  -- Arc control over loop start & end 
  -- params:add_separator()
  arcify:register("LOOP START",1)
  arcify:register("LOOP END",1)
  arcify:add_params()
  
  -- send audio input to softcut input + adjust cut volume
  
  audio.level_cut(1)
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  
  -- METROS
  
  m = metro.init(count,clkSpd,-1)
  m:start()
  
  -- POSITION POLL
  
  softcut.event_phase(update_positions)
  softcut.poll_start_phase()
  
  -- CROW
  
  crow.input[1].change = count
  crow.output[1].action = "pulse(0.01,7,1)"
  crow.input[2].mode("none")
  -- crow.input[2].stream = scLevel
  
	-- SOFTCUT 
	
	softcut.buffer_clear()
	
  for i=1,2 do
    softcut.enable(i,1)
    softcut.buffer(i,i)
    softcut.level(i,1.0)
    softcut.rec_level(i,recLevel)
    softcut.loop(i,1)
    softcut.loop_start(i,1)
    softcut.loop_end(i,loopEnd)
    softcut.position(i,1)
    softcut.play(i,1)
    softcut.fade_time(i,fade)
    softcut.rec_level(i,1)
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
  
  stereo()
  
end

--------------------------------------------------

function count()
  pos = (pos % #step) + 1
  if params:get("clock") == 1 then
    act[step[pos]]()
  else
    actCrow[step[pos]]()
  end
  redraw()
end

function cutReset()
  for i=1,2 do
    softcut.position(i,loopStart)
    softcut.rate(i,1)
  end
  softcut.buffer_clear()
end

function randomize_steps()
  for i=1,#step do
    if params:get("clock") == 1 then
      step[i] = math.random(COMMANDS)
    else
      step[i] = math.random(COMMANDS-5)
    end
  end
end

function enc(n,d)
  if n==1 then
    if KEYDOWN1 == 1 then
      STEPS = util.clamp(STEPS+d,2,16)
    else 
      pageNum = util.clamp(pageNum+d,1,#pages)
    end
  elseif n==2 then
    if KEYDOWN1 == 1 then
      params:delta("START POINT",d)
      loopStart = sPoint
    else
      if pageNum == 1 then
        edit = util.clamp(edit+d,1,#step)
      end
    end
  elseif n==3 then
    if KEYDOWN1 == 1 then
      --params:delta("LOOP END",d)
      params:delta("END POINT",d)
      loopEnd = ePoint
    else
      if pageNum == 1 then
        if params:get("clock") == 1 then
          step[edit] = util.clamp(step[edit]+d, 1, COMMANDS)
        else
          step[edit] = util.clamp(step[edit]+d, 1, COMMANDS-5)
        end
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
        ratePos = 5
        for i=1,#step do
          step[i] = 1
        end
        for i=1,2 do
          softcut.position(i,loopStart)
          softcut.rate(i,1)
        end
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
      end
    end
  end
  redraw()
end

function drawMenu()
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
    if params:get("clock") == 1 then
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
    -- if params:get("clock") == 2 then
    --   screen.text("DISABLED: EXTERNAL CLOCK")
    -- else
    --   screen.text("")
    -- end
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
