MTable = class:new()

MTable.Name = ""
MTable.Columns = {}

function MTable:Initialize(name)
	self.Name = name
	return self
end

local function _columns(cols)
	if (cols == nil) then return "*" end
	return join(cols, ", ")
end

function MTable:GetTable()
	local name = self.Name
	if (sql.TableExists(name)) then
		self:SetTableDetails()
		return self
	else
		return self, "Table " .. name .. " does not exist"
	end
end

function MTable:Exists()
	return sql.TableExists(self.Name)
end

function MTable:SetTableDetails()
	local t = sql.Query("PRAGMA table_info(".. self.Name .. ");")
	for k,v in pairs(t) do
		self.Columns[v["name"]] = v["type"]
	end
end

function MTable:Create(opts)
	if (self:Exists()) then
		return self, "MTable:Create: Already exists"
	else
		local sqlstr = "CREATE TABLE " .. self.Name .. " ("
		for k,v in pairs(opts) do
			sqlstr = sqlstr .. k .. " " .. v .. ", "
		end
		sqlstr = sqlstr:sub(1, -3)
		sqlstr = sqlstr .. ")"
		result = sql.Query(sqlstr)
		self:SetTableDetails()
	end
end

function MTable:All(tbl, cols)
	local columns = _columns(cols)
	if (tbl == nil or #tbl < 1) then
		local res = sql.Query("SELECT " .. columns .. " FROM " .. self.Name)
		return res and res[1] or false
	else
		local sqlstr = "SELECT " .. columns .. " FROM " .. self.Name .. " WHERE "
		local val
		for k,v in pairs(tbl) do
			val = type(v) == "string" and '"' .. v .. '"' or v
			if (next(tbl,k) == nil) then
				sqlstr = sqlstr .. k .. " = " .. val
			else
				sqlstr = sqlstr .. k .. " = " .. val .. " AND "
			end
		end

		local res = sql.Query(sqlstr)
		return res and res or false
	end
end

function MTable:Find(tbl, cols)
	local columns = _columns(cols)
	if (tbl ~= nil) then
		local sqlstr = "SELECT " .. columns .. " FROM " .. self.Name .. " WHERE "
		local val
		for k,v in pairs(tbl) do
			val = type(v) == "string" and '"' .. v .. '"' or v
			if (next(tbl,k) == nil) then
				sqlstr = sqlstr .. k .. " = " .. val
			else
				sqlstr = sqlstr .. k .. " = " .. val .. " AND "
			end
		end

		local res = sql.Query(sqlstr)
		return res and res[1] or false
	else
		return false, "MTable:Find: Table expected"
	end
end

function MTable:Insert(tbl)
	if (tbl ~= nil) then
		if (type(tbl) ~= "table") then
			return false, "MTable:Insert: First parameter must be a table"
		else
			-- INSERT INTO tablename (key1, key2) VALUES ('val1', 'val2')
			-- sort the table so we know the order
			table.sort(tbl)
			local sqlstr = "INSERT INTO " .. self.Name .. " ("
			for k,_ in pairs(tbl) do
				if (next(tbl, k) ~= nil) then
					sqlstr = sqlstr .. k .. ", "
				else
					sqlstr = sqlstr .. k .. ")"
				end
			end
			sqlstr = sqlstr .. " VALUES ("

			local addValue = function(key, val)
				-- if key is a string, wrap in quotes
				if (self.Columns[key] == "varchar") then
					return '"' .. val .. '"'
				end
				return val
			end

			for k,v in pairs(tbl) do
				if (next(tbl,k) ~= nil) then
					sqlstr = sqlstr .. addValue(k, v) .. ", "
				else
					sqlstr = sqlstr .. addValue(k, v) .. ")"
				end
			end

			local res = sql.Query(sqlstr)
			if (res == nil) then return MRow(tbl), false end
			return false, "MTable:Insert: Query failed" 
		end
	else
		return false, "MTable:Insert: Parameter expected"
	end
end
