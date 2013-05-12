-- Copyright (C) 2012-2013 Spacebuild Development Team
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local player_manager = player_manager

local meta = FindMetaTable( "Player" )
if not meta then error("Why is there no Player Metatable?") return end

function meta:getRace()
	return player_manager.RunClass( self, "getRace" )
end

function meta:getRaceColour()
	return player_manager.RunClass( self, "getRaceColour" )
end

function meta:getCredits()
	return player_manager.RunClass( self, "getCredits" )
end

function meta:setCredits( credits )
	player_manager.RunClass( self, "setCredits", credits)
	return player_manager.RunClass( self, "getCredits" )
end