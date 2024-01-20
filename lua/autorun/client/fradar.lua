FRadar = {}

local mat = Material("fradar/rp_saemchet_radar.png", "smooth")
local ms, mx, my = 8.63, -5632, 4992

local Col = Color( 0, 0, 0 )

-- Create the RT
local TEX_SIZE = 512
local tex = GetRenderTarget( "RadarRT", TEX_SIZE, TEX_SIZE )

FRadar.Mat = CreateMaterial( "RadarRTMat", "UnlitGeneric", {
	["$basetexture"] = tex:GetName(), -- Make the material use our render target texture
	["$translucent"] = 1,
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
} )

local mat_c = Material("vgui/circle")
local mat_g = Material("vgui/gradient-d")
function FRadar.AssembleRadarRT( height, fov, tilt, additional, aspect )
	local size = 64
	render.PushRenderTarget( tex )
	render.OverrideAlphaWriteEnable( true, true )

	local angles = Angle( tilt, EyeAngles().y-90, 0 )
	local norigin = -angles:Forward()*height
	if additional then
		norigin:Add( angles:Right() * additional.x )
		norigin:Add( angles:Forward() * additional.y )
		norigin:Add( angles:Up() * additional.z )
	end
	cam.Start( {
		x = 0,
		y = 0,
		w = TEX_SIZE,
		h = TEX_SIZE,
		origin = norigin,
		angles = angles,
		aspect = aspect or 1,
		fov = fov,
	} )
		
	render.ClearDepth()
	render.Clear( 0, 0, 0, 255 )
	local vec = Vector()
	vec.x = -(LocalPlayer():EyePos().y - my) / (ms * 1024) * size
	vec.y = (LocalPlayer():EyePos().x - mx) / (ms * 1024) * size

	vec.x = vec.x - (size/2)
	vec.y = vec.y - (size/2)
	vec.z = 0

	local ang = Angle( 0, 0 or EyeAngles().y, 0 )
	
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
end