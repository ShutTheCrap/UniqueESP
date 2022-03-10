local defaultBoxProperties = {
	Thickness = 1;
	Color = Color3.new(1,1,1); 
	Outlined = true;
	Rounding = 4;
}

local defaultTextProperties = {
	Size = 18;
	Color = Color3.new(1, 1, 1);
	Outlined = true;
}

local playerList, connects = {}, {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Camera = game:GetService("Workspace").CurrentCamera

local StreamingEnabled = workspace.StreamingEnabled

local Rogue = game.GameId == 1087859240
local FightingGame = game.GameId == 1277659167
local Deepwoken = game.GameId == 1359573625

local Purple, White = Color3.new(0.5, 0, 0.75), Color3.new(1,1,1)

local lower, Vector2New, Vector3New, WTVPP, FindFirstChild, FindFirstChildOfClass, floor, C3fromRGB, C3New = string.lower, Vector2.new, Vector3.new, Camera.WorldToViewportPoint, game.FindFirstChild, game.FindFirstChildOfClass, math.floor, Color3.fromRGB, Color3.new

local Enabled = true

local function Destroy()
    for _,Player in pairs(playerList) do
		Player:Destroy()
	end

    for i,v in pairs(connects) do v:Disconnect() end

    RunService:UnbindFromRenderStep("x_upESP")

    table.clear(playerList)
    table.clear(connects)

    getgenv().Destroy = nil
end

getgenv().Destroy = Destroy

local function GetHeldTool(Character)
	return ((FindFirstChildOfClass(Character, "Tool") and FindFirstChildOfClass(Character, "Tool").Name) or "N/A")
end

local Player = {}; do
	Player.__index = Player

	function Player.new(player)
        if player == LocalPlayer then return end
        
		local self = {}; setmetatable(self, Player)

		self.Player = player
		self.Character = player.Character
		self.Name = player.Name
		self.Team = player.Team ~= nil and player.Team.Name or nil
		self.Drawings = {}
		self.Connects = {}

		self.Connects["CharacterAdded"] = player.CharacterAdded:Connect(function(char) self:SetupCharacter(char) end)
		self.Connects["CharacterRemoving"] = player.CharacterRemoving:Connect(function() 
			self:RemoveDrawings()
            for i,v in pairs({"Character", "RootPart", "Humanoid"}) do
				self[v] = nil
			end
		end)
		self.Connects["TeamChanged"] = player:GetPropertyChangedSignal("Team"):Connect(function()
			self.Team = player.Team ~= nil and player.Team.Name or nil
		end)

		self:SetupCharacter(player.Character)

		self.Index = table.insert(playerList, self)

		return self
	end

	function Player:SetupCharacter(Character)
		if Character then --// todo: make function to support other games (i.e. phantom forces, strucid, etc,.)
			self.Character = Character
			self.RootPart = Character:WaitForChild("HumanoidRootPart", 3)
            self.Humanoid = Character:WaitForChild("Humanoid", 3)
			
			if StreamingEnabled and self.Character and not self.RootPart then
				self.Connects["ChildAdded"] = self.Character.ChildAdded:Connect(function(part)
					if part.Name == "HumanoidRootPart" and part:WaitForChild("RootAttachment", 1) and part:WaitForChild("RootJoint", 1) then
						self.RootPart = part
						self:SetupESP()
					end
				end)
			end

			if self.RootPart then
				self:SetupESP()
			end
		end
	end

	function Player:SetupESP()
		--// create points
		local topLeftBoxPoint = PointInstance.new(self.RootPart, CFrame.new(-2, 2.5, 0))
		local bottomLeftBoxPoint = PointInstance.new(self.RootPart, CFrame.new(-2, -3, 0))
		local bottomRightBoxPoint = PointInstance.new(self.RootPart, CFrame.new(2, -3, 0))
		
		local topLeftHealthPoint = PointOffset.new(topLeftBoxPoint, -5, 0)
		local bottomRightHealthPoint = PointOffset.new(bottomLeftBoxPoint, -3, 0)

		local textPoint = PointInstance.new(self.RootPart, CFrame.new(0, -3, 0))

		for i,v in pairs({topLeftBoxPoint, bottomRightBoxPoint, textPoint, bottomLeftBoxPoint}) do v.RotationType = CFrameRotationType.CameraRelative end
		--// create drawings
		local PrimaryBox = RectDynamic.new(topLeftBoxPoint, bottomRightBoxPoint); for i,v in pairs(defaultBoxProperties) do PrimaryBox[i] = v end
		
		local PrimaryText = TextDynamic.new(textPoint); for i,v in pairs(defaultTextProperties) do PrimaryText[i] = v end
		PrimaryText.Text = self.Name
		PrimaryText.YAlignment = YAlignment.Bottom
        
		local HealthBox = RectDynamic.new(topLeftHealthPoint, bottomRightHealthPoint); for i,v in pairs(defaultBoxProperties) do HealthBox[i] = v end
		HealthBox.Filled = true
		HealthBox.Color = White
        HealthBox.Rounding = 0
--[[   
        local HealthBoxBorder = RectDynamic.new(PointOffset.new(topLeftBoxPoint, -6, -1), PointOffset.new(topLeftBoxPoint, -2, 1))
        HealthBoxBorder
]]      
		--// add to table for updates
		self.Drawings.Box = PrimaryBox
		self.Drawings.Text = PrimaryText
		self.Drawings.HealthBar = HealthBox
	end

	function Player:Update()
		if not self.Player then self:Destroy() return end --// if the player is gone then dont update

		local Box = self.Drawings.Box
		local Text = self.Drawings.Text
		local HealthBar = self.Drawings.HealthBar
        
		if not Box or not Text or not self.Character or not self.RootPart or not self.Humanoid then return end --// if no box or text or character then dont update
		
		local Humanoid = self.Humanoid
		local Health, MaxHealth = Humanoid.Health, Humanoid.MaxHealth
		local HPP = math.clamp(Health / MaxHealth, 0, 1)

        for i,v in pairs({Box, Text, HealthBar}) do v.Visible = Enabled end 


		--// get display name | todo: function for getting display name to support other games easier?
		local InGameName;
        if Deepwoken and self.Humanoid and self.Humanoid.DisplayName then 
            local displayName = self.Humanoid.DisplayName:split("\n")[1]
            InGameName = displayName
        end

		--// update text
		Text.Text = self.Name..((Deepwoken and InGameName) and " ["..InGameName.."]" or "").."\n["..floor((Camera.CFrame.p - self.RootPart.Position).Magnitude).."] ["..floor(self.Humanoid.Health).."/"..floor(self.Humanoid.MaxHealth).."]\n["..GetHeldTool(self.Character).."]"
	
		--// update health bar
		HealthBar.Color = White:Lerp(Purple, math.clamp(1 - HPP, 0, 1)) --// thx ic3 
		--HealthBar.Size = Vector2New(2, -floor((Box.Size.Y) * Health / MaxHealth))
	end

    function Player:RemoveDrawings()
        for i,v in pairs(self.Drawings) do
			v.Visible = false
		end
        table.clear(self.Drawings)
    end

    function Player:Toggle()
        for i,v in pairs(self.Drawings) do
            v.Visible = Enabled
        end
    end

	function Player:Destroy()
		for i,v in pairs(self.Connects) do
			v:Disconnect()
		end

		self:RemoveDrawings()
		
		table.remove(playerList, self.Index)

		table.clear(self.Drawings)
		table.clear(self.Connects)
	end
end

for _,v in pairs(Players:GetPlayers()) do task.spawn(Player.new, v) end

RunService:BindToRenderStep('x_upESP', 200, function()
	for i,v in pairs(playerList) do
		v:Update()
	end
end)

table.insert(connects, Players.PlayerAdded:Connect(Player.new))
table.insert(connects, game:GetService("UserInputService").InputBegan:Connect(function(inputObject, gp)
    if gp then return end
    if inputObject.KeyCode == Enum.KeyCode.F3 then
        for _,Player in pairs(playerList) do
            Enabled = not Enabled
        end
    end
end))
