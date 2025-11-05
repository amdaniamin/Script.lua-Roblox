--// Amdani Amin Muhadzdzib R. - Client Side Script (v6.11)
--// GUI tidak hilang saat respawn + draggable + ON/OFF + input X,Y,Z + random + cooldown + heading to me (speed) + playmusic (input soundID)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 🧱 GUI utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SlashControlGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 415)
Frame.Position = UDim2.new(0.5, -130, 0.5, -170)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "Slash All Controller"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = Frame

-- 🔠 Fungsi buat TextBox input
local function makeTextBox(yPos, placeholder, text)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -20, 0, 25)
	box.Position = UDim2.new(0, 10, 0, yPos)
	box.PlaceholderText = placeholder
	box.Text = text
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.SourceSans
	box.TextSize = 18
	box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	box.TextColor3 = Color3.fromRGB(255,255,255)
	box.Parent = Frame
	return box
end

-- 🔘 Tombol dan input utama
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, -20, 0, 30)
Toggle.Position = UDim2.new(0, 10, 0, 40)
Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Toggle.Text = "OFF"
Toggle.TextColor3 = Color3.fromRGB(255, 100, 100)
Toggle.Font = Enum.Font.SourceSansBold
Toggle.TextSize = 20
Toggle.Parent = Frame

local XInput = makeTextBox(80, "X value (contoh: 0)", "0")
local YInput = makeTextBox(110, "Y value (contoh: 0)", "0")
local ZInput = makeTextBox(140, "Z value (contoh: 0)", "0")
local CooldownInput = makeTextBox(170, "Cooldown (detik, contoh: 0.5)", "0.5")
local SpeedInput = makeTextBox(200, "Speed (contoh: 50)", "50")
local MusicInput = makeTextBox(230, "Music SoundID (contoh: 123456789)", "") -- 🎵 input sound id

local RandomToggle = Instance.new("TextButton")
RandomToggle.Size = UDim2.new(1, -20, 0, 30)
RandomToggle.Position = UDim2.new(0, 10, 0, 265)
RandomToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
RandomToggle.Text = "RANDOM: OFF"
RandomToggle.TextColor3 = Color3.fromRGB(255, 255, 150)
RandomToggle.Font = Enum.Font.SourceSansBold
RandomToggle.TextSize = 18
RandomToggle.Parent = Frame

local HeadingToggle = Instance.new("TextButton")
HeadingToggle.Size = UDim2.new(1, -20, 0, 30)
HeadingToggle.Position = UDim2.new(0, 10, 0, 300)
HeadingToggle.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
HeadingToggle.Text = "HEADING TO ME: OFF"
HeadingToggle.TextColor3 = Color3.fromRGB(255, 200, 150)
HeadingToggle.Font = Enum.Font.SourceSansBold
HeadingToggle.TextSize = 18
HeadingToggle.Parent = Frame

local PlayMusicToggle = Instance.new("TextButton")
PlayMusicToggle.Size = UDim2.new(1, -20, 0, 30)
PlayMusicToggle.Position = UDim2.new(0, 10, 0, 335)
PlayMusicToggle.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
PlayMusicToggle.Text = "PLAY MUSIC: OFF"
PlayMusicToggle.TextColor3 = Color3.fromRGB(150, 255, 150)
PlayMusicToggle.Font = Enum.Font.SourceSansBold
PlayMusicToggle.TextSize = 18
PlayMusicToggle.Parent = Frame

-- ⚙️ Variabel utama
local running = false
local randomMode = false
local headingToMe = false
local playMusic = false
local currentSound = nil
local loopThread

-- 🔊 Fungsi musik
local function playSoundFromID(soundID)
	if currentSound then
		currentSound:Stop()
		currentSound:Destroy()
	end

	local id = tostring(soundID or ""):match("%d+") -- ambil angka saja
	if not id or id == "" then
		warn("⚠️ SoundID tidak valid!")
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. id
	sound.Volume = 3
	sound.Looped = true
	sound.Parent = workspace
	sound:Play()

	currentSound = sound
end

local function stopMusic()
	if currentSound then
		currentSound:Stop()
		currentSound:Destroy()
		currentSound = nil
	end
end

-- Fungsi pembantu
local function randomNear(value)
	value = tonumber(value) or 0
	local range = math.max(math.abs(value * 0.1), 5)
	return math.random(value - range, value + range)
end

local function getHeadingVector(target, stopDistance, speed)
	if not (target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
		return Vector3.new(0, 0, 0)
	end

	local targetPos = target.Character.HumanoidRootPart.Position
	local myPos = LocalPlayer.Character.HumanoidRootPart.Position
	local distance = (myPos - targetPos).Magnitude

	if distance <= stopDistance then
		return Vector3.new(0, 0, 0)
	else
		return (myPos - targetPos).Unit * speed
	end
end

-- 🔁 Loop utama
local function startSlashLoop()
	if running then return end
	running = true
	Toggle.Text = "ON"
	Toggle.TextColor3 = Color3.fromRGB(100, 255, 100)

	if playMusic then
		playSoundFromID(MusicInput.Text)
	end

	loopThread = task.spawn(function()
		while running do
			local cooldown = tonumber(CooldownInput.Text) or 0.5
			local speed = tonumber(SpeedInput.Text) or 50

			for _, target in pairs(Players:GetPlayers()) do
				if target ~= LocalPlayer and target.Character and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Slap") then
					local args

					if headingToMe then
						local headingVec = getHeadingVector(target, 6, speed)
						args = {"slash", target.Character, headingVec, "HeadingToMe"}

					elseif randomMode then
						args = {
							"slash",
							target.Character,
							Vector3.new(
								randomNear(tonumber(XInput.Text) or 0),
								randomNear(tonumber(YInput.Text) or 0),
								randomNear(tonumber(ZInput.Text) or 0)
							)
						}

					else
						args = {
							"slash",
							target.Character,
							Vector3.new(
								tonumber(XInput.Text) or 0,
								tonumber(YInput.Text) or 0,
								tonumber(ZInput.Text) or 0
							)
						}
					end

					LocalPlayer.Character.Slap.Event:FireServer(unpack(args))
				end
			end

			task.wait(cooldown)
		end
	end)
end

local function stopSlashLoop()
	running = false
	stopMusic()
	Toggle.Text = "OFF"
	Toggle.TextColor3 = Color3.fromRGB(255, 100, 100)
end

-- 🔘 Event tombol GUI
Toggle.MouseButton1Click:Connect(function()
	if running then stopSlashLoop() else startSlashLoop() end
end)

RandomToggle.MouseButton1Click:Connect(function()
	randomMode = not randomMode
	RandomToggle.Text = "RANDOM: " .. (randomMode and "ON" or "OFF")
	RandomToggle.TextColor3 = randomMode and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 255, 150)
end)

HeadingToggle.MouseButton1Click:Connect(function()
	headingToMe = not headingToMe
	if headingToMe then
		HeadingToggle.Text = "HEADING TO ME: ON"
		HeadingToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
	else
		HeadingToggle.Text = "HEADING TO ME: OFF"
		HeadingToggle.TextColor3 = Color3.fromRGB(255, 200, 150)
	end
end)

PlayMusicToggle.MouseButton1Click:Connect(function()
	playMusic = not playMusic
	if playMusic then
		PlayMusicToggle.Text = "PLAY MUSIC: ON"
		PlayMusicToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
		playSoundFromID(MusicInput.Text)
	else
		PlayMusicToggle.Text = "PLAY MUSIC: OFF"
		PlayMusicToggle.TextColor3 = Color3.fromRGB(150, 255, 150)
		stopMusic()
	end
end)

-- 🧩 Persist GUI saat respawn
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	if running then startSlashLoop() end
end)
