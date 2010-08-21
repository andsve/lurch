module("triggers")

function help(bot, chan, msg)
  local t = {}
  for k,v in pairs(triggers) do
    table.insert(t, tostring(k))
  end
  bot:say(chan, "Available triggers: " .. tostring(table.concat(t, ", ")))
end

function git(bot, chan, msg)
  bot:say(chan, "html: http://gist.github.com/" .. bot.config.gistid .. " - public clone url: git://gist.github.com/" .. bot.config.gistid .. ".git")
end

function gibbon(bot, chan, msg)
  bot:say(chan, '"shit was so cash, regards dolan"')
end

function dolan(bot, chan, msg)
  local http = require("socket.http")
  local ltn12 = require("ltn12")

  local i,j,t1,t2 = string.find(msg, 'dolan "(.-)" "(.-)"')
  if not (i == nil) then
    request_body = "templateType=AdviceDogSpinoff&text0=" .. tostring(t1) .. "&text1=" .. tostring(t2) .. "&templateID=106165&generatorName=Uncle-Dolan"
  
    b, c, h = http.request("http://memegenerator.net/Instance/CreateOrEdit", request_body)

    local a,c,img_url = string.find(b, '.-a href="(.-)".+')
    if not (a == nil) then
      bot:say(chan, "http://images.memegenerator.net" .. tostring(img_url) .. ".jpg")
    end

  end
end

function bitch(bot, chan, msg)
  local http = require("socket.http")
  local ltn12 = require("ltn12")

  local i,j,t1,t2 = string.find(msg, 'bitch "(.-)" "(.-)"')
  if not (i == nil) then
    request_body = "templateType=AdviceDogSpinoff&text0=" .. tostring(t1) .. "&text1=" .. tostring(t2) .. "&templateID=1343&generatorName=stupid-bitch"
  
    b, c, h = http.request("http://memegenerator.net/Instance/CreateOrEdit", request_body)
    local a,c,img_url = string.find(b, '.-a href="(.-)".+')
    if not (a == nil) then
      bot:say(chan, "http://images.memegenerator.net" .. tostring(img_url) .. ".jpg")
    else
      bot:say(chan, "Failed to get image!")
      print(b)
    end

  end
end
