class "Teleport"

function Teleport:__init()
	Events:Subscribe("ModuleLoad", self, self.ModuleLoad)
	Events:Subscribe("ModulesLoad", self, self.HelpAddItem)
	Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
	Events:Subscribe("LocalPlayerChat", self, self.LocalPlayerChat)
end

function Teleport:LocalPlayerChat(args)
	local msg = args.text

	-- If the string is"t a command, we"re not interested!
	if msg:sub(1, 1) ~= "/" then
		return true
	end

	local cmdargs = {}
	for word in string.gmatch(msg:sub(2), "[^%s]+") do
		table.insert(cmdargs, word)
	end

	if cmdargs[1] == "pos" then
		Chat:Print((LocalPlayer:GetPosition().x + 16384) .. ", " .. LocalPlayer:GetPosition().y .. ", " .. (LocalPlayer:GetPosition().z + 16384), Color(255, 255, 255))

		return false
	elseif cmdargs[1] == "realpos" then
		Chat:Print(LocalPlayer:GetPosition().x  .. ", " .. LocalPlayer:GetPosition().y .. ", " .. LocalPlayer:GetPosition().z, Color(255, 255, 255))

		return false
	elseif cmdargs[1] == "aimpos" then
		Chat:Print((LocalPlayer:GetAimTarget().position.x + 16384) .. ", " .. LocalPlayer:GetAimTarget().position.y .. ", " .. (LocalPlayer:GetAimTarget().position.z + 16384), Color(255, 255, 255))

		return false
	end
end

function Teleport:ModuleLoad()
	self:HelpAddItem()
end

function Teleport:HelpAddItem()
	Events:Fire("HelpAddItem", {
		name = "Teleport",
		text = "To teleport to a player via ID, type /goto ID in chat and hit enter.\n\n" ..
			   "To teleport to a player via name, type /goto name  in chat and hit enter.\n\n" ..
			   "To teleport to a specific location, type /goto x y z in chat and hit enter.\n\n" ..
			   "To teleport to where you're looking, type /jump in chat and hit enter.\n\n" ..
			   "To teleport to where you last were, type /back in chat and hit enter.\n\n" ..
			   "To get your current position type, type /pos in chat and hit enter.\n\n" ..
			   "To get your current aim position type, type /aimpos in chat and hit enter.\n\n\n"
	})
end

function Teleport:ModuleUnload()
	Events:Fire("HelpRemoveItem", {
		name = "Teleport"
	})
end

teleport = Teleport()
