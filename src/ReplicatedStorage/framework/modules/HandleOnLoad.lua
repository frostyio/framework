return function(Network)
	local Storage = Network.Storage;
	local Event = Network.InternalEvent;

	Event:Add("OnLoad");
	Storage.Event:Add("Loaded");
	Storage.Loaded = false;

	Event:On("OnLoad"):Wait();
	Storage.Loaded = true;
	Storage.Event:Fire("Loaded", true);
	
end