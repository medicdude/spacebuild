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

local GM = GM
local system = system
local http = http

-- The below code is experimental, and may error on error handling as I can't possibly test every scenario

local function getOS()
	if system.IsWindows then return "Windows"
	elseif system.IsOSX then return "Mac"
	elseif system.IsLinux then return "Linux"
	end
end

local function getProfileID( steam_id, onSuccess, onFailure )
	return http.Fetch( "http://localhost:8080/convert?steam_id="..steam_id, onSuccess, onFailure )
end

local function getMe()
	-- Encode resolution as a string, delimited by a comma ',' The server will split this into the 2 number values required
	return {
		steam_id = LocalPlayer():SteamID(),
		nick = LocalPlayer():GetName(),
		os = getOS(),
		resolution = ScrW()..","..ScrH() -- x,y will be delimited by the server based upon commas.
		-- This is because the content-type gmod uses won't encoded a freakin' object literal / array
	}
end


function GM:SBClCreateUser()

	if not LocalPlayer() then return end

	-- This is the format that the database stores. MongoDB
	--{
	-- -- "steam_id":"STEAM_0:1:20447854",
	-- -- "profile_id":"76561198001161437",
	-- -- "nick":"Radon",
	-- -- "os":"Windows 7 64-Bit",
	-- -- "_id":"51a7c76fd5df3ad415000001",
	-- -- "__v":0,"hidden":false,
	-- -- "date":"2013-05-30T21:41:03.378Z",
	-- -- "resolution":[1920,1080]
	-- -- }

	local me = getMe()

	me.profile_id = getProfileID( me.steam_id,
		function( body, body_len, headers, code )
			if code == 200 then
				me.profile_id = body

				http.Post( "http://localhost:8080/user", me,
					function( body, body_len, headers,code )
						MsgN("CreateBody: "..body)
						if code == 201 then
							MsgN("We've made a new user in the database!")
						elseif tostring(body) == '{"message":"E11000 duplicate key error index: mongoose.users.$profile_id_1  dup key: { : \"'..me.steam_id..'\" }"}' then
								-- Duplicate entry
								MsgN("Duplicate Key: We're already in the database, try running updateUser instead")
						end
					end,
					function ( error )
						MsgN("Type of Error:",type(error))
						if type(error) == "Table" then
							PrintTable(error)
						else
							MsgN( error )
						end
					end
				)

			end
		end,

		function( error )
			if error then
				MsgN("Type of Error:",type(error))
				if type(error) == "Table" then
					PrintTable(error)
				else
					MsgN( error )
				end
			end
		end
		)
end

function GM:SBClUpdateUser()

	if not LocalPlayer() then return end

	-- This is the format that the database stores. MongoDB
	--{
	-- -- "steam_id":"STEAM_0:1:20447854",
	-- -- "profile_id":"76561198001161437",
	-- -- "nick":"Radon",
	-- -- "os":"Windows 7 64-Bit",
	-- -- "_id":"51a7c76fd5df3ad415000001",
	-- -- "__v":0,"hidden":false,
	-- -- "date":"2013-05-30T21:41:03.378Z",
	-- -- "resolution":[1920,1080]
	-- -- }

	local me = getMe()

	me.profile_id = getProfileID( me.steam_id,
		function( body, body_len, headers, code )
			if code == 200 then
				me.profile_id = body

				MsgN("URL: ".."http://localhost:8080/user/"..string.match(me.profile_id, '%d+') )

				http.Post( "http://localhost:8080/user/"..string.match(me.profile_id, '%d+'), me,
					function( body, body_len, headers,code )
						MsgN("Body: "..body)
						if code == 200 then
							MsgN("We've updated ourselves in the database")
						elseif code == 500 then
							if body == '"Cannot find specified user with id"' then
								-- We don't exist yet.
								MsgN("We don't exist in the database, adding ourselves now...")
								GM:SBClCreateUser()
							end
						end
					end,
					function ( error )
						MsgN("Type of Error:",type(error))
						if type(error) == "Table" then
							PrintTable(error)
						else
							MsgN( error )
						end
					end
				)

			end
		end,

		function( error )
			if error then
				MsgN("Type of Error:",type(error))
				if type(error) == "Table" then
					PrintTable(error)
				else
					MsgN( error )
				end
			end
		end
	)

end