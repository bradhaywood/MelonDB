MelonDB = class:new()

function MelonDB.Connect(dbtype, dbhost, dbuser, dbpass)
	if (dbtype ~= nil) then
		if (dbtype == "sqlite") then
			return MSchema()
		end
	else
		return false, "MelonDB.Connect: Database type expected"
	end
end
	