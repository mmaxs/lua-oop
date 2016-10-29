#! /usr/bin/env lua

require "oop"



function A(_abc)
  print("constructor A: ", A)
  local self = {
      abc = _abc or "a",
  }
  setconstructor(self, A)
  return self
end

function B(_abc, _def)
  print("constructor B: ", B)
  local base = A(_abc)
  local self = {
      def = _def or "b",
  }
  setprototype(self, base)
  setconstructor(self, B)
  return self
end

function C(_abc, _def, _ghi)
  print("constructor C: ", C)
  local base = B(_abc, _def)
  local self = {
      ghi = _ghi or "c",
  }
  setprototype(self, base)
  setconstructor(self, C)
  return self
end


function printobject(_obj, _prefix)
  local function print_subobject(_o, _i)
    io.write("  sub-object ", _i, " = ", tostring(_o), " {\n")
    for k, v in pairs(_o) do
      io.write("    ", tostring(k), "\t ", tostring(v), "\n")
    end
    io.write("  }\n")
  end

  io.write(_prefix or "", "{\n")
  print_subobject(_obj, 0)
  for i, o in prototypes(_obj) do
    print_subobject(o, i)
  end
  io.write("}\n")
end


local a = A()
printobject(a, "a = ")
print("a.abc = 1; a.def = 2")
a.abc = 1
a.def = 2
printobject(a, "a = ")
print()

local b = B()
printobject(b, "b = ")
print("b.abc = 1; b.def = 2; b.ghi = 3")
b.abc = 1
b.def = 2
b.ghi = 3
printobject(b, "b = ")
print()

local c = C()
printobject(c, "c = ")
print("c.abc = 1; c.def = 2; c.ghi = 3; c.jkl = 4")
c.abc = 1
c.def = 2
c.ghi = 3
c.jkl = 4
printobject(c, "c = ")
print()

print("c.abc, c.def = nil, nil")
c.abc = nil
c.def = nil
printobject(c, "c = ")
print("c.abc, c.def = -1, -2")
c.abc = -1
c.def = -2
printobject(c, "c = ")
print("c.ghi, c.jkl = nil, nil; c.ghi, c.jkl = -3, -4")
c.ghi, c.jkl = nil, nil;
c.ghi, c.jkl = -3, -4
printobject(c, "c = ")
print()

print("memberpairs(c):")
for k, v, t in memberpairs(c) do
  print(k, v, "(sub-object "..tostring(t)..")")
end
print()


local d1, d2 = setcowprototype({ jkl = "d1" }, b), setcowprototype({ jkl = "d2" }, b)
print(string.format("%-30s%-30s", "d1:", "d2:"))
print(string.format("%-3d%-27s%-3d%-27s", 0, tostring(d1), 0, tostring(d2)))
local it1, it2 = prototypes(d1), prototypes(d2)
while true do
  local i1, p1 = it1()
  local i2, p2 = it2()
  if not (i1 and i2) then break end

  if i1 then
    io.stdout:write(string.format("%-3d%-27s", i1, tostring(p1)))
  else
    io.stdout:write(string.format("%-3s%-27s", "-", "-"))
  end
  if i2 then
    io.stdout:write(string.format("%-3d%-27s", i2, tostring(p2)))
  else
    io.stdout:write(string.format("%-3s%-27s", "-", "-"))
  end
  print()
end
printobject(d1, "d1 = "); printobject(d2, "d2 = ")

--[[ -- loop in gettable --
setprototype(a, b)
setprototype(b, c)
setprototype(getprototype(getprototype(c)), a)
print(a.zzz)
a.zzz = 0
--]]

