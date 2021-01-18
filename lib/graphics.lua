draw_functions = {}

function draw_page_id(x,y)
  local page_name = {"Play", "Units", "Config"}
  -- screen.level(edit.page == 1 and state == 1 and 5 or 1 or edit.page > 1 and 5)
  if edit.page == 1 then
    if state == 1 then screen.level(5) else screen.level(1) end
  else
    screen.level(5)
  end
  screen.move(x,y)
  screen.text(page_name[edit.page])
  
  for i=1,3 do
    screen.level(i == edit.page and 15 or 2)
    screen.pixel(x+(i*4)-3,y+6)
    screen.stroke()
  end
end


function draw_page_name(x,y)
  screen.move(x,y)
  screen.text_right(page_name[edit.page])
end

function draw_unit_count(x,y)
  screen.level(selector == 5 and 15 or 2)
  screen.move(x,y)
  screen.text_right(edit.unit.."/"..#set)
end

function draw_unit_load(x,y)
  screen.move(x,y)
  screen.level(selector == id.unit and 15 or 2)
  screen.font_face(1)
  screen.font_size(24)
  if edit.unit <= #set then
    screen.text(edit.unit)
    screen.move(x+1,y+40)
    screen.font_size(8)
    if set[edit.unit].isLoaded == true then
      screen.level(selector == id.unit and 5 or 2)
      screen.text("Loaded")
    else
      screen.level(selector == id.unit and 5 or 0)
      screen.text("K3 load ; K2+3 load + rec")
    end
  else
    if edit.unit > #set and edit.unit < 9 then
      screen.text("New!")
      screen.move(x+1,y+40)
      screen.font_size(8)
      screen.level(selector == id.unit and 5 or 2)
      screen.text("K3 to create new unit")
    elseif edit.unit == 9 then
      screen.text("!")
      screen.move(x+1,y+40)
      screen.font_size(8)
      screen.level(selector == id.unit and 5 or 2)
      screen.text("embrace constraints")
    end
  end
end

function draw_record_button(x,y)
  screen.level(recLevel >= 0.01 and 15 or 3)
  screen.rect(x,y,15,15)
  screen.fill()
  screen.stroke()
  screen.level(recLevel >= 0.01 and 15 or 0)
  screen.rect(x+3,y+3,9,9)
  screen.fill()
  screen.stroke()
end




function draw_pointer(x,y)
  for i=2,4 do
    screen.level(i == selector and selector > 1 and selector < 5 and 10 or 0)
    screen.move(x, i*10 + y)
    screen.text_right("<")
  end
end


function draw_info(unit,x,y)
  screen.move(x,y)
  screen.level(5)
  if selector == id.tape then
    screen.text((set[unit].head-1).."."..(set[unit].tail-1))
  elseif selector == id.prob then
    screen.text(probs[set[unit].prob[edit.prob]])
  elseif selector == id.command then
    -- screen.text(set[unit].length)
  end
end

function draw_command_line(unit,x,y)
  screen.level(selector == id.command and 15 or 8)
  screen.move(x+104,y)
  screen.text(set[unit].length)
  for i=1,set[unit].length do
    screen.level(selector == id.command and i == edit.command and 15 or 2)
    
    if i == pos and edit.page == 1 then
      screen.level(5)
    end
    screen.move(i*6+x,y)
    screen.text(commands[set[unit].step[i]].label)
  end
end

function draw_prob_line(unit, x, y)
  screen.level(selector == id.prob and 15 or 8)
  screen.move(x+102,y)
  screen.text(probs[set[unit].prob[edit.prob]])
  for i=1,set[unit].length do
    screen.level(selector == id.prob and i == edit.prob and 15 or 2)
    screen.move(i*6+x,y)
    screen.line_rel(0,11-(set[unit].prob[i])-11)
    screen.stroke()
  end
end



function draw_loop(unit,x,y)
  local length = 90 -- 80
  screen.level(selector == id.tape and 15 or 8)
  screen.move(x+96,y)
  screen.text((set[unit].head-1).."."..(set[unit].tail-1))
  
  screen.level(2)
  -- draw full loop
  screen.move(x-1,y-2)
  screen.line(length+x,y-2)
  screen.stroke()
  -- draw sub-loop
  screen.level(4)
  screen.move((set[unit].loop_start*length)/loopLength-(length/loopLength)+x,y-2)
  screen.line((set[unit].loop_end*length)/loopLength-(length/loopLength)+x,y-2)
  screen.stroke()
  -- draw start/end points
  screen.level(15)
  screen.move((set[unit].head*length)/loopLength-(length/loopLength)+x,y-3)
  screen.line_rel(0,1)
  screen.stroke()
  screen.level(15)
  screen.move((set[unit].tail*length)/loopLength-(length/loopLength)+x,y-3)
  screen.line_rel(0,1)
  screen.stroke()
  -- draw playheads
  screen.level(15)
  for i=1,2 do
    screen.move((positions[i]-1)*(length/(loopLength))+(x-1),y-4)
    screen.line_rel(0,3)
    screen.stroke()
  end
end

function draw_unit(unit,x,y)
  draw_command_line(unit,x+10,y+10)
  draw_prob_line(unit,x+12,y+20)
  draw_loop(unit,x+18,y)
end

function draw_empty(x,y)
  screen.level(2)
  for i=1,3 do
    screen.move(x,y + (i*10))
    screen.line(x+90,y + (i*10))
    screen.stroke()
    screen.move(x+98,y + 2 + (i*10))
    screen.text("---")
  end
end

function draw_glyph(x,y,label)
  screen.rect(x,y,10,10)
  screen.stroke()
  screen.move(x+4,y+7)
  screen.text_center(label)
end

function draw_setup(x,y)
  for i=1,7 do
    screen.level(i == edit.setup and 15 or commands[i].is_enabled == false and 0 or 3)
    draw_glyph(i*13-10,7,commands[i].label)
  end
  for i=7,14 do
    screen.level(i == edit.setup and 15 or commands[i].is_enabled == false and 0 or 3)
    draw_glyph((i-7)*13-10,20,commands[i].label)
  end
  for i=14,19 do
    screen.level(i == edit.setup and 15 or commands[i].is_enabled == false and 0 or 3)
    draw_glyph((i-14)*13-10,33,commands[i].label)
  end
  screen.level(5)
  screen.font_size(8)
  screen.move(x+1,y+40)
  if edit.setup == 0 then
    screen.text("E2 select ; K3 disable/enable")
  else
    screen.text(commands[edit.setup].description)
  end
end

function splash()
  for n=1,5 do
    for i=1,max do
      screen.move(i*7-2,n*10)
      screen.level(math.random(2,8))
      screen.text(label[math.random(#label)])
    end
  end
end

------------------------------------------------

function draw_page_1()
  draw_pointer(124,18)
  draw_record_button(3,5)
  draw_unit(loaded(),-15,38)
end

function draw_page_2()
  draw_pointer(124,10)
    --draw_unit(edit.unit <= #set and edit.unit or (edit.unit - 1),-10,30)
  if edit.unit <= # set then
    draw_unit(edit.unit,-15,30)
  else
    -- draw_empty(7,18)
  end
  draw_unit_load(1,20)
end
  

  
return draw_functions

