class "Teleport"

function Teleport:__init()
	self.positions = {}
	self.allowedWorlds = {DefaultWorld}

	Events:Subscribe("AddTeleportWorld", self, self.AddTeleportWorld)
	Events:Subscribe("RemoveTeleportWorld", self, self.RemoveTeleportWorld)
	Events:Subscribe("PlayerChat", self, self.PlayerChat)
	Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
	Events:Subscribe("PlayerDeath", self, self.PlayerDeath)
end

function Teleport:Teleport(player, target)
	self.positions[player:GetId()] = player:GetPosition()
	player:SetPosition(target)
end

function Teleport:AddTeleportWorld(world)
	table.insert(self.allowedWorlds, world)
end

function Teleport:RemoveTeleportWorld(world)
	table.insert(self.allowedWorlds, table.find(self.allowedWorlds, world))
end

function Teleport:PlayerChat(args)
	local msg = args.text
	local player = args.player

	-- If the string is't a command, we're not interested!
	if msg:sub(1, 1) ~= "/" then
		return true
	end

	local cmdargs = {}

	for word in string.gmatch(msg:sub(2), "[^%s]+") do
		table.insert(cmdargs, word)
	end

	if table.find({"goto", "jump", "back"}, cmdargs[1]) then
		if not table.find(self.allowedWorlds, player:GetWorld()) then
			player:SendChatMessage("You can't use this command in a world that has teleport disabled!", Color(255, 0, 0))
		elseif cmdargs[1] == "goto" then
			if tonumber(cmdargs[2]) and tonumber(cmdargs[3]) and tonumber(cmdargs[4]) then
				self:Teleport(player, Vector3(tonumber(cmdargs[2]) - 16384, tonumber(cmdargs[3]), tonumber(cmdargs[4]) - 16384))
			elseif cmdargs[2] then
				local target = false

				if tonumber(cmdargs[2]) and not cmdargs[3] then
					target = Player.GetById(tonumber(cmdargs[2]))
				else
					for k, v in pairs(Player.Match(msg:sub(3 + #cmdargs[1]):lower():trim())) do
						target = v

						if player ~= v then
							break
						end
					end
				end

				if target then
					if target ~= player then
						if table.find(self.allowedWorlds, target:GetWorld()) then
							if player:GetWorld() ~= target:GetWorld() then
								player:SetWorld(target:GetWorld())
							end

							player:SendChatMessage("Teleporting to " .. target:GetName() .. "!", Color(0, 255, 0))
							target:SendChatMessage(player:GetName() .. " has teleported to you!", Color(255, 255, 0))
							player:SetAngle(target:GetAngle())
							self:Teleport(player, target:GetPosition() + (target:GetAngle() * -Vector3.Forward) + Vector3(0, 2.5, 0))
						else
							player:SendChatMessage("You can't teleport to someone in world that has teleport disabled!", Color(255, 0, 0))
						end
					else
						player:SendChatMessage("You can't teleport to yourself!", Color(255, 0, 0))
					end
				elseif tonumber(cmdargs[2]) and not cmdargs[3] then
					player:SendChatMessage("Could not find a player with the ID  " .. cmdargs[2] .. "!", Color(255, 0, 0))
				else
					player:SendChatMessage("Could not find a player with the name \"" .. msg:sub(3 + #cmdargs[1]):lower():trim() .. "\"!", Color(255, 0, 0))
				end
			else
				player:SendChatMessage("Please specify a player or position!", Color(255, 0, 0))
			end

			return false
		elseif cmdargs[1] == "jump" then
			self:Teleport(player, player:GetAimTarget().position)

			return false
		elseif cmdargs[1] == "back" then
			if self.positions[args.player:GetId()] then
				self:Teleport(player, self.positions[args.player:GetId()])
			else
				player:SendChatMessage("Nowhere to go!", Color(255, 0, 0))
			end

			return false
		end
	end
end

function Teleport:PlayerQuit(args)
	self.positions[args.player:GetId()] = nil
end

function Teleport:PlayerDeath(args)
	if table.find(self.allowedWorlds, args.player:GetWorld()) then
		self.positions[args.player:GetId()] = args.player:GetPosition()
	end
end

teleport = Teleport()
