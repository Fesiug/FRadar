
local s = ScreenScaleH
local cb = Color( 0, 0, 0, 200 )
local veh = 0
local sc = 1

local enabled = CreateClientConVar( "fradarstd", 0, true, false )

hook.Add( "Think", "FRadar_Think", function()
	veh = math.Approach( veh, LocalPlayer():InVehicle() and 1 or 0, FrameTime() )
	sc = math.Approach( sc, input.IsKeyDown( KEY_MINUS ) and 1 or input.IsKeyDown( KEY_EQUAL ) and 2 or sc, FrameTime()/0.5 )
end )

hook.Add("HUDPaint", "FRadar_HUDPaint", function()
	if !enabled:GetBool() then return end
	local vehl = math.ease.InOutSine( veh )
	local additional = Vector(
		0,
		0,
		Lerp( vehl, 0, 4 )
	)
	FRadar.AssembleRadarRT( 30, Lerp( vehl, 45 * sc, 20 * sc ), Lerp( vehl, 90, 30 ), additional )

	local cool = sc - 1
	local Bx, By, Bb, Bw, Bh = s(20), s(20), s(4), s(Lerp( cool, 128, 128*3 ) ), s(Lerp( cool, 128, 128*3 ) )

	--Bx = Lerp( cool, Bx, ScrW()/2 - Bw/2 )
	--By = Lerp( cool, By, ScrH()/2 - Bh/2 )

	local s = ScreenScaleH
	draw.RoundedBox( Bb, Bx, By, Bw, Bh, cb )

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( FRadar.Mat )
	surface.DrawTexturedRect( Bx + Bb, By + Bb, Bw - Bb - Bb, Bh - Bb - Bb )
	
end)