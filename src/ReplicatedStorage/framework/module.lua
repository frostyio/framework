return function()
	local Parent = script.Parent;
	local Essentials = Parent:WaitForChild("essentials");
	local Main = Essentials:WaitForChild("main");
	Main = require(Main);

	shared["main"], shared["Main"] = Main, Main;

	return Main;
end