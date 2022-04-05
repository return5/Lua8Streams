### Streams  
a simple module for emulating java 8 streams in lua.  
Doesn't provide 100% of functionality of native java streams.  

Please see 'examples.lua' for commented and working examples.

#### Functions  
- ```Streams:stream(t)```
    - creates a new stream from a table.

##### Intermediate operations


 - ```Streams:map(func)```  
    - intermediate operator which maps inputs into different outputs.  
    - takes in a function which does the mapping.  


 - ```Streams:filter(func)```  
    - intermediate operator which filters input items.  
    - takes in a function which accepts inputs and returns a boolean value.  

##### Finalizer methods  
- ```Streams:skip(n)```
    - intermediate function which returns a stream skipping over the first n items.


- ```Streams:limit(n)```
    - intermediate operation which returns a stream limited to the first n items.


 - ```Streams:collect()```  
    - finalizer method which returns a table with each item as an index of that table.  


 - ```Streams:distinct()```  
    - finalizer method which returns a table which has all duplicate values removed.  


 - ```Streams:join(del,prefix,suffix)```  
    - finalizer method which converts stream into string.  
    - all parameters are optional. takes in delimeter value for each item, a prefix for each item, and a postfix for each item.  


 - ```Streams:partitionBy(func)```  
    - finalizer method which returns a table with keys "true" and "false", with values which are tables containing each item from the stream which evaluates to either true false in the provided function.  
    - takes in a function which should accept the current item and the index value, should return a boolean value.  


 - ```Streams:groupBy(keyFunc,valueFunc)```  
    - finalizer method which returns a table where the keys and values are generated from the provided functions.
    - keyFunc generates the keys. should take in item and index value.  should return key value.  
    - valueFunc generated the values. should take in key, item, the table to return, and the index value. no return is expected.  


 - ```Streams:average(func)```  
    - finalizer method which returns the average of items in stream.  
    - optional parameter is a function for summing items in stream.  


 - ```Streams:sum(func)```  
   - finalizer method which returns the sum of all items in the stream.  
   - optional parameter is a function which controls how items are summed.  


 - ```Streams:count()```  
    - finalizer method which returns the count of items in teh stream.  


 - ```Streams:reduce(func,ident)```  
    - finalizer method which reduces stream down to a single value.  
    - func is a function which takes in current item and the results so far of reduction. returns updated result.    
    - ident is optional. inital value for starting reduction, if not provided then first item in stream is used.  


 - ```Streams:forEach(func)```  
    - for each item in the stream call the given function.  
    - func should take in the item and return nothing.  


 - ```Streams:allMatch(matchingFunc)```  
    - finalizer method which returns true if all items in stream evaluates to true in given function.  otherwise, returns false.  
    - matchingFunc should take in item and index of item, should return true or false.  


 - ```Streams:anyMatch(matchingFunc)```  
    - finalizer which returns true is any item in stream evaluates to true in the given function. otherwise, return false.
    - matchingFunc should accept item and index of item. should return true or false.  
   

 - ```Streams:noneMatch(matchingFunc)```  
    - finalizer method which returns true if none of the items in stream evaluates to true in the provided function. otherwise, returns false.  
    - matchingFunc should accept item and index, returns true or false.


 - ```Streams:findFirst()```  
    - finalizer which returns the first item in the stream.  
   

 - ```Streams:max(cmp)```  
    - finalizer method which returns the max value in the steam.  
    - accepts optional compare function which handles comparison for max value.
   

 - ```Streams:min(cmp)```  
     - finalizer method which returns the min value in the steam.
     - accepts optional compare function which handles comparison for min value.  


#### Basic working example  
``` 
    --import the module
    local Streams = require("Streams')
    --create a stream, filter it, then collect the reuslts.
    --first createa a stream from the given table.
    --we then filter out non even indexes.
    --then we collect the results into a table.
    local results = Streams({1,2,3,4,5,6,7,8}):filter(function(_,i) return i % 2 == 0 end):collect()    
    
    --from this point do whatever you want with the table.
```
