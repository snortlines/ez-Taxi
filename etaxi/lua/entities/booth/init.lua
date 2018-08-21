AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize( )

	if ( ETaxiConfig.NPCType == "ent" ) then

		self:SetModel( ETaxiConfig.ENTModel )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

	elseif( ETaxiConfig.NPCType == "npc" ) then
		
		self:SetModel( ETaxiConfig.NPCModel )
		self:SetHullType( HULL_HUMAN )
		self:SetHullSizeNormal()
		self:SetNPCState( NPC_STATE_SCRIPT )
		self:SetSolid( SOLID_BBOX )
		self:CapabilitiesAdd( CAP_ANIMATEDFACE, CAP_TURN_HEAD )
		self:SetUseType( SIMPLE_USE )	

	end

end

function ENT:OnTakeDamage( dmg )

	return false

end 	

ETaxi.ShouldPrint = true

util.AddNetworkString( "ETaxi::TaxiUI" )
function ENT:AcceptInput( Name, Activator, Caller )	

	if ( Name == "Use" and Caller:IsPlayer() ) then
		
		local trace = Caller:GetEyeTrace().Entity

		if ( trace:GetClass() == "booth" ) then
			
			if ( Caller:GetNWBool( "ETaxi_Cooldown" ) ) then Caller:MessageClient( "bad", "You have recently taken a taxi, please wait before taking another one!" ) return false end

			for k, v in pairs( ETaxi.Data ) do

				if ( v.boothid == trace.id ) then
					
					ETaxi.UpdateBooths( Caller, k )
					
				end

			end

			net.Start( "ETaxi::TaxiUI" ) net.Send( Caller )

		else
			
			if ( ETaxi.ShouldPrint ) then

				Caller:MessageClient( "bad", "Unable to send data, the entity you are looking at is not a taxi booth." )

				ETaxi.ShouldPrint = false

				timer.Simple( 10, function()

					ETaxi.ShouldPrint = true

				end )

			end

		end

	end
	
end

function ETaxi.Upper( first, rest )

	return first:upper() .. rest:lower()

end

local Key = 0

function ETaxi.CreateLocation( BoothID, Title, ... )

	Title = Title or "Unknown"

	local Data = { ... }

	ETaxi.Data[ Key ] = { boothid = BoothID, title = Title, key = Key, Data }

	Key = Key + 1

end

function ETaxi.PostEntity()

	if ( not file.IsDir( "taxibooth", "DATA" ) ) then
		
		print( "The NPC failed to spawn due to the position not existing." )

		return

	end

	local files, folders = file.Find( "taxibooth/*", "DATA" )

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

end
hook.Add( "InitPostEntity", "ETaxi::PostEntity", ETaxi.PostEntity )

util.AddNetworkString( "ETaxi::PostPlayerTeleportation" )
net.Receive( "ETaxi::PostPlayerTeleportation", function( _, ply )

	if ( ply:GetNWBool( "ETaxi_Cooldown" ) ) then return end

	local Key = tonumber( net.ReadString() )
	local trace = ply:GetEyeTrace().Entity

	if ( trace:GetClass() != "booth" ) then ply:MessageClient( "bad", "Uh oh. An unexpected error has occured. Please try that again!" ) return end

	local pos = trace:GetPos()

	if ( ply:GetPos():Distance( pos ) > 150 ) then ply:MessageClient( "bad", "Uh oh. An unexpected error has occured. Apparently you are too far away?" ) return end

	ply:Freeze( true )
	ply:GodEnable( true )
	ply:SetNoDraw( true )

end )

util.AddNetworkString( "ETaxi::TaxiTeleport" )
net.Receive( "ETaxi::TaxiTeleport", function( _, ply )

	if ( ply:GetNWBool( "ETaxi_Cooldown" ) ) then return end

	local Key = tonumber( net.ReadString() )
	local trace = ply:GetEyeTrace().Entity

	local VecPos = ETaxi.Data[ Key ][ 1 ][ 1 ].pos
	local Dist = ETaxiConfig.Dist or ETaxi.Data[ Key ][ 1 ][ 1 ].pos
	local Cost = ETaxiConfig.Cost or math.floor( ply:GetPos():Distance( VecPos ) / 3 )

	if ( not ply:canAfford( Cost ) ) then ply:MessageClient( "bad", "Can not afford to travel to " .. ETaxi.Data[ Key ].title ) return end
	if ( trace:GetClass() != "booth" ) then ply:MessageClient( "bad", "Uh oh. An unexpected error has occured. Please try that again!" ) return end

	local pos = trace:GetPos()

	if ( ply:GetPos():Distance( pos ) > 150 ) then ply:MessageClient( "bad", "Uh oh. An unexpected error has occured. Apparently you are too far away?" ) return end

	ply:addMoney( - Cost )
	ply:SetPos( VecPos )
	ply:SetNWBool( "ETaxi_Cooldown", true )

	ply:MessageClient( "good", "You have Arrived at " .. ETaxi.Data[ Key ].title .. ", which cost you $" .. Cost )

	ply:Freeze( false )
	ply:GodDisable()
	ply:SetNoDraw( false )
	ply:SetNWBool( "NoCollide", true )
	ply:SetCustomCollisionCheck( true )

	timer.Simple( 60, function() ply:SetNWBool( "ETaxi_Cooldown", false ) end )
	timer.Simple( 10, function() ply:SetNWBool( "NoCollide", false ) end )

end )

function ETaxi.PreventCollideAfterTeleport( ply, victim )

	if ( IsValid( ply ) and IsValid( victim ) ) then

		if ( ply:IsPlayer() and victim:IsPlayer() ) then

			if ( ply:GetNWBool( "NoCollide" ) ) then

				return false

			end

			return true

		end

	end

end
hook.Add( "ShouldCollide", "ETaxi::PreventCollision", ETaxi.PreventCollideAfterTeleport )

function ETaxi.PreventTeleportUponDamage( ply, dmg )

	if ( ply:IsPlayer() and dmg:GetAttacker():IsPlayer() ) then
		
		ply:SetNWBool( "ETaxiDamaged", true )

		timer.Simple( 10, function() ply:SetNWBool( "ETaxiDamaged", false ) end )

	end

end
hook.Add( "EntityTakeDamage", "ETaxi::PreventTeleport", ETaxi.PreventTeleportUponDamage )