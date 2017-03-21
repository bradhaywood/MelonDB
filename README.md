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
local result = userTable:Find({ username = "SomeName" }, { columns = {"username", "points"} })
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

## Real world example

Say you want to save a players experience when they leave and re-join your server. You can use 
a combination of `SetNWInt` and MelonDB to do just that.

```lua
-- set or retrieve experience when they spawn in initially
local function MyGM_InitSpawn(ply)
  local steamID = ply:SteamID()
  local playerRes = userTable:Find({ steam_id = steamID })
  
  -- if we get a result, then they've been here before
  if (playerRes) then
    ply:SetNWInt("experience", playerRes.experience)
  else
    -- set up a new row for the player
    local row, err = userTable:Insert({
      experience = 0,
      steam_id = steamID
    })

    -- make sure everything was ok before proceeding
    if (not err) then
      ply:SetNWInt("experience", 0)
    else
      -- handle the error
    end
  end
end

-- save their experience when they leave
local function MyGM_PlayerLeave(ply)
  local steamID = ply:SteamID()
  -- we should already have their details in the database
  -- but you can do error checking if you want
  local playerRes = userTable:Find({ steam_id = steamID })

  -- store the new experience value they received while playing
  playerRes:Update({ experience = ply:GetNWInt("experience") })
end

-- In the event we shut down the server, we still want to keep
-- the players experience up to date
local function MyGM_Shutdown()
  for _, ply in pairs(player.GetAll()) do
    local steamID = ply:SteamID()
    local playerRes = userTable:Find({ steam_id = steamID })
    playerRes:Update({ experience = ply:GetNWInt("experience") })
  end
end

-- finally, add the hooks
hook.Add("PlayerInitialSpawn", "GM Initial Spawn", MyGM_InitSpawn)
hook.Add("PlayerDisconnected", "GM Player Leave", MyGM_PlayerLeave)
hook.Add("ShutDown", "GM Shutdown", MyGM_Shutdown)
```

## Saving Network Vars

MelonDB can automagically sync data between the database and Network variables, if they have 
the same name of course.
**For this to work you need an `id` field with the type `varchar` which holds the players `SteamID()`**

This feature is highly experimental as it stands, so be warned.

```lua
hook.Add("PlayerDisconnected", "Player left", function(ply)
  local userRes = userTable:Find({ id = ply:SteamID() })
  userRes:Save(ply)
end)
```

That's literally all there is to it. It will go through and save every `SetNWString/Bool/Int` it can find directly to the 
database.