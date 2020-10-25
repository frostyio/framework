return function(Network)
	local RunService = game:GetService("RunService");
	local Create = Network.Get("Create");
	local EventManager = Network.Get("EventManager");
	local WaitFor = Network.WaitFor;

	local Event, Function;

	if RunService:IsServer() then
		-- create remotes
		Event = Create{"RemoteEvent", 
			Name = "Event",
			Parent = script
		};
		Function = Create{"RemoteFunction", 
			Name = "Function",
			Parent = script
		};
	else
		Event, Function = WaitFor(script, "Event"), WaitFor(script, "Function");
	end

	local RemoteHandler = {};
	RemoteHandler.__index = RemoteHandler;
	
	do
		function RemoteHandler.new()
			local self = setmetatable({}, RemoteHandler);

			self.Event = EventManager.new();

			self:StartListening();

			return self;
		end

		function RemoteHandler.Listen(self, Type, Name)
			-- Remote:Listen("Dead"):To(func);

			local data = "Listening_" .. Type .. "_" .. Name;
			self.Event:Add(data);
			return self.Event:On(data);
		end
		
		function RemoteHandler.Fire(self, Type, Name, to, ...)
			if Type:lower() == "function" then
				if RunService:IsServer() then
					return Function:InvokeClient(to, Name, ...);
				else
					return Function:InvokeServer(Name, to, ...);
				end
			elseif Type:lower() == "event" then
				if RunService:IsServer() then
					if to == "All" or to == "FireAllClients" then
						return Event:FireAllClients(Name, ...);
					else
						return Event:FireServer(to, Name, ...);
					end
				else
					return Event:FireServer(Name, to, ...);
				end
			end
		end

		function RemoteHandler.StartListening(self)
			if self.con1 then self.con1:Disconnect() end;

			if RunService:IsServer() then
				self.con1 = Event.OnServerEvent:Connect(function(Client, Name, ...) 
					self.Event:Fire("Listening_Event_" .. Name, Client, ...);
				end);
				
				-- if multiple RemoteHandlers, it will mess up
				Function.OnServerInvoke = function(Client, Name, ...)
					return self.Event:Fire("Listening_Function_" .. Name, Client, ...);
				end
			else
				self.con1 = Event.OnClientEvent:Connect(function(Name, ...) 
					self.Event:Fire("Listening_Event_" .. Name, ...);
				end);
				
				-- if multiple RemoteHandlers, it will mess up
				Function.OnClientInvoke = function(Name, ...)
					return self.Event:Fire("Listening_Function_" .. Name, ...);
				end
			end
		end
	end

	return RemoteHandler.new();
end