--[[---------------------------------------------------------
	Name: Taxi Chat Functions
-----------------------------------------------------------]]

function ETaxi.CreateBooth( ply, text )

	text = string.lower( text )

	if ( string.sub( text, 1, 12 ) == "!createbooth" or string.sub( text, 1, 12 ) == "/createbooth" ) then
		
		if ( not ply:IsSuperAdmin() ) then ply:MessageClient( "bad", "You are unable to access this command." ) return end

		if ( not file.IsDir( "taxibooth", "DATA" ) ) then
			
			ply:MessageClient( "bad", "[DATA]: taxibooth doesn't exist, creating..." )

			file.CreateDir( "taxibooth", "DATA" )

			ply:MessageClient( "good", "[DATA]: taxibooth successfully created." )

		end

		local BoothID = string.sub( text, 14 )

		if ( BoothID == "" or BoothID == nil ) then
			
			ply:MessageClient( "bad", "BoothID is nil. Usage: !createbooth <booth id>; !createbooth my_unique_identifier" )

			return

		end

		if ( file.IsDir( "taxibooth/" .. BoothID, "DATA" ) ) then
			
			ply:MessageClient( "bad", "[DATA]: " .. BoothID .. " already exists, please choose a unique name for your booths." )

			return

		end

		local booth = ents.Create( "booth" )
		booth:SetPos( ply:GetEyeTrace().HitPos )
		booth.id = BoothID
		booth.CanUpdate = true
		booth:Spawn()

	end

end
hook.Add( "PlayerSay", "ETaxi::CreateBooth", ETaxi.CreateBooth )

function ETaxi.SaveBooth( ply, text )

	text = string.lower( text )

	if ( string.sub( text, 1, 11 ) == "!savebooths" or string.sub( text, 1, 11 ) == "/savebooths" ) then
		
		if ( not ply:IsSuperAdmin() ) then ply:MessageClient( "bad", "You are unable to access this command." ) return end

		local storedBooths = {}
		local Found = 0

		for k, v in pairs( ents.GetAll() ) do
			
			if ( v:GetClass() == "booth" ) then

				if ( v.id == nil ) then ply:MessageClient( "bad", "Skipping unknown booth as it is invalid." ) continue end

				storedBooths[ v.id ] = { pos = v:GetPos(), ang = v:GetAngles() }
				Found = Found + 1

			end

		end

		if ( Found == 0 ) then
			
			ply:MessageClient( "bad", "There are no booths on the map! Create a booth by typing: !createbooth" )

			return

		end

		for id, v in pairs( storedBooths ) do
			
			if ( not file.IsDir( "taxibooth/" .. id, "DATA" ) ) then file.CreateDir( "taxibooth/" .. id, "DATA" ) file.CreateDir( "taxibooth/" .. id .. "/locations", "DATA" ) end

			file.Write( "taxibooth/" .. id .. "/pos.txt", tostring( v.pos ) )
			file.Write( "taxibooth/" .. id .. "/ang.txt", tostring( v.ang ) )

		end

		ply:MessageClient( "good", "All booths has been successfully saved." )

	end

end
hook.Add( "PlayerSay", "ETaxi::SaveBooth", ETaxi.SaveBooth )

function ETaxi.DeleteBooth( ply, text )

	text = string.lower( text )

	if ( string.sub( text, 1, 12 ) == "!deletebooth" or string.sub( text, 1, 12 ) == "/deletebooth" ) then
		
		if ( not ply:IsSuperAdmin() ) then ply:MessageClient( "bad", "You are unable to access this command." ) return end

		local BoothID = string.sub( text, 14 )

		if ( file.IsDir( "taxibooth/" .. BoothID, "DATA" ) ) then
			
			local files = select( 1, file.Find( "taxibooth/" .. BoothID .. "/locations/*", "DATA" ) )

			for k, v in pairs( files ) do
				
				file.Delete( "taxibooth/" .. BoothID .. "/locations/" .. v, "DATA" )

			end

			file.Delete( "taxibooth/" .. BoothID .. "/pos.txt" ) //Can't just delete the folder because it has to be empty... gmod plz
			file.Delete( "taxibooth/" .. BoothID .. "/ang.txt" ) //Can't just delete the folder because it has to be empty... gmod plz

			file.Delete( "taxibooth/" .. BoothID .. "/locations" )
			file.Delete( "taxibooth/" .. BoothID )

			for k, v in pairs( ents.GetAll() ) do
				
				if ( v:GetClass() == "booth" ) then
					
					if ( v.id == BoothID ) then
						
						v:Remove()

					end

				end

			end

			if ( file.IsDir( "taxibooth/" .. BoothID, "DATA" ) ) then

				ply:MessageClient( "bad", "Unable to delete booth " .. BoothID .. " for unknown reason." )

			else

				ply:MessageClient( "good", "Successfully deleted booth " .. BoothID )

			end

		else

			ply:MessageClient( "bad", "No booth found by the ID: " .. BoothID .. " was found." )

			return

		end

	end

end
hook.Add( "PlayerSay", "ETaxi::DeleteBooth", ETaxi.DeleteBooth )

function ETaxi.GetBoothID( ply, text )

	text = string.lower( text )

	if ( string.sub( text, 1, 8 ) == "!boothid" or string.sub( text, 1, 8 ) == "/boothid" ) then
		
		if ( not ply:IsSuperAdmin() ) then ply:MessageClient( "bad", "You are unable to access this command." ) return end

		local trace = ply:GetEyeTrace().Entity

		if ( trace:GetClass() == "booth" ) then
			
			timer.Simple( .1, function()

				ply:MessageClient( "good", "Booth ID: " .. trace.id )

			end )

			return

		end

		timer.Simple( .1, function()

			ply:MessageClient( "bad", "This is not a booth!" )

		end )

	end
	
end
hook.Add( "PlayerSay", "ETaxi::GetBoothID", ETaxi.GetBoothID )

function ETaxi.CreateLocation( ply, text )

	text = string.lower( text )

	if ( string.sub( text, 1, 15 ) == "!createlocation" or string.sub( text, 1, 15 ) == "/createlocation" ) then
		
		if ( not ply:IsSuperAdmin() ) then ply:MessageClient( "bad", "You are unable to access this command." ) return end

		text = string.Explode( " ", text )

		local BoothID = text[ 2 ]
		local BoothName = text[ 3 ]

		if ( not BoothID or BoothID == "" ) then
			
			ply:MessageClient( "bad", "You need a unique identifier for the booth!" )

			return

		end

		if ( not BoothName or BoothName == "" ) then
			
			ply:MessageClient( "bad", "You need to name your location." )

			return			

		end

		if ( not file.IsDir( "taxibooth/" .. BoothID, "DATA" ) ) then
			
			ply:MessageClient( "bad", "Unable to create location for " .. BoothID .. " because it doesn't exist. Remember to save the booth before creating a location for it." )

			return

		end

		if ( file.Exists( "taxibooth/" .. BoothID .. "/locations/" .. BoothName .. ".txt", "DATA" ) ) then
			
			ply:MessageClient( "bad", BoothName .. " already exists, please delete the location before creating a new one with the same name." )

			return

		end

		file.Write( "taxibooth/" .. BoothID .. "/locations/" .. BoothName .. ".txt", tostring( ply:GetPos() ) )

		if ( file.Exists( "taxibooth/" .. BoothID .. "/locations/" .. BoothName .. ".txt", "DATA" ) ) then
			
			ply:MessageClient( "good", "Successfully created " .. BoothName .. " inside of " .. BoothID .. ". Type !updatebooths to sync your booths." )

		else

			ply:MessageClient( "bad", "Oh noes! We were unable to create the location for you. Remember that your Booth Name can not contain spaces, or anything other than letters, numbers or underscores." )

			return

		end

	end
	
end
hook.Add( "PlayerSay", "ETaxi::CreateLocation", ETaxi.CreateLocation )

function ETaxi.DeleteLocation( ply, text )

	text = string.lower( text )

	if ( string.sub( text, 1, 15 ) == "!deletelocation" or string.sub( text, 1, 15 ) == "/deletelocation" ) then
		
		if ( not ply:IsSuperAdmin() ) then ply:MessageClient( "bad", "You are unable to access this command." ) return end

		text = string.Explode( " ", text )

		local booth = text[ 2 ] or "Unknown"
		local location = text[ 3 ] or "Unknown"

		if ( not file.IsDir( "taxibooth/" .. booth, "DATA" ) ) then
			
			ply:MessageClient( "bad", "Unable to delete location " .. location .. " from " .. booth .. " because the booth doesn't exist." )

			return

		end

		if ( not file.Exists( "taxibooth/" .. booth .. "/locations/" .. location .. ".txt", "DATA" ) ) then
			
			ply:MessageClient( "bad", location .. " for " .. booth .. " does not exist." )

			return

		end

		file.Delete( "taxibooth/" .. booth .. "/locations/" .. location .. ".txt", "DATA" )

		ply:MessageClient( "good", "Successfully deleted " .. location .. " from " .. booth .. ". Changes will take effect on next restart." )

	end
	
end 
hook.Add( "PlayerSay", "ETaxi::DeleteLocation", ETaxi.DeleteLocation )

util.AddNetworkString( "ETaxi::ResetBooths" )
function ETaxi.UpdateNPCS( ply, text )

	text = string.lower( text )

	if ( string.sub( text, 1, 13 ) == "!updatebooths" or string.sub( text, 1, 13 ) == "/updatebooths" ) then
		
		if ( not ply:IsSuperAdmin() ) then ply:MessageClient( "bad", "You are unable to access this command." ) return end

		local files, folders = file.Find( "taxibooth/*", "DATA" )

		for _, booths in pairs( ents.GetAll() ) do
			
			if ( booths:GetClass() == "booth" ) then
				
				booths:Remove()

			end

		end

		ETaxi.Data = {}
		net.Start( "ETaxi::ResetBooths" ) net.Broadcast()

		timer.Simple( .5, function()

			for k, v in pairs( folders ) do
				
				local pos = file.Read( "taxibooth/" .. v .. "/pos.txt", "DATA" )
				local ang = file.Read( "taxibooth/" .. v .. "/ang.txt", "DATA" )
				local boothid = v

				local locations = file.Find( "taxibooth/" .. v .. "/locations/*", "DATA" )

				for i = 0, #locations do
					
					if ( locations[ i ] ) == nil then continue end

					local loc = locations[ i ]:gsub( "%.txt", "" )
					local realPos = file.Read( "taxibooth/" .. v .. "/locations/" .. loc .. ".txt", "DATA" )

					loc = loc:gsub( "%_", " " )
					loc = loc:gsub( "(%a)([%w_']*)", ETaxi.Upper )

					ETaxi.CreateLocation( tostring( v ), tostring( loc ), {

						pos = Vector( realPos ),

					} )

				end

				local booth = ents.Create( "booth" )
				booth:SetPos( Vector( pos ) )
				booth:SetAngles( Angle( ang ) )
				booth.id = boothid
				booth:Spawn()

				booth:SetNWString( "ETaxi_id", boothid )

				local phys = booth:GetPhysicsObject()

				if ( IsValid( phys ) ) then
					
					phys:EnableMotion( false )

				end

			end		

			ply:MessageClient( "good", "Successfully synced booths." )

		end )

	end

end 
hook.Add( "PlayerSay", "ETaxi::UpdateNPCS", ETaxi.UpdateNPCS )