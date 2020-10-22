return function(Network)
	local event = {};

	do
		event.__index = event;
		function event.new(evs)
			local self = setmetatable({}, event);
			self.new = nil;

			self.events = {};
			self.WaitingForFire = {};

			self:Add(evs);

			return self;
		end

		function event.Add(self, evs)
			evs = type(evs) == "string" and {evs} or evs;

			for _, ev in pairs(evs or {}) do
				self.events[ev] = true;
			end

			for _, ev in pairs(evs or {}) do
				self.WaitingForFire[ev] = {};
			end
		end

		function event.On(self, event)
			local ev = self.events[event];
			if not ev then
				return Network.GetErrorType()(("%s is not a valid event"):format(event));
			end

			return {
				To = function(s, func)
					table.insert(self.WaitingForFire[event], func);

					return {
						Disconnect = function(s)
							table.remove(
								self.WaitingForFire[event], 
								table.find(self.WaitingForFire[event], func)
							);
						end
					};
				end,
				Wait = function(s)
					local thread = coroutine.running();

					local result = nil;
					table.insert(self.WaitingForFire[event], function(...) 
						result = {...};
						coroutine.resume(thread);
					end);

					coroutine.yield();

					return unpack(result);
				end
			};
		end

		function event.Fire(self, event, ...)
			local ev = self.events[event];
			if not ev then
				return Network.GetErrorType()(("%s is not a valid event"):format(event));
			end

			local ToFire = self.WaitingForFire[event];
			self.WaitingForFire[event] = {};

			for _, func in pairs(ToFire) do
				coroutine.wrap(func)(...);
			end
		end
	end

	return event;
end