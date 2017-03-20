MelonDB.Model = class:new()

local function _getTableTypes(tbl, t)
	local ret = {}
	local t = sql.Query("PRAGMA table_info(".. tbl .. ");")
	for k,v in pairs(t) do
		local valType = v["type"]
		if (string.starts(valType, "varchar")) then valType = "varchar" end
		if (string.starts(valType, "integer")) then valType = "integer" end
		if (string.starts(valType, "timestamp")) then valType = "timestamp" end
		ret[v["name"]] = valType
	end

	return ret
end

local function _addModel(mdl, tblName, fields)
	local modTable = MelonDB.Connect('sqlite').Table(tblName)

	metatable = FindMetaTable(mdl)
	assert(metatable ~= nil, "_addModel: Could not find metatable for " .. mdl)
	assert(fields["id"] ~= nil, "_addModel: An 'id' column is necessary for models")

	function metatable:Mdb_Load()
		if (mdl == "Player") then
			local steam_id = self:SteamID()
			local err
			local playerRes = modTable:Find({ id = tostring(steam_id) })
			-- they don't exist yet
			if (not playerRes) then
				playerRes, err = modTable:Insert({ id = tostring(steam_id) })
			end

			if (not err) then
				for key,vtype in pairs(fields) do
					if (vtype == "varchar" or vtype == "timestamp") then self:SetNWString(key, playerRes[key]) end
					if (vtype == "integer") then self:SetNWInt(key, playerRes[key]) end
					if (vtype == "boolean") then self:SetNWBool(key, playerRes[key]) end
				end
			end
		end
	end
end

function MelonDB.Model:Initialize(mdl, o)
	assert(o ~= nil, "MelonDB.Model: Expects a model and a table of arguments")
	assert(type(o) == "table", "MelonDB.Model: Second parameter must be a table")

	local tblName = o.tableName
	local fields  = o.fields

	if (sql.TableExists(tblName)) then
		_addModel(mdl, tblName, _getTableTypes(tblName, o.fields))
		return true
	else
		local result
		local sqlstr = "CREATE TABLE " .. tblName .. " ("
		for k,v in pairs(fields) do
			sqlstr = sqlstr .. k .. " " .. v .. ", "
		end
		sqlstr = sqlstr:sub(1, -3)
		sqlstr = sqlstr .. ")"
		result = sql.Query(sqlstr)
		_addModel(mdl, tblName, _getTableTypes(tblName, o.fields))
	end
end
	