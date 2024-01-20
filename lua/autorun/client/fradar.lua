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

local mat_c = Material("vgui/circle")
local mat_g = Material("vgui/gradient-d")

hook.Add( "Think", "FRadar_Think", function()
	veh = math.Approach( veh, LocalPlayer():InVehicle() and 1 or 0, FrameTime() )
	sc = math.Approach( sc, input.IsKeyDown( KEY_MINUS ) and 1 or input.IsKeyDown( KEY_EQUAL ) and 2 or sc, FrameTime()/0.5 )
	--fovdesire = math.Approach( fovdesire, LocalPlayer():InVehicle() and 30 or 90, FrameTime()*45*1.33 )
	--tiltdesire = math.Approach( tiltdesire, LocalPlayer():InVehicle() and 30 or 90, FrameTime()*90*1.33 )
end )

surface.CreateFont("TEST-1", {
	font = "Arial",
	size = 48,
})
	
hook.Add("HUDPaint", "FRadar_HUDPaint", function()
	local size = 64
	local dist = 30
	render.PushRenderTarget( tex )
	render.OverrideAlphaWriteEnable( true, true )

	local vehl = math.ease.InOutSine( veh )

	local angles = Angle( Lerp( vehl, 90, 30 ), EyeAngles().y-90, 0 )
	local norigin = -angles:Forward()*dist
	norigin:Add( angles:Up() * Lerp( vehl, 0, 4 ) * sc )
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
		local mat
		if ent:IsPlayer() then
			if ent == LocalPlayer() then
				Col.r = 120
				Col.g = 120
				Col.b = 255
				rs = rs * 4
			else
				Col.r = 120
				Col.g = 150
				Col.b = 120
				rs = rs * 2
			end
			mat = Material("icon16/status_offline.png")
		elseif ent:IsNPC() or ent:IsNextBot() then
			Col.r = 120
			Col.g = 170
			Col.b = 120
			rs = rs * 2
		elseif ent:IsVehicle() then
			if ent:GetClass() == "prop_vehicle_prisoner_pod" then continue end
			Col.r = 170
			Col.g = 170
			Col.b = 120
			rs = rs * 0
			mat = Material("icon16/car.png")
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

		local ct = 4

		local eang = Angle( 0, (ent.InVehicle and ent:InVehicle() and ent:GetAngles() or ent:EyeAngles()).y + ang.y - 90, 0 )
		local e_f, e_r = eang:Forward(), eang:Right()

		Col.a = 255
		render.SetMaterial( mat_g )
		render.DrawQuad(
			nvec + (e_f * rs) + (e_r * -rs),
			nvec + (e_f * rs) + (e_r * rs),
			nvec,
			nvec,
			Col )
		Col.a = 255

		-- Icon always should look at the viewer
		eang.y = angles.y-180
		e_f, e_r = eang:Forward(), eang:Right()

		render.SetMaterial( mat or mat_c )
		render.DrawQuad(
			nvec - e_f + e_r,
			nvec - e_f - e_r,
			nvec + e_f - e_r,
			nvec + e_f + e_r,
			Col )
	end
	cam.End()
	render.OverrideAlphaWriteEnable( false )
	render.PopRenderTarget()

	local cool = sc - 1
	local Bx, By, Bb, Bw, Bh = s(20), s(20), s(4), s(Lerp( cool, 128, 128*3 ) ), s(Lerp( cool, 128, 128*3 ) )

	--Bx = Lerp( cool, Bx, ScrW()/2 - Bw/2 )
	--By = Lerp( cool, By, ScrH()/2 - Bh/2 )

	local s = ScreenScaleH
	draw.RoundedBox( Bb, Bx, By, Bw, Bh, cb )

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( myMat )
	surface.DrawTexturedRect( Bx + Bb, By + Bb, Bw - Bb - Bb, Bh - Bb - Bb )
	
end)