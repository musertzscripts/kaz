local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local duplicatedHeads = {}
local visualizerConnection

-- Duplicate the head
local function createHead()
    local char = player.Character or player.CharacterAdded:Wait()
    local head = char:FindFirstChild("Head")
    if not head then return end

    local clone = head:Clone()
    clone.Anchored = true
    clone.CanCollide = false
    clone.Name = "FloatingHead"
    for _, d in pairs(clone:GetDescendants()) do
        if d:IsA("Motor6D") or d:IsA("Weld") then d:Destroy() end
    end
    clone.CFrame = head.CFrame + Vector3.new(0, 3, 0)
    clone.Parent = Workspace
    table.insert(duplicatedHeads, clone)
end

-- Remove all heads
local function clearHeads()
    for _, head in pairs(duplicatedHeads) do
        if head and head.Parent then head:Destroy() end
    end
    duplicatedHeads = {}
end

-- Visualizer styles
local function circle(t)
    local center = player.Character.Head.Position
    local radius = 6
    for i, head in ipairs(duplicatedHeads) do
        local angle = (2 * math.pi * i / #duplicatedHeads) + t
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        head.CFrame = CFrame.new(center + Vector3.new(x, 2, z))
    end
end

local function heart(t)
    local center = player.Character.Head.Position
    local scale = 3
    for i, head in ipairs(duplicatedHeads) do
        local theta = (2 * math.pi * i / #duplicatedHeads) + t
        local x = scale * 16 * math.sin(theta)^3
        local y = scale * (13 * math.cos(theta) - 5 * math.cos(2*theta) - 2*math.cos(3*theta) - math.cos(4*theta))
        head.CFrame = CFrame.new(center + Vector3.new(x * 0.1, y * 0.1 + 5, 0))
    end
end

local function wave(t)
    local center = player.Character.Head.Position
    for i, head in ipairs(duplicatedHeads) do
        local offsetX = (i - (#duplicatedHeads / 2)) * 2
        local offsetY = math.sin(t * 3 + i) * 2 + 5
        head.CFrame = CFrame.new(center + Vector3.new(offsetX, offsetY, 0))
    end
end

local function tornado(t)
    local center = player.Character.Head.Position
    for i, head in ipairs(duplicatedHeads) do
        local angle = t * 4 + i
        local height = i * 0.4
        local x = math.cos(angle) * 4
        local z = math.sin(angle) * 4
        head.CFrame = CFrame.new(center + Vector3.new(x, height + 2, z))
    end
end

local function spiral(t)
    local center = player.Character.Head.Position
    for i, head in ipairs(duplicatedHeads) do
        local angle = t + i * 0.4
        local height = i * 0.3
        local x = math.cos(angle) * 4
        local z = math.sin(angle) * 4
        head.CFrame = CFrame.new(center + Vector3.new(x, height + 2, z))
    end
end

-- Visualizer start/stop
local function startVisualizer(name)
    if visualizerConnection then visualizerConnection:Disconnect() end
    if name == "None" then return end

    local start = tick()
    visualizerConnection = RunService.RenderStepped:Connect(function()
        local t = tick() - start
        if name == "Circle" then circle(t)
        elseif name == "Heart" then heart(t)
        elseif name == "Wave" then wave(t)
        elseif name == "Tornado" then tornado(t)
        elseif name == "Spiral" then spiral(t)
        end
    end)
end

-- Rayfield UI
local Window = Rayfield:CreateWindow({
    Name = "Head Hub",
    LoadingTitle = "Head Hub",
    LoadingSubtitle = "Visualizer + Dupe",
    ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateButton({
    Name = "Duplicate Head",
    Callback = createHead
})

Tab:CreateButton({
    Name = "Clear All Heads",
    Callback = clearHeads
})

Tab:CreateDropdown({
    Name = "Visualizer Style",
    Options = {"None", "Circle", "Heart", "Wave", "Tornado", "Spiral"},
    CurrentOption = "None",
    Callback = function(option)
        startVisualizer(option)
    end
})
