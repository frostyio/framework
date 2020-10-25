return function(Network)
	local Create;

	function Create(properties)
		local instance = Instance.new(properties[1]);
		local parent = properties.Parent;

		local children = {};
		local children_result = {};

		for property, value in pairs(properties) do
			if type(value) == "table" then
				table.insert(children, value);
				continue;
			end
			if type(property) == "number" then
				continue;
			end

			instance[property] = value;
		end

		for _, child in pairs(children) do
			child.Parent = instance;
			for _, child_instance in pairs({Create(child[1], child)}) do
				table.insert(children_result, child_instance);
			end
		end

		instance.Parent = parent;

		return instance, unpack(children_result);
	end

	return Create;
end