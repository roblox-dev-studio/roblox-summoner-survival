-- Client-only spell and summon presentation; never awards damage or XP.
return function(deps)
	local Players = game:GetService("Players")
	local RS = game:GetService("ReplicatedStorage")
	local TweenService = game:GetService("TweenService")
	local Debris = game:GetService("Debris")
	local ContentProvider = game:GetService("ContentProvider")
	local Lighting = game:GetService("Lighting")
	local RunService = game:GetService("RunService")
	local player, net, gui = deps.player, deps.net, deps.gui
	local theme = require(script.Parent.Parent:WaitForChild("Theme"))
	local palette, make, label = theme.Palette, theme.Make, theme.Label
	local fx=deps.folder
	if not fx then fx=Instance.new("Folder");fx.Name="SummonerLocalEffects";fx.Parent=workspace end
	local art=require(script.Parent.SpellArt)({folder=fx})
	local areaArt=require(script.Parent.AreaArt)({folder=fx})
	local activeArt=require(script.Parent.ActiveArt)({folder=fx})
	local projectileArt=require(script.Parent.ProjectileArt)({folder=fx})
 local lightArt=require(script.Parent.LightArt)({folder=fx})
 local fireArt=require(script.Parent.FireArt)({folder=fx})
 local lightningArt=require(script.Parent.LightningArt)({folder=fx})
	local bloom=Lighting:FindFirstChild("SummonerSpellBloom")
	if not bloom then
		bloom=Instance.new("BloomEffect");bloom.Name="SummonerSpellBloom";bloom.Intensity=.22;bloom.Size=22;bloom.Threshold=1.35;bloom.Parent=Lighting
	end
	-- Bundled Roblox textures loaded successfully in this project; see ASSET_CREDITS.md.
	local smokeTexture="rbxasset://textures/particles/smoke_main.dds"
	task.spawn(function()
		local ok=pcall(function()
			ContentProvider:PreloadAsync({smokeTexture},function(_,status)
				gui:SetAttribute("SmokeTextureStatus",status.Name)
				if status~=Enum.AssetFetchStatus.Success then smokeTexture="rbxasset://textures/particles/smoke_main.dds" end
			end)
		end)
		if not ok then smokeTexture="rbxasset://textures/particles/smoke_main.dds" end
	end)
	local function visual(size,cf,color,shape,lifetime)
		local p=Instance.new("Part"); p.Size=size; p.CFrame=cf; p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Material=Enum.Material.Neon; p.Color=color
		p.Shape=shape or Enum.PartType.Ball; p.Parent=fx; Debris:AddItem(p,lifetime or 1); return p
	end
	local function ring(pos,radius,color)
		local p=visual(Vector3.new(.12,1,1),CFrame.new(pos.X,.2,pos.Z)*CFrame.Angles(0,0,math.pi/2),color,Enum.PartType.Cylinder)
		p.Transparency=.25
		TweenService:Create(p,TweenInfo.new(.4),{Size=Vector3.new(.12,radius*2,radius*2),Transparency=1}):Play()
	end
	local function dustBurst(point,direction,heavy)
		local host=visual(Vector3.new(.1,.1,.1),CFrame.lookAt(point,point+direction),palette.gold,nil,2)
		host.Name="SlamDust"; host.Transparency=1
		local emitter=Instance.new("ParticleEmitter")
		emitter.Name="ImpactDust"; emitter.Texture=smokeTexture; emitter.Rate=0
		emitter.Lifetime=NumberRange.new(.45,heavy and 1.1 or .7)
		emitter.Speed=NumberRange.new(heavy and 8 or 3,heavy and 15 or 7)
		emitter.EmissionDirection=Enum.NormalId.Front; emitter.SpreadAngle=Vector2.new(25,18)
		emitter.Acceleration=Vector3.new(0,3,0); emitter.Drag=3
		emitter.Rotation=NumberRange.new(0,360); emitter.RotSpeed=NumberRange.new(-70,70)
		emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,heavy and 2.8 or 1.3),NumberSequenceKeypoint.new(.45,heavy and 5 or 2.5),NumberSequenceKeypoint.new(1,heavy and 6.5 or 3)})
		emitter.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.45),NumberSequenceKeypoint.new(.4,.65),NumberSequenceKeypoint.new(1,1)})
		emitter.Color=ColorSequence.new(Color3.fromRGB(181,164,132),Color3.fromRGB(110,122,124))
		emitter.LightEmission=.08; emitter.LightInfluence=.8; emitter.Parent=host
		emitter:Emit(heavy and 5 or 3)
	end
	local function shockwave(pos,radius,color,heavy)
		local count=heavy and 24 or 12
		local center=Vector3.new(pos.X,.19,pos.Z)
		for i=1,count do
			local a=i*math.pi*2/count
			local dir=Vector3.new(math.cos(a),0,math.sin(a))
			local start=center+dir*1.7
			local finish=center+dir*radius
			local p=visual(Vector3.new(.8,.1,.18),CFrame.lookAt(start,start+dir),color,Enum.PartType.Block)
			p.Name="SlamShockwave";p.Transparency=.12
			TweenService:Create(p,TweenInfo.new(heavy and .5 or .32,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=CFrame.lookAt(finish,finish+dir),Size=Vector3.new(math.pi*2*radius/count*.91,.06,.12),Transparency=1}):Play()
		end
	end
	local function chargeGolem(pet,duration)
		if typeof(pet)~="Instance" or not pet.Parent then return end
		for _,name in ipairs({"LeftArm","RightArm"}) do
			local arm=pet:FindFirstChild(name)
			if arm then
				local attachment=Instance.new("Attachment"); attachment.Name="SlamCharge";attachment.Position=Vector3.new(0,-arm.Size.Y*.4,0);attachment.Parent=arm;Debris:AddItem(attachment,duration+1)
				local light=Instance.new("PointLight");light.Color=palette.gold;light.Range=9;light.Brightness=1.5;light.Parent=attachment
				local sparks=Instance.new("ParticleEmitter");sparks.Texture="rbxasset://textures/particles/sparkles_main.dds";sparks.Rate=25;sparks.Lifetime=NumberRange.new(.15,.35);sparks.Speed=NumberRange.new(1,4);sparks.SpreadAngle=Vector2.new(180,180);sparks.Size=NumberSequence.new(.45,0);sparks.Transparency=NumberSequence.new(0,1);sparks.Color=ColorSequence.new(palette.gold,palette.mint);sparks.LightEmission=1;sparks.Parent=attachment
				task.delay(duration,function()if attachment.Parent then sparks.Enabled=false;TweenService:Create(light,TweenInfo.new(.2),{Brightness=0}):Play() end end)
			end
		end
	end
	local function groundImpact(pos,radius,heavy,level)
		local color=heavy and palette.gold or palette.mint
		shockwave(pos,radius,color,heavy)
		if heavy then task.delay(.07,function()shockwave(pos,radius*.72,palette.mint,true)end) end
		local flash=visual(Vector3.new(1,.5,1),CFrame.new(pos.X,.4,pos.Z),color)
		flash.Name="SlamFlash"
		TweenService:Create(flash,TweenInfo.new(.18),{Size=Vector3.new(heavy and 7 or 3,.2,heavy and 7 or 3),Transparency=1}):Play()
		if heavy then
			local light=Instance.new("PointLight");light.Color=color;light.Range=20;light.Brightness=3;light.Parent=flash;TweenService:Create(light,TweenInfo.new(.2),{Brightness=0}):Play()
		end
		for i=1,(heavy and 10 or 4) do
			local a=i*math.pi*2/(heavy and 10 or 4)
			local dir=Vector3.new(math.cos(a),0,math.sin(a))
			dustBurst(Vector3.new(pos.X,.7,pos.Z)+dir*1.5,dir,heavy)
		end
		local count=heavy and 10 or 4
		for i=1,count do
			local a=i*math.pi*2/count
			local dir=Vector3.new(math.cos(a),0,math.sin(a))
			local point=Vector3.new(pos.X,.35,pos.Z)+dir*(heavy and 2.5 or 1.3)
			local size=heavy and 1.25 or .6
			local rock=visual(Vector3.new(size*1.3,size*.7,size),CFrame.new(point)*CFrame.Angles(a,a*.7,a*.3),Color3.fromRGB(105,121,123),Enum.PartType.Block)
			rock.Material=Enum.Material.Slate
			local land=point+dir*radius*.55
			TweenService:Create(rock,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=land+Vector3.new(0,heavy and 3 or 1.4,0)}):Play()
			task.delay(.22,function()
				if rock.Parent then TweenService:Create(rock,TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=land,Transparency=1}):Play() end
			end)
			local midpoint=Vector3.new(pos.X,.12,pos.Z)+dir*radius*.38
			local crack=visual(Vector3.new(heavy and .22 or .12,.05,radius*.55),CFrame.lookAt(midpoint,midpoint+dir),Color3.fromRGB(16,23,25),Enum.PartType.Block)
			crack.Material=Enum.Material.Slate
			TweenService:Create(crack,TweenInfo.new(.8),{Transparency=1}):Play()
		end
		local templates=RS:FindFirstChild("SummonerVFXAssets")
		local spikes=templates and templates:FindFirstChild("GroundSpikes")
		if heavy and spikes and spikes:IsA("MeshPart") then
			local mound=spikes:Clone();mound.Name="SlamGroundSpikes";mound.Size=Vector3.new(radius*.75,3.6,radius*.75);mound.CFrame=CFrame.new(pos.X,-1.8,pos.Z)*CFrame.Angles(0,math.random()*math.pi,0);mound.Color=Color3.fromRGB(74,92,91);mound.Material=Enum.Material.Slate;mound.Transparency=0;mound.Parent=fx;Debris:AddItem(mound,1.8)
			TweenService:Create(mound,TweenInfo.new(.12,Enum.EasingStyle.Back),{Position=Vector3.new(pos.X,.7,pos.Z)}):Play()
			task.delay(.8,function()if mound.Parent then TweenService:Create(mound,TweenInfo.new(.7),{Position=Vector3.new(pos.X,-2.5,pos.Z),Transparency=1}):Play() end end)
		end
		if heavy and level>=3 then
			for i=1,6 do
				local a=i*math.pi/3
				local point=Vector3.new(pos.X,-1,pos.Z)+Vector3.new(math.cos(a),0,math.sin(a))*radius*.75
				local shard=visual(Vector3.new(1.7,3.3,1.7),CFrame.new(point)*CFrame.Angles(.2,a,.2),Color3.fromRGB(100,137,128),Enum.PartType.Block)
				shard.Material=Enum.Material.Slate
				TweenService:Create(shard,TweenInfo.new(.15,Enum.EasingStyle.Back),{Position=point+Vector3.new(0,2.1,0)}):Play()
				task.delay(.4,function() if shard.Parent then TweenService:Create(shard,TweenInfo.new(.4),{Position=point,Transparency=1}):Play() end end)
			end
		end
	end
	local function spellBurst(pos,texture,color,count,size,speed)
		local host=visual(Vector3.new(.1,.1,.1),CFrame.new(pos),color,nil,1.5)
		host.Name="SpellParticles";host.Transparency=1
		local p=Instance.new("ParticleEmitter");p.Texture=texture;p.Rate=0
		p.Color=ColorSequence.new(color,Color3.fromRGB(242,248,255))
		p.Lifetime=NumberRange.new(.2,.6);p.Speed=NumberRange.new(speed*.4,speed)
		p.SpreadAngle=Vector2.new(180,180);p.Drag=3
		p.Size=NumberSequence.new(size,0);p.Transparency=NumberSequence.new(.1,1)
		p.Rotation=NumberRange.new(0,360);p.RotSpeed=NumberRange.new(-90,90)
		p.LightEmission=.8;p.Parent=host;p:Emit(count)
		return host
	end
	local function spellGlow(pos,color,size)
		local host=spellBurst(pos,"rbxasset://textures/particles/forcefield_glow_main.dds",color,1,size,0)
		host.Name="SpellGlow"
		local p=host:FindFirstChildOfClass("ParticleEmitter")
		p.Lifetime=NumberRange.new(.22,.35);p.Size=NumberSequence.new(size,size*1.7);p.Transparency=NumberSequence.new(.35,1);p.LightEmission=1;p:Clear();p:Emit(1)
	end
	local function runeCircle(pos,radius,color,lifetime)
		local center=Vector3.new(pos.X,.16,pos.Z)
		for i=1,16 do
			local a=i*math.pi*2/16
			local dir=Vector3.new(math.cos(a),0,math.sin(a))
			local point=center+dir*radius
			local p=visual(Vector3.new(radius*.32,.055,.07),CFrame.lookAt(point,point+dir),color,Enum.PartType.Block,lifetime+.1)
			p.Name="SpellRune";p.Transparency=.25
			TweenService:Create(p,TweenInfo.new(lifetime),{Transparency=1}):Play()
			if i%4==0 then
				local glyph=visual(Vector3.new(.35,.055,.35),CFrame.new(center+dir*(radius+.6))*CFrame.Angles(0,math.pi/4,0),color,Enum.PartType.Block,lifetime+.1)
				glyph.Name="SpellRune";TweenService:Create(glyph,TweenInfo.new(lifetime),{Transparency=1,Size=Vector3.new(.07,.055,.07)}):Play()
			end
		end
	end
	local fireTexture="rbxasset://textures/particles/fire_main.dds"
	local emberTexture="rbxasset://textures/particles/fire_sparks_main.dds"
	task.spawn(function()
		ContentProvider:PreloadAsync({fireTexture,emberTexture},function(asset,status)
			gui:SetAttribute(asset==fireTexture and "FireTextureStatus" or "EmberTextureStatus",status.Name)
		end)
	end)
	local function flameEmitter(host,core)
		local p=Instance.new("ParticleEmitter");p.Name=core and "FlameHeart" or "FlameTongues";p.Texture=fireTexture
		p.Orientation=Enum.ParticleOrientation.FacingCameraWorldUp
		p.EmissionDirection=Enum.NormalId.Top;p.SpreadAngle=Vector2.new(28,28)
		p.Lifetime=core and NumberRange.new(.18,.32) or NumberRange.new(.32,.55)
		p.Speed=core and NumberRange.new(2,4) or NumberRange.new(4,8)
		p.Acceleration=Vector3.new(0,6,0);p.Drag=1;p.VelocityInheritance=0
		p.Rotation=NumberRange.new(-12,12);p.RotSpeed=NumberRange.new(-25,25)
		p.Color=core and ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,243,170)),ColorSequenceKeypoint.new(.45,Color3.fromRGB(255,193,57)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,93,25))}) or ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,194,49)),ColorSequenceKeypoint.new(.35,Color3.fromRGB(255,104,20)),ColorSequenceKeypoint.new(1,Color3.fromRGB(204,37,25))})
		p.Size=core and NumberSequence.new({NumberSequenceKeypoint.new(0,.6),NumberSequenceKeypoint.new(.25,1.5,.3),NumberSequenceKeypoint.new(1,0)}) or NumberSequence.new({NumberSequenceKeypoint.new(0,1.2,.2),NumberSequenceKeypoint.new(.3,2.7,.5),NumberSequenceKeypoint.new(.65,2.1,.4),NumberSequenceKeypoint.new(1,0)})
		p.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.3),NumberSequenceKeypoint.new(.12,.05),NumberSequenceKeypoint.new(.55,.2),NumberSequenceKeypoint.new(1,1)})
		p.LightEmission=.8;p.LightInfluence=0;p.Rate=core and 24 or 42;p.Parent=host
		return p
	end

	local function magicBolt(a,b,radius)
        fireArt.Bolt(a,b,radius)
    end

	local function dashEffect(character,duration,direction)
		if typeof(character)~="Instance" or not character.Parent then return end
		local root=character:FindFirstChild("HumanoidRootPart");if not root then return end
		local a=Instance.new("Attachment");a.Position=Vector3.new(-.8,0,0);a.Parent=root;Debris:AddItem(a,duration+.4)
		local b=Instance.new("Attachment");b.Position=Vector3.new(.8,0,0);b.Parent=root;Debris:AddItem(b,duration+.4)
		local trail=Instance.new("Trail");trail.Name="DashRibbon";trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=.18;trail.MinLength=.05;trail.Color=ColorSequence.new(Color3.fromRGB(216,251,255),Color3.fromRGB(116,176,255));trail.Transparency=NumberSequence.new(.45,1);trail.WidthScale=NumberSequence.new(1,0);trail.LightEmission=.8;trail.Parent=a
		spellBurst(root.Position,"rbxasset://textures/particles/sparkles_main.dds",Color3.fromRGB(159,223,255),8,.25,5)
		task.spawn(function()
			for frame=1,3 do
				if not character.Parent then break end
				local count=0
				for _,part in ipairs(character:GetDescendants())do
					if part:IsA("BasePart") and part.Name~="HumanoidRootPart" and count<16 then
						local ghost=part:Clone()
						if ghost then
							for _,child in ipairs(ghost:GetChildren())do if not child:IsA("SpecialMesh") then child:Destroy() elseif child:IsA("SpecialMesh") then child.TextureId="" end end
							ghost.Name="ArcaneDashGhost";ghost.Anchored=true;ghost.CanCollide=false;ghost.CanTouch=false;ghost.CanQuery=false;ghost.CastShadow=false;ghost.Color=Color3.fromRGB(139,206,255);ghost.Material=Enum.Material.Neon;ghost.Transparency=.72
							if ghost:IsA("MeshPart") then ghost.TextureID="" end
							ghost.Parent=fx;Debris:AddItem(ghost,.32);TweenService:Create(ghost,TweenInfo.new(.3),{Transparency=1}):Play();count+=1
						end
					end
				end
				task.wait(.065)
			end
		end)
		task.delay(duration,function()if trail.Parent then trail.Enabled=false end end)
	end
	local function iceShard(size,cf,color,lifetime)
		local p=Instance.new("WedgePart");p.Name="IceCrystal";p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.Neon;p.Transparency=.15
		p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=fx;Debris:AddItem(p,lifetime or .7)
		return p
	end
	local function icePortal(cf,charge)
		local portal=Instance.new("Folder");portal.Name="IceCastingCircle";portal.Parent=fx
		local function glyph(size,localCF,color,delay)
			local p=Instance.new("Part");p.Name="FrostSigil";p.Size=size;p.CFrame=cf*localCF;p.Color=color;p.Material=Enum.Material.Neon;p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=portal
			task.delay(delay,function()if p.Parent then TweenService:Create(p,TweenInfo.new(.08),{Transparency=.18}):Play()end end)
		end
		for ring=1,2 do
			local count=ring==1 and 32 or 24
			local radius=ring==1 and 2.45 or 1.85
			for i=1,count do
				local a=(i-1)*math.pi*2/count
				local localCF=CFrame.new(math.cos(a)*radius,math.sin(a)*radius,0)*CFrame.Angles(0,0,a+math.pi/2)
				glyph(Vector3.new(math.pi*2*radius/count*.92,.055,.055),localCF,ring==1 and Color3.fromRGB(117,215,255)or Color3.fromRGB(213,251,255),(i-1)/count*charge*.7+(ring-1)*.05)
			end
		end
		for i=1,6 do
			local a=i*math.pi/3
			glyph(Vector3.new(.27,.27,.055),CFrame.new(math.cos(a)*2.95,math.sin(a)*2.95,0)*CFrame.Angles(0,0,a+math.pi/4),Color3.fromRGB(190,237,255),charge*.55)
		end
		for i=0,2 do glyph(Vector3.new(.055,2.6,.055),CFrame.Angles(0,0,i*math.pi/3),Color3.fromRGB(162,231,255),charge*.3)end
		spellGlow(cf.Position,Color3.fromRGB(134,218,255),2.4)
		return portal
	end
	local function iceProjectile(anchorName,portalCF,charge)
		if typeof(portalCF)~="CFrame" then return end
		local anchor=anchorName
		if type(anchorName)=="string" then
			local runtime=workspace:FindFirstChild("SummonerRuntime")
			anchor=runtime and (runtime:FindFirstChild(anchorName) or runtime:WaitForChild(anchorName,2))
		end
		if typeof(anchor)~="Instance" then return end
		if not anchor or not anchor.Parent then return end
		local portal=icePortal(portalCF,charge)
		local spear=Instance.new("Model");spear.Name="GlacialSpear";spear.Parent=fx
		local initial=anchor.CFrame
		local function piece(class,name,size,offset,color,material,transparency)
			local p=Instance.new(class);p.Name=name;p.Size=size;p.CFrame=initial*offset;p.Color=color;p.Material=material;p.Transparency=transparency;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=spear
			return p
		end
		local pivot=piece("Part","SpearPivot",Vector3.new(.05,.05,.05),CFrame.new(),Color3.new(1,1,1),Enum.Material.SmoothPlastic,1);spear.PrimaryPart=pivot
		-- Each triangular face is split at its altitude into two thin wedges.
		-- A closed diamond cross-section tapers to a real point at both ends.
		local function face(a,b,c,color)
			local ab,ac,bc=b-a,c-a,c-b
			local abd,acd,bcd=ab:Dot(ab),ac:Dot(ac),bc:Dot(bc)
			if abd>acd and abd>bcd then c,a=a,c elseif acd>abd and acd>bcd then a,b=b,a end
			ab,ac,bc=b-a,c-a,c-b
			local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit
			local height=math.abs(ab:Dot(up))
			local function half(v,axis,depth)
				if depth<.005 then return end
				piece("WedgePart","IceSpearFacet",Vector3.new(.025,height,depth),CFrame.fromMatrix((a+v)/2,axis,up,axis==right and back or -back),color,Enum.Material.Glass,.16).Reflectance=.08
			end
			half(b,right,math.abs(ab:Dot(back)));half(c,-right,math.abs(ac:Dot(back)))
		end
		local tip=Vector3.new(0,0,-6.5);local tail=Vector3.new(0,0,1.4)
		local ring={Vector3.new(.9,0,-2.2),Vector3.new(0,.9,-2.2),Vector3.new(-.9,0,-2.2),Vector3.new(0,-.9,-2.2)}
		local function edge(a,b)
			piece("Part","IceSpearRidge",Vector3.new(.045,.045,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),Color3.fromRGB(184,241,255),Enum.Material.Neon,.18)
		end
		for i=1,4 do
			local a,b=ring[i],ring[i%4+1]
			local color=i%2==0 and Color3.fromRGB(173,230,255) or Color3.fromRGB(75,162,230)
			face(tip,a,b,color);face(tail,b,a,color)
			edge(tip,a);edge(tail,a);edge(a,b)
		end
		local left=Instance.new("Attachment");left.Position=Vector3.new(-.6,0,0);left.Parent=pivot
		local right=Instance.new("Attachment");right.Position=Vector3.new(.6,0,0);right.Parent=pivot
		local trail=Instance.new("Trail");trail.Name="GlacialSpearTrail";trail.Attachment0=left;trail.Attachment1=right;trail.Enabled=false;trail.Lifetime=.25;trail.MinLength=.1;trail.Color=ColorSequence.new(Color3.fromRGB(220,252,255),Color3.fromRGB(109,177,255));trail.Transparency=NumberSequence.new(.25,1);trail.WidthScale=NumberSequence.new(.7,0);trail.LightEmission=.8;trail.Parent=pivot
		spear:ScaleTo(.12)
		local scale=Instance.new("NumberValue");scale.Value=.12;scale.Parent=spear
		local scaleConn=scale.Changed:Connect(function(value)if spear.Parent then spear:ScaleTo(value)end end)
		TweenService:Create(scale,TweenInfo.new(charge*.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Value=1}):Play()
		local launched=false
		local renderConn,destroyConn
		local function clear()
			if renderConn then renderConn:Disconnect()end;if destroyConn then destroyConn:Disconnect()end;scaleConn:Disconnect()
			if portal.Parent then portal:Destroy()end;if spear.Parent then spear:Destroy()end
		end
		destroyConn=anchor.Destroying:Connect(clear)
		renderConn=RunService.RenderStepped:Connect(function(dt)
			if not anchor.Parent then clear();return end
			spear:PivotTo(spear:GetPivot():Lerp(anchor.CFrame,1-math.exp(-dt*35)))
			if not launched and anchor:GetAttribute("Launched") then
				launched=true;trail.Enabled=true
				spellBurst(portalCF.Position,"rbxasset://textures/particles/sparkles_main.dds",Color3.fromRGB(191,242,255),14,.3,4)
				for _,p in ipairs(portal:GetChildren())do if p:IsA("BasePart")then TweenService:Create(p,TweenInfo.new(.25),{Transparency=1}):Play()end end
				Debris:AddItem(portal,.3)
			end
		end)
	end
	local function iceImpact(model,pos,duration)
		spellGlow(pos,Color3.fromRGB(145,223,255),4)
		runeCircle(pos,2.8,Color3.fromRGB(133,235,255),.7)
		local mist=spellBurst(pos,smokeTexture,Color3.fromRGB(149,211,240),7,1.5,3)
		local fog=mist:FindFirstChildOfClass("ParticleEmitter");fog.LightEmission=.25;fog.Size=NumberSequence.new(1.2,3.8);fog.Transparency=NumberSequence.new(.7,1)
		spellBurst(pos,"rbxasset://textures/particles/sparkles_main.dds",Color3.fromRGB(200,246,255),22,.4,8)
		shockwave(pos,3.8,Color3.fromRGB(166,238,255),false)
		for i=1,10 do
			local angle=i*math.pi*2/10
			local dir=Vector3.new(math.cos(angle),0,math.sin(angle))
			local p=iceShard(Vector3.new(.35,1.1+(i%3)*.25,.5),CFrame.new(pos+dir*.6)*CFrame.Angles(.2,angle,.3),i%2==0 and Color3.fromRGB(190,251,255) or Color3.fromRGB(109,181,255),.7)
			TweenService:Create(p,TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=pos+dir*3.5+Vector3.new(0,.4,0),Transparency=1}):Play()
		end
		if typeof(model)=="Instance" and model.Parent then
			local old=model:FindFirstChild("SpellFreezeHighlight");if old then old:Destroy() end
			local h=Instance.new("Highlight");h.Name="SpellFreezeHighlight";h.Adornee=model;h.FillColor=Color3.fromRGB(109,207,255);h.OutlineColor=Color3.fromRGB(223,251,255);h.FillTransparency=.42;h.OutlineTransparency=.12;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=model
			local conn,destroyConn
			local function clear()
				if conn then conn:Disconnect() end;if destroyConn then destroyConn:Disconnect() end
				if h.Parent then h:Destroy() end
			end
			conn=model:GetAttributeChangedSignal("Frozen"):Connect(function()if not model:GetAttribute("Frozen") then clear() end end)
			destroyConn=model.Destroying:Connect(clear)
			-- Handles a late event arriving after the replicated frozen state has cleared.
			task.delay(duration+.2,function()if model.Parent and not model:GetAttribute("Frozen") then clear() end end)
		end
	end
	local augmentArt=require(script.Parent.AugmentArt)({folder=fx})
	local generation=0
	local fieldArt=require(script.Parent.Parent.world.FieldBossArt)(fx)
	local function play(kind,a,b,c)
		if not fx.Parent then return end
		if kind=="augmentImpact" then augmentArt.Impact(a,b,c)
        elseif kind=="augmentArc" then augmentArt.Arc(a,b,c)
        elseif kind=="fieldBoss" then fieldArt(a,b,c)
        elseif kind=="hit" then
			local p=visual(Vector3.new(.05,.05,.05),CFrame.new(a+Vector3.new(0,3,0)),palette.text); p.Transparency=1
			local billboard=make("BillboardGui",p,{Size=UDim2.fromOffset(70,32),AlwaysOnTop=true,Adornee=p})
			local number=label(billboard,tostring(b),UDim2.fromScale(1,1),nil,Enum.Font.GothamBold,palette.gold); number.TextSize=18
			TweenService:Create(p,TweenInfo.new(.55),{Position=p.Position+Vector3.new(0,2,0)}):Play(); TweenService:Create(number,TweenInfo.new(.55),{TextTransparency=1}):Play()
		elseif kind=="dragonSlam" then art.Slam(a,b)
        elseif kind=="dragonTailSpin" then art.TailSpin(a,b,c)
        elseif kind=="dragonFireLine" then fireArt.FireLine(a,b,c)
        elseif kind=="dragonCharge" then fireArt.Charge(a,b)
        elseif kind=="dragonBreath" then fireArt.Breath(a,b,c)
        elseif kind=="dragonAirBreath" then fireArt.AirBreath(a,b,c)
        elseif kind=="dragonEruption" then art.Rupture(a,b,false)
        elseif kind=="enemyExplosion" then art.Rupture(a,b,true)
        elseif kind=="dragonDive" then art.Dive(a,b)
        elseif kind=="dragonArrival" then art.Rupture(a,b,false)
        elseif kind=="golemCharge" then chargeGolem(a,b)
		elseif kind=="golemHeavy" or kind=="golemLight" then groundImpact(a,b,kind=="golemHeavy",c)
		elseif kind=="dash" then dashEffect(a,b,c)
		elseif kind=="fire" then magicBolt(a,b,c)
		elseif kind=="fireProjectile" then fireArt.Projectile(a);augmentArt.Cast(a,"fire")
		elseif kind=="lightning" then
			local epoch=generation;task.delay(math.min(.3,math.max(0,(c or 1)-1)*.045),function()if epoch==generation and fx.Parent then lightningArt.Strike(a,b,c)end end)
		elseif kind=="lightCast" then lightArt.Cast(a,b);augmentArt.Cast(a,b)
		elseif kind=="lightHit" then lightArt.Hit(a,b)
		elseif kind=="basicBolt" then lightArt.Bolt(a)
		elseif kind=="basicHit" then lightArt.Hit(a,"basic")
		elseif kind=="thunderSpear" then projectileArt.Cast(a,"thunder");augmentArt.Cast(a,"thunder")
		elseif kind=="aetherSpear" then projectileArt.Cast(a,"aetherLance");augmentArt.Cast(a,"aetherLance")
		elseif kind=="aetherHit" then projectileArt.Impact(a,"aetherLance")
		elseif kind=="crystalBolt" then projectileArt.Cast(a,"crystal");augmentArt.Cast(a,"blades","bolt")
		elseif kind=="skyLanceHit" then areaArt.Burst(a,b,Color3.fromRGB(157,204,255))
		elseif kind=="crystalHit" then projectileArt.Impact(a,"crystal")
		elseif kind=="homingMissile" then projectileArt.Cast(a,"missile");augmentArt.Cast(a,"missile")
		elseif kind=="thunderHit" then projectileArt.Impact(a,"thunder")
		elseif kind=="missileHit" then projectileArt.Impact(a,"missile")
		elseif kind=="activeCast" then activeArt.Charge(a,b)
		elseif kind=="activeStrike" then activeArt.Strike(a,b,c);if c and c.kind=="iceRush"and(c.width or 0)>6 then augmentArt.Corridor(a,b,c.range,c.width)end
		elseif kind=="areaCast" then areaArt.Cast(a,b);augmentArt.Cast(a,b,"aura")
		elseif kind=="augmentPulse" then augmentArt.Impact(a,b,{ids="ward_pulse",phase="hit"})
        elseif kind=="augmentFireHit" then art.Rupture(a,b,false)
        elseif kind=="meteorHit" then art.Rupture(a,b,false);areaArt.MeteorImpact(a,b)
		elseif kind=="frostHit" then areaArt.FrostImpact(a,b)
		elseif kind=="wardHit" then areaArt.Burst(a,b and 5 or 2.5,Color3.fromRGB(255,222,152))
		elseif kind=="iceCast" then iceProjectile(a,b,c);augmentArt.Cast(a,"ice")
		elseif kind=="iceHit" then iceImpact(a,b,c)
		end
	end
	local connection
	if deps.listen~=false then connection=net.Effect.OnClientEvent:Connect(play) end

	return {
		Folder = fx,
        Clear = function()generation+=1;augmentArt.Clear()end,
        AugmentStats = augmentArt.Stats,
		Play = play,
		Disconnect = function()generation+=1;augmentArt.Clear();if connection then connection:Disconnect();connection=nil end end,
	}
end
