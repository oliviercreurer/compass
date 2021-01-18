unit = {}

function unit:new(id)
  local o = setmetatable({}, { __index = unit })
  -- Constructor
  o.id = (id or nil)
  o.isLoaded = false
  o.length = 16
  o.tape = 1
  o.head = 1
  o.tail = 61 
  o.loop_start = 1 
  o.loop_end = 61 
  o.prob = {}
  o.step = {}
  for i=1,o.length do
    o.prob[i] = 5
    o.step[i] = 1
  end
  return o
end

function create_unit(t)
  if #t >= 8 then return end
  table.insert(t,unit:new(#t+1))
end 

function delete_unit(t,unit)
  table.remove(t,unit)
end

function load(x)
  for i=1,#set do set[i].isLoaded = false end
  x.isLoaded = true
  redraw()
end

function loaded()
  for i=1,#set do
    if set[i].isLoaded == true then return set[i].id end
  end
end

function unit:update_length(delta)
  self.length = util.clamp(self.length + delta, 2, 16)
  if edit.command > self.length then
    edit.command = self.length
  end
  if edit.prob > self.length then
    edit.prob = self.length
  end
end

function unit:update_head(delta)
  self.head = util.clamp(self.head + delta, 1, self.tail - 1) 
  self.loop_start = self.head
end

function unit:update_tail(delta)
  self.tail = util.clamp(self.tail + delta, self.head + 1, 61) 
  self.loop_end = self.tail
end

function unit:rand_loop()
  self.loop_start = math.random(self.head,self.loop_end - 1)
  self.loop_end = math.random(self.loop_start + 1, self.tail)
end

function unit:update_step(delta, pos, max)
  self.step[pos] = util.clamp(self.step[pos] + delta, 1, max)
end

function unit:update_prob(delta, pos)
  self.prob[pos] = util.clamp(self.prob[pos] + delta, 1, 5)
end

function unit:randomize_probs()
  for i=1,#self.prob do
    self.prob[i] = math.random(2,5)
  end
end

function unit:update_all_probs(delta)
  for i=1,#self.prob do
    self.prob[i] = util.clamp(self.prob[i] + delta, 1, 5)
  end
end 

function unit:reset_probs()
  for i=1,#self.prob do
    self.prob[i] = 5
  end
end

function unit:randomize_commands(t)
  for i=1,#self.step do
    self.step[i] = t[math.random(#t)]
  end 
end 

function unit:reset_commands(t)
  for i=1,#self.step do
    self.step[i] = t[1]
  end
end

function unit.init()
  create_unit(set)
  load(set[1])
end

return unit