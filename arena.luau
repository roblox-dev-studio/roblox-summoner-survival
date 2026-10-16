-- Run in Studio edit mode. Only creates the prototype's own arena.
local Lighting = game:GetService("Lighting")
local arena = Instance.new("Folder")
arena.Name = "SummonerArena"
local function part(name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Anchored = true
	p.Color = color
	p.Material = material or Enum.Material.Slate
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = arena
	return p
end
local floor = part("ArenaFloor", Vector3.new(186, 3, 186), CFrame.new(0,-1.5,0), Color3.fromRGB(38,51,55))
local base = workspace:FindFirstChild("Baseplate")
if base then base.Transparency = 1; base.CanCollide = false end
local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
if spawn then spawn.Position=Vector3.new(0,0.5,0); spawn.Transparency=1; spawn.CanCollide=false; spawn.Neutral=true; spawn.Duration=0 end
for i=1,48 do
	local a=i*math.pi*2/48
	local cf=CFrame.new(math.cos(a)*88, 2.5, math.sin(a)*88)*CFrame.Angles(0,-a,0)
	part("BoundaryStone",Vector3.new(6,5+(i%3),5),cf,Color3.fromRGB(51,65,69))
	if i%4==0 then
		local p=part("RuneLantern",Vector3.new(1.5,1.5,1.5),cf*CFrame.new(0,4,0),Color3.fromRGB(72,232,205),Enum.Material.Neon)
		p.CanCollide=false
		local light=Instance.new("PointLight"); light.Color=p.Color; light.Range=18; light.Brightness=1.3; light.Parent=p
	end
end
for i=1,40 do
	local a=i*math.pi*2/40
	local p=part("SummoningCircle",Vector3.new(2.4,0.04,0.16),CFrame.new(math.cos(a)*10,0.035,math.sin(a)*10)*CFrame.Angles(0,-a-math.pi/2,0),Color3.fromRGB(64,133,127),Enum.Material.Neon)
	p.CanCollide=false
end
for i=1,28 do
	local a=i*2.39996; local radius=24+(i%6)*9
	local p=part("OldPaving",Vector3.new(5+i%3,0.06,4),CFrame.new(math.cos(a)*radius,0.04,math.sin(a)*radius)*CFrame.Angles(0,a,0),Color3.fromRGB(46,61,64))
	p.CanCollide=false
end
for _,edge in ipairs({{0,94,190,4},{0,-94,190,4},{94,0,4,190},{-94,0,4,190}}) do
	local p=part("InvisibleBoundary",Vector3.new(edge[3],30,edge[4]),CFrame.new(edge[1],12,edge[2]),Color3.new())
	p.Transparency=1
end
arena.Parent=workspace
Lighting.ClockTime=14.5
Lighting.Brightness=2
Lighting.Ambient=Color3.fromRGB(135,151,166)
Lighting.OutdoorAmbient=Color3.fromRGB(145,163,175)
Lighting.FogColor=Color3.fromRGB(44,65,75)
Lighting.FogStart=140; Lighting.FogEnd=350
local atmosphere=Instance.new("Atmosphere")
atmosphere.Density=0.22; atmosphere.Color=Color3.fromRGB(164,191,191); atmosphere.Decay=Color3.fromRGB(62,82,99); atmosphere.Parent=Lighting
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(0,95,80),Vector3.new(0,0,0))
return "SummonerArena created"
