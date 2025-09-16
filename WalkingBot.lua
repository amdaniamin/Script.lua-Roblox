-- LocalScript, taruh di StarterPlayer > StarterPlayerScripts

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FloatingGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 3
UIStroke.Parent = Frame

task.spawn(function()
	while task.wait() do
		for h = 0, 1, 0.01 do
			UIStroke.Color = Color3.fromHSV(h, 1, 1)
			task.wait(0.05)
		end
	end
end)

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0, 180, 0, 40)
Toggle.Position = UDim2.new(0, 10, 0, 10)
Toggle.Text = "Walking Bot: OFF"
Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.Parent = Frame

local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(0, 180, 0, 30)
SpeedBox.Position = UDim2.new(0, 10, 0, 60)
SpeedBox.PlaceholderText = "Input speed (contoh: 16)"
SpeedBox.Text = ""
SpeedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedBox.TextColor3 = Color3.new(1, 1, 1)
SpeedBox.Parent = Frame

-- WALKING BOT SYSTEM
local walkingBot = false
local currentConnection

local function startWalkingBot()
	if walkingBot then return end
	walkingBot = true
	Toggle.Text = "Walking Bot: ON"

	currentConnection = RunService.RenderStepped:Connect(function()
		local char = player.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end

		local speed = tonumber(SpeedBox.Text) or 16
		hum.WalkSpeed = speed

		-- ✅ jalan sesuai arah HRP, bukan kamera
		hum:Move(hrp.CFrame.LookVector, false)

		-- Raycast cek objek di depan
		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {char}
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist

		local rayResult = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 5, rayParams)

		if rayResult then
			local turn = math.random(0, 1) == 0 and -90 or 90
			hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(turn), 0)
		end
	end)
end

local function stopWalkingBot()
	walkingBot = false
	Toggle.Text = "Walking Bot: OFF"
	humanoid.WalkSpeed = 16
	if currentConnection then
		currentConnection:Disconnect()
		currentConnection = nil
	end
end

Toggle.MouseButton1Click:Connect(function()
	if walkingBot then
		stopWalkingBot()
	else
		startWalkingBot()
	end
end)

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = newChar:WaitForChild("Humanoid")
	if walkingBot then
		stopWalkingBot()
		task.wait(1)
		startWalkingBot()
	end
end)
