-------------------------------------------------------------------------------
-- A package hierarchy library for LuaJIT
-- lffiheir
-- Author: Andrew McWatters
-------------------------------------------------------------------------------
local ffi       = require( "ffi" )

local execdir   = "./"
local gsub      = string.gsub
local targetdir = arg[ 2 ]

if ( jit.os == "Windows" ) then
	execdir = ".\\"

	-- Declare `SetDllDirectoryA`
	ffi.cdef[[
		int __stdcall SetDllDirectoryA(const char* lpPathName);
	]]

	-- Get working directory
	execdir         = gsub( arg[ 0 ], "\\lua\\init%.lua$", "\\" )
	package.execdir = execdir

	-- Set DLL directory
	ffi.C.SetDllDirectoryA( execdir .. "bin" )

	-- Add `lib'
	package.path    = package.path  .. ";" .. execdir .. "lib\\?.lua;"
	package.cpath   = package.cpath .. ";" .. execdir .. "lib\\?.dll;"
	package.cpath   = package.cpath .. execdir .. "lib\\loadall.dll"

	-- Add `./?/init.lua'
	if ( targetdir ) then
		package.path = gsub(
			package.path,
			"^%.\\%?%.lua;",
			targetdir .. "\\?.lua;" .. targetdir .. "\\?\\init.lua;"
		)
	else
		package.path = gsub(
			package.path,
			"^%.\\%?%.lua;",
			execdir .. "?.lua;"
		)
	end
else
	-- Get working directory
	execdir         = gsub( arg[ 0 ], "/lua/init%.lua$", "/" )
	package.execdir = execdir

	-- Add Windows LUA_LDIR paths
	local ldir      = "./?.lua;!lua/?.lua;!lua/?/init.lua;"
	package.path    = gsub( package.path, "^%./%?%.lua;", ldir )
	package.path    = gsub( package.path, "!", execdir )

	-- Add `lib'
	package.path    = package.path  .. ";" .. execdir .. "lib/?.lua"
	package.cpath   = package.cpath .. ";" .. execdir .. "lib/?.so;"
	package.cpath   = package.cpath .. execdir .. "lib/loadall.so"

	-- Add `./?/init.lua'
	if ( targetdir ) then
		package.path = gsub(
			package.path,
			"^%./%?%.lua;",
			targetdir .. "/?.lua;" .. targetdir .. "/?/init.lua;"
		)
	else
		package.path = gsub(
			package.path,
			"^%./%?%.lua;",
			execdir .. "?.lua;"
		)
	end
end
