--适合索引从1开始的连续Table                                                                 \/]]
table.reverse = function(self)
    local copy = table.copy(self);
    local len = #self;

    for i = 1, len do
        self[i] = copy[len];
        len = (len - 1);
    end;

    return self;
end;

--------------------------------------------------------------------------------
--适合索引从1开始的连续Table
table.slice = function(self, from, len)
    if (from + 0) < 0 then
        from = (#self + 1 + from);
    elseif from == 0 then
        from = (from + 1);
    end;

    if not len then
        len = #self;
    elseif len <= 0 then
        len = (#self + len + 1);
    end;

    for i, v in ipairs(self) do
        if i < from or i > len then
            self[i] = nil;
        end;
    end;

    return self;
end;

--------------------------------------------------------------------------------
--适合索引从1开始的连续Table
table.merge = function(self, ...)
    for i = 1, arg.n do
        for k, v in pairs(arg[i]) do
            self[type(k) == 'number' and (k + #self) or k] = v;
        end;
    end;

    return self;
end;

--------------------------------------------------------------------------------

table.dump = function(self)
    local result = tostring(self)..' {\n';
    local count, scope = 1, {};
    local map = {[true] = 'true', [false] = 'false'};
    local function _dump(t)
        local id = tostring(t);
        local tab = ('    '):rep(count);

        if scope[id] then
            result = ('%s%s*RECURSION*\n'):format(result, tab);
            return;
        else
            scope[id] = true;
        end;

        for k, v in pairs(t) do
            if type(v) ~= 'table' then
                result = ('%s%s[%s] => (%s)%s\n'):format(result, tab, k, type(v), tostring(map[v] or v));
            else
                result = ('%s%s[%s] => %s {\n'):format(result, tab, k, id);
                count = (count + 1);
                _dump(v);
                result = ('%s%s}\n\n'):format(result, tab);
                count = (count - 1);
            end;
        end;
    end;

    _dump(self);
    return result..'}';
end;

--------------------------------------------------------------------------------

table.keys = function(self)
    local result = {};

    for k, v in pairs(self) do
        table.insert(result, k);
    end;

    return result;
end;

--------------------------------------------------------------------------------

table.values = function(self)
    local result = {};

    for k, v in pairs(self) do
        table.insert(result, v);
    end;

    return result;
end;

--------------------------------------------------------------------------------

table.copy = function(self)
    local result = {};

    for k, v in pairs(self) do
        if type(v) == 'table' then
            result[k] = table.copy(v);
        else
            result[k] = v;
        end;
    end;

    return result;
end;

--------------------------------------------------------------------------------

table.each = function(self, callback)
    for k, v in pairs(self) do
        if type(v) == 'table' then
            self[k] = table.each(v, callback);
        else
            self[k] = callback(k, v);
        end;
    end;

    if #self > 0 then
        return self;
    end;
end;

--------------------------------------------------------------------------------

table.search = function(self, value)
    for k, v in pairs(self) do
        if v == value then
            return k;
        end;
    end;
end;

--------------------------------------------------------------------------------

table.size = function(self)
    local count = 0;

    for k in pairs(self) do
        count = (count + 1);
    end;

    return count;
end;

--------------------------------------------------------------------------------

--针对Key是数组的下标的情况.插入到最后面
table.push_back = function(self,value)
	if __DEBUG__ then
		if self == nil then
			LogFile("table.txt", "a", "Got nil table %s", debugInfo())
		end
	end
    table.insert(self, value)
end

--针对Key是数组的下标的情况.插入到最前面
table.push_front = function(self,value)
	if __DEBUG__ then
		if self == nil then
			LogFile("table.txt", "a", "Got nil table %s", debugInfo())
		end
	end
    table.insert(self, 1, value)
end
--------------------------------------------------------------------------------
--此方法后面的索引会往前移 注意 table.remove
--------------------------------------------------------------------------------

table.pop_back = function(self)
    table.remove(self)
end

--------------------------------------------------------------------------------


-- 连接嵌套的字符串数组
table.rconcat = function(t)
	if type(t) ~= "table" then return t end
	local res = {}
	for i = 1, #t do
		res[i] = rconcat(t[i])
	end
	return table.concat(res)
end

table.deepcopy = function(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end  -- if
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end  -- for
        return setmetatable(new_table, getmetatable(object))
    end  -- function _copy
    return _copy(object)
end  -- function deepcopy