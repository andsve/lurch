local b = {}

-- load external triggers
--triggers = {} -- { trigger_id = trigger_func(bot, chan, msg) }
--dofile("triggers.lua")

-- extra class vars
b.trusted_users = {"sweetfish"}

-- fancy print to console
function b:log(str)
  print("[" .. os.date() .. "] " .. str)
end

-- send a raw message to the server
function b:send(str)
  self.client:send(str .. "\n")
  self:log("[<-] " .. str)
end

-- called when we have a working connection
function b:on_connected()
  
  -- join all channels we know
  for k,v in pairs(self.config.channels) do
    self:join_channel(v)
  end
end

function b:is_trusted_user(nickname)
  
  for k,v in pairs(self.trusted_users) do
    if v == nickname then
      return true
    end
  end
  
  return false
end

-- parse incomming messages
function b:parse_message(line, err)
  if not err then
    self:log("[->] " .. tostring(line))
  else
    self:log("Recieved an error: " .. tostring(err) .. " (line '" .. tostring(line) .. "')")
  end

  -- first incomming message?
  if not self.firstresponse then
    self.firstresponse = true
  
    -- send auth response
    self:send("NICK " .. self.config.nickname)
    self:send("USER " .. self.config.nickname .. " lua bot :mr lurch")
    return
  end
  
  -- we have a working connection!
  if string.sub(line, 1, 1) == ":" then
    if not self.connection_ok then
      self.connection_ok = true
      if not (self.on_connected == nil) then
        self:on_connected()
      end
    end
  end

  -- ping message?
  if string.sub(line, 1, 4) == "PING" then
    self:send("PONG " .. string.sub(line, 6))
    return
  end
  
  -- trigger ?
  -- (triggers are in the form of ':<triggername>')
  local i,j,s,c,k = string.find(line, ":(.-)!.- PRIVMSG (.-) :" .. triggerprefix .. "(.+)")
  if not (i == nil) then
    
    -- if 'sender' was not a channel, it must be the nickname
    if not (string.sub(c, 1, 1) == "#") then
      c = s
    end
    
    self:trigger(s, c, k)
  end
end

-- send a message to a specific channel or nickname
function b:say(chan, msg)
  if not (self.client) then
    return
  end
  
  if not (msg == nil) then
    
    -- broadcast?
    if (chan == nil) then
      chan = ""
      local i = 1
      for k,v in pairs(self.channels) do
        if not (string.sub(v, 1, 1) == "#") then
          v = "#" .. v
        end
        
        if #chan == 0 then
          chan = v
        else
          chan = chan .. "," .. v
        end
      end
    end
    
    self:send("PRIVMSG " .. chan .. " :" .. msg)
  end
end

-- join a channel
function b:join_channel(chan)
  if not (string.sub(chan, 1, 1) == "#") then
    chan = "#" .. chan
  end
  
  self:send("JOIN " .. chan)
end

-- change nickname
function b:change_nickname(new_nick)
  self.config.nickname = new_nick
  self:send("NICK " .. new_nick)
end

-- quit the irc network and exit the script
function b:quit(msg)
  self:say(nil, msg)
  self:send("QUIT :" .. msg)
  os.exit()
end


-- reload core.lua script and rebind methods
-- function also pulls the latest commit from the git repo
function b:reload(chan)
  self:say(chan, "Pulling latest git...")
  os.execute("git pull")
  self:say(chan, "Reloading core.lua...")
  
  local succ, err = pcall(dofile, "core.lua")
  if succ then
    local succ, err = pcall(bind_functions, self)
    
    if succ then
      self:say(chan, "Done.")
    else
      self:say(chan, "Method binding failed:")
      self:say(chan, tostring(err))
    end
  else
    self:say(chan, "Failed, error:")
    self:say(chan, tostring(err))
  end
end

--[[
TODO: This code will be useful for the module system later on.
function b:rebase(chan, gistid)
  self:say(chan, "Adding remote git repo.")
  os.execute("git remote add " .. tostring(gistid) .. " git://gist.github.com/" .. tostring(gistid) .. ".git")
  self:say(chan, "Pulling remote git repo.")
  os.execute("git pull " .. tostring(gistid) .. " master")
  
  self:say(chan, "Reloading core.lua...")
  
  local succ, err = pcall(dofile, "core.lua")
  if succ then
    local succ, err = pcall(bind_functions, self)
    
    if succ then
      self:say(chan, "Done.")
      self.gistid = gistid
    else
      self:say(chan, "Method binding failed:")
      self:say(chan, tostring(err))
    end
  else
    self:say(chan, "Failed, error:")
    self:say(chan, tostring(err))
  end

  self.config.gistid = gistid
end
]]

-- parse triggers
function b:trigger(user, chan, msg)
  
  
  -----------------------------
  -- core triggers
  
  if (self:is_trusted_user(user)) then
    -- echo trigger?
    if string.sub(msg, 1, 4) == "echo" then
      self:say(chan, string.sub(msg, 6))
    end
  
    -- quit ?
    if string.sub(msg, 1) == "quit" then
      self:quit("good bye!")
    end
  
    -- reload ?
    if string.sub(msg, 1) == "reload" then
      self:save_config("settings")
      self:reload(chan)
    end

    -- saveconf ?
    if string.sub(msg, 1) == "saveconf" then
      self:save_config("settings")
    end

    -- loadconf ?
    if string.sub(msg, 1) == "loadconf" then
      self:load_config("settings")
    end
    
    --[[ rebase ?
    --- Depricated!
    if string.sub(msg, 1, 6) == "rebase" then
      local i,j,gitid = string.find(msg, "rebase (%d+)")
      if not (i == nil) then
        self:save_config("settings")
        self:rebase(chan, gitid)
      end
    end
    ]]
  
    -- join ?
    if string.sub(msg, 1, 4) == "join" then
      local i,j,c = string.find(msg, "join (.+)")
      if not (i == nil) then
        if not (string.sub(c, 1, 1) == "#") then
          c = "#" .. c
        end
        
        self:send("JOIN " .. c)
        
        -- add channel to internal channel list
        for k,v in pairs(self.config.channels) do
          if v == c then
            return
          end
        end
        table.insert(self.config.channels, c)
        
      end
    end
  
    -- nick ?
    if string.sub(msg, 1, 4) == "nick" then
      local i,j,n = string.find(msg, "nick (.+)")
      if not (i == nil) then
        self:change_nickname(n)
      end
    end

    -- exec ?
    if string.sub(msg, 1, 4) == "exec" then
      local i,j,s = string.find(msg, "exec (.+)")
      if not (i == nil) then
        
        local res = assert(loadstring("return (" .. s .. ")"))()
        self:say(chan, res)
        --self:send(tostring(res))
      end
    end
  
  end
  
  
  --------------------------------
  -- normal (public) triggers
  
  for k,v in pairs(self.triggers) do
    if string.sub(msg, 1, #tostring(k)) == tostring(k) then
      v(self, chan, msg)
      break
    end
  end
  
end

-- save bot config to file
function b:load_config(file)
  local config = require(file)
  
  self.config = {}
  for k,v in pairs(config) do
    if not (string.sub(tostring(k), 1, 1) == "_") then
      self.config[k] = v
    end
  end
end

-- load bot config from file
function b:save_config(file)
  local new_data = 'module("' .. tostring(file) .. '")\n'
  
  local function configval_to_string(k,v,indent)
    if type(v) == "number" then
      return (tostring(k) .. ' = "' .. tostring(v) .. '"')
    elseif type(v) == "string" then
      return (tostring(k) .. ' = ' .. tostring(v))
    elseif type(v) == "table" then
      
      local ret_str = tostring(k) .. " = {"
      
      local ret_table = {}
      for i,j in pairs(v) do
        table.insert(ret_table, configval_to_string(i,j,indent + #tostring(k) + 3))
      end
      local sep = ""
      for b=1,indent do
        sep = sep .. " "
      end
      ret_str = ret_str .. table.concat(ret_table, ",\n" .. sep )
      
      return (ret_str .. "\n" .. sep .. "}")
    else
      return "ERROR"
    end
  end
  
  local new_config_table = {}
  if not (self.config == nil) then
    for k,v in pairs(self.config) do
      local new_value = ""
      table.insert(new_config_table, configval_to_string(k,v, #tostring(k) + 3))
    end
  end
  
  new_data = new_data .. table.concat(new_config_table, "\n")
  
  local new_file = io.open(tostring(file) .. ".lua", "w+")
  new_file:write(new_data .. "\n")
  new_file:close()
  
end

-- main bot loop
-- pumps through all messages sent from the server
-- retruns false if an error occurs
function b:pump()
  
  local line, err = self.client:receive()
  
  if not (err == nil) then
    self:log("Error from client:recieve(): " .. tostring(err))
    return false
  end
  
  if line then
    -- got message
    local succ, err = pcall(self.parse_message, self, line, err)
    if not succ then
      self:log("Error when trying to parse message: " .. tostring(err))
    end
  end
  
  return true
end


-- bind functions to specific bot instance
function bind_functions( bot )
  for k,v in pairs(b) do
    bot[tostring(k)] = v
  end
  
  -- load triggers
  bot.triggers = require("triggers")
end
