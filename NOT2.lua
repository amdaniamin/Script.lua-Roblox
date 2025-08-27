-- LocalScript: StarterPlayerScripts/FE_Aimbot_AutoJump_GUI.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

-- ===== VARIABEL =====
local aimbotEnabled = false
local autoJumpEnabled = false

-- ===== AIMBOT =====
local function getClosestVisibleEnemy()
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local rayOrigin = Camera.CFrame.Position
                    local rayDirection = (hrp.Position - rayOrigin).Unit * (hrp.Position - rayOrigin).Magnitude
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

                    local result = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                    if result and result.Instance:IsDescendantOf(player.Character) then
                        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                        if dist < closestDist then
                            closest, closestDist = hrp, dist
                        end
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestVisibleEnemy()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- ===== AUTO JUMP =====
local function setupAutoJump(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    humanoid.StateChanged:Connect(function(_, newState)
        if autoJumpEnabled and newState == Enum.HumanoidStateType.Landed then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(setupAutoJump)
if LocalPlayer.Character then
    setupAutoJump(LocalPlayer.Character)
end

-- ===== GUI MELAYANG =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FeatureToggleGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 100)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local uiList = Instance.new("UIListLayout")
uiList.FillDirection = Enum.FillDirection.Vertical
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 5)
uiList.Parent = frame

-- helper buat toggle
local function createToggle(name, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 40)
    button.Position = UDim2.new(0, 5, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    button.Text = name .. ": OFF"
    button.Font = Enum.Font.SourceSansBold
    button.TextColor3 = Color3.new(1,1,1)
    button.TextSize = 18
    button.Parent = frame

    local enabled = false
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        callback(enabled)
        if enabled then
            button.Text = name .. ": ON"
            button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        else
            button.Text = name .. ": OFF"
            button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        end
    end)
end

-- buat toggle Aimbot
createToggle("Aimbot", function(state)
    aimbotEnabled = state
end)

-- buat toggle Auto Jump
createToggle("Auto Jump", function(state)
    autoJumpEnabled = state
end)
