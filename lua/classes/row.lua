MRow = class:new()

function MRow:Initialize(tbl, _table, _where)
	self._table = _table
	if (_where ~= nil) then self._where = _where end

	for k,v in pairs(tbl) do
		self[k] = v
	end
end

function MRow:Update(tbl)
	if (tbl ~= nil) then
		local sqlstr = "UPDATE " .. self._table.Name .. " SET "
		for k,v in pairs(tbl) do
			val = type(v) == "string" and '"' .. v .. '"' or v
			if (next(tbl,k) == nil) then
				sqlstr = sqlstr .. k .. " = " .. val
			else
				sqlstr = sqlstr .. k .. " = " .. val .. ", "
			end
		end

		if (self._where ~= nil) then
			sqlstr = sqlstr .. " WHERE " .. self._where
		end
		local res = sql.Query(sqlstr)
		if (res == nil) then
			for k,v in pairs(tbl) do
				self[k] = v
			end
			return self
		else
			return false
		end
	else
		return false, "MRow:Update: Table expected"
	end
end

function MRow:Save(ply)
	assert(ply ~= nil, "MRow:Save: Player object required")
	assert(type(ply) == "Player", "MRow:Save: First argument must be a Player")

	for key, vtype in pairs(self._table.Columns) do
		if (key ~= "id") then -- never dynamically alter the id
			local gettype = (function()
				if (vtype == "varchar") then return "GetNWString" end
				if (vtype == "timestamp") then return "GetNWString" end
				if (vtype == "boolean") then return "GetNWBool" end
				if (vtype == "integer") then return "GetNWInt" end
			end)()

			if (gettype ~= nil) then
				local getval = ply[gettype](ply, key, "MDB_NULL")
				if (getval ~= "MDB_NULL") then
					self:Update({ [key] = getval })
				end
			end
		end
	end
end