command = {}

function command.init()
  
  commands = {}
  
  commands[1] = {
    id = 1,
    action = clk_min,
    is_enabled = true,
    label = "[",
    description = "Slowest clock speed"
  }
  
  commands[2] = {
    id = 2,
    action = clk_max,
    is_enabled = true,
    label = "]",
    description = "Fastest clock speed",
  }
  
  commands[3] = {
    id = 3,
    action = clk_dec ,
    is_enabled = true,
    label = "<",
    description = "Decrease clock speed",
  }
  
  commands[4] = {
    id = 4,
    action = clk_inc,
    is_enabled = true,
    label = ">",
    description = "Increase clock speed",
  }
  
  commands[5] = {
    id = 5,
    action = rnd_step,
    is_enabled = true,
    label = "?",
    description = "Jump to random step",
  }
  
  commands[6] = {
    id = 6,
    action = forward_rate,
    is_enabled = true,
    label = "F",
    description = "Set softcut rate to 1",
  }
  
  commands[7] = {
    id = 7,
    action = reverse_rate,
    is_enabled = true,
    label = "R",
    description = "Set softcut rate to -1",
  }
  
  commands[8] = {
    id = 8,
    action = rate_inc,
    is_enabled = true,
    label = "+",
    description = "Increase softcut rate",
  }
  
  commands[9] = {
    id = 9,
    action = rate_dec,
    is_enabled = true,
    label = "-",
    description = "Decrease softcut rate",
  }
  
  commands[10] = {
    id = 10,
    action = rnd_rate,
    is_enabled = true,
    label = "!",
    description = "Set random softcut rate",
  }
  
  commands[11] = {
    id = 11,
    action = start_pos,
    is_enabled = true,
    label = "1",
    description = "Jump to start of buffers",
  }
  
  commands[12] = {
    id = 12,
    action = rnd_pos,
    is_enabled = true,
    label = "P",
    description = "Set random buffer positions",
  }
  
  commands[13] = {
    id = 13,
    action = rnd_loop,
    is_enabled = true,
    label = "L",
    description = "Set random loop length",
  }
  
  commands[14] = {
    id = 14,
    action = rnd_overdub,
    is_enabled = true,
    label = "O",
    description = "Set random overdub amount",
  }
  
  commands[15] = {
    id = 15,
    action = rnd_pan_l,
    is_enabled = true,
    label = "(",
    description = "Set random pan position (L)",
  }
  
  commands[16] = {
    id = 16,
    action = rnd_pan_r,
    is_enabled = true,
    label = ")",
    description = "Set random pan position (R)",
  }
  
  commands[17] = {
    id = 17,
    action = toggle_rec ,
    is_enabled = true,
    label = "::",
    description = "Toggle recording",
  }
  
  commands[18] = {
    id = 18,
    action = crow_trig ,
    is_enabled = true,
    label = "T",
    description = "Crow - pulse (out 1)",
  }
  
  commands[19] = {
    id = 19,
    action = crow_rnd,
    is_enabled = true,
    label = "V",
    description = "Crow - rnd voltage (out 2)",
  }
  
end


return command