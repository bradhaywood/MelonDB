include "includes/class.lua" -- class builder
include "classes/row.lua"
include "classes/table.lua"
include "classes/schema.lua"
include "classes/connector.lua"

local function LoadModules()
	local files, _ = file.Find("addons/melondb/lua/modules/*", "GAME")
	if (files ~= nil and #files > 0) then
		for _,file in pairs(files) do
			print("Found module ".. file)
		end
	end
end

local function MelonDB_Init()
	LoadModules()
end

hook.Add("Initialize", "MelonDB First Run", MelonDB_Init)