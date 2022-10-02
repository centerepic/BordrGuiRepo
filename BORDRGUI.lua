-- sashaa supremacy 😎

-- [S0] Initialalization & Golfing

local function OrionLibCustomizarize()
    local OrionGui = game:GetService("CoreGui").Orion
    for _, v in ipairs(OrionGui:GetDescendants()) do
        if v:IsA("TextLabel") then
            v.Font = Enum.Font.Arcade
            v.TextColor3 = Color3.new(0.933333, 0.941176, 0.568627)
            v:GetPropertyChangedSignal("Font"):Connect(function()
                v.Font = Enum.Font.Arcade
            end)
        end
        if v:IsA("UICorner") then
            local OriginalCornerRadius = v.CornerRadius
            v.CornerRadius = UDim.new(0,OriginalCornerRadius.Offset/2)
            v:GetPropertyChangedSignal("CornerRadius"):Connect(function()
                v.CornerRadius = UDim.new(0,OriginalCornerRadius.Offset/2)
            end)
        end
    end
end

local OTick = tick()
local Version = 1.1
local SupportedGameVersion = 1474
local TargetWalkspeed = 0
local FCD = fireclickdetector
local FPP = fireproximityprompt
local FTI = firetouchinterest
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/centerepic/LifeSentanceScript/main/Aiming_Module.lua"))()
Aiming.TeamCheck(true)

-- [S1] Player

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Backpack = LocalPlayer.Backpack
local Character = LocalPlayer.Character
local LastTeam = LocalPlayer.Team
local CurrentTeam

LocalPlayer.CharacterAdded:Connect(function(Model)
    Character = Model
end)

local function TP(Position)

    if typeof(Position) == "Instance" then
        Position = Position.CFrame
    end
    
    if typeof(Position) == "CFrame" then
        Character:PivotTo(Position)
    else
        warn("[!] Invalid Argument Passed to TP()")
    end
    
end

-- [S2] Item Collection

local CollectableItems = workspace.Interactables.CollectableItems
local ItemsList = 
	{
		"Apple",
		"GhostBrick",
		"Bone",
		"BerryBush",
		"Caterpillar",
		"Coconut",
		"PinkFlower",
		"Moonrock",
		"ShinyBar"
	}

local Items = {}

local cont = true
for _,x in pairs(ItemsList) do
	for _,y in ipairs(CollectableItems:GetDescendants()) do
		if y.Name == x then
            cont = true
            for _,l in pairs(y:GetDescendants()) do
                if l.Name == "TeamOnly" or l.Name == "Owner" then
                    cont = false
                end
            end
            if cont == true then
                Items[x] = y
            end
		end
	end
end

local function CollectItem(Instance)
    local OriginalPositon = Character.HumanoidRootPart.CFrame
	local ClickDetector
    for i,v in ipairs(Instance:GetDescendants()) do
        if v:IsA("ClickDetector") then
            ClickDetector = v
        end
    end

    TP(ClickDetector.Parent)
    task.wait(0.3)
    FCD(ClickDetector,1)
    TP(OriginalPositon)
end

-- [S3] Potion Brewing

local PotionRemote = ReplicatedStorage.Remotes.BrewPotion

local PotionTable = {}
PotionTable["JumpPower"] = {Items["Moonrock"],Items["PinkFlower"],Items["BerryBush"]}
PotionTable["Heal"] = {Items["Apple"],Items["PinkFlower"],Items["Bone"]}
PotionTable["Speed"] = {Items["Moonrock"],Items["ShinyBar"],Items["Bone"]}
PotionTable["Invisible"] = {Items["Caterpillar"],Items["PinkFlower"],Items["GhostBrick"]}
PotionTable["Armor"] = {Items["Caterpillar"],Items["ShinyBar"],Items["Moonrock"]}
PotionTable["Stamina"] = {Items["PinkFlower"],Items["Apple"],Items["Caterpillar"],Items["ShinyBar"]}    -- who needs obfuscation when your code is shit
PotionTable["Disguise"] = {Items["BerryBush"],Items["ShinyBar"],Items["Bone"],Items["PinkFlower"]}
PotionTable["FullBelly"] = {Items["BerryBush"],Items["Caterpillar"],Items["Apple"]}

function MakePotion(Name)
    if PotionTable[Name] then
        local OriginalPositon = Character.HumanoidRootPart.CFrame
        for _,v in pairs(PotionTable[Name]) do
            CollectItem(v)
        end
        task.wait(1)
        PotionRemote:FireServer(Name)
        TP(OriginalPositon)
    end
end

-- [S4] Player/Character functions

local SwordReachPart = Instance.new("Part")

task.defer(function()
    
    local oldIndex = nil 
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, Index)
        if self == Mouse and not checkcaller() and OrionLib.Flags["SilentAim"] and Aiming.SelectedPart ~= nil then
            local HitPart = Aiming.SelectedPart
             
            if Index == "Target" or Index == "target" then 
                return HitPart
            elseif Index == "Hit" or Index == "hit" then 
                return CFrame.new(Aiming.SelectedPart.Position)
            elseif Index == "X" or Index == "x" then 
                return self.X 
            elseif Index == "Y" or Index == "y" then 
                return self.Y 
            elseif Index == "UnitRay" then 
                return Ray.new(self.Origin, (self.Hit - self.Origin).Unit)
            end
        end
    
        return oldIndex(self, Index)
    end))

    SwordReachPart.Shape = Enum.PartType.Ball
    SwordReachPart.CanCollide = false
    SwordReachPart.BrickColor = BrickColor.new("Pastel Blue")
    SwordReachPart.Massless = true
    SwordReachPart.Transparency = 0.8
    SwordReachPart.Parent = workspace
    SwordReachPart.Position = Vector3.new(0,9e9,0)
    SwordReachPart.Anchored = true

    local SwordReachWeld = Instance.new("Weld")
    SwordReachWeld.Parent = SwordReachPart
    SwordReachWeld.Part0 = SwordReachPart

    SwordReachWeld:GetPropertyChangedSignal("Part1"):Connect(function()
        wait()
        if not SwordReachWeld.Part1 then
            SwordReachPart.Anchored = true
            SwordReachPart.Position = Vector3.new(0,9e9,0)
        end
    end)

    SwordReachPart.Touched:Connect(function(Hit)
        if OrionLib.Flags["SwordReach"].Value == true then
            if Hit.Parent:FindFirstChildOfClass("Humanoid") and Hit.Parent.Name ~= Character.Name then
                for _,v in pairs(Hit.Parent:GetChildren()) do
                    if v:IsA("Part") then
                        FTI(v,SwordReachWeld.Part1,0)
                        FTI(v,SwordReachWeld.Part1,1)
                    end
                end
            end
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        pcall(function()
            if Character.Humanoid.MoveDirection.Magnitude > 0 and Character.Humanoid.Health > 0 then
                Character:TranslateBy(Character.Humanoid.MoveDirection * TargetWalkspeed/100)
            end
        end)
    end)

    LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
        if LocalPlayer.Team.Name == "timeout" then
            TP(CFrame.new(Vector3.new(0, 9, -5061)))
            wait(3)
            TP(CFrame.new(Vector3.new(0, 9, -5061)))
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function(Model) -- omg he connected characterdadded twice so inefficient
        Model.DescendantAdded:Connect(function(Descendant)
            if Descendant:IsA("Tool") then
                if Descendant:FindFirstChild("LegalPotion") and OrionLib.Flags["ReusablePotions"].Value == true then
                    local TCON
                    TCON = function()
                        wait()
                        FPP(Descendant.Handle.TakeTool,0)
                    end
                    Descendant.Activated:Connect(TCON)
                end
            end
            if Descendant:IsA("Sparkles") then
                if OrionLib.Flags["NoParticles"].Value == true then
                    wait()
                    Descendant:Destroy()
                end
            end
            if Descendant.Name == "Hunger" then
                if OrionLib.Flags["NoHunger"].Value == true then
                    wait()
                    Descendant:Destroy()
                end
            end
            if Descendant.Name == "Stamina" then
                if OrionLib.Flags["InfStam"].Value == true then
                    wait()
                    Descendant.Value = math.huge
                end
            end
            if Descendant.Name == "NameGui" then
                if OrionLib.Flags["NoName"].Value == true then
                    wait()
                    Descendant:Destroy()
                end
            end
            if Descendant.Name == "Sheath" and OrionLib.Flags["InvisSword"].Value == true then
                wait()
                Descendant.ChildAdded:Connect(function(Child)
                    if Child:IsA("WeldConstraint") then
                        wait()
                        Child:Destroy()
                    end
                end)
            end
            if Descendant.Name == "sword" then
                if OrionLib.Flags["InvisSword"].Value == true then
                    wait()
                    for i,v in pairs(Descendant.Handle:GetChildren()) do
                        if v:IsA("WeldConstraint") then
                            v:Destroy()
                        end
                    end
                end
                if OrionLib.Flags["SwordReach"].Value == true then
                    wait()
                    SwordReachPart.Anchored = false
                    SwordReachPart.Position = Descendant.Handle.Position
                    SwordReachWeld.Part1 = Descendant.Handle
                end
            end
        end)
    end)

    repeat wait()
    until Character:FindFirstChild("HumanoidRootPart")
    if Character then
        Character.DescendantAdded:Connect(function(Descendant)
            if Descendant:IsA("Tool") then
                if Descendant:FindFirstChild("LegalPotion") and OrionLib.Flags["ReusablePotions"].Value == true then
                    local TCON
                    TCON = function()
                        wait()
                        FPP(Descendant.Handle.TakeTool,0)
                    end
                    Descendant.Activated:Connect(TCON)
                end
            end
            if Descendant:IsA("Sparkles") then
                if OrionLib.Flags["NoParticles"].Value == true then
                    wait()
                    Descendant:Destroy()
                end
            end
            if Descendant.Name == "Hunger" then
                if OrionLib.Flags["NoHunger"].Value == true then
                    wait()
                    Descendant:Destroy()
                end
            end
            if Descendant.Name == "Stamina" then
                if OrionLib.Flags["InfStam"].Value == true then
                    wait()
                    Descendant.Value = math.huge
                end
            end
            if Descendant.Name == "NameGui" then
                if OrionLib.Flags["NoName"].Value == true then
                    wait()
                    Descendant:Destroy()
                end
            end
            if Descendant.Name == "Sheath" and OrionLib.Flags["InvisSword"].Value == true then
                wait()
                Descendant.ChildAdded:Connect(function(Child)
                    if Child:IsA("WeldConstraint") then
                        wait()
                        Child:Destroy()
                    end
                end)
            end
            if Descendant.Name == "sword" then
                if OrionLib.Flags["InvisSword"].Value == true then
                    wait()
                    for i,v in pairs(Descendant.Handle:GetChildren()) do
                        if v:IsA("WeldConstraint") then
                            v:Destroy()
                        end
                    end
                end
                if OrionLib.Flags["SwordReach"].Value == true then
                    wait()
                    SwordReachPart.Anchored = false
                    SwordReachPart.Position = Descendant.Handle.Position
                    SwordReachWeld.Part1 = Descendant.Handle
                end
            end
        end)
    end
end)

local function SetTeam(TeamName)
    -- todo
end

-- [S5] Teleporting
local TeleportList = {}
TeleportList["Bricklandia"] = Vector3.new(-371, 7, -142)
TeleportList["Evil Brick God"] = Vector3.new(505, 39, 46)
TeleportList["Brick God"] = Vector3.new(-508, 73, -364)
TeleportList["Viking Fort"] = Vector3.new(32, 6, -72)
TeleportList["Farlands"] = Vector3.new(617, 6, -96)
TeleportList["Iceberg"] = Vector3.new(245, 7, 1474)
TeleportList["Witch Cave"] = Vector3.new(-482, 6, -345)
TeleportList["Pointless Button"] = Vector3.new(-53, 7, -386)
TeleportList["Pirate Spawn"] = Vector3.new(276, 6, -1506)
TeleportList["Quest"] = Vector3.new(797, 6, -886)
TeleportList["Choosing Island"] = Vector3.new(-1, 6, -5004)
local function TPLocation(Location)
    TP(CFrame.new(TeleportList[Location]))
end

-- [U1] User Interface

local Window = OrionLib:MakeWindow({Name = "BordrBreakr v"..tostring(Version), HidePremium = true, SaveConfig = true, ConfigFolder = "BordrSex",IntroEnabled = false})

local CharTab = Window:MakeTab({
	Name = "Character",
	Icon = "rbxassetid://11136342710",
	PremiumOnly = false
})

CharTab:AddToggle({
	Name = "Hide Name",
	Default = false,
	Save = true,
    Flag = "NoName",
    Callback = function(Value)
        if Value == true then
            if Character:FindFirstChild("Head") and Character.Head:FindFirstChild("NameGui") then
                Character.Head.NameGui:Destroy()
            end
        end
    end
})

CharTab:AddToggle({
	Name = "No Hunger",
	Default = false,
	Save = true,
    Flag = "NoHunger",
    Callback = function(Value)
        if Value == true then
            if Character:FindFirstChild("Hunger") then
                Character.Hunger:Destroy()
            end
        end
    end
})

local OldStam = 10
CharTab:AddToggle({
	Name = "Infinite Stamina",
	Default = false,
	Save = true,
    Flag = "InfStam",
    Callback = function(Value)
        if Value == true then
            if Character:FindFirstChild("Stamina") then
                OldStam = Character.Stamina.Value
                Character.Stamina.Value = math.huge
            end
        else
            if Character:FindFirstChild("Stamina") then
                Character.Stamina.Value = OldStam
            end
        end
    end
})

CharTab:AddToggle({
	Name = "Anti-Timeout",
	Default = false,
	Save = true,
    Flag = "AntiTimeout"
})

CharTab:AddSlider({
	Name = "Speed Boost",
	Min = 0,
	Max = 100,
	Default = 0,
	Color = Color3.fromRGB(19, 191, 214),
	Increment = 1,
	Callback = function(Value)
		TargetWalkspeed = Value
	end    
})

local CombatTab = Window:MakeTab({
	Name = "Combat",
	Icon = "rbxassetid://6563628859",
	PremiumOnly = false
})

CombatTab:AddToggle({
	Name = "Invisible Sword",
	Default = false,
	Save = true,
    Flag = "InvisSword"
})

CombatTab:AddToggle({
	Name = "Silent Aim",
	Default = false,
	Save = true,
    Flag = "SilentAim",
    Callback = function(Value)
        Aiming.ShowFOV = Value
    end
})

CombatTab:AddSlider({
	Name = "FOV",
	Min = 15,
	Max = 360,
	Default = 60,
    Save = true,
	Color = Color3.fromRGB(49, 125, 240),
	Increment = 1,
	Callback = function(Value)
		Aiming.FOV = Value
	end    
})

CombatTab:AddToggle({
	Name = "Sword Reach",
	Default = false,
	Save = true,
    Flag = "SwordReach",
    Callback = function(Value)
        if Value then
            SwordReachPart.Transparency = 0.8
        else
            SwordReachPart.Transparency = 1
        end
    end
})

CombatTab:AddSlider({
	Name = "Reach Size",
	Min = 1,
	Max = 12,
	Default = 0,
	Color = Color3.fromRGB(214, 81, 19),
	Increment = 0.5,
	Callback = function(Value)
		SwordReachPart.Size = Vector3.new(Value,Value,Value)
	end    
})

local TeleportTab = Window:MakeTab({
	Name = "Teleports",
	Icon = "rbxassetid://11138239018",
	PremiumOnly = false
})

local TeleportsTemp = {}
for i,_ in pairs(TeleportList) do
    table.insert(TeleportsTemp,i)
end

TeleportTab:AddDropdown({
	Name = "Locations",
	Default = nil,
	Options = TeleportsTemp,
	Callback = function(Value)
		TPLocation(Value)
	end    
})


local PotionTab = Window:MakeTab({
	Name = "Potions",
	Icon = "rbxassetid://4975968586",
	PremiumOnly = false
})

local OptionsTemp = {}
for i,_ in pairs(PotionTable) do
    table.insert(OptionsTemp,i)
end

PotionTab:AddDropdown({
	Name = "Craft Potion",
	Default = nil,
	Options = OptionsTemp,
	Callback = function(Value)
		MakePotion(Value)
	end    
})

PotionTab:AddToggle({
	Name = "No Sparkles",
	Default = false,
	Save = true,
    Flag = "NoParticles"
})

PotionTab:AddToggle({
	Name = "Reusable Potions",
	Default = false,
	Save = true,
    Flag = "ReusablePotions"
})

OrionLib:Init()
OrionLibCustomizarize()