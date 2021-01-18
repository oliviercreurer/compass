actions = {}

function actions.init()
  norns.enc.sens(1,8)
end

function enc_1_actions(n,d)
  if keydown[1] == 0 then
      edit.page = util.clamp(edit.page + d,1,3)
      if edit.page == 1 then
        selector = 2
      elseif edit.page == 2 then
        selector = 1
        edit.unit = loaded()
      end
    else
  end
end

function enc_2_actions(n,d)
  if edit.page == 1 then
        if selector == id.tape then set[loaded()]:update_head(d)
    elseif selector == id.prob then edit.prob = util.clamp(edit.prob + d, 1, set[loaded()].length)
    elseif selector == id.command then edit.command = util.clamp(edit.command + d, 1, set[loaded()].length)
    end
  elseif edit.page == 2 then
        if selector == id.unit then edit.unit = util.clamp(edit.unit + d, 1, #set+1)
    elseif selector == id.tape then set[edit.unit]:update_head(d)
    elseif selector == id.command then edit.command = util.clamp(edit.command + d, 1, set[edit.unit].length)
    elseif selector == id.prob then edit.prob = util.clamp(edit.prob + d, 1, set[edit.unit].length)
    end
  elseif edit.page == 3 then
    edit.setup = util.clamp(edit.setup + d, 1, #commands)
    print(edit.setup)
  end
end

function enc_3_actions(n,d)
  if keydown[2] == 0 then
          if selector == id.tape then set[edit.unit]:update_tail(d)
      elseif selector == id.command then set[edit.unit]:update_step(d, edit.command, #commands)
      elseif selector == id.prob then set[edit.unit]:update_prob(d, edit.prob)
      end
    else
          if selector == id.command then set[edit.unit]:update_length(d)
      elseif selector == id.prob then set[edit.unit]:update_all_probs(d)
    end
  end
end

function key_2_actions(k,z)
  keydown[2] = z
    if z == 1 then
      down_time = util.time() else hold_time = util.time() - down_time
      if hold_time < 0.25 then
        if edit.page == 1 then
          selector = selector + 1
          if selector > 4 then
            selector = 2
          end
        elseif edit.page == 2 then
          selector = (selector % 4) + 1
        end
      else
        -- nothing
      end
    end
end


function key_3_actions(k,z)
  keydown[3] = z
  if z == 1  then
    down_time = util.time() 
  else hold_time = util.time() - down_time
    if hold_time < 1 then
  
      if edit.page == 1 then
        if keydown[2] == 0 then
              if selector == id.tape    then if state == 1 then toggle_rec() end
          --elseif selector == id.command then set[loaded()]:randomize_commands(#act)
          elseif selector == id.command then clk:toggle()
          elseif selector == id.prob    then set[loaded()]:randomize_probs()
          end
        else
          if selector == id.tape then state = 1 - state ; toggle_app_state(state)
          elseif selector == id.command then set[loaded()]:randomize_commands(user_commands())
          elseif selector == id.prob then set[loaded()]:reset_probs()
          end
        end
      elseif edit.page == 2 then
        if keydown[2] == 0 then
              if selector == id.unit and edit.unit > #set  then create_unit(set); edit.unit = #set
          elseif selector == id.unit and edit.unit <= #set and set[edit.unit].isLoaded ~= true then load(set[edit.unit]); edit.page = 1; selector = 2; if params:get("unitrec") == 1 then recLevel = 1 end
          elseif selector == id.tape then ---
          elseif selector == id.command then set[edit.unit]:randomize_commands(user_commands())
          elseif selector == id.prob then set[edit.unit]:randomize_probs()
          end
        else -- if key2 is pressed then
              if selector == id.unit and edit.unit <= #set and set[edit.unit].isLoaded == false then load(set[edit.unit]); edit.page = 1; selector = 2; recLevel = 1;
          elseif selector == id.tape then ---
          elseif selector == id.command then set[edit.unit]:randomize_commands(user_commands())
          elseif selector == id.prob then set[loaded()]:reset_probs()
          end
        end
      elseif edit.page == 3 then
        if keydown[2] == 0 then
          toggle_command(edit.setup)
        else
          for i=1,#commands do
            commands[i].is_enabled = true
          end
        end
      end
    else
      -- long press actions
      if edit.page == 1 then
        if     selector == id.command then set[loaded()]:reset_commands(user_commands())
        elseif selector == id.tape then reset_buffers()
        end
      elseif edit.page == 2 then
        if selector == id.command then set[loaded()]:reset_commands(user_commands()) end
      end
    end
  end
end

return commands
