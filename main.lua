local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- 1. Create GUI Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = " " 
ScreenGui.ResetOnSpawn = false 
ScreenGui.DisplayOrder = 999   
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- 2. Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 110)
Frame.Position = UDim2.new(0.5, -125, 0.5, -55)
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BorderColor3 = Color3.new(1, 0, 0)
Frame.BorderSizePixel = 2
Frame.Active = true
Frame.Parent = ScreenGui

-- Draggable Logic
local dragging, dragInput, dragStart, startPos
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- 3. Title
local Title = Instance.new("TextLabel")
Title.Text = "SPEEDHAX"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.new(1, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = Frame

-- 4. Variables
local IsEnabled = false
local SpeedBoost = 0
local IsArmed = false 
local SpeedLoop 

-- 5. Toggle Button
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0, 60, 0, 45)
Toggle.Position = UDim2.new(0.7, 0, 0.4, 0)
Toggle.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Toggle.TextColor3 = Color3.new(1, 0, 0)
Toggle.Text = "OFF"
Toggle.Parent = Frame

Toggle.MouseButton1Click:Connect(function()
    IsEnabled = not IsEnabled
    Toggle.Text = IsEnabled and "ON" or "OFF"
    Toggle.BackgroundColor3 = IsEnabled and Color3.new(0, 0.4, 0) or Color3.new(0.1, 0.1, 0.1)
end)

-- 6. Speed Buttons (Updated to 0.75 / Max 20)
local BoostPlus = Instance.new("TextButton")
BoostPlus.Size = UDim2.new(0, 150, 0, 20)
BoostPlus.Position = UDim2.new(0.05, 0, 0.4, 0)
BoostPlus.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
BoostPlus.TextColor3 = Color3.new(1, 0, 0)
BoostPlus.Text = "Boost: 0 (+)"
BoostPlus.Parent = Frame

local BoostMinus = Instance.new("TextButton")
BoostMinus.Size = UDim2.new(0, 150, 0, 20)
BoostMinus.Position = UDim2.new(0.05, 0, 0.65, 0)
BoostMinus.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
BoostMinus.TextColor3 = Color3.new(1, 0, 0)
BoostMinus.Text = "Decrease (-)"
BoostMinus.Parent = Frame

local function UpdateUI()
    -- Rounds display to 2 decimal places
    BoostPlus.Text = "Boost: " .. string.format("%.2f", SpeedBoost) .. " (+)"
end

BoostPlus.MouseButton1Click:Connect(function()
    SpeedBoost = math.clamp(SpeedBoost + 0.75, 0, 20)
    UpdateUI()
end)

BoostMinus.MouseButton1Click:Connect(function()
    SpeedBoost = math.clamp(SpeedBoost - 0.75, 0, 20)
    UpdateUI()
end)

-- 7. Fixed Close Button Logic
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 25, 0, 25)
Close.Position = UDim2.new(1, -30, 0, 5)
Close.Text = "X"
Close.TextColor3 = Color3.new(1, 0, 0)
Close.BackgroundColor3 = Color3.new(0.2, 0, 0)
Close.Parent = Frame

Close.MouseButton1Click:Connect(function()
    if not IsArmed then
        IsArmed = true
        Close.Text = "?"
        Close.BackgroundColor3 = Color3.new(0.6, 0, 0)
        task.delay(3, function()
            if Close and IsArmed then
                IsArmed = false
                Close.Text = "X"
                Close.BackgroundColor3 = Color3.new(0.2, 0, 0)
            end
        end)
    else
        ScreenGui:Destroy()
    end
end)

-- 8. Core Speed Loop
SpeedLoop = RunService.Stepped:Connect(function()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if hum and hrp then
        if hum.Health <= 0 then
            IsEnabled = false
            Toggle.Text = "OFF"
            Toggle.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
            return
        end
        
        if IsEnabled and hum.MoveDirection.Magnitude > 0 then
            -- Nudge logic with the new SpeedBoost value
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (SpeedBoost / 10))
        end
    end
end)

-- 9. Silent Unload
ScreenGui.AncestryChanged:Connect(function(_, parent)
    if not parent then
        if SpeedLoop then
            SpeedLoop:Disconnect()
            SpeedLoop = nil
        end
    end
end)

--speed changer
