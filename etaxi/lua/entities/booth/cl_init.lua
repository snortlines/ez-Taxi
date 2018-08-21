include('shared.lua')

surface.CreateFont( "TaxiBoothFont", { font = "Arial", size = 50 } )
surface.CreateFont( "TaxiText", { font = "Arial", size = 16 } )

net.Receive( "ETaxi::UpdateBooths", function()
	
	local id = net.ReadString()
	local Title = net.ReadString()
	local Vec = net.ReadVector()
	local Key = tonumber( net.ReadString() )

	ETaxi.Data[ Key ] = { boothid = id, title = Title, vector = Vec }

end )

--[[---------------------------------------------------------
	Name: xPos - So I don't have to type ( ScrW() / 2 ) * .1
-----------------------------------------------------------]]
local function xPos( times )

	return ( ScrW() / 2 ) * times

end

--[[---------------------------------------------------------
	Name: yPos - So I don't have to type ( ScrH() / 2 ) * .1
-----------------------------------------------------------]]
local function yPos( times )

	return ( ScrH() / 2 ) * times

end

--[[---------------------------------------------------------
	Name: xSize - So I don't have to type ( ScrW() / 2 ) * .1
-----------------------------------------------------------]]
local function xSize( times )

	return ( ScrW() / 2 ) * times

end

--[[---------------------------------------------------------
	Name: ySize - So I don't have to type ( ScrH() / 2 ) * .1
-----------------------------------------------------------]]
local function ySize( times )

	return ( ScrH() / 2 ) * times

end

local PANEL = {}

ETaxi.I = 0

function PANEL:CreateButtonLocation( parent, id, title, key, func )

	local trace = LocalPlayer():GetEyeTrace().Entity:GetNWString( "ETaxi_id" )
	func = func or function() return end

	local Mat = Material( "icon16/world_go.png" )

	if ( trace != id ) then return end

	local Dist = ETaxi.Data[ key ].vector
	local Cost = ETaxiConfig.Cost or math.floor( LocalPlayer():GetPos():Distance( Dist ) / 3 )

	title = title .. " | Cost:  $" .. Cost

	self.LocButton = vgui.Create( "DButton", parent )
	self.LocButton:SetPos( 0, yPos( .1 ) + yPos( ETaxi.I ) )
	self.LocButton:SetSize( parent:GetWide(), ySize( .07 ) )
	self.LocButton:SetText( "" )

	self.LocButton.Paint = function( q, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, Color( 32, 32, 32, 255 ) )
		surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
		surface.SetMaterial( Mat )
		surface.DrawTexturedRect( xPos( .02 ), yPos( .015 ), 16, 16 )

		draw.DrawText( title, "TaxiText", xPos( .05 ), yPos( .015 ), Color( 255, 255, 255, 220 ), TEXT_ALIGN_LEFT )

		if ( q:IsHovered() ) then
			
			draw.RoundedBox( 0, 0, 0, xSize( .005 ), h, Color( 255, 131, 0, 255 ) )

		end

		draw.RoundedBox( 0, 0, yPos( .065 ), w, ySize( .002 ), Color( 21, 21, 21, 255 ) )
		draw.RoundedBox( 0, 0, yPos( .067 ), w, ySize( .002 ), Color( 38, 38, 38, 255 ) )

	end

	self.LocButton.DoClick = func

	ETaxi.I = ETaxi.I + .069

end

function PANEL:Init()

	local oldExitText = "Cancel"

	JILL.Multiplier = 0

	self:SetPos( xPos( .7 ), yPos( .6 ) )
	self:SetSize( xSize( .6 ), ySize( .8 ) )
	self:SetTitle( "Taxi Booth" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self:MakePopup()
	self.Paint = function( p, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, Color( 28, 28, 28, 255 ) )

		//Top
		draw.RoundedBox( 0, xPos( 0 ), yPos( .095 ), w, ySize( .002 ), Color( 21, 21, 21, 255 ) )
		draw.RoundedBox( 0, xPos( 0 ), yPos( .097 ), w, ySize( .002 ), Color( 38, 38, 38, 255 ) )

		//Bottom
		draw.RoundedBox( 0, xPos( 0 ), yPos( .726 ), w, ySize( .002 ), Color( 21, 21, 21, 255 ) )
		draw.RoundedBox( 0, xPos( 0 ), yPos( .728 ), w, ySize( .002 ), Color( 38, 38, 38, 255 ) )

	end

	self.Exit = vgui.Create( "Button", self )
	self.Exit:SetPos( xPos( 0 ), yPos( .732 ) )
	self.Exit:SetSize( self:GetWide(), ySize( .07 ) )
	self.Exit:SetText( "" )
	self.Exit.Paint = function( p, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, Color( 32, 32, 32, 255 ) )

		if ( p:IsHovered() ) then
			
			draw.RoundedBox( 0, 0, 0, xSize( .005 ), h, Color( 0, 255, 0, 255  ) )

		end

		draw.DrawText( oldExitText, "TaxiText", xPos( .295 ), yPos( .012 ), Color( 150, 150, 150, 255 ), TEXT_ALIGN_CENTER )

	end

	self.Exit.DoClick = function()

		LocalPlayer():ConCommand( "play UI/buttonclickrelease.wav" )
		
		self:Remove()

	end

	for k, v in pairs( ETaxi.Data ) do
	
		self:CreateButtonLocation( self, v.boothid, v.title, k, function()

			local Dist = ETaxi.Data[ k ].vector
			local Cost = ETaxiConfig.Cost or math.floor( LocalPlayer():GetPos():Distance( Dist ) / 3 )
			local ToTravel = ETaxiConfig.Dist or math.floor( LocalPlayer():GetPos():Distance( Dist ) / 4 )
			local ShouldNetwork = false

			if ( not LocalPlayer():canAfford( Cost ) ) then oldExitText = "Can not afford!" timer.Simple( 3, function() oldExitText = "Cancel" end ) return end
			if ( LocalPlayer():GetNWBool( "ETaxiDamaged", false ) ) then oldExitText = "You were recently damaged, wait 10 seconds!" timer.Simple( 3, function() oldExitText = "Cancel" end ) return end

			self.Overlay = vgui.Create( "DFrame" )
			self.Overlay:SetPos( 0, 0 )
			self.Overlay:SetSize( ScrW(), ScrH() )
			self.Overlay:SetTitle( "" )
			self.Overlay:ShowCloseButton( false )
			self.Overlay:SetDraggable( false )
			self.Overlay:MakePopup()
			self.Overlay:SetAlpha( 0 )
			self.Overlay:AlphaTo( 255, 2, 0 )

			local Overlay = self.Overlay

			self.Overlay.Paint = function( p, w, h )

				draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 255 ) )

				draw.DrawText( "Traveling to " .. v.title, "TaxiText", xPos( 1 ), yPos( .9 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
				draw.DrawText( "Cost $" .. Cost, "TaxiText", xPos( 1 ), yPos( .94 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
				draw.DrawText( "Distance to travel " .. tostring( ToTravel ) .. " units", "TaxiText", xPos( 1 ), yPos( .98 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )

				ToTravel = ToTravel - 1

				if ( ToTravel < 0 ) then

					ToTravel = 0

					ShouldNetwork = true

				end

			end

			timer.Create( "CheckNetworkStatus" .. LocalPlayer():SteamID64(), 1, 0, function()

				if ( ShouldNetwork ) then
				
					net.Start( "ETaxi::TaxiTeleport" )
						net.WriteString( k )
					net.SendToServer()

					Overlay:AlphaTo( 0, 1, 0, function() Overlay:Remove() end )

					timer.Destroy( "CheckNetworkStatus" .. LocalPlayer():SteamID64() )

				end

			end )

			net.Start( "ETaxi::PostPlayerTeleportation" )
				net.WriteString( k )
			net.SendToServer()

			self:Remove()

		end )

	end

end
derma.DefineControl( "ETaxiUI", "", PANEL, "DFrame" )

net.Receive( "ETaxi::TaxiUI", function()

	ETaxi.I = 0

	vgui.Create( "ETaxiUI" )

end )

function ENT:Draw()

	self:DrawModel()

	if ( IsValid( self ) && LocalPlayer():GetPos():Distance( self:GetPos() ) < 500 ) then

		 local ang = Angle( 0, ( LocalPlayer():GetPos() - self:GetPos() ):Angle()[ "yaw" ], ( LocalPlayer():GetPos() - self:GetPos() ):Angle()[ "pitch" ] ) + Angle( 0, 90, 90 )

		cam.IgnoreZ( false )
		cam.Start3D2D( self:GetPos() + Vector( 0, 0, 90 ), ang, .10 )

			draw.SimpleTextOutlined( ETaxiConfig.Header, "TaxiBoothFont", 0, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, .5, Color( 0, 0, 0, 255 ) )

		cam.End3D2D()

	end

end

net.Receive( "ETaxi::ResetBooths", function( _, ply )

	ETaxi.Data = {}

end )