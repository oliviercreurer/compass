--
-- Compass (3.2)
-- Command-based looper
-- llllllll.co/t/compass/25192
-- @olivier w/ contributions
-- from @justmat + @gonecaving
--
--
-- see full manual @
-- compass-manual.glitch.me

g = grid.connect()
sc = softcut

pattern_time = require 'pattern_time'

local recLevel = 0
local pos = 1
local edit = 1
local clkSpd = 1
local division = 1

local loopLength = 64
local loopStart = 1
local sPoint = 1
local loopEnd = loopLength+1
local ePoint = loopLength+1
local loop_time = ePoint - sPoint

-- local fade = 0.05

local pageNum = 1
local rateSlew = 0.1

local down_time = 0
local KEYDOWN1 = 0
local KEYDOWN2 = 0
local key_mode = 0
local edit_lev = 0

local positions = {0,0}
local rate_pos = 5
local rates = {-2,-1,-0.5,0.5,1,2}

local STEPS = 16
local step = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}

local led_lev = 1
local metro_state = 1

local Arcify = include("lib/arcify")
local arcify = Arcify.new()

local COMMANDS = 18
local act = {
  label = {}
}

function update_positions(i,x)
  grid_redraw()
  positions[i] = util.clamp(x,0.1,loopEnd)
  for i=1,2 do
    sc.recpre_slew_time(i,2)
    if recLevel == 0 then
      sc.pre_level(i,1)
    else
      sc.pre_level(i,params:get("Overdub"))
    end
    -- sc.level(i,1)
    sc.rate_slew_time(i,rateSlew)
    sc.rec_level(i,recLevel)
    sc.loop_start(i,loopStart)
    sc.loop_end(i,loopEnd)
  end
  setn(step,STEPS)
  COMMANDS = #act
  redraw()
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
  sc.level_input_cut(1, 1, 0.5)
  sc.level_input_cut(2, 1, 0)
  sc.level_input_cut(1, 2, 0.5)
  sc.level_input_cut(2, 2, 0)
end

function set_input(n)
  if n == 1 then
    stereo()
  else
    mono()
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

-- Sequence ommands
function metroSteady() division = 1 end
function metroDec() division = util.clamp(division / 2, 1, 16) end
function metroInc() division = util.clamp(division * 2, 1, 16) end
function metroTop() division = 16 end
function metroBottom() division = 1 end
function stepRnd() pos = math.random(1,#step) end

-- Softcut
function rateForward() for i=1,2 do sc.rate(i,rates[5]) end end
function rateReverse() for i=1,2 do sc.rate(i,rates[2]) end end
function rateInc() rate_pos = util.clamp(rate_pos+1,1,6) ; for i=1,2 do sc.rate(i,rates[rate_pos]) end end
function rateDec() rate_pos = util.clamp(rate_pos-1,1,6) ; for i=1,2 do sc.rate(i,rates[rate_pos]) end end
function rateRnd() for i=1,2 do sc.rate(i,rates[math.random(1,6)]) end end
function sPosStart() for i=1,2 do sc.position(i,loopStart) end end
function sPosRnd() for i=1,2 do sc.position(i,math.random(loopStart,loopEnd)) end end
function loopRnd() loopStart = math.random(sPoint,loopEnd-1) ; loopEnd = math.random(loopStart+1,ePoint) end
function rndPanL() params:set("Pan (L)",math.random(0,8)/-10) end
function rndPanR() params:set("Pan (R)",math.random(0,8)/10) end
function toggleRec() recLevel = 1 - recLevel end

-- Record
function recordP()
  if recLevel == 0 then
    sc.buffer_clear()
    sPosStart()
    loopEnd = loopLength
    recLevel = 1
  else
    recLevel = 0
    sPosStart()
    loopEnd = math.floor(positions[1])
  end
end

-- Crow
function crowTrig() crow.output[1].execute() end
function crowRnd() crow.output[2].volts = math.random(10) end

local command_list = {
  {metroBottom,1,"[", "Slowest clock speed"},
  {metroTop,1,"]", "Fastest clock speed"},
  {metroDec,1,"<", "Decrement clock speed"},
  {metroInc,1,">", "Increment clock speed"},
  {stepRnd,1,"?", "Random sequence position"},
  {rateForward,1,"F", "Set SC rate to 1x"},
  {rateReverse,1,"R", "Set SC rate to -1x"},
  {rateInc,1,"+", "Set random forward rate"},
  {rateDec,1,"-", "Set random reverse rate"},
  {rateRnd,1,"!", "Set random rate"},
  {sPosStart,1,"1", "Jump to start of buffers"},
  {sPosRnd,1,"P", "Set random buffer positions"},
  {loopRnd,1,"L", "Set random loop length"},
  {rndPanL,1,"(", "Random pan position (L)"},
  {rndPanR,1,")", "Random pan position (R)"},
  {toggleRec,1,"::", "Toggle recording on/off"},
  {crowTrig,1,"T", "Crow trig (out 1)"},
  {crowRnd,1,"V", "Crow rnd voltage (out 2)"},
}

function build_command_list()
  act = { label = {} }
  for i=1,#command_list do
    if command_list[i][2] == 1 then
      table.insert(act,command_list[i][1])
      table.insert(act.label,command_list[i][3])
    end
  end
end

local grid_pattern = {}

function init()

  main_clk = clock.run(bang)

  -- COMMAND SETUP
  build_command_list()

  -- GRID SETUP
  for i=1,4 do
    grid_pattern[i] = pattern_time.new()
    grid_pattern[i].process = grid_pattern_execute
  end
  for i=13,16 do
    grid_pattern[i] = pattern_time.new()
    grid_pattern[i].process = grid_pattern_execute_comm
  end
  grid_redraw()

  -- PARAMS

  params:set("clock_tempo",80)

  params:add_group("COMPASS",26)
  params:add_separator("RECORDING")
  params:add_option("Input", "Input", {"Stereo", "Mono (L)"}, 1)
  params:set_action("Input", function(x) set_input(x) end)
  params:add_control("Record Level","Record level",controlspec.new(0,1,'lin',0.01,1))
  params:set_action("Record Level", function(x) for i=1,2 do sc.rec_level(i,x) end  end)
  params:add_control("Overdub","Overdub",controlspec.new(0,1,'lin',0.01,1))
  params:set_action("Overdub", function(x) end) --pre = x
  params:add_control("Rec", "Rec", controlspec.new(0,1,'lin',0.01,1))
  params:set_action("Rec", function() recordP() end)

  params:add_separator("BUFFERS")
  params:add{id="Rate (coarse)", name="Rate (coarse)", type="control",
    controlspec=controlspec.new(-4,4,'lin',0.50,1,""),
    action=function(x)
      sc.rate(1,x)
      sc.rate(2,x)
    end}
  params:add_control("Rate (slew)", "Rate (slew)", controlspec.new(0,2,'lin',0.01,0.1))
  params:set_action("Rate (slew)", function(x) rateSlew = x end)
  params:add_control("Fade","Fade",controlspec.new(0,1,'lin',0.01,0.05))
  params:set_action("Fade", function(x) for i=1,2 do sc.fade_time(i,x) end  end)
  params:add_control("Pan (R)", "Pan (R)", controlspec.new(-1,1,'lin',0.01,0.5))
  params:set_action("Pan (R)", function(x) sc.pan(1,x) end) --panR = x
  params:add_control("Pan (L)", "Pan (L)", controlspec.new(-1,1,'lin',0.01,-0.5))
  params:set_action("Pan (L)", function(x) sc.pan(2,x) end) --panL = x
  params:add_control("Pan slew", "Pan (slew)", controlspec.new(0,2,'lin', 0.01,0.25))
  params:set_action("Pan slew", function(x) for i=1,2 do sc.pan_slew_time(i,x) end end)

  -- params:add_control("Level slew", "Level (slew)", controlspec.new(0,10,'lin', 0.01,0.25))
  -- params:set_action("Level slew", function(x) for i=1,2 do sc.level_slew_time(i,x) end end)

  params:add_control("Start point","Start point",controlspec.new(1,ePoint-1,'lin',1,1))
  params:set_action("Start point", function(x) sPoint = util.clamp(x,1,ePoint-1); loopStart = sPoint end)
  params:add_control("End point","End point",controlspec.new(sPoint+1,65,'lin',1,65))
  params:set_action("End point", function(x) ePoint = util.clamp(x,sPoint+1,65); loopEnd = ePoint end)

  -- params:add_separator("CLOCKING")
  -- params:add_option("Clock", "Clock", {"Internal", "crow in 1"},1)
  -- params:set_action("Clock", function(x) set_clock(x) end)

  params:add_separator("CROW")
  params:add_option("Mode (input 2)", "Mode (input 2)", {"Off", "SC Level", "SC Rate"}, 1)
  params:set_action("Mode (input 2)", function(x) set_crowIn2(x) end)

  -- Arc control over loop start & end
  params:add_separator("ARC")
  arcify:register("Start point",1)
  arcify:register("End point",1)
  arcify:add_params()

  -- send audio input to sc input + adjust cut volume
  audio.level_cut(1)
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)

  -- CLOCK


  -- METROS
  -- m = metro.init(count,clkSpd,-1)
  -- m:start()
  e = metro.init(pulse,0.10,-1)
  ledcounter = metro.init(ledclk, 0.10, -1)
  ledcounter:start()


  -- POSITION POLL
  sc.event_phase(update_positions)
  sc.poll_start_phase()

  -- CROW
  crow.input[1].change = count
  crow.output[1].action = "pulse(0.01,7,1)"
  crow.input[2].mode("none")

  norns.enc.sens(1,5) -- set encoder 1 to sensitivity 4 (slower)

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
    sc.fade_time(i,params:get("Fade"))
    sc.pre_level(i,params:get("Overdub"))
    sc.rec(i,1)
    sc.pan(1,params:get("Pan (R)"))
    sc.pan(2,params:get("Pan (L)"))
    sc.rate(i,1)
    sc.phase_quant(i,0.03)
    sc.rate_slew_time(i,rateSlew)
    sc.level_slew_time(i,0.10)
    sc.pre_filter_dry(i, 1)
    sc.pre_filter_lp(i, 0)
    sc.pre_filter_hp(i, 0)
    sc.pre_filter_bp(i, 0)
    sc.pre_filter_br(i, 0)
  end
  stereo()
end

--------------------------------------------------

function bang()
  while true do
    clock.sync(1/division)
    count()
  end
end

function count()
  pos = (pos % #step) + 1
  if edit == pos and KEYDOWN2 == 1 then
    print("Ignored")
  else
    act[step[pos]]()
  end
  redraw()
end



-- RESET FUNCTIONS
function commReset()
  -- ratePos = 5
  for i=1,#step do
    step[i] = 1
  end
end

function cutReset()
  for i=1,2 do
    sc.position(i,loopStart)
    sc.rate(i,1)
  end
  sc.buffer_clear()
end

function randomize_steps()
  for i=1,#step do
    step[i] = math.random(COMMANDS)
  end
end

-- ENCODERS & KEYS

function enc(n,d)
  -- ENCODER 1
  if n==1 then
    if edit > #step then
        edit = #step
      end
    if KEYDOWN1 == 0 then
      -- increase max to 3 when third edit page is built
      pageNum = util.clamp(pageNum+d,1,2)
    else
      if pageNum == 1 then
        STEPS = util.clamp(STEPS+d,2,16)
      end
    end
  -- ENCODER 2
  elseif n==2 then
    if pageNum == 1 then
      if KEYDOWN1 == 0 then
        edit = util.clamp(edit+d,1,#step)
      else
        params:delta("Start point",d)
        loopStart = sPoint
        loop_time = ePoint - sPoint
      end
    elseif pageNum == 2 then
      edit = util.clamp(edit+d,1,#command_list)
    end
  -- ENCODER 3
  elseif n==3 then
    if pageNum == 1 then
      if KEYDOWN1 == 0 then
        step[edit] = util.clamp(step[edit]+d, 1, COMMANDS)
      else
        params:delta("End point",d)
        loopEnd = ePoint
        loop_time = ePoint - sPoint
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
    if KEYDOWN1 == 0 then
      if z == 1 then
        down_time = util.time()
      else
        hold_time = util.time() - down_time
        if pageNum == 1 then
          if hold_time < 1 then
            randomize_steps()
          else
            commReset()
          end
        elseif pageNum == 2 then
          command_list[edit][2] = 1 - command_list[edit][2]
          build_command_list()
          commReset()
          -- for i=1,#command_list do
          --   if act[step[i]] == command_list[i][1] then
          --     if command_list[i][2] == 0 then
          --       act[step[i]] = act[step[1]]
          --     end
          --   end
          -- end
        elseif pageNum == 3 then

        end
      end
    else
      if z == 1 then
        if pageNum == 1 then
          metro_state = 1 - metro_state
          if metro_state == 1 then
            main_clk = clock.run(bang)
          else
            clock.cancel(main_clk)
          end
        end
      end
    end


  elseif n == 3 then

    if KEYDOWN1 == 0 then
      if z == 1 then
        down_time = util.time()
      else
        hold_time = util.time() - down_time
        if pageNum == 1 then
          if hold_time < 1 then
            recLevel = 1 - recLevel
          else
            cutReset()
          end
        elseif pageNum == 2 then
          -- future saving/loading stuff
        elseif pageNum == 3 then
          -- nothing
        end
      end
    end
  end
  redraw()
end

-- GRID ---------------------------------------------

-- local gridRate = 10
local gridALT = 0
local pattern_mode = 0

function ledclk()
  led_lev = (led_lev % 15) + 1
end

function patternbank_a(x,y,z)
  for i=1,4 do
    if z == 1 and y == 1 and x == i then
      led_lev = 1
      if gridALT == 0 then
        if grid_pattern[i].rec == 1 then
          grid_pattern[i]:rec_stop()
          grid_pattern[i]:start()
        elseif grid_pattern[i].count == 0 then
          grid_pattern[i]:rec_start()
        elseif grid_pattern[i].play == 1 then
          grid_pattern[i]:stop()
        else
          grid_pattern[i]:start()
        end
      elseif gridALT == 1 then
        grid_pattern[i]:rec_stop()
        grid_pattern[i]:stop()
        grid_pattern[i]:clear()
        g:all(0)
      end
    end
    if pattern_mode == 0 then
      if z == 1 and y == 1 and x ~= i and x < 5 then
        if gridALT == 0 then
          grid_pattern[i]:stop()
        end
      end
    else
      if z == 1 and y == 1 and x ~= i then
        if gridALT == 0 then
          grid_pattern[i]:stop()
        end
      end
    end
  end
  for i=1,4 do
    if z == 1 and y ~= 8 then
      record_this = {}
      record_this.x = x
      record_this.y = y
      grid_pattern[i]:watch(record_this)
      g:all(0)
      g:led(x,y,z*15)
    end
  end
end

function patternbank_b(x,y,z)
  for i=13,16 do
    if z == 1 and y == 1 and x == i then
      led_lev = 1
      if gridALT == 0 then
        if grid_pattern[i].rec == 1 then
          grid_pattern[i]:rec_stop()
          grid_pattern[i]:start()
        elseif grid_pattern[i].count == 0 then
          grid_pattern[i]:rec_start()
        elseif grid_pattern[i].play == 1 then
          grid_pattern[i]:stop()
        else
          grid_pattern[i]:start()
        end
      elseif gridALT == 1 then
        grid_pattern[i]:rec_stop()
        grid_pattern[i]:stop()
        grid_pattern[i]:clear()
        g:all(0)
      end
    end
    if pattern_mode == 0 then
      if z == 1 and y == 1 and x ~= i and x > 12 then
        if gridALT == 0 then
          grid_pattern[i]:stop()
        end
      end
    else
      if z == 1 and y == 1 and x ~= i then
        if gridALT == 0 then
          grid_pattern[i]:stop()
        end
      end
    end
  end
  for i=13,16 do
    if z == 1 and y ~= 8 then
      record_this = {}
      record_this.x = x
      record_this.y = y
      grid_pattern[i]:watch(record_this)
      g:all(0)
      g:led(x,y,z*15)
    end
  end
end

g.key = function(x,y,z)
  if x == 1 and y == 8 then
    gridALT = z
  end
  if pageNum == 1 then
    patternbank_a(x,y,z)
    patternbank_b(x,y,z)
    if z == 1 then
      if x == 16 and y == 8 then
        metro_state = 1 - metro_state
        if metro_state == 1 then
          main_clk = clock.run(bang)
        else
          clock.cancel(main_clk)
        end
      elseif x == 1 and y == 2 then
        pattern_mode = 1 - pattern_mode
      elseif x > 0 and y == 7 then
        if gridALT == 1 then
          STEPS = x
        else
          pos = x-1
          count()
        end

      elseif y == 4 then
        sc.position(1,math.floor((x*65)/16)-3)
      elseif y == 5 then
        sc.position(2,math.floor((x*65)/16)-3)
      end
    end
  else
    for i=1,9 do
      if x == i and y == 4 and z == 1 then
        if gridALT == 1 then
          command_list[i][2] = 1 - command_list[i][2]
          build_command_list()
          commReset()
        end
        edit = x

      end
    end
    for i=10,#command_list do
      if x == (i-9) and y == 5 and z == 1 then
        if gridALT == 1 then
          command_list[i][2] = 1 - command_list[i][2]
          build_command_list()
          commReset()
        end
        edit = x+9

      end
    end
  end
  redraw()
end

function grid_pattern_execute(recorded)
  g:all(0)
  g:led(recorded.x,recorded.y,15)
  grid_redraw()
  g:refresh()
  if recorded.y == 4 then
    sc.position(1,math.floor((recorded.x*65)/16)-3)
  elseif recorded.y == 5 then
    sc.position(2,math.floor((recorded.x*65)/16)-3)
  end
  if pattern_mode == 1 then
    if recorded.y == 7 then
      pos = recorded.x-1
      count()
    end
  end
end

function grid_pattern_execute_comm(recorded)
  g:all(0)
  g:led(recorded.x,recorded.y,15)
  grid_redraw()
  g:refresh()
  if recorded.y == 7 then
    pos = recorded.x-1
    count()
  end
  if pattern_mode == 1 then
    if recorded.y == 4 then
      sc.position(1,math.floor((recorded.x*65)/16)-3)
    elseif recorded.y == 5 then
      sc.position(2,math.floor((recorded.x*65)/16)-3)
    end
  end
end

function grid_redraw()
  g:all(0)
  g:led(1,8,5)
  if pageNum == 1 then
    for i=1,4 do
      if grid_pattern[i].rec == 1 then
        g:led(i,1,led_lev)
      elseif grid_pattern[i].play == 1 then
        g:led(i,1,15)
      elseif grid_pattern[i].play == 0 and grid_pattern[i].count > 0 then
        g:led(i,1,5)
      else
        g:led(i,1,3)
      end
    end

    for i=13,16 do
      if grid_pattern[i].rec == 1 then
        g:led(i,1,led_lev)
      elseif grid_pattern[i].play == 1 then
        g:led(i,1,15)
      elseif grid_pattern[i].play == 0 and grid_pattern[i].count > 0 then
        g:led(i,1,5)
      else
        g:led(i,1,3)
      end
    end

    local gStart = util.clamp(math.abs(math.floor(sPoint*16/65)+1),1,16)
    local gEnd = util.clamp(math.abs(math.floor(ePoint*16/65)+1),1,16)

    -- clock led
    g:led(16,8,metro_state*3+3)
    -- pattern mode led
    g:led(1,2,pattern_mode*7+3)
    for i=1,16 do
      g:led(i,7,2)
    end
    for i=1,STEPS do
      g:led(i,7,i==pos and 15 or 5)
    end
    for i=gStart,gEnd do
      g:led(i,4,i==util.clamp(math.abs(math.floor((positions[1]*16)/65)+1),1,16) and 15 or 5)
      g:led(i,5,i==util.clamp(math.abs(math.floor((positions[2]*16)/65)+1),1,16) and 15 or 5)
    end
  elseif pageNum == 2 then
    for i=1,9 do
      g:led((i),4,(command_list[i][2]*5)+3)
    end
    for i=10,#command_list do
      g:led(((i-9)),5,(command_list[i][2]*5)+3)
    end
  end
  g:refresh()
end

-- SCREEN -------------------------------------------

function pulse()
  edit_lev = (edit_lev % 10) + 1
end

function drawMenu()

    screen.move(2,10)
    if pageNum == 1 then
      screen.level(10)
      screen.text("Play")
    else
      screen.level(10)
      screen.text("Edit")
      screen.move(20,10)
      screen.level(1)
      -- if pageNum == 2 then
      --   screen.text("| 1")
      -- elseif pageNum == 3 then
      --   screen.text("| 2")
      -- elseif pageNum == 4 then
      --   screen.text("| 3")
      -- end
    end
    screen.move(124,10)
    screen.level(3)
    if KEYDOWN1 == 1 then
      screen.move(22,10)
      screen.level(2)
      screen.text("| "..loop_time.."s.")
    end
end

function drawEdit()
  screen.move(2,20)
  if key_mode == 0 then
    if recLevel >= 0.01 then
      screen.level(15)
      screen.rect(121,6,4,4)
      screen.fill()
    else
      screen.level(2)
    end
    screen.rect(121,6,4,4)
  end

  screen.stroke()
  drawLoop()
  drawCommands()
end

function drawCommands()

  for i=1,#step do
    screen.move(i*8-8+2,58)
    if pageNum == 1 then
      if i == edit then
        screen.level(15)
      elseif i == pos then
        screen.level(3)
      else
        screen.level(1)
      end
      screen.text(act.label[step[i]])
    elseif pageNum == 3 then
      screen.level(10)
      screen.text(act.label[step[i]])
    end
  end

end

function draw_ref()
  for i=1,9 do
    screen.level((command_list[i][2]*10)+1)
    screen.move(i*10-8,27)
    screen.text(command_list[i][3])
    --
    screen.move(i*10-8,32)
    if i == edit then
      screen.level(10)
    else
      screen.level(2)
    end
    screen.line_rel(5,0)
    screen.stroke()
  end
  for i=10,#command_list do
    screen.level((command_list[i][2]*10)+1)
    screen.move((i-8)*10-18,42)
    screen.text(command_list[i][3])
    --
    screen.move((i-8)*10-18,47)
    if i == edit then
      screen.level(10)
    else
      screen.level(2)
    end
    screen.line_rel(5,0)
    screen.stroke()
  end
  screen.level(5)
  screen.move(2,58)
  screen.text(command_list[edit][4])
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

-- function set_clock(x)
--   if x == 1 then
--     m:start()
--     crow.input[1].mode("none")
--     for i=1,5 do
--       command_list[i][2] = 1
--     end
--     build_command_list()
--     commReset()
--   else
--     m:stop()
--     crow.input[1].mode("change", 2.0, 0.25, "rising")
--     for i=1,5 do
--       command_list[i][2] = 0
--     end
--     build_command_list()
--     commReset()
--   end
--   for i=1,#step do
--     step[i] = 1
--   end
--   count()
--   redraw()
-- end

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

function redraw()
  screen.clear()
  drawMenu()
  if pageNum == 1 then
    drawEdit()
  elseif pageNum == 2 then

    draw_ref()
  elseif pageNum == 3 then
    drawMenu()
    drawCommands()
  end
  screen.stroke()
  screen.update()
end
