-- hier.lua
-- a package hierarchy library for LuaJIT
-- distributed under the MIT license

local ffi = require( "ffi" )

local cwd = "./"
local gsub = string.gsub
local targetdir = arg[2]

if (jit.os == "Windows") then
  cwd = ".\\"

  -- Declare `SetDllDirectoryA`
  ffi.cdef[[
    int __stdcall SetDllDirectoryA(const char* lpPathName);
  ]]

  -- Get working directory
  cwd            = gsub(arg[0], "\\lua\\init%.lua$", "\\")
  package.cwd    = cwd

  -- Set DLL directory
  ffi.C.SetDllDirectoryA(cwd .. "bin")

  -- Add `lib'
  package.path   = package.path  .. ";" .. cwd .. "lib\\?.lua;"
  package.cpath  = package.cpath .. ";" .. cwd .. "lib\\?.dll;"
  package.cpath  = package.cpath .. cwd .. "lib\\loadall.dll"

  -- Add `./?/init.lua'
  if (targetdir) then
    package.path = gsub(package.path, "^%.\\%?%.lua;", targetdir .. "\\?.lua;"
      .. targetdir .. "\\?\\init.lua;")
  else
    package.path = gsub(package.path, "^%.\\%?%.lua;", cwd .. "?.lua;")
  end
else
  -- Get working directory
  cwd            = gsub(arg[0], "/lua/init%.lua$", "/")
  package.cwd    = cwd

  -- Add Windows LUA_LDIR paths
  local ldir     = "./?.lua;!lua/?.lua;!lua/?/init.lua;"
  package.path   = gsub(package.path, "^%./%?%.lua;", ldir)
  package.path   = gsub(package.path, "!", cwd)

  -- Add `lib'
  package.path   = package.path  .. ";" .. cwd .. "lib/?.lua"
  package.cpath  = package.cpath .. ";" .. cwd .. "lib/?.so;"
  package.cpath  = package.cpath .. cwd .. "lib/loadall.so"

  -- Add `./?/init.lua'
  if (targetdir) then
    package.path = gsub(package.path, "^%./%?%.lua;", targetdir .. "/?.lua;" ..
	  targetdir .. "/?/init.lua;")
  else
    package.path = gsub(package.path, "^%./%?%.lua;", cwd .. "?.lua;")
  end
end
