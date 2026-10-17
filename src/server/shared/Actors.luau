-- Procedural actor geometry; shared by enemies and summons.
return function(deps)
	local world = deps.world
	local function block(parent, name, size, pos, color, material)
		local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=CFrame.new(pos)
		p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false
		p.Color=color; p.Material=material or Enum.Material.SmoothPlastic; p.Parent=parent
		return p
	end
	local createEnemy=require(script.Parent.EnemyModels)({block=block})
	local function creature(name, color, golem, kind)
        if not golem then return createEnemy(name,kind or "stalker",world) end
		local m=Instance.new("Model"); m.Name=name
		local size=golem and 1.2 or 0.85
		local root=block(m,"Core",Vector3.new(2.6,2.5,1.8)*size,Vector3.new(0,3,0),color,Enum.Material.Slate)
		m.PrimaryPart=root
		block(m,"Head",Vector3.new(1.9,1.5,1.6)*size,Vector3.new(0,5.1*size,0),color,Enum.Material.Slate)
		for _,side in ipairs({-1,1}) do
			block(m,golem and (side==-1 and "LeftArm" or "RightArm") or "Arm",Vector3.new(1,2.5,1.2)*size,Vector3.new(side*1.9*size,2.8*size,0),color,Enum.Material.Slate)
			block(m,"Leg",Vector3.new(1,1.8,1.3)*size,Vector3.new(side*.72*size,.9*size,0),color,Enum.Material.Slate)
			block(m,"Eye",Vector3.new(.3,.25,.12),Vector3.new(side*.45*size,5.25*size,-.85*size),golem and Color3.fromRGB(96,255,222) or Color3.fromRGB(255,112,115),Enum.Material.Neon)
		end
		block(m,"Rune",Vector3.new(.65,.8,.12),Vector3.new(0,3*size,-.96*size),golem and Color3.fromRGB(96,255,222) or Color3.fromRGB(215,70,104),Enum.Material.Neon)
		m.Parent=world
		return m
	end

	return {
		Block = block,
		Create = creature,
	}
end
