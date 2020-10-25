return function(Network, origin)
	local Event = Network.EventManager.new({"ModuleAdded", "ModuleHalted"});

	local Modules = {};
	local Threads = {};

	local ErrorType = Network.GetErrorType();

	local function Include(path)
		local object = type(path) == "string" and Network.Path(path, origin) or path;

		if Modules[object.Name] then
			return ErrorType(("%s is already included!"):format(object.Name));
		end

		if typeof(object) ~= "Instance" then
			return ErrorType(("%s is not a module, is %s"):format(path, object));
		end
		local required = require(object);
		if type(required) ~= "function" then
			return ErrorType("returned value is not a function for module", object.Name);
		end
		
		local success, result, thread;
		coroutine.wrap(function() 
			thread = coroutine.running();
			success, result = pcall(required, Network);
		end)();

		if not success and result ~= nil then
			return ErrorType(result);
		end

		Threads[object.Name] = thread;
		Modules[object.Name] = result;

		Event:Fire("ModuleAdded", result);

		return result;
	end

	local function HandleGet(name)
		local module = Modules[name];
		if module then return module end;
		local thread = coroutine.running();

		local connection; connection = Event:On("ModuleAdded"):To(function(m) 
			module = Modules[name];
			if module then
				coroutine.resume(thread);
				connection:Disconnect();
			end
		end);

		delay(5, function() 
			connection:Disconnect();
			ErrorType(("Cannot get module %s, timed out"):format(name), 2);
			coroutine.resume(thread);
		end);

		coroutine.yield();

		return module;
	end

	local function Get(name)
		if type(name) == "table" then
			local results = {};
			for _, value in pairs(name) do
				table.insert(results, HandleGet(value));
			end
			return unpack(results);
		else
			return HandleGet(name);
		end
	end

	local function Add(name, value)
		Modules[name] = value;

		Event:Fire("ModuleAdded", value);
		return value;
	end

	Network.Get = Get;
	Network.AddModule = Add;

	return Include;
end