local api = getgenv().__astolfoaim_api or loadstring(game:HttpGetAsync 'https://astolfoaim.femboy.cafe/', 'apiloader')()
api:Cleanup()
api.SetState(false, true)

local ws = {}

if WebSocket then
  ws.connect = function(url)
    local wsapi = {}
    local socket = WebSocket.connect(url)
    wsapi.internal = socket
    wsapi.OnMessage = socket.OnMessage
    wsapi.OnClose = socket.OnClose
    wsapi.Send = function(self, data)
      return self.internal:Send(data)
    end
    wsapi.Close = function(self)
      return self.internal:Close()
    end
    return wsapi
  end
elseif WebsocketClient and WebsocketClient.new then
  ws.connect = function(url)
    local socket = WebsocketClient.new(url)
    local wsapi = {}
    wsapi.internal = socket
    wsapi.OnMessage = {
      ['Connect'] = function(self, ...)
        return socket.DataReceived:Connect(...)
      end,
    }
    wsapi.OnClose = {
      ['Connect'] = function(self, ...)
        return socket.ConnectionClosed:Connect(...)
      end,
    }
    wsapi.Send = function(self, data)
      return self.internal:Send(data)
    end
    wsapi.Close = function(self)
      return self.internal:Close()
    end
    socket:Connect()
    return wsapi
  end
elseif syn and syn.websocket and syn.websocket.connect and not WebSocket then
  ws.connect = function(url)
    local wsapi = {}
    local socket = syn.websocket.connect(url)
    wsapi.internal = socket
    wsapi.OnMessage = socket.OnMessage
    wsapi.OnClose = socket.OnClose
    wsapi.Send = function(self, data)
      return self.internal:Send(data)
    end
    wsapi.Close = function(self)
      return self.internal:Close()
    end
    return wsapi
  end
else
  error 'No Websocket Library Present :/'
end

local APIDomain = AstolfoAPIDomain or 'https://aim.femboy.cafe'

local Request = (http and http.request or http_request or request or (syn and syn.request))
if not Request then
  error 'No Request Function'
end

local code = getgenv().AstolfoIdentificationCode and {
  Body = getgenv().AstolfoIdentificationCode,
} or Request { Url = APIDomain .. '/get-connection-code' }
if not code then
  error 'no code ok'
end
code = code.Body
local connect
if getgenv().webuisocket then
  getgenv().webuisocket:Close()
end
connect = function()
  local location = string.gsub(string.gsub(APIDomain, 'https', 'wss'), 'http', 'ws') .. '/c/' .. code
  local socket = ws.connect(location)
  getgenv().webuisocket = socket
  local connected = true
  socket.OnMessage:Connect(function(data)
    if string.sub(data, 1, 5) == 'exec:' then
      data = string.sub(data, 6)
      local exec = 'local api = ...;' .. data
      local a, err = loadstring(exec)
      if not a then
        return socket:Send('notif:Compilation Error: ' .. err)
      end
      local response = tostring(a(api))
      socket:Send('notif:' .. response)
    end
  end)
  local connectionStart = os.clock()
  socket.OnClose:Connect(function()
    connected = false
    rconsoleprint 'Connection Closed.\n'
    if getgenv().webuisocket == socket then
      task.wait(math.max(os.clock() - connectionStart + 15, 5))
      rconsoleprint 'Retrying Connection...\n'
      connect()
    end
  end)
  if rconsoleshow then
    rconsoleshow()
  end
  task.spawn(function()
    -- avoid gc & do keepalive
    while socket and connected do
      socket:Send 'keepalive'
      task.wait(1)
    end
  end)
end
connect()
task.spawn(function()
  pcall(function()
    setclipboard(code)
  end)
end)
if getgenv().__use_messagebox then
  (messageboxasync or messagebox or function() end)(code, 'Code', 0)
end
if rconsolecreate then
  pcall(rconsolecreate, 'ok')
end
rconsoleprint 'Code: '
rconsoleprint(code)
rconsoleprint '\nEnter it in the Web UI: '
rconsoleprint(APIDomain .. '/ui')
rconsoleprint '\nDO NOT SHARE IT WITH ANYONE.\n'
return api
