local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local duplicatedHeads = {}
local visualizerRunning = false
local currentVisualizer = "Circle"

-- Head dupe function
local function duplicateHead()
    local character = player.Character or player.CharacterAdded:Wait()
    local head = character:FindFirstChild("Head")
    if not head then return end

    local clone = head:Clone()
    clone.Anchored = true
    clone.CanCollide = false
    clone.Parent = workspace

    table.insert(duplicatedHeads, clone)
end

local function clearHeads()
    for _, h in pairs(duplicatedHeads) do
        if h and h.Parent then h:Destroy() end
    end
    duplicatedHeads = {}
end

-- Visualizer patterns
local function visualizerCircle(t)
    local center = player.Character and player.Character:FindFirstChild("Head") and player.Character.Head.Position or Vector3.new()
    local radius = 8
    local count = #duplicatedHeads
    for i, head in ipairs(duplicatedHeads) do
        local angle = (2 * math.pi * i / count) + t * 2
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        head.CFrame = CFrame.new(center + Vector3.new(x, 3, z))
    end
end

local function visualizerHeart(t)
    local center = player.Character and player.Character:FindFirstChild("Head") and player.Character.Head.Position or Vector3.new()
    local scale = 4
    for i, head in ipairs(duplicatedHeads) do
        local theta = (2 * math.pi * i / #duplicatedHeads) + t * 2
        local x = scale * 16 * math.sin(theta)^3
        local y = scale * (13 * math.cos(theta) - 5 * math.cos(2*theta) - 2*math.cos(3*theta) - math.cos(4*theta))
        head.CFrame = CFrame.new(center + Vector3.new(x, y * 0.1 + 6, 0))
    end
end

local function visualizerWave(t)
    local center = player.Character and player.Character:FindFirstChild("Head") and player.Character.Head.Position or Vector3.new()
    for i, head in ipairs(duplicatedHeads) do
        local offset = Vector3.new(i * 3 - (#duplicatedHeads * 1.5), math.sin(t * 5 + i) * 2 + 5, 0)
        head.CFrame = CFrame.new(center + offset)
    end
end

local function visualizerTornado(t)
    local center = player.Character and player.Character:FindFirstChild("Head") and player.Character.Head.Position or Vector3.new()
    for i, head in ipairs(duplicatedHeads) do
        local angle = t * 5 + i
        local height = i * 0.5
        local x = math.cos(angle) * 5
        local z = math.sin(angle) * 5
        head.CFrame = CFrame.new(center + Vector3.new(x, height + 2, z))
    end
end

local function visualizerSpiral(t)
    local center = player.Character and player.Character:FindFirstChild("Head") and player.Character.Head.Position or Vector3.new()
    for i, head in ipairs(duplicatedHeads) do
        local angle = t + i * 0.5
        local height = i * 0.6
        local x = math.cos(angle) * 3
        local z = math.sin(angle) * 3
        head.CFrame = CFrame.new(center + Vector3.new(x, height + 2, z))
    end
end

-- Start/Stop visualizer loop
local function startVisualizer()
    if visualizerRunning then return end
    visualizerRunning = true
    local start = tick()

    task.spawn(function()
        while visualizerRunning do
            local time = tick() - start
            if currentVisualizer == "Circle" then
                visualizerCircle(time)
            elseif currentVisualizer == "Heart" then
                visualizerHeart(time)
            elseif currentVisualizer == "Wave" then
                visualizerWave(time)
            elseif currentVisualizer == "Tornado" then
                visualizerTornado(time)
            elseif currentVisualizer == "Spiral" then
                visualizerSpiral(time)
            end
            RunService.RenderStepped:Wait()
        end
    end)
end

local function stopVisualizer()
    visualizerRunning = false
end

-- Rayfield UI Setup
local Window = Rayfield:CreateWindow({
    Name = "Head Hub",
    LoadingTitle = "Head Hub",
    LoadingSubtitle = "by ChatGPT",
    ConfigurationSaving = {
        Enabled = false
    }
})

local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateButton({
    Name = "Duplicate Head",
    Callback = duplicateHead
})

Tab:CreateButton({
    Name = "Clear All Heads",
    Callback = clearHeads
})

Tab:CreateDropdown({
    Name = "Visualizer Style",
    Options = {"Circle", "Heart", "Wave", "Tornado", "Spiral"},
    CurrentOption = "Circle",
    Callback = function(v)
        currentVisualizer = v
    end
})

Tab:CreateToggle({
    Name = "Enable Visualizer",
    CurrentValue = false,
    Callback = function(v)
        if v then
            startVisualizer()
        else
            stopVisualizer()
        end
    end
})
