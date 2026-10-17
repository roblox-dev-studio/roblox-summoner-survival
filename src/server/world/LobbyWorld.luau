-- Reproducible waiting sanctuary, separate from the combat runtime.
return function()
 local old=workspace:FindFirstChild('SummonerLobby');if old then old:Destroy()end
 local folder=Instance.new('Folder');folder.Name='SummonerLobby';folder.Parent=workspace
 local function part(name,size,cf,color,material,shape)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.Slate;p.Shape=shape or Enum.PartType.Block;p.Anchored=true;p.Parent=folder;return p
 end
 local stone=Color3.fromRGB(39,49,72);local mint=Color3.fromRGB(91,244,216)
 part('Sanctuary',Vector3.new(3,68,68),CFrame.new(0,-1.5,150)*CFrame.Angles(0,0,math.pi/2),stone,nil,Enum.PartType.Cylinder)
 part('Dais',Vector3.new(.4,22,22),CFrame.new(0,.2,150)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(57,64,90),nil,Enum.PartType.Cylinder)
 for i=1,40 do
  local a=i*math.pi/20
  local p=part('RunicInlay',Vector3.new(2,.08,.17),CFrame.new(math.cos(a)*10,.44,150+math.sin(a)*10)*CFrame.Angles(0,-a-math.pi/2,0),mint,Enum.Material.Neon);p.CanCollide=false
 end
 for i=1,8 do
  local a=i*math.pi/4;local pos=Vector3.new(math.cos(a)*27,0,150+math.sin(a)*27)
  part('Obelisk',Vector3.new(3,9,3),CFrame.new(pos+Vector3.new(0,4.5,0)),stone)
  local p=part('SpellCrystal',Vector3.new(2,3.5,2),CFrame.new(pos+Vector3.new(0,11,0))*CFrame.Angles(0,math.pi/4,.3),i%2==0 and mint or Color3.fromRGB(188,151,255),Enum.Material.Neon);p.CanCollide=false
  local light=Instance.new('PointLight');light.Color=p.Color;light.Range=18;light.Brightness=1.5;light.Parent=p
 end
 for i=1,24 do
  local a=i*math.pi/12
  local p=part('PortalArc',Vector3.new(1.7,1.7,1.1),CFrame.new(math.cos(a)*8,9+math.sin(a)*8,127)*CFrame.Angles(0,0,a),i%3==0 and mint or stone, i%3==0 and Enum.Material.Neon or Enum.Material.Slate);p.CanCollide=false
 end
 return CFrame.new(0,4,150)*CFrame.Angles(0,math.pi,0)
end
