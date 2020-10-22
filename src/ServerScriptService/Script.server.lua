local ReplicatedStorage = game:GetService("ReplicatedStorage");
require(ReplicatedStorage:WaitForChild("framework"):WaitForChild("module"))();

local Network = shared.main;
local Event = Network:Get("Event");

Event:On("Loaded"):Wait();

print("Loaded");

local Include = Network.Get("Include");
print(Include);