# framework

initialize framework for the client and server by doing
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage");
require(ReplicatedStorage:WaitForChild("framework"):WaitForChild("module"))();
```

now it's initalized
you can now access it in any script by doing
```lua
local Network = shared.main;
```

to grab the main event, you can do
```lua
local Event = Netowrk:Get("Event")
```

and to wait till the framework is completely loaded, do
```lua
Event:On("Loaded"):Wait();
```

# API

<h2>Network (shared.main)</h2>

to access any variable inside, you must use the method :Get on the Network variable
example:
```lua
Network:Get(...)
```
to set any key to a value, you must use the method :Set
example:
```lua
Network:Set(...)
```

The network comes with a list of included modules by default, these modules are
 * EventManager
 * Include
 * Create
 * Networking

EventManager, Include, and Create are already included by default, including is like requiring, except for the Framework.
to include modules, you must grab the Include module, then include the module.
```lua
local Include = Network:Get("Include");
```
All included modules by default you can include with just a string, such as:
```lua
local Include = Network:Get("Include");
local Networking = Include("Networking");
```
to grab a module from another script after it's included, you can do
```lua
Network.Get("Networking")
```

<h2>modules/Create (Include("Create"))</h2>

this module is a function, it creates instances, example:
```lua
local Create = Include("Create");
local Part = Create{"Part", Name = "Hi", Size = Vector3.new(1, 1, 1), Parent = workspace};
```
any nested tables when calling with create will be a child of the first table's instance, example:
```lua
local Create = Include("Create");
local Part, Child = Create{"Part", Name = "Hi", Size = Vector3.new(1, 1, 1), Parent = workspace, {"Part", Name = "Child"}};

<h2>modules/EventManager (Include("EventManager"))</h2>

to create a new Event instance, you can do
```lua
local EventManager = Network.Get("EventManager");
local Event = EventManager.new();
```
to initialize the event with events, add it in the table.
to add events after the class is created, simple call :Add on the Event, the only parameter can be a string or table for list of events you wish to add.
example:
```lua
Event:Add("Dead");
Event:Add({"Dead1", "Dead2"});
```
to listen to these events, you can do
```lua
local EventResult = Event:On("Dead");
```
EventResult will contain 2 methods, To, and Wait
 * To is a method with the parameter needed as a function, this function will be called whenever the event is fired with vararg passed on.
 * Wait will yield until the event is fired, while returning the vararg.
 
example:
```lua
EventResult:To(function(variable) print(variable) end);
local variable = EventResult:Wait();
```
to fire an event, do
```lua
Event:Fire("Dead", "variable!");
```

<h2>modules/Networking (Include("Networking"))</h2>

To listen for events coming from either the client or the server, do
```lua
local Networking = Include("Networking");
Networking:Listen(Type, Name)
```
the two types are
 * Event
 * Function
 
examples:
```lua
local EventResult = Networking:Listen("Event", "Dead");
local KilledBy = EventResult:Wait();
```
in another script:
```lua
Networking:Fire("Event", "Dead", "All", "you");
```
