
table.removeByValue = function(t, v)
    for key, value in pairs(t) do
        if value == v then
            table.remove(t, key)
            break
        end
    end
end

table.count = function(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

table.isEmpty = function(t)
    return table.count(t) == 0
end

table.findKey = function(t, v)
    for key, value in pairs(t) do
        if value == v then
            return key
        end
    end
    return nil
end

table.findLastElement = function(t)
    return t[t.count]
end