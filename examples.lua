--examples for using Streams module.
--un comment out the function call at the bottom to run those examples.

--import the module
local Streams = require("Streams")


--tables to stream over.
local t = {1,2,3,4,5,6,7,8,9,0}
local tg = Streams({15,42,33,24,11})

--create a Stream from a table
local stream = Streams(t)

--function for printing out tables in a nice way. just for the examples.
local function printTableArrayNice(tbl)
    io.write("{")
    for i=1,(#tbl)-1,1 do
        io.write(tbl[i],",")
    end
    io.write(tbl[#tbl],"}\n")
end

--function for printing out tables in a nice way. just for the examples.
local function printTableKeyValueNice(tbl)
    for k,v in pairs(tbl) do
        io.write("key is: ",tostring(k),". values are: \n")
        if type(v) == "table" then
            printTableArrayNice(v)
        else
            io.write(tostring(v))
        end
    end

end

--some basic stream finalizer methods.
local function simpleFinalizerExamples()
    --we can count the number of items in our stream.
    io.write("\ncount of items is: ",stream:count(),"\n")


    --we can get the sum of all items in oour stream.
    io.write("\nsum of items is: ",stream:sum(),"\n")

    --we can get the average of all items in our stream.
    io.write("\naverage of items is: ",stream:average(),"\n")

    --we can get the max value in our stream.
    io.write("\nmax of items is: ",stream:max(),"\n")

    --we can get the min value in our stream.
    io.write("\nmin of items is: ",stream:min(),"\n\n")

    --we can run a for each loop over each item in our stream. accepts a function which takes in the value,the index value, and the original table as parameters.
    stream:forEach(function(v) io.write("the value in our stream is: ",v,"\n")  end)

    --we can collect the results of our stream into a table.
    --since we havent used any intermediate operators the results here will be identical to the original table.
    local tbl = stream:collect()
    io.write("\nthe results of collecting the stream is: \n")
    printTableArrayNice(tbl)

    --we can convert our stream into a string.
    --takes in three optional parameters. a delimiter value, a prefix value for each item, and a post fix value for each item.
    io.write("\nour stream as a string: ",stream:join(",","pre-","-post"),"\n")
end

--some more complicated finalizer examples.
local function complexFinalizerExamples()
    --we can reduce our stream down using a reduction function. pass in the function and an optional initial value.
    --function takes in the current stream item and the results of the reduction so far. should return the total results.
    --in our case we are simply summing all values in the stream.
    io.write("\nthe reduced value is: ",stream:reduce(function(item,results) return results + item end,0),"\n")

    --we can collect our stream into a table were the keys are ture and false.
    --the value for each is a table which contains all values in the stream which evaluates in the given function to true or false.
    --sorting function takes in the item and the index of that item in the table.
    --here we will sort the keys base don if the index is even. all even indexes will be under the key 'true' all others will be under 'false'.
    local tureFalse = stream:partitionBy(function(v,i) return i % 2 == 0 end)
    io.write("\nthe keys sorted based on even keys: \n")
    printTableKeyValueNice(tureFalse)

    --we can group of stream into a table where the keys are generated based on a function and values are also generated by a function.
    --the function for the keys takes in the current item and the index in the original table. it should return a key.
    --function for values takes in he generated key, the value which wa used in the key function, the table for the kes/values, and the index value of the item.
    --here our key function only used index and generates true/false based on if the index is divisible by three.
    --the value function simply adds the value to the end of the table which is associated with the key.
    local tbl = stream:groupBy(function(v,i) return i % 3 == 0  end, function(k,v,tb,i) if not tb[k] then tb[k] = {} end tb[k][#tb[k] + 1] = v end)
    io.write("\nthe keys sorted based on divisible by three: \n")
    printTableKeyValueNice(tbl)


    --we can get a table of all unique values in our table.
    --first we make a table with repeat values.
    local repeatTable = {1,2,3,4,1,2,3,4,5,3,2,1,5}
    io.write("\nthe unique values in our stream are: \n")
    local uniqueTbl = Streams(repeatTable):distinct()
    printTableArrayNice(uniqueTbl)

end

--examples of intermediate operations.
--when using intermediate operators it is best not to reuse streams.
--after applying immediate operators you need to apply a finalizer method. you can use any of the them with any intermediate method.
local function intermediateOperationExamples()
    --we can limit our stream to the first n items.
    io.write("we limit ourselves to the first 5 items: \n")
    local limitTbl = Streams(t):limit(5):collect()
    printTableArrayNice(limitTbl)

    --we can skip our the first n items in our stream.
    io.write("\nwe skip over the first 5 items:\n")
    local skipTbl = Streams(t):skip(5):collect()
    printTableArrayNice(skipTbl)

    --we can filter our stream . only items which return true in the filer function
    --we filter out any non even items
    local filteredTbl = Streams(t):filter(function(v,i) return i % 2 == 0  end):collect()
    io.write("\nonly the values form even index in our stream: \n")
    printTableArrayNice(filteredTbl)


    --we can map items in our stream form one value to another.
    --here we map from the original value into the square of that item.
    local mappedTbl = Streams(t):map(function(v,i) return v * v  end):collect()
    io.write("\nthe square of each item: \n")
    printTableArrayNice(mappedTbl)


    --we can combine as many intermediate operations as we want.
    --we first remove any even numbered items, then we map to the square of each filtered item, then we remove any item less than 20
    local multiIntTbl = Streams(t):filter(function(_,i) return i % 3 == 0  end):map(function(v,_) return v * v end):filter(function(v,_) return v >= 20  end):collect()
    io.write("\nafter applying filter and map functions to stream: \n")
    printTableArrayNice(multiIntTbl)
end


--simpleFinalizerExamples()
--complexFinalizerExamples()
--intermediateOperationExamples()

