local RunService = game:GetService("RunService");

local config = {
	name = "framework",
};

local function GetErrorType()
	return RunService:IsStudio() and error or warn;
end

local function GetToString(self)
	local meta = getmetatable(self) or self;
	return ("%s - %s"):format(meta.__name or "unnamed", config.name);
end

local function LockedMetatable()
	return "locked - " .. config.name;
end

local function GetMetatableValue(table, value)
	return getmetatable(table)[value];
end

-- this proxies a function with already given parameters
local function ProxyFuncWithParams(func, ...)
	local args = {...};
	return function()
		return func(unpack(args));
	end
end

-- Storage is where all the Client's data for the game can be stored
-- it is dynamic to the game
local Storage = setmetatable({}, {
	__name = "Storage",
	__tostring = GetToString,
});

-- This is what is given to the client to access the framework
local ClientStorage = setmetatable({
	Get = function(self, index)
		return rawget(Storage, index);
	end,
	Set = function(self, index, value)
		rawset(Storage, index, value);
		return value;
	end
}, {
	__tostring = ProxyFuncWithParams(GetMetatableValue(Storage, "__tostring"), Storage),
	__metatable = LockedMetatable,

	__newindex = function(self) 
		return GetErrorType()("cannot assign index to Storage, use :Set(...) instead", 2);
	end,
	__index = function(self) 
		return GetErrorType()("cannot index in Storage, use :Get(...) instead", 2);
	end,
});

-- This instance is only to be used here and only here.
local Global = {
	Storage = Storage,
	Config = config,
};

-- GlobalProxy is only to be given to the internal framework
local GlobalProxy = setmetatable({}, {
	__index = Global, 
	__newindex = Global,
	__tostring = ProxyFuncWithParams(GetToString, {__name = "Global Proxy"}),
	__metatable = LockedMetatable,
});

-- WaitFor function

local WaitFor;
do
	local cached = {};
	function WaitFor(origin, child, limit)
		cached[origin] = cached[origin] or {};

		if cached[origin][child] then
			return cached[origin][child];
		end

		cached[origin][child] = origin:WaitForChild(child, limit);
		return cached[origin][child];
	end
end

-- Internal pathing function

local function Path(dir, origin)
	origin = origin or script;
	local current = origin;
	for child in dir:gmatch("[^/]+") do
		if child == "~" then
			current = origin.Parent.Parent;
		elseif child == "." then
			current = current.Parent;
		else
			current = WaitFor(current, child);
		end
	end

	return current;
end

-- Adding everything to the global proxy
GlobalProxy.Path = Path;
GlobalProxy.WaitFor = WaitFor;
GlobalProxy.GetErrorType = GetErrorType;

-- Event Manager
GlobalProxy.EventManager = require(Path("./EventManager"))(GlobalProxy);

-- Internal include function
local IncludeFunction = require(Path("./Include"));
GlobalProxy.Include = IncludeFunction(GlobalProxy);

-- Misc
GlobalProxy.AddModule("EventManager", GlobalProxy.EventManager);
GlobalProxy.AddModule("Include", GlobalProxy.Include);

GlobalProxy.InternalEvent = GlobalProxy.EventManager.new();

Storage.Event = GlobalProxy.EventManager.new();

GlobalProxy.Include("~/modules/HandleOnLoad");

-- Handle User Storage
Storage.GetErrorType = GetErrorType;
Storage.Path = Path;
Storage.WaitFor = WaitFor;
Storage.EventManager = GlobalProxy.EventManager;
Storage.Include = IncludeFunction(Storage);
Storage.AddModule("EventManager", GlobalProxy.EventManager);
Storage.AddModule("Include", GlobalProxy.Include);

-- Finishing
delay(0, function() -- run on next tick
	GlobalProxy.InternalEvent:Fire("OnLoad", true);
end);

return ClientStorage;