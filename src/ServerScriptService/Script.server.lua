local ReplicatedStorage = game:GetService("ReplicatedStorage");
require(ReplicatedStorage:WaitForChild("framework"):WaitForChild("module"))();

local Network = shared.main;
local Event = Network:Get("Event");
Event:On("Loaded"):Wait();

local Include = Network:Get("Include");
local Networking = Include("Networking");

Networking:Listen("Event", "Dead"):To(function(...) print("dead by", ...) end);