local _tbl = {}

function _tbl.crush(old_table, new_table)
	for k, v in pairs(new_table) do
		old_table[k] = v
	end
end

function _tbl.contain_key(tbl, key)
	for k, _ in pairs(tbl) do
		if k == key then
			return true
		end
	end

	return false
end

function _tbl.contains(tbl, value, iterator)
	if not iterator then
		iterator = ipairs
	end

	for _, v in iterator(tbl) do
		if v == value then
			return true
		end
	end

	return false
end

return _tbl
