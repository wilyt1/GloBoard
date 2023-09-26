return function(name, text, rank, displayName, thumbnail, showDisplayNameIfSameAsName)
	local iconTemplateFrame = Instance.new("Frame")
	iconTemplateFrame.BorderSizePixel = 0
	iconTemplateFrame.BackgroundTransparency = 1
	iconTemplateFrame.Size = UDim2.new(1, 0, 0, 64)
	iconTemplateFrame.Name = name

	local Rank = Instance.new("TextLabel")
	Rank.Name = "Rank"
	Rank.Text = `#{rank}`
	Rank.BackgroundTransparency = 1
	Rank.Position = UDim2.new(0, 12, 0.5, 0)
	Rank.AnchorPoint = Vector2.new(0, 0.5)
	Rank.Size = UDim2.fromOffset(42, 42)
	Rank.TextColor3 = Color3.fromRGB(49, 49, 49)
	Rank.TextSize = 25
	Rank.Font = Enum.Font.GothamMedium
	Rank.Parent = iconTemplateFrame

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0.5, 0)
	UICorner.Parent = Rank

	local UIStroke = Instance.new("UIStroke")
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Color = Color3.fromRGB(56, 56, 56)
	UIStroke.Parent = Rank

	if thumbnail then
		local Icon = Instance.new("ImageLabel")
		Icon.Name = "Icon"
		Icon.BackgroundTransparency = 1
		Icon.Position = UDim2.new(0, 64, 0.5, 0)
		Icon.Size = UDim2.fromOffset(60, 60)
		Icon.AnchorPoint = Vector2.new(0, 0.5)
		Icon.Image = thumbnail
		Icon.Parent = iconTemplateFrame

		local UICorner1 = Instance.new("UICorner")
		UICorner1.CornerRadius = UDim.new(0.5, 0)
		UICorner1.Parent = Icon

		local UIStroke1 = Instance.new("UIStroke")
		UIStroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		UIStroke1.Color = Color3.fromRGB(56, 56, 56)
		UIStroke1.Parent = Icon
	end

	local Name = Instance.new("TextLabel")
	Name.Name = "Name"
	Name.Text = if displayName and (showDisplayNameIfSameAsName or displayName ~= name)
		then `{displayName} <font color="rgb(125,125,125)">(@{name})</font>`
		else `@{name}`
	Name.BackgroundTransparency = 1
	Name.Position = UDim2.new(0, if thumbnail then 128 else 64, 0.5, 0)
	Name.AnchorPoint = Vector2.new(0, 0.5)
	Name.Size = UDim2.new(0.5, 0, 0, 32)
	Name.RichText = true
	Name.TextScaled = true
	Name.Font = Enum.Font.GothamMedium
	Name.TextXAlignment = Enum.TextXAlignment.Left
	Name.Parent = iconTemplateFrame

	local Value = Instance.new("TextLabel")
	Value.Name = "Value"
	Value.Text = text
	Value.BackgroundTransparency = 1
	Value.Position = UDim2.new(1, -8, 0.5, 0)
	Value.AnchorPoint = Vector2.new(1, 0.5)
	Value.Size = UDim2.new(0.24, 0, 0, 32)
	Value.TextScaled = true
	Value.Font = Enum.Font.GothamMedium
	Value.TextXAlignment = Enum.TextXAlignment.Right
	Value.Parent = iconTemplateFrame

	return iconTemplateFrame
end
