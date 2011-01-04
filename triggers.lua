module("triggers")

function help(bot, chan, msg)
  local t = {}
  for k,v in pairs(bot.triggers) do
    if not (string.sub(tostring(k), 1, 1) == "_") then
      table.insert(t, tostring(k))
    end
  end
  bot:say(chan, "Available triggers: " .. tostring(table.concat(t, ", ")))
end

function git(bot, chan, msg)
  bot:say(chan, "html: http://github.com/sweetfish/lurch - public clone url: git://github.com/sweetfish/lurch.git")
end

function dolan(bot, chan, msg)
  local http = require("socket.http")
  local ltn12 = require("ltn12")

  local i,j,t1,t2 = string.find(msg, 'dolan "(.-)" "(.-)"')
  if not (i == nil) then
    local request_body = "templateType=AdviceDogSpinoff&text0=" .. tostring(t1) .. "&text1=" .. tostring(t2) .. "&templateID=106165&generatorName=Uncle-Dolan"
  
    local b, c, h = http.request("http://memegenerator.net/Instance/CreateOrEdit", request_body)

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
    local request_body = "templateType=AdviceDogSpinoff&text0=" .. tostring(t1) .. "&text1=" .. tostring(t2) .. "&templateID=1343&generatorName=stupid-bitch"
  
    local b, c, h = http.request("http://memegenerator.net/Instance/CreateOrEdit", request_body)
    local a,c,img_url = string.find(b, '.-a href="(.-)".+')
    if not (a == nil) then
      bot:say(chan, "http://images.memegenerator.net" .. tostring(img_url) .. ".jpg")
    else
      bot:say(chan, "Failed to get image!")
      print(b)
    end

  end
end

function yuno(bot, chan, msg)
  local http = require("socket.http")
  local ltn12 = require("ltn12")

  local i,j,t1,t2 = string.find(msg, 'yuno "(.-)" "(.-)"')
  if not (i == nil) then
    local request_body = "templateType=Y-U-NO&text0=" .. tostring(t1) .. "&text1=" .. tostring(t2) .. "&templateID=4930081&generatorName=Y-U-NO"
  
    local b, c, h = http.request("http://memegenerator.net/Instance/CreateOrEdit", request_body)

    local a,c,img_url = string.find(b, '.-a href="(.-)".+')
    if not (a == nil) then
      bot:say(chan, "http://images.memegenerator.net" .. tostring(img_url) .. ".jpg")
    end

  end
end
