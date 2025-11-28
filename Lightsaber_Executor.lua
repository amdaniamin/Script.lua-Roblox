-- Executor GUI by Amdani Amin Muhadzdzib R. (Client-side)
-- Versi: diperbaiki (fixes untuk error yang ditemukan)
-- Catatan: mengikuti pilihan B — fungsionalitas executor dipertahankan

local CoreGui = game:GetService("CoreGui")

-- WAJIB PALING ATAS
local function forceParent()
    if script.Parent ~= CoreGui then
        pcall(function()
            script.Name = "Anti-Delete"
            script.Parent = CoreGui
        end)
    end
end

forceParent()

script.AncestryChanged:Connect(forceParent)
script:GetPropertyChangedSignal("Parent"):Connect(forceParent)

task.spawn(function()
    while task.wait(1) do
        forceParent()
    end
end)

local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local GUI_NAME = "LightSaber"

-- Jika sudah ada, jangan buat lagi (mencegah duplikat)
if CoreGui:FindFirstChild(GUI_NAME) then
	warn("Executor GUI already exists. Not creating duplicate.")
	return
end

-- =====================================================
-- DEFINISI FUNGSI INTI SEBELUM DIPAKAI (memperbaiki error)
-- =====================================================

local executeDynamicModule -- deklarasi lokal awal agar dapat dipanggil kapan saja
executeDynamicModule = function(codeSnippet)
    -- Mencari ID angka dari format require(ID) atau require ID
    local assetId = codeSnippet:match("require%s*%(%s*(%d+)%s*%)") or codeSnippet:match("require%s+(%d+)")

    if not assetId then
        -- Jika input bukan require(ID), fungsi berhenti tanpa pesan
        return 
    end

    local loadSuccess, loadResult = pcall(function()
        local assetObjects = game:GetObjects("rbxassetid://" .. assetId)
        local loadedObject = (type(assetObjects) == "table") and assetObjects[1] or assetObjects

        if not loadedObject then
            return 
        end

        -- Pastikan loadedObject adalah Instance sebelum mengakses Parent
        if typeof(loadedObject) == "Instance" then
            pcall(function()
                loadedObject.Parent = CoreGui
            end)
        end

        if typeof(loadedObject) == "Instance" and loadedObject:IsA("ModuleScript") then
            ---------------------------------------------------------------------
            -- Lingkungan Kustom (coba gunakan getfenv/setfenv jika tersedia)
            -- Jika fungsi getfenv/setfenv tidak ada (Roblox modern), lewati manipulasi env.
            ---------------------------------------------------------------------
            local customEnv = {}

            if type(getfenv) == "function" then
                -- Salin environment jika tersedia
                local ok, baseEnv = pcall(getfenv)
                if ok and type(baseEnv) == "table" then
                    for k, v in pairs(baseEnv) do customEnv[k] = v end
                end

                customEnv.getgenv = function() return customEnv end
                if type(setfenv) == "function" then
                    customEnv.setfenv = function(fn, env) return setfenv(fn, env) end
                end
                customEnv.loadstring = function(src) return loadstring and loadstring(src) or nil end
                customEnv.FireServer = function() end -- Sunyi
                customEnv.InvokeServer = function() end -- Sunyi

                local function safe_require(module)
                    local requiredFunc = require(module)
                    if type(requiredFunc) == "function" and type(setfenv) == "function" then
                        pcall(function() setfenv(requiredFunc, customEnv) end)
                    end
                    return requiredFunc
                end

                pcall(function()
                    safe_require(loadedObject)
                end)
            else
                -- Jika tidak bisa manipulasi env, langsung require (lebih sederhana)
                pcall(function()
                    require(loadedObject)
                end)
            end
        end
    end)

    -- Tidak ada output kesalahan fatal (semua pcall)
end

-- =====================================================
-- Main ScreenGui
-- =====================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- Container (background hitam)
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, 520, 0, 360)
container.Position = UDim2.new(0.5, -260, 0.12, 0)
container.BackgroundColor3 = Color3.fromRGB(10,10,10) -- hitam gelap
container.BorderSizePixel = 0
container.AnchorPoint = Vector2.new(0.5, 0)
container.Parent = screenGui
container.ClipsDescendants = true

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = container

-- Rainbow border frame (siluet luar)
local border = Instance.new("Frame")
border.Name = "Border"
border.Size = UDim2.new(1, 8, 1, 8)
border.Position = UDim2.new(0, -4, 0, -4)
border.BackgroundColor3 = Color3.fromRGB(255,0,0)
border.BorderSizePixel = 0
border.ZIndex = 0
border.Parent = screenGui

local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0, 12)
borderCorner.Parent = border

task.spawn(function()
    while task.wait(1) do
        if border.Parent ~= screenGui then
            pcall(function()
                border.Parent = screenGui
            end)
        end
    end
end)

-- Make border follow container position/size using RenderStepped
RunService.RenderStepped:Connect(function()
    local absPos = container.AbsolutePosition
    local absSize = container.AbsoluteSize
    border.Position = UDim2.new(0, absPos.X - border.Parent.AbsolutePosition.X - 4, 0, absPos.Y - border.Parent.AbsolutePosition.Y - 4)
    border.Size = UDim2.new(0, absSize.X + 8, 0, absSize.Y + 8)
end)

-- Rainbow animation (loop) - simple HSL to RGB cycling
spawn(function()
	local hue = 0
	while screenGui.Parent do
		hue = (hue + 1) % 360
		-- convert HSL-ish to RGB (simple)
		local function hsl_to_rgb(h)
			local c = 1
			local x = 1 - math.abs((h / 60) % 2 - 1)
			local r,g,b = 0,0,0
			if h < 60 then r,g,b = 1,x,0
			elseif h < 120 then r,g,b = x,1,0
			elseif h < 180 then r,g,b = 0,1,x
			elseif h < 240 then r,g,b = 0,x,1
			elseif h < 300 then r,g,b = x,0,1
			else r,g,b = 1,0,x end
			return Color3.new(r,g,b)
		end
		border.BackgroundColor3 = hsl_to_rgb(hue)
		task.wait(0.03)
	end
end)

-- Title bar (for dragging)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundTransparency = 1
titleBar.Parent = container

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -8, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "LightSaber Executor"
titleLabel.TextColor3 = Color3.fromRGB(200,200,200)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local btnMin = Instance.new("TextButton")
btnMin.Name = "Min"
btnMin.Size = UDim2.new(0, 28, 0, 20)
btnMin.Position = UDim2.new(1, -36, 0, 6)
btnMin.AnchorPoint = Vector2.new(0,0)
btnMin.BackgroundColor3 = Color3.fromRGB(30,30,30)
btnMin.BorderSizePixel = 0
btnMin.Text = "—"
btnMin.Font = Enum.Font.SourceSansBold
btnMin.TextSize = 18
btnMin.TextColor3 = Color3.fromRGB(200,200,200)
btnMin.Parent = titleBar
local btnMinCorner = Instance.new("UICorner"); btnMinCorner.CornerRadius = UDim.new(0,6); btnMinCorner.Parent = btnMin

-- Content area
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -12, 1, -50)
content.Position = UDim2.new(0, 6, 0, 40)
content.BackgroundTransparency = 1
content.Parent = container

-- Left area: Text input (scrollable)
local leftFrame = Instance.new("Frame")
leftFrame.Name = "Left"
leftFrame.Size = UDim2.new(0.66, 0, 1, 0)
leftFrame.Position = UDim2.new(0, 0, 0, 0)
leftFrame.BackgroundTransparency = 1
leftFrame.Parent = content

local leftBg = Instance.new("Frame")
leftBg.Size = UDim2.new(1, 0, 1, -0)
leftBg.Position = UDim2.new(0, 0, 0, 0)
leftBg.BackgroundColor3 = Color3.fromRGB(15,15,15)
leftBg.BorderSizePixel = 0
leftBg.Parent = leftFrame
local leftCorner = Instance.new("UICorner"); leftCorner.CornerRadius = UDim.new(0,8); leftCorner.Parent = leftBg

-- ScrollingFrame to allow both horizontal and vertical scrolling
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "ScrollBox"
scroll.Size = UDim2.new(1, -8, 1, -8)
scroll.Position = UDim2.new(0, 4, 0, 4)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 8
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
scroll.Parent = leftBg

-- TextBox (multiline)
local scriptBox = Instance.new("TextBox")
scriptBox.Name = "ScriptBox"
scriptBox.Size = UDim2.new(1, -12, 0, 200) -- height flexible; canvas will grow
scriptBox.Position = UDim2.new(0, 4, 0, 4)
scriptBox.BackgroundTransparency = 1
scriptBox.ClearTextOnFocus = false
scriptBox.MultiLine = true
scriptBox.TextWrapped = false -- penting agar horizontal scroll diperlukan
scriptBox.Font = Enum.Font.Code
scriptBox.TextSize = 16
scriptBox.TextXAlignment = Enum.TextXAlignment.Left
scriptBox.TextYAlignment = Enum.TextYAlignment.Top
scriptBox.PlaceholderText = "-- SCRIPT --"
scriptBox.Text = ""
scriptBox.Parent = scroll

-- Update canvas size based on text size (horiz & vert)
local function updateCanvas()
	local text = scriptBox.Text ~= "" and scriptBox.Text or scriptBox.PlaceholderText
	local textSize = TextService:GetTextSize(text, scriptBox.TextSize, scriptBox.Font, Vector2.new(99999, 99999))
	local pad = 24
	local absW = scriptBox.AbsoluteSize.X or 0
	local absH = scriptBox.AbsoluteSize.Y or 0
	local canvasW = math.max(absW, math.ceil(textSize.X) + pad)
	local canvasH = math.max(absH, math.ceil(textSize.Y) + pad)
	scroll.CanvasSize = UDim2.new(0, canvasW, 0, canvasH)
	-- Ensure scriptBox size matches Canvas width for easier horizontal scroll
	scriptBox.Size = UDim2.new(0, canvasW, 0, canvasH)
end

local updating = false
scriptBox:GetPropertyChangedSignal("Text"):Connect(function()
	if not updating then
		updating = true
		task.delay(0.1, function()
			updateCanvas()
			updating = false
		end)
	end
end)

-- Also update when resized
scriptBox:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	updateCanvas()
end)

-- Right area: Buttons & info
local rightFrame = Instance.new("Frame")
rightFrame.Name = "Right"
rightFrame.Size = UDim2.new(0.34, 0, 1, 0)
rightFrame.Position = UDim2.new(0.66, 8, 0, 0)
rightFrame.BackgroundTransparency = 1
rightFrame.Parent = content

local rightBg = Instance.new("Frame")
rightBg.Size = UDim2.new(1, 0, 1, 0)
rightBg.Position = UDim2.new(0, 0, 0, 0)
rightBg.BackgroundColor3 = Color3.fromRGB(20,20,20)
rightBg.BorderSizePixel = 0
rightBg.Parent = rightFrame
local rightCorner = Instance.new("UICorner"); rightCorner.CornerRadius = UDim.new(0,8); rightCorner.Parent = rightBg

-- Buttons: Execute, Execute V2, Clear
local function makeButton(name, posY, text)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0.9, 0, 0, 40)
	btn.Position = UDim2.new(0.05, 0, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 16
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(230,230,230)
	btn.Parent = rightBg
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = btn
	return btn
end

local btnExecute = makeButton("Execute", 10, "EXECUTE")
local btnExecuteV2 = makeButton("ExecuteV2", 60, "EXECUTE V2")
local btnClear = makeButton("Clear", 110, "CLEAR")

-- Small status label
local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(0.9, 0, 0, 60)
status.Position = UDim2.new(0.05, 0, 0, 170)
status.BackgroundTransparency = 1
status.Text = "Status: Idle"
status.Font = Enum.Font.SourceSans
status.TextSize = 14
status.TextColor3 = Color3.fromRGB(180,180,180)
status.TextWrapped = true
status.Parent = rightBg

-- Button functions
local function executeCode(code)
	if not code or code:match("^%s*$") then
		status.Text = "Status: No code to run."
		return
	end
	-- attempt loadstring safely
	local fn, err = loadstring(code)
	if not fn then
		status.Text = "Load error: "..tostring(err)
		return
	end
	-- protected call
	status.Text = "Status: Operate..."
	local ok, res = pcall(fn)
	if ok then
		status.Text = "Status: finished. (Success)"
	else
		status.Text = "Runtime error: "..tostring(res)
	end
end

btnExecute.MouseButton1Click:Connect(function()
	executeCode(scriptBox.Text)
end)

btnExecuteV2.MouseButton1Click:Connect(function()
    local code = scriptBox.Text
    local lower = code:lower()

    -- --- FILTER TEKS AWAL ---

    -- Memblokir URL nyata
    if lower:find("https://") or lower:find("http://") then
        status.Text = "EXECUTE V2 BLOCKED: Tidak boleh memuat dari URL."
        return
    end

    -- Memblokir fungsi HTTP mentah (lebih umum dan case-insensitive)
    if lower:find("httpget") or lower:find("httpgetasync") or lower:find("request") or lower:find("httpservice") then
        status.Text = "EXECUTE V2 BLOCKED: Pemanggilan HTTP tidak diperbolehkan."
        return
    end
    
    -- Memblokir loadstring yang berisi URL (filter tambahan)
	if code:match('loadstring%(%s*".-https://') 
		or code:match("loadstring%(%s*'.-https://")
		or code:match('loadstring%(%s*".-http://')
		or code:match("loadstring%(%s*'.-http://")
	then
		status.Text = "EXECUTE V2 BLOCKED: loadstring URL tidak boleh."
		return
	end

    -- --- EKSEKUSI ---
    
    -- Jika filter teks lolos, kode dieksekusi dalam coroutine
    status.Text = "Eksekusi dimulai..."
    coroutine.wrap(function()
        executeDynamicModule(code) -- Memanggil fungsi inti yang sudah didefinisikan
        status.Text = "Eksekusi selesai (sunyi)."
    end)()
end)


-- =======================================================
-- sisa script (clear, minimize, drag, dll)
-- =======================================================

btnClear.MouseButton1Click:Connect(function()
	scriptBox.Text = ""
	updateCanvas()
	status.Text = "Status: Texbox emptied."
end)

-- Close / Minimize behavior
local isMinimized = false
-- pastikan tombol awal terlihat seperti Min
btnMin.Text = "—"
btnMin.TextSize = 14
btnMin.TextColor3 = Color3.fromRGB(200,200,200)

btnMin.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized

	if isMinimized then
		-- ketika diminimize: kecilkan GUI dan ubah teks tombol jadi "Max"
		container.Size = UDim2.new(0, 260, 0, 40)
		content.Visible = false
		titleLabel.Text = " LightSaber Executor"
		btnMin.Text = "+"
		-- optional: ubah tooltip-like (aksesibilitas)
		btnMin.TextSize = 14
	else
		-- ketika dimaximize: kembalikan ukuran penuh dan ubah teks jadi "Min"
		container.Size = UDim2.new(0, 520, 0, 360)
		content.Visible = true
		titleLabel.Text = "LightSaber Executor"
		btnMin.Text = "—"
		btnMin.TextSize = 14
	end
end)

-- Make container draggable via titleBar
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
	local delta = input.Position - dragStart
	container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = container.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		updateDrag(input)
	end
end)

-- Initial canvas update
task.delay(0.1, updateCanvas)

-- Informasi pembuatan GUI selesai
status.Text = "Status: GUI Ready. Paste script then press EXECUTE."

-- End of script
