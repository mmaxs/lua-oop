#! /usr/bin/env lua-5.1
--{michaelus{

require "oop"
require "printtable"

setprototype = setweakprototype

function A(_abc)
  print("constructor A: ", A)
  local self = {
      abc = _abc or "a"
  }
  setconstructor(self, A)
  return self
end

function B(_abc, _def)
  print("constructor B: ", B)
  local base = A(_abc)
  local self = {
      def = _def or "b"
  }
  setprototype(self, base)
  setconstructor(self, B)
  return self
end

function C(_abc, _def, _ghi)
  print("constructor C: ", C)
  local base = B(_abc, _def)
  local self = {
      ghi = _ghi or "c"
  }
  setprototype(self, base)
  setconstructor(self, C)
  return self
end


local a = A()
printtable(a, "[A] "); printtable(getprototype(a), "[] "); printtable(getprototype(getprototype(a)), "[] ")
print("a.abc = 1; a.def = 2")
a.abc = 1
a.def = 2
printtable(a, "[A] "); printtable(getprototype(a), "[] "); printtable(getprototype(getprototype(a)), "[] ")

local b = B()
printtable(b, "[B] "); printtable(getprototype(b), "[A] "); printtable(getprototype(getprototype(b)), "[] ")
print("b.abc = 1; b.def = 2; b.ghi = 3")
b.abc = 1
b.def = 2
b.ghi = 3
printtable(b, "[B] "); printtable(getprototype(b), "[A] "); printtable(getprototype(getprototype(b)), "[] ")

local c = C()
printtable(c, "[C] "); printtable(getprototype(c), "[B] "); printtable(getprototype(getprototype(c)), "[A] ")
print("c.abc = 1; c.def = 2; c.ghi = 3; c.jkl = 4")
c.abc = 1
c.def = 2
c.ghi = 3
c.jkl = 4
printtable(c, "[C] "); printtable(getprototype(c), "[B] "); printtable(getprototype(getprototype(c)), "[A] ")

print("c.def = nil")
c.def = nil
printtable(c, "[C] "); printtable(getprototype(c), "[B] "); printtable(getprototype(getprototype(c)), "[A] ")
print("c.def = -2")
c.def = -2
printtable(c, "[C] "); printtable(getprototype(c), "[B] "); printtable(getprototype(getprototype(c)), "[A] ")
print("c.abc = nil");
c.abc = nil
printtable(c, "[C] "); printtable(getprototype(c), "[B] "); printtable(getprototype(getprototype(c)), "[A] ")
print("c.abc = -1")
c.abc = -1
printtable(c, "[C] "); printtable(getprototype(c), "[B] "); printtable(getprototype(getprototype(c)), "[A] ")
print("c.ghi, c.jkl = nil, nil; c.ghi, c.jkl = -3, -4")
c.ghi, c.jkl = nil, nil;
c.ghi, c.jkl = -3, -4
printtable(c, "[C] "); printtable(getprototype(c), "[B] "); printtable(getprototype(getprototype(c)), "[A] ")

for i, p in prototypechain(c) do
  print(i, p)
end

for k, v, t in memberpairs(c) do
  print(k, v, "(sub-object "..tostring(t)..")")
end

--}michaelus}
