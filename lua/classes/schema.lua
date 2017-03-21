MSchema = class:new()

function MSchema:Initialize()
	return self
end

function MSchema.Table(name)
	if (name ~= nil) then
		local tbl = MTable(name)
		return tbl:GetTable()
	else
		return false, "MSchema.Table: Table name expected"
	end
end