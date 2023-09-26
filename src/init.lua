local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local UserService = game:GetService("UserService")

local abbreviateTime = require(script.AbbreviateTime)
local abbreviateNumber = require(script.AbbreviateNumber)
local createTemplate = require(script.IconTemplate)

local blankHumanoidDescription = Instance.new("HumanoidDescription")

local thumbnailCache = {}
local userDataCache = {}

local function requestThumbnailAsync(userId, cache, debug)
	if thumbnailCache[userId] then
		return thumbnailCache[userId]
	end

	local success, response = pcall(
		Players.GetUserThumbnailAsync,
		Players,
		userId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size150x150
	)
	if not success then
		if debug then
			warn(`Error getting user thumbnail: {response}`)
		end

		return "rbxasset://textures/ui/GuiImagePlaceholder.png"
	end

	if cache then
		thumbnailCache[userId] = response
	end

	return response
end

local GloBoard = {}
GloBoard.__index = GloBoard

function GloBoard.new(contentData)
	local self = setmetatable({}, GloBoard)

	assert(
		typeof(contentData.leaderboardIconParent) == "Instance",
		"The 'leaderboardIconParent' property is not an Instance."
	)
	assert(type(contentData.dataStoreKey) == "string", "The 'dataStoreKey' property is not a string.")

	self.disabledLocalServer = false

	self.iconParent = contentData.leaderboardIconParent

	self.formatter = contentData.format or "Comma"

	self.lines = contentData.lines or 25
	self.descendingOrder = contentData.descendingOrder or false

	self.displayNamesEnabled = contentData.displayNamesEnabled or true
	self.thumbnailsEnabled = contentData.thumbnailsEnabled or false
	self.thumbnailCache = contentData.thumbnailCache or true
	self.userDataCache = contentData.userDataCache or true
	self.showDisplayNameIfSameAsName = contentData.showDisplayNameIfSameAsName or false

	self.template = contentData.iconTemplate or createTemplate

	self.fakeUserData = { Username = "NIL", DisplayName = "NIL" }

	self.autoUpdating = false
	self.currentTimer = 1
	self.updateTimers = {}

	self.characterBinds = {}

	self._appendingUserIds = {}

	self.frontPrefix = contentData.frontPrefix or ""
	self.backPrefix = contentData.backPrefix or ""

	self.debug = contentData.debug or false

	self.dataStoreProfile = DataStoreService:GetOrderedDataStore(contentData.dataStoreKey)

	return self
end

function GloBoard:DisableLocalServerTesting(state)
	self.disabledLocalServer = state or true
end

function GloBoard:Clear()
	for _, object in self.iconParent:GetChildren() do
		if object:IsA("GuiObject") then
			object:Destroy()
		end
	end
end

function GloBoard:Load()
	for userId, value in self._appendingUserIds do
		local success, response = pcall(self.dataStoreProfile.SetAsync, self.dataStoreProfile, userId, value)
		if not success and self.debug then
			warn(`Error setting data store profile: {response}`)
		end

		self._appendingUserIds[userId] = nil
	end

	local pagesSuccess, pagesResponse =
		pcall(self.dataStoreProfile.GetSortedAsync, self.dataStoreProfile, self.descendingOrder, self.lines)
	if not pagesSuccess then
		return if self.debug then warn(`Error getting sorted data from data store: {pagesResponse}`) else nil
	end

	local pageSuccess, pageResponse = pcall(pagesResponse.GetCurrentPage, pagesResponse)
	if not pageSuccess then
		return if self.debug then warn(`Error getting current page: {pageResponse}`) else nil
	end

	local userIds = {}

	for _, data in pageResponse do
		table.insert(userIds, tonumber(data.key))
	end

	for rank, character in self.characterBinds do
		if not pageResponse[rank] then
			continue
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			continue
		end

		local success, response = pcall(Players.GetHumanoidDescriptionFromUserId, Players, pageResponse[rank].key)
		if not success then
			if self.debug then
				warn(`Error getting humanoid description from user ID: {response}`)
			end
			continue
		end

		character:PivotTo(character:GetPivot() * CFrame.new(0, -humanoid.HipHeight, 0))

		humanoid:ApplyDescription(blankHumanoidDescription)
		humanoid:ApplyDescription(response)

		character:PivotTo(character:GetPivot() * CFrame.new(0, humanoid.HipHeight, 0))
	end

	local userData = {}
	for _, value in UserService:GetUserInfosByUserIdsAsync(userIds) do
		userData[value.Id] = value
	end

	for rank, data in pageResponse do
		local userId = tonumber(data.key)
		local value = if type(self.formatter) == "string"
			then if self.formatter == "Abbreviate"
				then abbreviateNumber(data.value)
				elseif self.formatter == "Comma" then abbreviateNumber(data.value, "Comma")
				elseif self.formatter == "Time" then abbreviateTime(data.value)
				else data.value
			else self.formatter(data.value)
		local thumbnail = if self.thumbnailsEnabled
			then requestThumbnailAsync(userId, self.thumbnailCache, self.debug)
			else nil

		if self.userDataCache and not userDataCache[userId] then
			userDataCache[userId] = userData[userId]
		end

		self.template(
			(userDataCache[userId] or userData[userId] or self.fakeUserData).Username,
			`{self.frontPrefix}{value}{self.backPrefix}`,
			rank,
			(userDataCache[userId] or userData[userId] or self.fakeUserData).DisplayName,
			thumbnail,
			self.showDisplayNameIfSameAsName
		).Parent =
			self.iconParent
	end

	return pageSuccess
end

function GloBoard:Update()
	self:Clear()
	return self:Load()
end

function GloBoard:Append(userId, value)
	if type(userId) ~= "number" or type(value) ~= "number" then
		return warn("Error: Both 'userId' and 'value' must be of type number.")
	end

	if userId < 1 and self.disabledLocalServer then
		return warn("Error: User ID is less than 1, and the local server is disabled.")
	end

	self._appendingUserIds[userId] = value
end

function GloBoard:Erase(userId)
	if type(userId) ~= "number" then
		return warn("Error: 'userId' must be of type number.")
	end

	local success, response = pcall(self.dataStoreProfile.RemoveAsync, self.dataStoreProfile, userId)
	if not success and self.debug then
		warn(`Error removing data from data store: {response}`)
	end

	return success
end

function GloBoard:ClearCache()
	thumbnailCache = {}
	userDataCache = {}
end

function GloBoard:AutoUpdate(updateTime)
	if type(updateTime) ~= "number" then
		return warn("Error: 'updateTime' must be of type number.")
	end

	self.autoUpdating = true

	task.spawn(function()
		while self.autoUpdating do
			self.currentTimer -= 1

			if #self.updateTimers > 0 then
				for index, textLabel in self.updateTimers do
					if textLabel.Parent then
						textLabel.Text = `Refresh in: {abbreviateTime(self.currentTimer)}`
					else
						self.updateTimers[index] = nil
					end
				end
			end

			if self.currentTimer == 0 then
				self.currentTimer = updateTime

				self:Update()
			end

			task.wait(1)
		end
	end)
end

function GloBoard:BreakAutoUpdater()
	self.autoUpdating = false
end

function GloBoard:AttachRefreshTimer(refreshTimer)
	table.insert(self.updateTimers, refreshTimer)
end

function GloBoard:BindRankToCharacter(rank, character)
	if type(rank) ~= "number" then
		return warn("Error: 'rank' must be of type number.")
	end

	self.characterBinds[rank] = character
end

return GloBoard
