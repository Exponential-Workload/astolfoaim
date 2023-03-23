--[=[
  AstolfoAim - A Free & Open-Source Pure-Lua Roblox Aimbot Script
  Copyright (C) 2022 Exponential-Workload

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as
  published by the Free Software Foundation, either version 3 of the
  License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
]=]

local rng = getgenv()._random_number_generator
  or loadstring(
    game:HttpGetAsync 'https://gist.githubusercontent.com/Exponential-Workload/593d4b56701133bc827902fe6fdf16a2/raw/random.lua'
  )()

local plrs = game:GetService 'Players'
local lp = plrs.LocalPlayer
local uis = game:GetService 'UserInputService'
local ws = game:GetService 'Workspace'
local tms = game:GetService 'Teams'
local aimInstance = 'Head'
---Moves the mouse by x,y pixels
---@param x number
---@param y number
---@return nil
local moveMouse = mousemoverel or function(x, y)
  error 'No mousemoverel()'
end
local mouse = lp:GetMouse()

if not Drawing then
  error 'No Drawing'
end

---------------------------------------
-- BUILD | DO NOT CHANGE
local build = 'RELEASE/0.6.1'
---------------------------------------
-- settings:
local fovRadius = 180
local maxDistance = 512
local wallCheck = false
local triggerBot = true
local toggleKeybind = true -- Is the keybind toggled? If false, its only active while keybind held
local targetInfo = false -- Target Info (Drawing Lib) | NONFUNCTIONAL
local toggleKey = Enum.KeyCode.LeftAlt -- Toggle/Active Keybind
local useMouseMove = true -- Use mousemoverel if present
local circleSides = 42 -- Amount of sides the circle should have
local refreshRate = 0.02 -- Refresh Rate in seconds
local isTeamed = true -- Team Check
local smoothing = 0.1 -- 0 to 1 - 0 = instant, 1 = no movement at all - i'd suggest 0.9 max - tied to refreshrate & fps
local jitter = 0 -- jitter in pixels, only if useMouseMove
local yfix = true -- fix some y issues in some stupid games
local preferVisible = true -- if wallCheck is false, always use people that are visible over ones that arent, while still locking onto anyone

local doScopeCheck = false -- add 5 studs of distance for any actual blockages for wallchecks

local useMouseSensitivity = true

-- Keep in mind, ESP is a nice-to-have, not the selling point. It's VERY basic & meant primarily for PF (& other games unnamed esp cant work in that we can) - I'd STRONGLY encourage using unnamed esp instead | pcall(function() loadstring('local syn=true;\n'..game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua'))() end)
local esp = false -- Should use Drawing-based ESP?                         [[VERY LAGGY, RE-DRAWS EVERY FRAME         ]]
local highlightesp = false -- Should use Highlight-based ESP?              [[LOOKS NICE BUT NOT OBS PROOF!            ]]
local linkAimbotESP = false -- Should we turn ESP off while Aimbot is off? [[ONLY CHANGES DRAWING-BASED ESP BEHAVIOUR!]]
local legitESP = false -- Should ESP only show players that are visible?   [[ONLY AFFETS DOTESP!                      ]]
local legitHLESP = false -- Should ESP only show players that are visible? [[ONLY AFFETS HLESP!                       ]]

local useHumanoids = false -- use humanoid/npc loader over player loader
local useHumanoidsShouldDetectPlayersViaFindPlrs = getgenv()._useHumanoidsShouldDetectPlayersViaGetPlrs
local deadCheck = true

local pfsens = 'AUTO' -- Phantom Forces Sensitivity | 'AUTO' to automatically attempt to find it; if failed, will default to 1 | NOTE: WE DO NOT ACCOUNT FOR AIM SENSITIVITY MULTIPLIER & ASSUME IT'S AT ONE!!!

local debug = getgenv().__astofloaim_show_debug_info or false -- Should we provide debug information in the top left of the screen

local limitRaycastToCircle = false -- FPS Optimization: Only Raycast within circle, regardless of other settings

-- Zero Smoothing Precision | Improves accuracy on smoothing=0 by running multiple rounds per frame, may increase lag, only works on mousemoverel
local zeroPrecision = not getgenv().__astolfoaim_disable_zero_precision
local recursionCount = getgenv().__astolfoaim_zero_precision_recursion_count or 0

local maximumPixelsPerSecond = 10000
local maximumPixelsPerFrame = 1000

local onlyTriggerBotWhileRMB = true
local minimumRMBHoldTime = 1 / 4

local finalDiv = 2

local hackulaSupport = false -- arsenal only, can flag or error elsewhere

local useDesynchronizedThreads =
  getgenv().__astolfoaim_internal_do_not_mess_with_this_unless_you_know_what_you_are_doing________________enable_desynced_threads_where_threads_are_being_synchronized

local doPcall = (not getgenv().__use_pcall) and function(a, ...)
  return true, a(...)
end or pcall
---@param func function
---@return function
local getPcalledFunction = getgenv().__use_pcall
    and function(func, ...)
      local args = { ... }
      return function(...)
        return doPcall(func, table.unpack(args), ...)
      end
    end
  or function(v)
    return v
  end
---------------------------------------
-- What to display execs as in debug logs:
local formatExecs = {
  ['Fluxus'] = 'Fluxus',
  ['ScriptWare'] = 'Script-Ware',
  ['Synapse'] = 'Synapse',
  ['Synapse X'] = 'Synapse-X',
  ['Comet'] = 'Comet',
  ['Unknown'] = 'Unknown',
}
local exec, execver
if debug then
  exec = formatExecs[(identifyexecutor or function() end)()] or formatExecs.Unknown
  local _
  _, execver = (identifyexecutor or function() end)()
end
---------------------------------------
local isPf = false
local minSmoothing = 0
---Checks if the character is alive
---@param char Model
---@return boolean
local isAliveCheck = function(char)
  local h = char:FindFirstChildOfClass 'Humanoid'
  if h then
    return h.Health > 0
  else
    return true
  end
end
---Returns a list of Players or {Character=Instance,Team=Team,Name=String} Objects
---@return Player[]
local findPlrs = function()
  return plrs:GetPlayers()
end
---Finds the Character from the Player
---@return Model
local findChar = function(plr)
  return plr.Character
end
---Finds a player's team from the plr object
---@return Team
local findTeam = function(plr)
  return plr.Team
end
---Teamcheck, by default ne(team,ourTteam) | DOES NOT CALL findTeam()
---@return boolean
local teamCheck = function(team)
  return team ~= lp.Team
end
---Middleware for aimPart, useful in games with weird names to not break UIs
---@return string
local mapAimPart = function(aimpart)
  return aimpart
end
---Returns a findPlrs-alike list of humanoids. If useHumanoidsShouldDetectPlayersViaFindPlrs is true, it will call findPlrs() for players instead of adding player characters in the same way as NPCs, at the cost of even more performance. This method can be laggy asf.
local findHumanoids = (function()
  local npcTeam = Instance.new 'Team'
  local g = game
  local ws = g:GetService 'Workspace'
  local pS = g:GetService 'Players'
  local gPFC = pS.GetPlayerFromCharacter
  --local o = 1;
  return function()
    local gD = ws:GetDescendants()
    local h = {}
    for _, o in pairs(gD) do
      if o:FindFirstChildOfClass 'Humanoid' then
        table.insert(h, o)
      end
    end
    --for _,e in pairs(gD) do if o:FindFirstChildOfClass('Humanoid') then table.insert(h,o,e) end end
    local theZaza = {}
    for _, o in pairs(h) do
      local t = npcTeam
      local gpfcR = gPFC(pS, o)
      local shouldAdd = true
      if gpfcR then
        if useHumanoidsShouldDetectPlayersViaFindPlrs then
          t = gpfcR.Team
        else
          shouldAdd = false
        end
      end
      if shouldAdd then
        table.insert(theZaza, { ['Character'] = o, ['Team'] = t, ['Name'] = gpfcR and o.Name or o:GetFullName() })
      end
    end
    if useHumanoidsShouldDetectPlayersViaFindPlrs then
      for _, player in pairs(findPlrs()) do
        table.insert(theZaza, player)
      end
    end
    return theZaza
  end
end)()
-- PF hacked-in shit:
if tostring(game.PlaceId) == '292439477' or tostring(game.GameId) == '292439477' then
  isPf = true
  local findTeamByName = function(teamName)
    for _, o in pairs(tms:GetChildren()) do
      if tostring(o.TeamColor) == teamName then
        return o
      end
    end
  end
  findPlrs = function()
    local teams = ws:FindFirstChild('Players'):GetChildren()
    local players = {}
    for _, o in pairs(teams) do
      local team = findTeamByName(o.Name)
      for _, p in pairs(o:GetChildren()) do
        table.insert(players, { ['Character'] = p, ['Team'] = team, ['Name'] = p })
      end
    end
    return players
  end
  teamCheck = function(team)
    return team.TeamColor ~= lp.Team.TeamColor
  end
  minSmoothing = 0.15
end
-- Bad Business Patches
if tostring(game.PlaceId) == '3233893879' then
  local chars = ws:WaitForChild('Characters', math.huge)
  findPlrs = function()
    local players = {}
    for _, p in pairs(chars:GetChildren()) do
      if p:FindFirstChild 'Body' then
        table.insert(players, { ['Character'] = p.Body, ['Name'] = p })
      end
    end
    return players
  end
  findTeam = function(plr)
    return plr
  end
  teamCheck = function(team, plr)
    for _, o in pairs(lp.PlayerGui:GetChildren()) do
      if o.Name == 'NameGui' and o.Adornee:IsDescendantOf(plr.Character) then
        return false
      end
    end
    return true
  end
end
---------------------------------------
local determinePFSensitivity = function()
  if isPf then
    -- Determine Sensitivity
    pcall(function()
      if pfsens == 'AUTO' then
        pfsens = 1
        local sts = lp.PlayerGui.MenuScreenGui.Pages.PageSettingsMenu.DisplaySettingsList.Container
        for _, o in pairs(sts:GetChildren()) do
          if
            o.Name == 'ButtonSettingsSlider'
            and o:FindFirstChild 'Title'
            and o.Title:FindFirstChild 'Design'
            and o.Title:FindFirstChild 'TextFrame'
            and string.upper(o.Title.TextFrame.Text or '') == 'MOUSE SENSITIVITY'
            and o:FindFirstChild 'DisplaySlider'
            and o.DisplaySlider:FindFirstChild 'TextBox'
            and tonumber(o.DisplaySlider.TextBox.Text)
          then
            pfsens = tonumber(o.DisplaySlider.TextBox.Text)
          end
        end
      end
    end)
    -- convert pf sens % into actual pf sensitivity
    pcall(function()
      -- base sig: func(p3,p4,p5,p6,p7,p8,p9)
      -- called in displaysettingsmousesens using (p1,p2,'Mouse Sensitivity','looksens',0.00390725,4,100)
      local p7, p8 = 0.00390725, 4
      local p14 = pfsens
      local u14 = p7
      local u15 = p8
      pfsens = (u14 ^ (1 - p14)) * (u15 ^ p14)
    end)
  end
end
determinePFSensitivity()
---------------------------------------
---Final hook for mouse x,y movement - by default returns the 2nd argument.
---@param type "'x'"|"'y'"
---@param value number
---@return number
local finalHook = function(type, value) -- type='x'|'y', value: int pixels
  return value
end
---------------------------------------
local isMousePressed = uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
local _isMousePressedID = 0
uis.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton2 then
    local id = _isMousePressedID + 1
    _isMousePressedID = id
    task.wait(minimumRMBHoldTime)
    if _isMousePressedID == id then
      isMousePressed = true
    end
  end
end)
uis.InputEnded:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton2 then
    _isMousePressedID = _isMousePressedID + 1
    isMousePressed = false
  end
end)
---------------------------------------
--- @type Highlight[]
local hls = {}
--- @type table[]
local espdrawings = {}
local cachedDrawingObjects = {}
local cachedDrawingObjectCount = {}
local getDrawingObject = function(type)
  local objects = cachedDrawingObjects[type] or {}
  cachedDrawingObjects[type] = objects
  local count = cachedDrawingObjectCount[type] or 0
  cachedDrawingObjectCount[type] = count -- faster than length operator: tracking our own lengths
  if count > 0 then
    local object = objects[1]
    table.remove(objects, 1)
    cachedDrawingObjectCount[type] = count - 1
    return object
  else
    return Drawing.new(type)
  end
end
local collectDrawingObject = function(item, type)
  pcall(function()
    if item and item.Visible then
      cachedDrawingObjects[type] = cachedDrawingObjects[type] or {}
      table.insert(cachedDrawingObjects[type], item)
      cachedDrawingObjectCount[type] = cachedDrawingObjectCount[type] + 1
      item.Visible = false
    end
  end)
end
---Finds the player to target | Additionally Updates Highlights & a bunch of other shit; effectively the main loop
---@return Model|nil
---@return boolean
local searchForPlayer = function()
  local targetAimPart = mapAimPart(aimInstance)
  local mouseX, mouseY, mouseV2
  local lpchr = findChar(lp)
  local mousePosition = uis:GetMouseLocation()
  local camera = ws.CurrentCamera
  local currentPlayer, currentMagnitude, currentIsVisible
  local p = useHumanoids and findHumanoids() or findPlrs()
  if hackulaSupport and ws:FindFirstChild 'Map' and ws.Map:FindFirstChild 'Hackula' then
    p = { { Character = ws.Map.Hackula } }
  end
  if highlightesp then
    -- gc hls
    for k, v in pairs(hls) do
      if v then
        local hasPlayer = false
        for _, plr in pairs(p) do
          if plr.Name == k then
            local teamCheckResult
            if not isTeamed then
              teamCheckResult = true
            else
              teamCheckResult = teamCheck(findTeam(plr), plr)
            end
            if teamCheckResult then
              hasPlayer = true
            end
          end
        end
        if not hasPlayer then
          v:Destroy()
        end
      end
    end
  end
  for _, o in pairs(espdrawings) do
    collectDrawingObject(o, 'Circle')
  end
  for _, plr in pairs(p) do
    local teamCheckResult
    if not isTeamed then
      teamCheckResult = true
    else
      teamCheckResult = teamCheck(findTeam(plr), plr)
    end
    if plr ~= lp and teamCheckResult then
      local char = findChar(plr)
      local isAlive = not deadCheck or isAliveCheck(char)
      if char and char:FindFirstChild(targetAimPart, true) and isAlive then
        -- ESP
        if highlightesp and not hls[plr.Name] then
          local hl = Instance.new 'Highlight'
          hl.Parent = gethui and gethui() or game:GetService 'CoreGui'
          if legitHLESP then
            hl.DepthMode = Enum.HighlightDepthMode.Occluded
          else
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
          end
          hls[plr.Name] = hl
        end
        if highlightesp then
          hls[plr.Name].Adornee = char
        end
        local charPos = (
          char:FindFirstChild(targetAimPart, true):IsA 'BasePart' and char:FindFirstChild(targetAimPart, true)
          or char:FindFirstChildOfClass 'BasePart'
        ).Position
        if (charPos - camera.CFrame.Position).Magnitude < maxDistance then
          local screenData, isOnScreen = camera:WorldToViewportPoint(charPos)
          local screenPoistion = Vector2.new(screenData.X, screenData.Y)
          local cached = nil
          local isCachedResult = false
          if limitRaycastToCircle and (not mouseX or not mouseY) then
            mouseX, mouseY = mousePosition.X or mouse.X, mousePosition.Y or mouse.Y
            mouseV2 = Vector2.new(mouseX, mouseY)
          end
          local checkVisibility = function()
            if isCachedResult then
              return cached
            end
            if limitRaycastToCircle and (mouseV2 - screenPoistion).Magnitude > fovRadius then
              isCachedResult = true
              cached = false
              return cached
            end
            local t = char:FindFirstChild(targetAimPart, true)
            local targets = { charPos, t and t.Position }
            local parts = camera:GetPartsObscuringTarget(targets, { lpchr })
            local actualBlockages = {}
            for _, o in pairs(parts) do
              if
                not o:IsDescendantOf(char)
                and (not (isPf or doScopeCheck) or (camera.CFrame.Position - o.Position).Magnitude > 5)
              then
                table.insert(actualBlockages, o)
              end
            end
            isCachedResult = true
            cached = #actualBlockages == 0
            return cached
          end
          if esp and isOnScreen and (not legitESP or checkVisibility()) then
            local size = --[[math.min(
              math.max((1 / (charPos - camera.CFrame.Position).Magnitude) * 1000 + (]]
              (checkVisibility() and 4 or 3)--[[ - 1), 3),
              7
            )]]
            local sq = getDrawingObject 'Circle'
            sq.Visible = true
            sq.Radius = size
            sq.Position = screenPoistion - Vector2.new(0, size - 15)
            sq.Filled = true
            sq.Color = checkVisibility() and Color3.new(1, 0.219607, 0.219607) or Color3.new(0.552941, 0, 0)
            table.insert(espdrawings, sq)
          end
          -- if highlightesp and legitHLESP and not checkVisibility() and hls[plr.Name] then
          --   hls[plr.Name].Enabled = false
          -- elseif checkVisibility() then
          --   hls[plr.Name].Enabled = true
          -- end
          if not wallCheck or checkVisibility() then
            local mag = (screenPoistion - mousePosition).Magnitude
            if preferVisible and currentIsVisible and not checkVisibility() then
              -- do nothing
            elseif (not currentMagnitude or mag < currentMagnitude) and isOnScreen then
              currentPlayer = char
              currentMagnitude = mag
              currentIsVisible = checkVisibility()
            end
          end
        end
      end
    end
  end
  if currentPlayer and currentMagnitude < fovRadius then
    return currentPlayer, currentIsVisible
  end
  return nil
end

local work = false
local isEnabled = false
local stepDelta = 0
local rs2 = game:GetService('RunService').RenderStepped:Connect(getPcalledFunction(function(delta)
  stepDelta = stepDelta + delta
  if stepDelta > refreshRate then
    stepDelta = 0
  else
    return
  end
  if esp then
    if linkAimbotESP and not isEnabled then
      if work then
        return
      end
      work = true
      for _, o in pairs(espdrawings) do
        pcall(function()
          collectDrawingObject(o, 'Circle')
          game:GetService('RunService').RenderStepped:Wait()
        end)
      end
      work = false
      espdrawings = {}
    elseif not isEnabled then
      searchForPlayer()
    end
  end
end))

local _ScreenGUI = Instance.new 'ScreenGui'
_ScreenGUI.Name = rng(0, 100000000)
_ScreenGUI.Parent = gethui and gethui() or game:GetService 'CoreGui'
_ScreenGUI.IgnoreGuiInset = true

task.spawn(function()
  while task.wait(1) do
    for _, o in pairs(hls) do
      o:Destroy()
    end
    hls = {}
    if highlightesp and not isEnabled then
      searchForPlayer()
    end
  end
end)

local circle

local tl = Instance.new 'TextLabel'
tl.BackgroundTransparency = 1
tl.Position = UDim2.new(0.5, 0, 0.95, -8)
tl.AnchorPoint = Vector2.new(0.5, 1)
tl.Text = '' -- "Yielding#3961"
tl.TextTransparency = 1
tl.TextColor3 = Color3.new(1, 1, 1)
tl.Parent = _ScreenGUI
tl.TextSize = 16
local tlc = Drawing.new 'Text'
tlc.Text = 'aim.astolfo.gay BETA | Quality Universal Aimbot'
tlc.Size = 24
tlc.Position = tl.AbsolutePosition
pcall(function()
  tlc.Centered = true
end)
pcall(function()
  tlc.Center = true
end)
tlc.Color = Color3.fromHSV(0, 1, 1)
tlc.Visible = true
local conn
task.spawn(function()
  task.wait(10)
  tlc.Visible = false
  conn:Disconnect()
end)
local hue = 0
conn = game:GetService('RunService').RenderStepped:Connect(function(delta)
  hue = hue + (delta / 3)
  if hue > 1 then
    while hue > 1 do
      hue = hue - 1
    end
  end
  if tlc and tlc.Visible then
    pcall(function()
      tlc.Position = tl.AbsolutePosition
      tlc.Color = Color3.fromHSV(hue, 1, 1)
    end)
  end
end)
pcall(function()
  tlc.Font = Drawing.Fonts.Plex
end)
-- local tl2 = Instance.new("TextLabel")
-- tl2.BackgroundTransparency = 1
-- tl2.Position = UDim2.new(0.5, 0, 0.5, 0)
-- tl2.AnchorPoint = Vector2.new(0.5, 1)
-- tl2.Text = "https://aim.astolfo.gay"
-- tl2.TextColor3 = Color3.new(1, 1, 1)
-- tl2.Parent = _ScreenGUI
-- tl2.TextSize = 18
local tl2 = Drawing.new 'Text'
tl2.Text = rng(0, 100) > 50 and 'aim.astolfo.gay' or 'aim.femboy.cafe'
tl2.Size = 24
pcall(function()
  tl2.Centered = true
end)
pcall(function()
  tl2.Center = true
end)
tl2.Color = Color3.new(1, 1, 1)
local drawingObjects = { tl2, tlc }
local updatedebug = function() end
if debug then
  local debugtxt = Drawing.new 'Text'
  debugtxt.Position = Vector2.new(10, 180)
  debugtxt.Size = 20
  -- debugtxt.Text = 'hehe'
  debugtxt.Color = Color3.new(1, 1, 1)
  debugtxt.Visible = true
  updatedebug = function()
    debugtxt.Text = string.format(
      [[AstolfoAim Build %s
  cfg.state(ti=%s, isT=%s, sm=%s)
  exec(%s, %s)]],
      build,
      tostring(targetInfo),
      tostring(isTeamed),
      tostring(smoothing),
      exec,
      tostring(execver or 'UNKNOWN')
    )
  end
  updatedebug()
  pcall(function()
    debugtxt.Font = Drawing.Fonts.Plex
  end)
  debugtxt.Outline = true
  table.insert(drawingObjects, debugtxt)
end
local moveCircle = function() end
local isJob
local remakeCircle = function()
  -- get center of screen
  local _Frame = Instance.new 'Frame'
  _Frame.Size = UDim2.new(1, 0, 1, 0)
  _Frame.BorderSizePixel = 0
  _Frame.BackgroundTransparency = 1
  _Frame.Parent = _ScreenGUI

  -- create aim url
  local movetl2 = function()
    tl2.Position = (getgenv().__astolfoaim_always_center_circle and _Frame.AbsoluteSize / 2 or uis:GetMouseLocation())
      + ((not getgenv().__astolfoaim_put_at_fixed_height) and Vector2.new(0, math.min(128, fovRadius)) or Vector2.new(0, 32))
  end
  movetl2()
  moveCircle = function()
    if getgenv().__astolfoaim_always_center_circle then
      circle.Position = _Frame.AbsoluteSize / 2
    else
      circle.Position = uis:GetMouseLocation()
    end
    movetl2()
  end

  -- create fov circle
  if not circle then
    circle = Drawing.new('Circle', true)
  end
  if not isJob then
    isJob = true
    task.spawn(function()
      while _Frame and task.wait(2) do
        pcall(moveCircle)
      end
      isJob = false
    end)
  end
  circle.Filled = false
  circle.NumSides = circleSides
  circle.Radius = fovRadius
  circle.Visible = isEnabled
  circle.Color = Color3.new(255, 255, 255)
  pcall(moveCircle)
  pcall(function()
    circle.Thickness = 1
  end)
  table.insert(drawingObjects, circle)

  -- if targetInfo then
  --   local targetInfoOuterFrame = Drawing.new 'Square'
  --   local frameSize = Vector2.new(450, 250)
  --   targetInfoOuterFrame.Position = _Frame.AbsoluteSize / 2 - Vector2.new(-1 * (fovRadius + 5), frameSize.Y / 2)
  --   targetInfoOuterFrame.Filled = true
  --   targetInfoOuterFrame.Color = Color3.fromRGB(0, 0, 0)
  --   targetInfoOuterFrame.Size = frameSize
  --   targetInfoOuterFrame.Visible = true
  --   table.insert(drawingObjects, targetInfoOuterFrame)
  --   -- TODO: COMPLETE THIS
  -- end

  _Frame.Visible = false
end
remakeCircle()

local isActive = false
local _queueRelease = false
local connectionList = {}
local destroyed = false
local disconnectAimbot
local redoConnections
---Sets Aimbot State & Connects shit
---@param state boolean
---@param setIsTeamed boolean
local SetAimbotState = function(state, setIsTeamed)
  if typeof(state) == 'nil' then
    state = not isEnabled
  end
  isEnabled = state
  circle.Visible = not not isEnabled
  tl2.Visible = not not isEnabled
  if typeof(setIsTeamed) ~= 'nil' then
    isTeamed = setIsTeamed
  end
  if isActive then
    return
  end
  isActive = true
  local updateDelta = 0
  local id = ''
  for _ = 0, 1000, 1 do
    id = id .. tostring(math.floor(rng(0, 10000000) + rng(0, 10000000)))
  end
  local func = function(delta)
    local ugs = UserSettings():GetService 'UserGameSettings'
    local _doClick = true
    if _queueRelease then
      mouse1release()
      _queueRelease = false
      _doClick = false
    end
    updateDelta = updateDelta + delta
    if updateDelta > refreshRate then
      local smoothLerp = 1
      if smoothing ~= 0 then
        smoothLerp = (1 - (smoothing + minSmoothing))
        if not getgenv().__astolfoaim_unlink_smoothing_from_framerate then
          smoothLerp = smoothLerp * (updateDelta * 50)
        end
        smoothLerp = math.min(smoothLerp, 1)
      end
      task.spawn(function()
        pcall(moveCircle)
      end)
      local updDelta = updateDelta
      updateDelta = 0
      if isActive and isEnabled then
        local targetPlayer, targetVisible = searchForPlayer()
        if not targetPlayer then
          return
        end
        if useMouseMove and mousemoverel and useDesynchronizedThreads then
          task.desynchronize()
        end
        local Aim = targetPlayer:FindFirstChild(mapAimPart(aimInstance), true)
        if Aim ~= nil then
          local aimPos = Aim.CFrame.Position
          if yfix and ws.CurrentCamera.CFrame.Position.Y - aimPos.Y > 200 then
            return
          end
          if useMouseMove and mousemoverel then
            local movement
            movement = function(i)
              local mousev2 = useDesynchronizedThreads and mouse or uis:GetMouseLocation()
              local mX = mousev2.X
              local mY = mousev2.Y
              local progress = smoothLerp
              local pfs = isPf and pfsens or 1
              if useMouseSensitivity then
                progress = progress / (ugs.MouseSensitivity / 0.20016)
              end
              local tPos = ws.CurrentCamera:WorldToViewportPoint(aimPos)
              local rX, rY = tPos.X - mX, tPos.Y - mY
              local calcJitter = function()
                if jitter == 0 then
                  return 0
                end
                return math.random(jitter * -10, jitter * 10) / 10
              end
              local fx = finalHook('x', ((rX * progress) + calcJitter()) / pfs)
              local fy = finalHook('y', ((rY * progress) + calcJitter()) / pfs)
              local val = math.min(maximumPixelsPerFrame, maximumPixelsPerSecond * updDelta)
              local clamp = math.clamp
                or function(num, min, max)
                  return math.max(math.min(num, min), max)
                end
              local handleMinMax = function(v)
                local rt = clamp(v, val * -1, val)
                -- print(v, val, '->', rt)
                return rt
              end
              -- print(fx, rX, pfs, progress, '=>', smoothing, '+', minSmoothing)
              moveMouse(handleMinMax(fx) / finalDiv, handleMinMax(fy) / finalDiv)
              -- local newTPos = ws.CurrentCamera:WorldToViewportPoint(aimPos)
              -- local newMX = mouse.X
              -- local newMY = mouse.Y
              -- print '---'
              -- print(rX, '->', newTPos.X - newMX)
              -- print(rY, '->', newTPos.Y - newMY)
              if typeof(i) == 'nil' then
                i = math.huge
              end
              if typeof(recursionCount) == 'nil' then
                recursionCount = 0
              end
              if zeroPrecision and recursionCount > 0 and i < math.min(recursionCount, 32) then
                movement(i + 1)
              end
            end
            movement(0)
          else
            local target = CFrame.lookAt(ws.CurrentCamera.CFrame.Position, aimPos)
            if smoothLerp == 1 then
              ws.CurrentCamera.CFrame = target
            else
              ws.CurrentCamera.CFrame = ws.CurrentCamera.CFrame:Lerp(target, smoothLerp)
            end
          end
          local wtvp = ws.CurrentCamera:WorldToViewportPoint(aimPos)
          local shouldTriggerBot = true
          if onlyTriggerBotWhileRMB and not isMousePressed then
            shouldTriggerBot = false
          end
          -- if triggerBot and targetVisible and shouldTriggerBot then
          --   print(
          --     (
          --       Vector2.new(wtvp.X, wtvp.Y)
          --       - (useDesynchronizedThreads and Vector2.new(mouse.X, mouse.Y) or uis:GetMouseLocation())
          --     ).Magnitude < 7
          --   )
          -- end
          if triggerBot and targetVisible and shouldTriggerBot and _doClick then
            local wtvp = ws.CurrentCamera:WorldToViewportPoint(aimPos)
            if
              (
                Vector2.new(wtvp.X, wtvp.Y)
                - (useDesynchronizedThreads and Vector2.new(mouse.X, mouse.Y) or uis:GetMouseLocation())
              ).Magnitude < 7
            then
              mouse1press()
              _queueRelease = true
            end
          end
        end
      end
    end
  end
  local rsc
  redoConnections = function()
    if rsc then
      rsc:Disconnect()
    end
    if not isActive then
      return
    end
    if getgenv().__astolfoaim_use_renderstepped_connection then
      rsc = game:GetService('RunService').RenderStepped:Connect(func)
    else
      rsc = {
        Disconnect = function()
          game:GetService('RunService'):UnbindFromRenderStep(id)
        end,
      }
      game:GetService('RunService'):BindToRenderStep(id, getgenv().__astolfoaim_renderstep_priority or 299, func)
    end
  end
  redoConnections()
  getgenv().__astolfoaim_reconnect_to_render_step_on_latest_instance = redoConnections
  disconnectAimbot = function()
    isEnabled = false
    destroyed = true
    circle.Visible = false
    tl2.Visible = false
    rsc:Disconnect()
    for _, o in pairs(connectionList) do
      o:Disconnect()
    end
    local s = pcall(function()
      circle:Destroy()
    end)
    if not s then
      pcall(function()
        circle:Remove()
      end)
    end
    _ScreenGUI:Destroy()
    searchForPlayer = function() end
    for _, o in pairs(drawingObjects) do
      if o then
        pcall(function()
          o:Destroy()
        end)
      end
    end
    for _, o in pairs(espdrawings) do
      if not pcall(function()
        o:Destroy()
      end) then
        pcall(function()
          o:Remove()
        end)
      end
    end
    for _, o in pairs(hls) do
      if o then
        pcall(function()
          o:Destroy()
        end)
      end
    end
    rs2:Disconnect()
    for _, list in pairs(drawingObjects) do
      for _, v in pairs(list) do
        if not pcall(function()
          v:Destroy()
        end) then
          if not pcall(function()
            v:Remove()
          end) then
            pcall(function()
              v.Visible = false
            end)
          end
        end
      end
    end
    drawingObjects = {}
  end
  getgenv().disconnectAimbot = disconnectAimbot
end

table.insert(
  connectionList,
  game:GetService('UserInputService').InputBegan:Connect(function(inp)
    if toggleKeybind then
      return
    end
    if inp.KeyCode == toggleKey then
      SetAimbotState(true)
    end
  end)
)

table.insert(
  connectionList,
  game:GetService('UserInputService').InputEnded:Connect(function(inp)
    if inp.KeyCode == toggleKey then
      if toggleKeybind then
        SetAimbotState()
      else
        SetAimbotState(false)
      end
    end
  end)
)
---------------------------------------
-- API
local API = setmetatable({
  Cleanup = function()
    pcall(function()
      if getgenv().disconnectAimbot then
        getgenv().disconnectAimbot()
      end
    end)
  end,
  SetState = SetAimbotState,
  Destroy = disconnectAimbot,
  ReconnectToRenderStep = redoConnections,
  JoinDiscord = function()
    local request = request or http_request or (http or {}).request or (syn or {}).request
    local setclip = setclip or setclipboard or setClipboard or (syn or {}).setclipboard
    local code =
      game:HttpGetAsync 'https://gist.githubusercontent.com/Exponential-Workload/40ca1ea2ee73f219337430329a5acadc/raw/discord'
    setclip('discord.gg/' .. code)
    pcall(function()
      request {
        Url = 'http://127.0.0.1:6463/rpc?v=1',
        Method = 'POST',
        Headers = { ['Content-Type'] = 'application/json', ['Origin'] = 'https://discord.com' },
        Body = game:GetService('HttpService'):JSONEncode {
          ['cmd'] = 'INVITE_BROWSER',
          ['args'] = {
            ['code'] = code,
          },
          ['nonce'] = game:GetService('HttpService'):GenerateGUID(false),
        },
      }
    end)
  end,
}, {
  __index = function(t, k)
    k = string.lower(k)
    if k == 'enabled' then
      return isEnabled and isActive
    end
    if k == 'destroyed' then
      return destroyed
    end
    if k == 'fov' then
      return fovRadius
    end
    if k == 'maxdistance' then
      return maxDistance
    end
    if k == 'wallcheck' then
      return wallCheck
    end
    if k == 'triggerbot' then
      return triggerBot
    end
    if k == 'keybindtoggle' then
      return toggleKeybind
    end
    if k == 'targetinfo' then
      return error 'Feature Unimplemented as of now.'
    end
    if k == 'keybind' then
      return toggleKey
    end
    if k == 'esp' then
      return esp
    end
    if k == 'hlesp' then
      return highlightesp
    end
    if k == 'legitesp' then
      return legitESP
    end
    if k == 'legithlesp' then
      return legitHLESP
    end
    if k == 'usemousemove' then
      return useMouseMove
    end
    if k == 'circlesides' then
      return circleSides
    end
    if k == 'refreshcap' then
      return refreshRate
    end
    if k == 'smoothing' then
      return smoothing
    end
    if k == 'jitter' then
      return jitter
    end
    if k == 'pfsens' then
      if not isPf then
        error 'Cannot newindex pfsens outside of Phantom Forces.'
      end
      return pfsens
    end
    if k == 'hackula' then
      return hackulaSupport
    end
    if k == 'aimtarget' then
      return aimInstance
    end
    if k == 'linkaimbotesp' then
      return linkAimbotESP
    end
    if k == 'recursioncount' then
      return recursionCount
    end
    if k == 'doscopecheck' then
      return doScopeCheck or isPf
    end
    if k == 'limitraycasttocircle' then
      return limitRaycastToCircle
    end
    if k == 'version' then
      return build
    end
    if k == 'accountforsensitivity' then
      return useMouseSensitivity
    end
    if k == 'triggerbotminimumrmbtime' then
      return minimumRMBHoldTime
    end
    if k == 'onlytriggerbotwhilermb' then
      return onlyTriggerBotWhileRMB
    end
    if k == 'finaldiv' then
      return finalDiv
    end
    if k == 'usefindhumanoids' then
      return useHumanoids
    end
    if k == 'usehumanoidsshoulddetectplayersviafindplrs' then
      return useHumanoidsShouldDetectPlayersViaFindPlrs
    end
    if k == 'deathcheck' then
      return deadCheck
    end
    if k == 'internals' then
      local defaultFuncs = {
        ['findPlrs'] = findPlrs,
        ['findChar'] = findChar,
        ['findTeam'] = findTeam,
        ['teamCheck'] = teamCheck,
        ['searchForPlayer'] = searchForPlayer,
        ['finalHook'] = finalHook,
        ['findHumanoids'] = findHumanoids,
        ['isAliveCheck'] = isAliveCheck,
      }
      return setmetatable({}, {
        __newindex = function(t, k, v)
          if k == 'findPlrs' then
            findPlrs = v
            return
          end
          if k == 'findChar' then
            findChar = v
            return
          end
          if k == 'findTeam' then
            findTeam = v
            return
          end
          if k == 'teamCheck' then
            teamCheck = v
            return
          end
          if k == 'searchForPlayer' then
            searchForPlayer = v
            return
          end
          if k == 'finalHook' then
            finalHook = v
            return
          end
          if k == 'findHumanoids' then
            findHumanoids = v
            return
          end
          if k == 'isAliveCheck' then
            isAliveCheck = v
            return
          end
          error(
            'Invalid Function Name: '
              .. k
              .. '\nCheck to make sure your AstolfoAim version matches matches the one your script is targetting.\nFor cross-version api interactions, you may need to pcall this newindex.'
          )
        end,
        __index = function(t, k)
          if k == 'original' then
            return setmetatable({}, {
              __index = defaultFuncs,
              __newindex = function()
                error 'attempt to newindex read-only table.'
              end,
            })
          end

          if k == 'findPlrs' then
            return findPlrs
          end
          if k == 'findChar' then
            return findChar
          end
          if k == 'findTeam' then
            return findTeam
          end
          if k == 'teamCheck' then
            return teamCheck
          end
          if k == 'searchForPlayer' then
            return searchForPlayer
          end
          if k == 'finalHook' then
            return finalHook
          end
          if k == 'findHumanoids' then
            return findHumanoids
          end
          if k == 'isAliveCheck' then
            return isAliveCheck
          end
        end,
        __tostring = function()
          local keys
          for key in pairs(defaultFuncs) do
            keys = (keys and keys .. ', ' or '') .. key
          end
          return 'AstolfoAim Internals\nFunctions:' .. keys
        end,
        __metatable = 'AstofloAim Internal Function API',
      })
    end
    error('Unknown or unwritable property: ' .. k)
  end,
  __newindex = function(t, k, v)
    k = string.lower(k)
    local num = function(nilAllowed)
      if typeof(v) ~= 'number' then
        if typeof(v) == 'nil' and nilAllowed then
          return
        end
        error('Must input number' .. (nilAllowed and ' or nil' or ''))
      end
    end
    if k == 'enabled' then
      return SetAimbotState(not not v)
    end
    if k == 'destroyed' then
      error 'Cannot write to read-only property "destroyed".'
    end
    if k == 'fov' then
      num(true)
      fovRadius = v or 180
      remakeCircle()
      updatedebug()
      return
    end
    if k == 'maxdistance' then
      num(true)
      maxDistance = v or 512
      return
    end
    if k == 'wallcheck' then
      wallCheck = v or false
      return
    end
    if k == 'triggerbot' then
      triggerBot = v or false
      return
    end
    if k == 'keybindtoggle' then
      toggleKeybind = v or false
      return
    end
    if k == 'targetinfo' then
      return error 'Feature Unimplemented as of now.'
    end
    if k == 'keybind' then
      if typeof(v) ~= 'EnumItem' and v then
        return error 'Not an EnumItem!'
      end
      toggleKey = v or Enum.KeyCode.LeftAlt
      return
    end
    if k == 'esp' then
      esp = not not v
      return
    end
    if k == 'hlesp' then
      highlightesp = not not v
      return
    end
    if k == 'legitesp' then
      legitESP = not not v
      return
    end
    if k == 'onlytriggerbotwhilermb' then
      onlyTriggerBotWhileRMB = not not v
      return
    end
    if k == 'deathcheck' then
      deadCheck = typeof(v) == 'nil' and true or not not v
      return
    end
    if k == 'triggerbotminimumrmbtime' then
      num(true)
      if typeof(v) == 'nil' then
        v = 1 / 4
      end
      minimumRMBHoldTime = v
      return
    end
    if k == 'legithlesp' then
      local diff = legitHLESP ~= not not v
      legitHLESP = not not v
      if diff then
        for _, hlobjs in pairs(hls) do
          for _, hl in pairs(hlobjs) do
            if hl then
              if legitHLESP then
                hl.DepthMode = Enum.HighlightDepthMode.Occluded
              else
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
              end
            end
          end
        end
      end
      return
    end
    if k == 'linkaimbotesp' then
      linkAimbotESP = typeof(v) == 'nil' and true or not not v
      return
    end
    if k == 'usemousemove' then
      local newVal = typeof(v) == 'nil' and true or not not v
      local changed = false
      if useMouseMove ~= newVal then
        changed = true
      end
      useMouseMove = newVal
      if changed then
        redoConnections()
      end
      return
    end
    if k == 'circlesides' then
      num(true)
      circleSides = v or 42
      circle.NumSides = circleSides
      return
    end
    if k == 'refreshcap' then
      num(true)
      refreshRate = v or 1 / 300
      return
    end
    if k == 'teamed' then
      isTeamed = typeof(v) == 'nil' and true or not not v
      updatedebug()
      return
    end
    if k == 'accountforsensitivity' then
      useMouseSensitivity = typeof(v) == 'nil' and true or not not v
      return
    end
    if k == 'smoothing' then
      num(true)
      if v < 0 then
        error 'Cannot have sub-zero smoothing'
      end
      if v >= 1 then
        error 'Cannot have >=1 smoothing'
      end
      smoothing = typeof(v) == 'nil' and 0.1 or v
      return
    end
    if k == 'jitter' then
      num(true)
      if v < 0 then
        error 'Cannot have sub-zero jitter'
      end
      jitter = typeof(v) ~= 'nil' and v or 0
      return
    end
    if k == 'maximumpixelsperframe' then
      num(true)
      if v < 1 then
        error 'Cannot have sub-one maximum pixels per frame'
      end
      maximumPixelsPerFrame = typeof(v) == 'nil' and 1000 or v
      return
    end
    if k == 'maximumpixelspersecond' then
      num(true)
      if v < 1 then
        error 'Cannot have sub-one maximum pixels per second'
      end
      maximumPixelsPerSecond = typeof(v) == 'nil' and 100000 or v
      return
    end
    if k == 'finaldiv' then
      num(true)
      finalDiv = v or 2
      return
    end
    if k == 'doscopecheck' then
      doScopeCheck = not not v
      return
    end
    if k == 'pfsens' then
      if typeof(v) == 'string' then
        if string.lower(v) == 'auto' then
          return determinePFSensitivity()
        else
          return error 'If a string is passed to pfsens, it must be "AUTO".'
        end
      end
      num(true)
      if not v or v < 0 then
        determinePFSensitivity()
        return
      end
      pfsens = typeof(v) ~= 'nil' and v or 0
      return
    end
    if k == 'hackula' then
      hackulaSupport = not not v
      return
    end
    if k == 'aimtarget' then
      aimInstance = tostring(v)
      return
    end
    if k == 'limitraycasttocircle' then
      limitRaycastToCircle = not not v
      return
    end
    if k == 'recursioncount' then
      num(false)
      recursionCount = v
      return
    end
    if k == '__minsmoothing' then
      num(false)
      minSmoothing = v
      return
    end
    if k == 'usefindhumanoids' then
      useHumanoids = not not v
      return
    end
    if k == 'usehumanoidsshoulddetectplayersviafindplrs' then
      useHumanoidsShouldDetectPlayersViaFindPlrs = not not v
      return
    end
    if k == 'version' then
      error 'Cannot write to version. What the fuck are you doing?'
    end
    if k == 'internals' then
      error 'Cannot __newindex internals. Do api.internals.<func>=<...> instead of api.internals=<...>.'
    end
    error('Unknown Property: ' .. k)
  end,
  __metatable = 'AstofloAim API',
})
return API
---------------------------------------
