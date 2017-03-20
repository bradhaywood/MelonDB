MRow = class:new()

function MRow:Initialize(tbl)
	for k,v in pairs(tbl) do
		self[k] = v
	end
end