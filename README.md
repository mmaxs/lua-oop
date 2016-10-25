### oop.lua

Prototype-based style of object-oriented programming can be failry naturally implemented in Lua by means of using the `__index` metamethod. This library provides a few functions that support prototype-based programming in Lua in a straightforward way to keep things clear and simple.

setprototype()
setcowprototype()
                 copy-on-write


setconstructor()
getconstructor()

getprototype()
unsetprototype()
prototypes()

memberpairs()

### The full list of the library functions and ther returns:
- `setprototype(object, prototype)`     --> object
- `setcowprototype(object, prototype)`  --> object
- `getprototype(object)`    --> object prototype
- `unsetprototype(object)`  --> object prototype
- `prototypes(object)`      --> iterator for object prototype chain --> index in the chain, sub-object
- `setconstructor(object, constructor)` --> object
- `getconstructor(object)`  --> object constructor function
- `memberpairs(object)`     --> object (including all sub-objects) member iterator --> key, value, sub-object

