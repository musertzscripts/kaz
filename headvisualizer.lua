local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local duplicatedHeads = {}
local visualizerRunning = false
local currentVisualizer = "Circle"

-- Create a detached head clone
local function createHead()
    local character = player.Character or player.CharacterAdded:Wait()
    local head = character:FindFirstChild("Head")
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

local function clearHeads()
    for _, head in pairs(duplicatedHeads) do
        if head and head.Parent then head:Destroy() end
    end
    duplicatedHeads = {}
end

-- Visualizers
local function visualizerCircle(t)
    local center = player.Character.Head.Position
    local radius = 6
    for i, head in ipairs(duplicatedHeads) do
        local angle = (2 * math.pi * i / #duplicatedHeads) + t
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        head.CFrame = CFrame.new(center + Vector3.new(x, 2, z))
    end
end

local function visualizerHeart(t)
    local center = player.Character.Head.Position
    local scale = 3
    for i, head in ipairs(duplicatedHeads) do
        local theta = (2 * math.pi * i / #duplicatedHeads) + t
        local x = scale * 16 * math.sin(theta)^3
        local y = scale * (13 * math.cos(theta) - 5 * math.cos(2*theta) - 2*math.cos(3*theta) - math.cos(4*theta))
        head.CFrame = CFrame.new(center + Vector3.new(x * 0.1, y * 0.1 + 5, 0))
    end
end

local function visualizerWave(t)
    local center = player.Character.Head.Position
    for i, head in ipairs(duplicatedHeads) do
        local offsetX = (i - (#duplicatedHeads / 2)) * 2
        local offsetY = math.sin(t * 3 + i) * 2 + 5
        head.CFrame = CFrame.new(center + Vector3.new(offsetX, offsetY, 0))
    end
end

local function visualizerTornado(t)
    local center = player.Character.Head.Position
    for i, head in ipairs(duplicatedHeads) do
        local angle = t * 4 + i
        local height = i * 0.4
        local x = math.cos(angle) * 4
        local z = math.sin(angle) * 4
        head.CFrame = CFrame.new(center + Vector3.new(x, height + 2, z))
    end
end

local function visualizerSpiral(t)
    local center = player.Character.Head.Position
    for i, head in ipairs(duplicatedHeads) do
        local angle = t + i * 0.4
        local height = i * 0.3
        local x = math.cos(angle) * 4
        local z = math.sin(angle) * 4
        head.CFrame = CFrame.new(center + Vector3.new(x, height + 2, z))
    end
end

-- Run/Stop visualizer
local function startVisualizer()
    if visualizerRunning then return end
    visualizerRunning = true
    local start = tick()

    task.spawn(function()
        while visualizerRunning do
            local t = tick() - start
            if currentVisualizer == "Circle" then
                visualizerCircle(t)
            elseif currentVisualizer == "Heart" then
                visualizerHeart(t)
            elseif currentVisualizer == "Wave" then
                visualizerWave(t)
            elseif currentVisualizer == "Tornado" then
                visualizerTornado(t)
            elseif currentVisualizer == "Spiral" then
                visualizerSpiral(t)
            end
            RunService.RenderStepped:Wait()
        end
    end)
end

local function stopVisualizer()
    visualizerRunning = false
end

-- Rayfield UI
local Window = Rayfield:CreateWindow({
    Name = "Head Hub",
    LoadingTitle = "Head Hub",
    LoadingSubtitle = "Visualizer + Dupe",
    ConfigurationSaving = {
        Enabled = false
    }
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
    Options = {"Circle", "Heart", "Wave", "Tornado", "Spiral"},
    CurrentOption = "Circle",
    Callback = function(value)
        currentVisualizer = value
    end
})

Tab:CreateToggle({
    Name = "Enable Visualizer",
    CurrentValue = false,
    Callback = function(value)
        if value then
            startVisualizer()
        else
            stopVisualizer()
        end
    end
})
