local tbl = require("helpers.tbl")

local _core = { mt = {}, _private = {} }

function _core:modules()
	local mods = {}
	for _, mod in ipairs(self._private.mods) do
		table.insert(mods, {
			name = mod.name,
			mod = require("modules." .. mod.modname),
		})
	end

	return mods
end

function _core:load_mod(module)
	local required_properties = {
		"name",
		"mod",
	}

	for _, prop in ipairs(required_properties) do
		if not tbl.contain_key(module, prop) then
			error(
				"Module "
					.. (module.name and module.name or "<unknown name>")
					.. " does not have a "
					.. prop
					.. " property"
			)
		end
	end

	if type(module.mod) ~= "table" then
		error("Module " .. (module.name and module.name or "<unknown name>") .. " does not have a valid mod property")
	end

	if not tbl.contain_key(module.mod, "setup") then
		error("Module " .. (module.name and module.name or "<unknown name>") .. " does not have a setup function")
	end

	local mod = module.mod()
	mod:setup()
end

function _core.mt:__call()
	local ret = {}
	tbl.crush(ret, _core)

	ret._private.mods = {
		{ name = "configuration", modname = "configuration" },
		{ name = "keybindings", modname = "keybindings" },
    { name = "autocommands", modname = "autocmds" },
		{ name = "plugins-loader", modname = "plugins.loader" },
	}

	return ret
end

return setmetatable(_core, _core.mt)
