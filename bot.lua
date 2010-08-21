local socket = require("socket")

-- creates bot 'instance'
function create_bot(serveraddr, serverport)
  local bot = {serveraddr = serveraddr,
               serverport = serverport,
               
               -- internal states
               firstresponse = false, -- change as soon as the server sends us any data
               connection_ok = false, -- callback to call when a connection is successfully made
               
               config = { nickname = "lurch", -- standard config
                          altnicks = {"lurch_", "lurchbot"},
                          channels = {"lurchbot"},
                          triggerprefix = ":",
               }
              }
  
  -- initiate a connection to the server
  function bot:connect()
    self.client = socket.tcp()
    self.client:settimeout(60*3, 't') -- set total timeout
    local succ, err = self.client:connect(self.serveraddr, self.serverport)
    if not succ then
      print("Connection failed: " .. tostring(err))
    end
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
