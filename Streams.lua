--[[

    Lua module to emulate java 8 streams.

    license: GPL 3.0.  written by: github/return5

    Copyright (C) <2022>  <return5>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

local Streams = {}
Streams.__index = Streams

local setmetatable = setmetatable
local concat = table.concat
local huge = math.huge

_ENV = Streams


local function filterFunc(v,i,func)
    if func(v,i) then return v end
    return nil
end

local function mapFunc(v,i,func)
    return func(v,i)
end

function Streams:stream(t)
    return setmetatable({tbl = t,funcs = {}},Streams)
end

function Streams:map(func)
    self.funcs[#self.funcs + 1] = {"map",func}
    return self
end

function Streams:filter(func)
    self.funcs[#self.funcs + 1] = {"filter",func}
    return self
end

local funcMapping = {filter = filterFunc, map = mapFunc}

local function loopFuncs(i,tbl,funcs)
    local value = tbl[i]
    local j = 1
    while j <= #funcs and value ~= nil do
        value = funcMapping[funcs[j][1]](value,i,funcs[j][2])
        j = j + 1
    end
    return value
end

local function loopTbl(func,self)
    local t = {}
    for i=1,#(self.tbl),1 do
        local value = loopFuncs(i,self.tbl,self.funcs)
        if value then
            func(value,i,t) end
    end
    return t
end

function Streams:collect()
    return loopTbl(function(v,_,t) t[#t + 1] = v  end,self)
end

local function getSumCount(summingFun,self)
    local sum = 0
    local count = 0
    local func = summingFun and summingFun or function(v) return v  end
    loopTbl(function(v,_,_)  sum = sum + func(v,sum); count = count + 1 end,self)
    return sum,count
end

function Streams:distinct()
    local seen = {}
    local func = function(v) if not seen[v] then seen[v] = true return true end return false end
    self:filter(func)
    return self:collect()
end

function Streams:join(del,prefix,suffix)
    if prefix and suffix then
        self:map(function(v,i) return prefix .. v .. suffix  end)
    else
        if prefix then self:map(function(v,i) return prefix .. v end) end
        if suffix then self:map(function(v,i) return v .. suffix  end) end
    end
    local t = self:collect()
    return concat(t,del)
    end

function Streams:partitionBy(func)
    local keyValuefunc = function(v,i,t) local key = func(v,i); if not t[key] then t[key] = {} end; t[key][#t[key] + 1] = v  end
    return loopTbl(keyValuefunc,self)
end

function Streams:groupBy(keyFunc,valueFunc)
    local func = function(v,i,t) local key = keyFunc(v,i);valueFunc(key,v,t,i) end
    return loopTbl(func,self)
end

function Streams:average(func)
    local sum,count = getSumCount(func,self)
    return sum / count
end

function Streams:sum(func)
    local sum,_ = getSumCount(func,self)
    return sum
end

function Streams:count()
    local _,count = getSumCount(nil,self)
    return count
end

function Streams:reduce(func,ident)
    local result = ident and ident or nil
    loopTbl(function(value)if not result then result = value end result = func(value,result) end,self)
    return result
end

function Streams:forEach(func)
    loopTbl(func,self)
end

local function matching(match,breakingFunc,defaultReturn,self)
    for i=1,#self.tbl,1 do
        local value = loopFuncs(i,self.tbl,self.funcs)
        if value then
            local result = match(value,i)
            local breakflag,returnValue = breakingFunc(result)
            if breakflag then return returnValue end
        end
    end
    return defaultReturn
end

function Streams:allMatch(matchingFunc)
     return matching(matchingFunc,function(r) return not r,r end,true,self)
end

function Streams:anyMatch(matchingFunc)
    return matching(matchingFunc,function(r) return r,r end,false,self)
end

function Streams:noneMatch(matchingFunc)
    return matching(matchingFunc,function(r) return r, not r end,true,self)
end

function Streams:findFirst()
    return matching(function(v) return v end,function(v) return true,v end,nil,self)
end

function Streams:max(cmp)
    local max = -huge
    local func = cmp and cmp or function(v)if v > max then  max = v end  end
    loopTbl(func,self)
    return max
end

function Streams:min(cmp)
    local min = huge
    local func = cmp and cmp or function(v) if v < min then  min = v end end
    loopTbl(func,self)
    return min
end

function Streams:skip(n)
    return self:filter(function(_,i) return i > n end)
end

function Streams:limit(n)
    return self:filter(function(_,i) return i <= n end)

end

return setmetatable(Streams,{__call = Streams.stream})
