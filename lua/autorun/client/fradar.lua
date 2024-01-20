local mat = Material("fradar/rp_saemchet_radar.png", "smooth")
local ms, mx, my = 8.63, -5632, 4992

local s = ScreenScaleH
local cb = Color( 0, 0, 0, 200 )
local Col = Color( 0, 0, 0 )

-- Give the RT a size
local TEX_SIZE = 512

-- Create the RT
local tex = GetRenderTarget( "RadarRT", TEX_SIZE, TEX_SIZE )

local myMat = CreateMaterial( "RadarRTMat", "UnlitGeneric", {
	["$basetexture"] = tex:GetName(), -- Make the material use our render target texture
	["$translucent"] = 1,
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
} )

local veh = 0
local sc = 1

hook.Add( "Think", "FRadar_Think", function()
	veh = math.Approach( veh, LocalPlayer():InVehicle() and 1 or 0, FrameTime() )
	sc = math.Approach( sc, input.IsKeyDown( KEY_MINUS ) and 1 or input.IsKeyDown( KEY_EQUAL ) and 2 or sc, FrameTime() / 0.5 )
	--fovdesire = math.Approach( fovdesire, LocalPlayer():InVehicle() and 30 or 90, FrameTime()*45*1.33 )
	--tiltdesire = math.Approach( tiltdesire, LocalPlayer():InVehicle() and 30 or 90, FrameTime()*90*1.33 )
end )
	
hook.Add("HUDPaint", "FRadar_HUDPaint", function()
	local size = 64
	local dist = 30
	render.PushRenderTarget( tex )
	render.OverrideAlphaWriteEnable( true, true )

	local vehl = math.ease.InOutSine( veh )

	local angles = Angle( Lerp( vehl, 90, 30 ), EyeAngles().y-90, 0 )
	local norigin = -angles:Forward()*dist
	norigin:Add( angles:Up() * Lerp( vehl, 4, 4 ) * sc )
	cam.Start( {
		x = 0,
		y = 0,
		w = TEX_SIZE,
		h = TEX_SIZE,
		origin = norigin,
		angles = angles,
		aspect = 1,
		fov = Lerp( vehl, 45 * sc, 20 * sc ),
	} )
		
	render.ClearDepth()
	render.Clear( 0, 0, 0, 0 )
	local vec = Vector()
	vec.x = -(LocalPlayer():EyePos().y - my) / (ms * 1024) * size
	vec.y = (LocalPlayer():EyePos().x - mx) / (ms * 1024) * size

	vec.x = vec.x - (size/2)
	vec.y = vec.y - (size/2)

	vec.z = 0
	--vec.z = vec.z - 64+8

	local ang = Angle( 0, 0 or EyeAngles().y, 0 )
	--vec = vec + ang:Forward()*32
	
	render.SetMaterial( mat )
	render.DrawQuadEasy( vec, vector_up, size, size, color_white, ang.y )

	for i, ent in ents.Iterator() do
		local rs = (size/64)
		if ent:IsPlayer() then
			Col.r = 120
			Col.g = 120
			Col.b = 255
			rs = rs * 4
		elseif ent:IsNPC() or ent:IsNextBot() then
			Col.r = 120
			Col.g = 170
			Col.b = 120
			rs = rs * 2
		--elseif ent:IsVehicle() then
		--	Col.r = 170
		--	Col.g = 170
		--	Col.b = 120
		--	rs = rs * 0
		else
			continue
		end
		local nvec = Vector( vec )

		local cx = 0
		local cy = 0
		
		cx = cx - (size/2)
		cy = cy + (size/2)

		cx = cx + (ent:GetPos().x - mx) / (ms * 1024) * size
		cy = cy + (ent:GetPos().y - my) / (ms * 1024) * size

		nvec = nvec + ang:Right() * cx
		nvec = nvec + ang:Forward() * cy

		local ct = CurTime()
		ct = math.sin( ct*30*math.pi )*1
		ct = math.max( 1, ct )

		local eang = Angle( 0, ent:GetAngles().y + ang.y - 90, 0 )

		render.SetMaterial( Material("vgui/circle") )
		render.DrawQuadEasy( nvec, vector_up, ct, ct, Col, 0 )

		render.SetMaterial( Material("vgui/gradient-d") )
		render.DrawQuad( nvec + (eang:Forward() * rs) +  (eang:Right() * -rs), nvec + (eang:Forward() * rs) +  (eang:Right() * rs), nvec, nvec, Col )

		
	end
	cam.End()
	render.OverrideAlphaWriteEnable( false )
	render.PopRenderTarget()

	local Bx, By, Bb, Bw, Bh = s(20), s(20), s(4), s(128 * sc), s(128 * sc)

	local s = ScreenScaleH
	draw.RoundedBox( Bb, Bx, By, Bw, Bh, cb )

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( myMat )
	surface.DrawTexturedRect( Bx + Bb, By + Bb, Bw - Bb - Bb, Bh - Bb - Bb )
	
end)