# MelonDB
GMod SQL made easy

## SYNOPSIS

```lua
---
-- Creating a connection and table
---

local schema, err = MelonDB.Connect('sqlite')
if (err) then
	-- obviously this should not be a problem for sqlite..
	print("Error connecting: " .. err)
end

local userTable, err = schema.Table("users")
if (err) then
	print("User table doesn't exist, creating")
	local userTable, err = userTable.Create({
		username = "varchar(250)",
		status   = "varchar(40)",
		points   = "integer"
	})

	if (err) then
		print("Problem creating table: " .. err)
	else
		print("Created table")
	end
end

---
-- Inserting a row
---

local row, err = userTable:Insert({
	username = 'SomeName',
	status = 'active',
	points = 5000
})

---
-- Retrieving a row from an existing table
---

local userTable, err = schema.Table("users")
local result = userTable:Find({ username = "SomeName" })
if (result) then
	print("Found user " .. result.username)
end

-- You can search multiple columns

-- this would return false, because SomeName's status is "active"
local result = userTable:Find({ username = "SomeName", status = "disabled" })
```