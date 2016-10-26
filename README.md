##### oop.lua

Prototype-based style of object-oriented programming can be fairly naturally implemented in Lua by means of using the `__index` metamethod. This library provides a few functions that support prototype-based programming in Lua in a straightforward way to keep things clear and simple.

##### Guide and usage examples

You can set a given table `a` to be a _prototype_ of an arbitrary table `b`:
```lua
local a = { aaa = 111 }
local b = { bbb = 222 }
setprototype(b, a)

```
The function `setprototype()` modifies the metatable of the table `b` (or creates and sets a metatable for `b` if it does not exist yet) so that the table `a` becomes the `__index` metamethod. It also sets the `__newindex` metamethod to a function that tracks indexing assignments to the table `b` and dispatches them to existing keys in the table `a` (all the new keys that are not present in `b` nor in `a` are created in the table `b` as per normal).

Now we can consider the table `b` as an _object_ that has two _members_: field `bbb` and field `aaa`. It consists of the two _sub-objects_: the part that is the original table `b` itself with the field `bbb`, and another one disposed as the first item in the _prototype chain_ - the table from the variable `a` with the field `aaa`.

Instead of `setprototype()` you can use the `setcowprototype()` function, which means to set "copy-on-write" prototype. This function is the same as the former one but it does't touch the `__newindex` metamethod. In this case the tables building up the prototype chain can be considered as read only, and every key from these tables is automatically copied into the most outer sub-object before performing a first assignment operation to it. Keys and values in prototype sub-objects themselves remain unaffected.

Normally, we will define some function that creates and initializes a new object instance. Let's call this function the object _constructor_. You can save the reference to the constructor function which a certain object instance has been created with into that object metatable by using the `setconstructor()` function.
```lua
function A(_aaa)  -- constructor for the objects of class A
  local self = { aaa = _aaa or 111 }
  setconstructor(self, A)
  return self
end
```
The function `setconstructor()` saves its second argument in the field `constructor` of the metatable for its first argument (the metatable is created and attached if it doesn't exist yet).
```lua
function B(_aaa, _bbb)  -- constructor for the objects of class B
  local base = A(_aaa)
  local self = { bbb = _bbb or 222 }
  setprototype(self, base)
  setconstructor(self, B)
  return self
end

local b = B(1, 2)
function C(_ccc)  -- constructor for the objects of class C written in less verbose manner
  return setconstructor(
      setcowprototype({ ccc = _ccc or 3 }, b),
      C
  )
end
```
After that we can at any time apply the `getconstructor()` function for obtaining the object constructor from the instance to be able to create a new instance of the same object _class_ and to use the same sort of constructing function, if there are several ones for that class.
```lua
local c = C()
...

local make_b = getconstructor(b)
local b1, b2 = make_b(), make_b()

local make_c = getconstructor(c)
local c1, c2 = make_c(), make_c()

```
Note that according to definitions of the example constructor functions, instances of `b1` and `b2` will have distinct sub-objects on every level of their prototype chains. Whereas, in contrast, instances of `c1` and `c2` will have distinct parts only for the most outer sub-objects in their structure and both have the very same single table `b` as the first item in their prototype chains which is also being set as copy-on-write with `setcowprototype()`.


`getprototype()`
`prototypes()`

`memberpairs()`

That's basically all.

##### The full list of the library functions and what they return
- `setprototype(object, prototype)`     --> object
- `setcowprototype(object, prototype)`  --> object
- `getprototype(object)`    --> object prototype
- `prototypes(object)`      --> iterator for the object prototype chain --> index in the chain, sub-object
- `setconstructor(object, constructor)` --> object
- `getconstructor(object)`              --> object constructor function
- `memberpairs(object)`     --> object (including all sub-objects) member iterator --> key, value, sub-object that the pair belongs to

##### Further documentation
 don't modify tables in any way, don't modify metatables except as described above and don't remove them even if they are becoming empty and were created and set by these functions before.

--
Copyright (c) 2016 Mikhail Usenko <michaelus@tochka.ru>. All rights reserved.
GNU General Public License.
