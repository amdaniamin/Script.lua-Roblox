local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

------------------------------------------------------
-- 1. FORCE SCRIPT PARENT TO COREGUI
------------------------------------------------------
pcall(function()
	script.Name = "FlingScript_Protected"
	script.Parent = CoreGui
end)

------------------------------------------------------
-- 2. GUI SETUP
------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimateFlingGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 80, 0, 80)
button.Position = UDim2.new(0, 605, 0.45, 0)
button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "Fling"
button.Parent = screenGui

------------------------------------------------------
-- 3. ANTI DELETE
------------------------------------------------------
task.spawn(function()
	while true do
		task.wait(0.25)

		if not CoreGui:FindFirstChild("AnimateFlingGUI") then
			screenGui.Parent = CoreGui
		end

		if script.Parent ~= CoreGui then
			script.Parent = CoreGui
		end
	end
end)

------------------------------------------------------
-- 4. ANIMATION SETUP
------------------------------------------------------
local animId = "rbxassetid://186934658"
local track
local holding = false

local function setupCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	local anim = Instance.new("Animation")
	anim.AnimationId = animId
	track = humanoid:LoadAnimation(anim)
	track.Looped = true
end

if player.Character then
	setupCharacter(player.Character)
end

player.CharacterAdded:Connect(function(char)
	setupCharacter(char)
end)

------------------------------------------------------
-- 5. SOUND EFFECT
------------------------------------------------------
local effectFreeId = "rbxassetid://28144425"
local effectHitId  = "rbxassetid://429400881"

local function PlaySound(id, parent)
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = 1
	s.Parent = parent
	s:Play()
	s.Ended:Connect(function() s:Destroy() end)
end

------------------------------------------------------
-- 6. FLING SYSTEM (VERSI ASLI - NO AssemblyLinearVelocity)
------------------------------------------------------
local movel = 1
local hiddenFling = false
local touchedConnection = nil

local function RepairTouched(hrp)
	if touchedConnection and touchedConnection.Connected then
		return
	end

	touchedConnection = hrp.Touched:Connect(function(hit)
		if holding then
			if hit:IsA("BasePart") and (hit.Parent:FindFirstChild("Humanoid") or not hit.Anchored) then
				PlaySound(effectHitId, hrp)
			end
		end
	end)
end

local function StartFling(character)
	local hrp = character:WaitForChild("HumanoidRootPart")
	hiddenFling = true

	RepairTouched(hrp)

	task.spawn(function()
		while hiddenFling and hrp and hrp.Parent do

			local speedFactor = (track and track.Speed) or 1
			local flingVelocity = 10000 * speedFactor
			local upwardVelocity = 10000 * speedFactor
			local smallMove = movel * speedFactor

			local originalVelocity = hrp.Velocity

			-- BAGIAN FLING ASLI
			hrp.Velocity = originalVelocity * flingVelocity + Vector3.new(0, upwardVelocity, 0)
			RunService.RenderStepped:Wait()

			hrp.Velocity = originalVelocity
			RunService.Stepped:Wait()

			hrp.Velocity = originalVelocity + Vector3.new(0, smallMove, 0)
			movel = -movel

			if holding then
				PlaySound(effectFreeId, hrp)
			end

			task.wait(0.01)
		end
	end)
end

local function StopFling()
	hiddenFling = false
	if touchedConnection then
		touchedConnection:Disconnect()
		touchedConnection = nil
	end
end

------------------------------------------------------
-- 7. BUTTON CONTROL (NO LIMIT SPEED)
------------------------------------------------------
button.MouseButton1Down:Connect(function()
	holding = true
	if track then
		track:Play()
	end

	StartFling(player.Character)

	task.spawn(function()
		local speed = 2
		while holding do
			speed = speed + 0.2
			if track then
				track:AdjustSpeed(speed)
			end
			task.wait(0.01)
		end
	end)
end)

button.MouseButton1Up:Connect(function()
	holding = false
	if track then
		track:Stop()
	end
	StopFling()
end)

button.MouseLeave:Connect(function()
	if holding then
		holding = false
		if track then
			track:Stop()
		end
		StopFling()
	end
end)
