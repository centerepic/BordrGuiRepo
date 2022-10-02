local MainAccount = "yournamehere"

local ScreenGui = Instance.new("ScreenGui")
local ProfitLabel = Instance.new("TextLabel")
local StatusLabel = Instance.new("TextLabel")

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 1000
ProfitLabel.Parent = ScreenGui
ProfitLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ProfitLabel.BackgroundTransparency = 1.000
ProfitLabel.Position = UDim2.new(0.5, -190, 0.5, -25)
ProfitLabel.Size = UDim2.new(0, 380, 0, 50)
ProfitLabel.Font = Enum.Font.Arcade
ProfitLabel.Text = "Profit - 0$"
ProfitLabel.TextColor3 = Color3.fromRGB(4, 255, 0)
ProfitLabel.TextScaled = true
ProfitLabel.TextSize = 14.000
ProfitLabel.TextStrokeColor3 = Color3.fromRGB(8, 7, 7)
ProfitLabel.TextStrokeTransparency = 0.000
ProfitLabel.TextWrapped = true
StatusLabel.Parent = ScreenGui
StatusLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.BackgroundTransparency = 1.000
StatusLabel.Position = UDim2.new(0.5, -190, 0.553361773, -25)
StatusLabel.Size = UDim2.new(0, 380, 0, 29)
StatusLabel.Font = Enum.Font.Arcade
StatusLabel.Text = "Loading autofarm..."
StatusLabel.TextColor3 = Color3.fromRGB(252, 255, 69)
StatusLabel.TextScaled = true
StatusLabel.TextSize = 14.000
StatusLabel.TextStrokeTransparency = 0.000
StatusLabel.TextWrapped = true

local function Status(Status)
    StatusLabel.Text = Status
end

local GC = getconnections or get_signal_cons
if GC then
	for i,v in pairs(GC(game.Players.LocalPlayer.Idled)) do
		if v["Disable"] then
			v["Disable"](v)
		elseif v["Disconnect"] then
			v["Disconnect"](v)
		end
	end
else
	game.Players.LocalPlayer.Idled:Connect(function()
		local VirtualUser = game:GetService("VirtualUser")
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
end

local RunService = game:GetService("RunService")
local otick = tick()
local oc = game:GetService("Players").LocalPlayer.leaderstats.coins.Value
local Ocean = game:GetService("Workspace").Map.Ocean
local IceburgProximityPrompt = nil

for i,v in ipairs(Ocean:GetDescendants()) do
    if v.Name == "CollectIce" then
        IceburgProximityPrompt = v
    end
end

local Coconut = game:GetService("Workspace").Interactables.CollectableItems.Coconut
local ShaveIcePrompt = game:GetService("Workspace").BredStand.Part.ShaveIce
local GettingIce = false
local LocalPlayer = game:GetService("Players").LocalPlayer

local Ice = function()
    local num = 0
    for i,v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if v.Name == "icecube" then
            num = num + 1
        end
    end
    return num
end

local ShaveIce = function()
    local num = 0
    for i,v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if v.Name == "shave ice" then
            num = num + 1
        end
    end
    return num
end

local TPBind = nil

local function TP(Position)
    if typeof(Position) == "Instance" then
        Position = Position.Position
    end
    
    if TPBind ~= nil then
        TPBind:Disconnect()
    end
    
    TPBind = RunService.RenderStepped:Connect(function()
        LocalPlayer.Character:PivotTo(CFrame.new(Position))
    end)
end

local function SellIce()
    game:GetService("ReplicatedStorage").Remotes.Shop:FireServer("shave ice",false)
end

local function GetCoconut()
    TP(Coconut.Handle)
    wait(0.5)
    fireclickdetector(Coconut.Handle.ClickDetector,0)
end

local function GetIce()
    TP(IceburgProximityPrompt.Parent.Position - Vector3.new(0,2,0))
    wait(0.2)
    fireproximityprompt(IceburgProximityPrompt,0)
    GettingIce = true
    delay(11,function()
        GettingIce = false
    end)
end

local function Initialize()
    
    setfpscap(30)
    game:GetService("RunService"):Set3dRenderingEnabled(false)
    
    local Character = LocalPlayer.Character
    
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        
        game:GetService("Workspace").Camera.CameraSubject = Character.HumanoidRootPart
        
        Character:WaitForChild("Hunger"):Destroy() -- rofl
        
        Character.ChildAdded:Connect(function(Child)
            if Child.Name == "icecube" then
                if Child.Melt then
                    Child.Melt:Destroy()
                end
            end
        end)
        
        for i,v in ipairs(Character:GetDescendants()) do
            if v:IsA("Accessory") then
    			for i,p in next, v:GetDescendants() do
    				if p:IsA("Weld") then
    					p:Destroy()
    				end
    			end
            end
        end
	
        Character.Head.NameGui:Destroy() -- ROFL!!
        
        local function NoclipLoop()
		if LocalPlayer.Character ~= nil then
			for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
				if child:IsA("BasePart") and child.CanCollide == true then
					child.CanCollide = false
					child.Velocity = Vector3.new(0,0,0)
				end
		    end
	    end
	    end
	    RunService.Stepped:Connect(NoclipLoop)
    end
end

local function DropAllMoney()
    TP(Vector3.new(0, 3.1, -5060.5))
    wait(5)
    TP(Vector3.new(-1331, 206, -148))
    game.Players.LocalPlayer.PlayerGui:WaitForChild("Mission"):Destroy()
    LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:WaitForChild("coin"))
    wait(0.2)
    LocalPlayer.Character:WaitForChild("coin").Handle.Mesh:Destroy() -- so your main knows it's from your alts
    game:GetService("Players").LocalPlayer.Character.coin.RemoteEvent:FireServer(BrickColor.new(333))
    wait(0.2)
    repeat game:GetService("Players").LocalPlayer.Character.coin:Activate() wait()
    until game:GetService("Players").LocalPlayer.leaderstats.coins.Value < 100
    TP(game:GetService("Workspace").Map.Bricklandia.ChangeTeam.Part)
    wait(0.2)
    fireproximityprompt(game:GetService("Workspace").Map.Bricklandia.ChangeTeam.Part.ChangeTeam,0)
    LocalPlayer.CharacterAdded:Wait()
    wait(1)
    Initialize()
end

Initialize()

Status("[!] Autofarm loaded in "..tostring(tick()-otick).." seconds.")

while true do
    task.wait(1)
    ProfitLabel.Text = "Profit - $" .. tostring(game:GetService("Players").LocalPlayer.leaderstats.coins.Value - oc)
    if Ice() > 0 then
        Status("Getting coconut!")
        GetCoconut()
        wait(0.2)
        Status("Shaving ice!")
        TP(Vector3.new(552.945, 4.35484, -188.667))
        wait(0.2)
        fireproximityprompt(ShaveIcePrompt,0)
        wait(11.5)
        Status("Selling Shaved ice!")
        for i = ShaveIce(),1,-1 do -- sell residual ice
            SellIce()
            wait(1)
        end
    else
        
        if LocalPlayer.leaderstats.coins.Value >= 500 and LocalPlayer.Name ~= MainAccount then
            Status("Dropping money!")
            DropAllMoney()
        elseif LocalPlayer.Name == MainAccount then
            for i,v in pairs(workspace:GetChildren()) do
                if v.Name == "100" and v:FindFirstChild("Mesh") == nil then
                    Status("Collecting money!")
                    TP(v)
                    wait(0.2)
                end
            end
        end
        
        if not GettingIce then
            Status("Getting ice!")
            GetIce()
        end
    end
end