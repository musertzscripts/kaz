-- [ Head Visualizer by kazumi] --
print("kaz hub loading...")
wait(4)
print("Loaded!")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Head Hub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Adding net bypass...",
   LoadingSubtitle = "by kaz",
   ShowText = "Head Hub", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "HeadVisulaizer"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "Key",
      Subtitle = "Get the key",
      Note = "Join out discord server to get key", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = false, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"alwaysfreaky"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local DupeTab = Window:CreateTab("Duper", "chevron-last") -- Title, Image
local Section = DupeTab:CreateSection("Copy Discord Link")

local Button = DupeTab:CreateButton({
   Name = "Discord",
   Callback = function()
   setclipboard("gg/niggers")
   end,
})

local Section2 = DupeTab:CreateSection("Dupe Head")

Tab:CreateInput({
    Name = "How many times to clone?",
    PlaceholderText = "Enter number of clones",
    RemoveTextAfterFocusLost = false,
    Callback = function(input)
        local amount = tonumber(input)
        if not amount or amount <= 0 then
            warn("Invalid number")
            return
        end

        local head = Character:FindFirstChild("Head")
        if not head then
            warn("No head found")
            return
        end

        for i = 1, amount do
            -- Duplicate Head
            local headClone = head:Clone()
            headClone.Name = "HeadClone_" .. i
            headClone.CFrame = head.CFrame * CFrame.new(math.random(-6,6), math.random(2,8), math.random(-6,6))
            headClone.Parent = workspace

            -- Duplicate Accessories
            for _, accessory in ipairs(Character:GetChildren()) do
                if accessory:IsA("Accessory") then
                    local handle = accessory:FindFirstChild("Handle")
                    if handle then
                        local accClone = handle:Clone()
                        accClone.Name = "AccessoryClone_" .. accessory.Name .. "_" .. i
                        accClone.CFrame = head.CFrame * CFrame.new(math.random(-6,6), math.random(2,8), math.random(-6,6))
                        accClone.Parent = workspace
                    end
                end
            end
        end

        -- 🛎️ Rayfield Notification
        Rayfield:Notify({
            Title = "done",
            Content = "successfly duped " .. amount .. " heads",
            Duration = 4,
            Image = "check",
        })
    end
})

local vis = Window:CreateTab("Visualizer", "activity") -- Title, Image

local player    = game.Players.LocalPlayer
local char      = player.Character or player.CharacterAdded:Wait()
local root      = char:WaitForChild("HumanoidRootPart")

local mode              = "circle"
local tilt              = 0
local speed             = 1
local sensitivity       = 5
local visualizerEnabled = false

local function getClones()
    local list = {}
    for _, p in ipairs(workspace:GetChildren()) do
        if p:IsA("BasePart") and p.Name:match("^HeadClone_") then
            table.insert(list, p)
        end
    end
    return list
end

local TWO_PI = math.pi * 2

local patterns = {}

patterns.circle = function(i, t, n)
    local r = sensitivity
    return Vector3.new(
        math.cos(t) * r,
        tilt,
        math.sin(t) * r
    )
end

patterns.heart = function(i, t, n)
    local x = 16*math.sin(t)^3
    local y = 13*math.cos(t) - 5*math.cos(2*t) - 2*math.cos(3*t) - math.cos(4*t)
    return Vector3.new(x, y, 0) * 0.1 * sensitivity + Vector3.new(0, tilt, 0)
end

patterns.wave = function(i, t, n)
    local x = (i - n/2) * 1.5
    local y = math.sin(t) * sensitivity
    return Vector3.new(x, y + tilt, 0)
end

patterns.tornado = function(i, t, n)
    local r = sensitivity
    local h = i * 0.5
    return Vector3.new(
        math.cos(t) * r,
        h + tilt,
        math.sin(t) * r
    )
end

patterns.spiral = function(i, t, n)
    local r = i * 0.3
    return Vector3.new(
        math.cos(t) * r,
        i * 0.2 + tilt,
        math.sin(t) * r
    )
end

patterns.square = function(i, t, n)
    local side = i % 4
    local d    = (i // 4) * 1.5
    if side == 0 then return Vector3.new( d, tilt, -d + (t % 1)*2*d) end
    if side == 1 then return Vector3.new( d - (t % 1)*2*d, tilt,  d) end
    if side == 2 then return Vector3.new(-d, tilt,  d - (t % 1)*2*d) end
    return                  Vector3.new(-d + (t % 1)*2*d, tilt, -d)
end

patterns.figure8 = function(i, t, n)
    local a = math.sin(t)
    local b = math.sin(t)*math.cos(t)
    return Vector3.new(a, tilt, b) * sensitivity
end

patterns.sphere = function(i, t, n)
    local phi   = (i / n) * math.pi
    local theta = t
    local r     = sensitivity
    return Vector3.new(
        r * math.sin(phi) * math.cos(theta),
        r * math.cos(phi) + tilt,
        r * math.sin(phi) * math.sin(theta)
    )
end

patterns.random = function(i, t, n)
    return Vector3.new(
        (math.noise(i, t, 0) - .5) * sensitivity * 2,
        (math.noise(i, t, 1) - .5) * sensitivity * 2 + tilt,
        (math.noise(i, t, 2) - .5) * sensitivity * 2
    )
end

local clock = 0
RunService.RenderStepped:Connect(function(dt)
    if not visualizerEnabled then return end
    clock += dt * speed
    local clones = getClones()
    local n = #clones
    for i, part in ipairs(clones) do
        local t = clock + i
        local f = patterns[mode] or patterns.circle
        local offset = f(i, t, n)
        part.CFrame = root.CFrame * CFrame.new(offset)
    end
end)

vis:CreateDropdown({
    Name = "Pattern",
    Options = {"circle","heart","wave","tornado","spiral","square","figure8","sphere","random"},
    CurrentOption = "circle",
    Callback = function(opt) mode = opt end,
})

vis:CreateButton({
    Name = "Visualizer (on / off)",
    Callback = function()
        visualizerEnabled = not visualizerEnabled
        Rayfield:Notify({
            Title   = "visualizer",
            Content = visualizerEnabled and "enabled" or "disabled",
            Duration= 2,
        })
    end
})

vis:CreateSlider({
    Name = "Tilt",
    Range = {-10, 10},
    Increment = 0.1,
    CurrentValue = 0,
    Suffix = "Y",
    Callback = function(v) tilt = v end,
})

vis:CreateSlider({
    Name = "Speed",
    Range = {0.1, 5},
    Increment = 0.1,
    CurrentValue = 1,
    Suffix = "x",
    Callback = function(v) speed = v end,
})

vis:CreateSlider({
    Name = "Sensitivity",
    Range = {1, 20},
    Increment = 1,
    CurrentValue = 5,
    Suffix = "range",
    Callback = function(v) sensitivity = v end,
})

vis:CreateButton({
    Name = "net",
    Callback = function()
        for _, part in ipairs(workspace:GetChildren()) do
            if part:IsA("BasePart") and part.Name:match("^HeadClone_") then
                part.Anchored = true
                part.CanCollide = false
                part.Massless = true
            end
        end
        Rayfield:Notify({
            Title = "net bypass",
            Content = "enabled anti-fall for head clones",
            Duration = 3,
            Image = "check",
        })
    end,
})

local creds = Window:CreateTab("Credits", "brush") -- Title, Image

local Label = creds:CreateLabel("made by kaz", "clipboard-pen")
