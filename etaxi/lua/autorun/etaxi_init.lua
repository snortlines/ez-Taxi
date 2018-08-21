--[[---------------------------------------------------------
	Name: Taxi Init
-----------------------------------------------------------]]

if ( CLIENT ) then ETaxi = {} ETaxi.Data = {} return end

ETaxi = {}
ETaxi.Data = ETaxi.Data or {}
ETaxi.Init = {}
ETaxi.Init.Client = FindMetaTable( "Player" )

util.AddNetworkString( "TaxiPrint" )
function ETaxi.Init.Client:MessageClient( typ, str )

	if ( str == "" or str == nil ) then return end

	net.Start( "TaxiPrint" )
		net.WriteString( typ )
		net.WriteString( str )
	net.Send( self )

end

util.AddNetworkString( "ETaxi::UpdateBooths" )
function ETaxi.UpdateBooths( ply, key )

	net.Start( "ETaxi::UpdateBooths" )
		net.WriteString( ETaxi.Data[ key ].boothid )
		net.WriteString( ETaxi.Data[ key ].title )
		net.WriteVector( ETaxi.Data[ key ][ 1 ][ 1 ].pos )
		net.WriteString( ETaxi.Data[ key ].key )
	net.Send( ply )

end