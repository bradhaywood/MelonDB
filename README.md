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
-- Retrieving a single row from an existing table
---

local userTable, err = schema.Table("users")
local result = userTable:Find({ username = "SomeName" })
if (result) then
  print("Found user " .. result.username)
end

-- You can search multiple columns

-- this would return false, because SomeName's status is "active"
local result = userTable:Find({ username = "SomeName", status = "disabled" })

---
-- Retrieve all matching rows
---

local resultset = userTable:All()
local resultsetWithFilters = userTable:All({ points = 5000 })

print("Found " .. table.Count(resultset) .. " entries")
for k,v in pairs(resultset) do
  print("User: " .. v["username"])
end

---
-- Return specific columns only
---

-- retrieve only the username and points columns from row
local result = userTable:Find({ username = "SomeName" }, { "username", "points"})
local resultset = userTable:All({}, { columns = {"username", "points"} })

---
-- Limit returned rows
---

local resultset = userTable:All({}, {
  columns = {"username", "points"},
  limit = 2
})

---
-- Updating
---

local result = userTable:Find({ username = "SomeName" })
print(result.username .. " has " .. result.points .. " points")
result:Update({ points = 10000 })

-- on a successful update, the object is changed as well as the database
print("They now have " .. result.points .. " points")

```