-- Compass

lattice = require("lattice")

local unit = include '/lib/unit'
local draw = include '/lib/graphics'
local sc = include 'lib/softcut-setup'
local prms = include 'lib/prms'
local action = include 'lib/actions'
local timing = include 'lib/timing'
local command = include 'lib/commands'
local functions = include 'lib/functions'


-- store units in set table
set = {}
act = {}

state = 1
selector = 2
probs = {0,25,50,75,100}
down_time = 0
loopLength = 60
keydown = {0,0,0}
sc = softcut
positions = {1,1}
pos = 1
division = 1
recLevel = 0

edit = {page = 1, unit = 1, command = 1, prob = 1, setup = 0}
id = {unit = 1, tape = 2, command = 3, prob = 4, setup = 5 }

edit.page = 1

function user_commands()
  local config = {}
    for i=1,#commands do
      if commands[i].is_enabled == true then
        table.insert(config, commands[i].id)
      end
    end
  return config
end

function toggle_command(command)
  if commands[command].is_enabled == true then
    commands[command].is_enabled = false
  else
    commands[command].is_enabled = true
  end
  user_commands()
  if commands[command].is_enabled == false then
    for i=1,#set do
      for n=1,#set[i].step do
        if set[i].step[n] == command then
          set[i].step[n] = user_commands()[1]
        end
      end
    end
  end
end

function init()
  functions.init()
  command.init()
  unit.init()
  actions.init()
  timing.init()
  prms.init()
  softcut.init()
  user_commands()
  redraw()
end

function count()
  clk:set_division(1/division)
  pos = (pos % set[loaded()].length) + 1
  if commands[set[loaded()].step[pos]].is_enabled == true then
    if math.random(1,100) <= probs[set[loaded()].prob[pos]] then
      commands[set[loaded()].step[pos]].action()
    end
  end
  redraw()
end

function enc(n,d)
      if n == 1 then enc_1_actions(n,d)
  elseif n == 2 then enc_2_actions(n,d)
  elseif n == 3 then enc_3_actions(n,d)
  end
  redraw()
end

function key(k,z)
  if     k == 2 then key_2_actions(k,z)
  elseif k == 3 then key_3_actions(k,z)
  end
  redraw()
end

function redraw()
  screen.clear()
  draw_page_id(99,12)
  screen.font_size(8)
  screen.font_face(1)
  if     edit.page == 1 then draw_page_1()
  elseif edit.page == 2 then draw_page_2()
  elseif edit.page == 3 then draw_setup(1,20)
  end
  screen.update()
end

