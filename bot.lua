local socket = require("socket")

-- creates bot 'instance'
function create_bot(serveraddr, serverport)
  local bot = {serveraddr = serveraddr,
               serverport = serverport,
               
               -- internal states
               firstresponse = false, -- change as soon as the server sends us any data
               connection_ok = false, -- callback to call when a connection is successfully made
               altnickid = 0,         -- currently used alt. nick (0 = non alternative, ie. normal nickname)
               
               -- modules loaded
               modules = {},
               
               -- time handling
               activitystamp = 0,
               activitytimeout = 60*3,
               lastsentstamp = 0,
               
               -- output handling
               outputqueue = {}, -- awaiting messages that should be sent
               queuemax = 2,     -- maximum queue elements that can be outputed at once
               queuewait = 3,    -- sec (wait time for messages bigger than the queuemax)
               msgwait = 1,      -- sec (wait time between all messages)
               maxstringlength = 350, -- maximum char length of a string per queue element
               
               
               -- standard config
               config = { nickname = "lurch",
                          altnicks = {"lurch_", "lurchbot"},
                          channels = {"lurchbot"},
                          modules = {},
                          triggerprefix = ":",
               }
              }
  
  -- initiate a connection to the server
  function bot:connect()
    self.client = socket.tcp()
    self.client:settimeout(3)
    local succ, err = self.client:connect(self.serveraddr, self.serverport)
    if not succ then
      print("Connection failed: " .. tostring(err))
    end
    self.client:settimeout(0)
    self.activitystamp = os.time()
    self.lastsentstamp = os.time()
  end
  
  -- bind core-functions (core.lua)
  function bot:bind_functions()
    --os.execute("git pull")
    dofile("core.lua")
    bind_functions(self)
  end
  
  -- close connection and reset state
  function bot:close()
    self.client:close()

    -- reset state
    self.firstresponse = false
    self.connection_ok = false
  end
  
  return bot
end

-- main loop
local bot = create_bot(arg[1], arg[2])
while 1 do
  
  bot:bind_functions()
  bot:connect()

  while 1 do
  
    if not bot:pump() then
      break
    end
  
  end

  bot:close()

end
