-- Original native-part academy sanctuary. Rebuilt from source; no uploaded assets.
-- Only Architecture collides. Decor/Interactions never enter the combat runtime.
return function()
 local old=workspace:FindFirstChild('SummonerLobby');if old then old:Destroy()end
 local hub=Instance.new('Folder');hub.Name='SummonerLobby';hub:SetAttribute('LobbyStyle','AstralAcademy');hub.Parent=workspace
 local architecture=Instance.new('Folder');architecture.Name='Architecture';architecture.Parent=hub
 local decor=Instance.new('Folder');decor.Name='Decor';decor.Parent=hub
 local interactions=Instance.new('Folder');interactions.Name='Interactions';interactions.Parent=hub
 local center=Vector3.new(0,0,178)
 local c={stone=Color3.fromRGB(58,66,83),pale=Color3.fromRGB(118,126,139),dark=Color3.fromRGB(32,40,57),gold=Color3.fromRGB(171,140,83),mint=Color3.fromRGB(113,195,183),violet=Color3.fromRGB(149,135,189),wood=Color3.fromRGB(92,67,56),text=Color3.fromRGB(232,230,209)}
 local function piece(parent,name,size,frame,color,material,shape)
  local p=Instance.new(shape=='wedge'and'WedgePart'or'Part');p.Name=name;p.Size=size;p.CFrame=frame;p.Color=color;p.Material=material or Enum.Material.Slate
  if shape and shape~='wedge'then p.Shape=shape end
  p.Anchored=true;p.CanCollide=parent==architecture;p.CanTouch=false;p.CanQuery=parent==architecture;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
 end
 local function block(parent,name,size,frame,color,material)return piece(parent,name,size,frame,color,material)end
 local function disc(parent,name,radius,height,frame,color,material)
  return piece(parent,name,Vector3.new(height,radius*2,radius*2),frame*CFrame.Angles(0,0,math.pi/2),color,material,Enum.PartType.Cylinder)
 end
 local function ring(name,frame,radius,width,count,color,material)
  for i=1,count do
   local a=(i-.5)*math.pi*2/count
   block(decor,name,Vector3.new(width,.07,math.pi*radius*2/count*.84),frame*CFrame.new(math.cos(a)*radius,0,math.sin(a)*radius)*CFrame.Angles(0,-a,0),color,material or Enum.Material.Metal)
  end
 end
 local function column(frame,height)
  disc(architecture,'ColumnFoot',1.12,.35,frame*CFrame.new(0,.175,0),c.pale)
  disc(architecture,'ColumnBase',.84,.55,frame*CFrame.new(0,.62,0),c.stone)
  disc(architecture,'FlutedColumn',.58,height-1.7,frame*CFrame.new(0,height*.5,0),c.pale,Enum.Material.Marble)
  disc(decor,'ColumnCollar',.7,.16,frame*CFrame.new(0,1.3,0),c.gold,Enum.Material.Metal)
  disc(decor,'ColumnCollar',.7,.16,frame*CFrame.new(0,height-.8,0),c.gold,Enum.Material.Metal)
  disc(architecture,'ColumnCapital',.95,.45,frame*CFrame.new(0,height-.225,0),c.stone)
 end
 local function arch(name,frame,radius,depth,color)
  local count=18
  for i=0,count do
   local a=i*math.pi/count
   block(decor,name,Vector3.new(.88,radius*math.pi/count*.96,depth),frame*CFrame.new(math.cos(a)*radius,math.sin(a)*radius,0)*CFrame.Angles(0,0,a),color)
  end
 end
 local function label(anchor,title,subtitle,accent)
  local gui=Instance.new('BillboardGui');gui.Name='LandmarkTitle';gui.Size=UDim2.fromOffset(250,68);gui.MaxDistance=85;gui.AlwaysOnTop=false;gui.Parent=anchor
  local titleLabel=Instance.new('TextLabel');titleLabel.Name='Title';titleLabel.Size=UDim2.fromScale(1,.55);titleLabel.BackgroundTransparency=1;titleLabel.Font=Enum.Font.GothamBold;titleLabel.TextSize=22;titleLabel.TextColor3=c.text;titleLabel.TextStrokeColor3=c.dark;titleLabel.TextStrokeTransparency=.2;titleLabel.Text=title;titleLabel.Parent=gui
  local sub=titleLabel:Clone();sub.Name='Subtitle';sub.Position=UDim2.fromScale(0,.58);sub.Size=UDim2.fromScale(1,.4);sub.TextSize=14;sub.TextColor3=accent;sub.Text=subtitle;sub.Parent=gui
 end
 local function marker(name,frame,title,subtitle,accent)
  local p=block(decor,name,Vector3.new(.2,.2,.2),frame,c.dark);p.Transparency=1;label(p,title,subtitle,accent)
 end
 local function entrance(action,frame,title)
  local anchor=block(interactions,'Entrance_'..action,Vector3.new(1,1,1),frame*CFrame.new(0,3,0),c.dark);anchor.Transparency=1;anchor:SetAttribute('LobbyHubAction',action)
  local prompt=Instance.new('ProximityPrompt');prompt.Name='Open_'..action;prompt.ActionText=action=='loadout'and'출전 준비'or'살펴보기';prompt.ObjectText=title;prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.HoldDuration=0;prompt.MaxActivationDistance=10;prompt.RequiresLineOfSight=false;prompt:SetAttribute('LobbyHubAction',action);prompt.Parent=anchor
 end
 local function station(action,point,title,subtitle,accent)
  local frame=CFrame.lookAt(point,Vector3.new(center.X,point.Y,center.Z))
  disc(architecture,'StationStep_'..action,13,.22,frame*CFrame.new(0,.11,0),c.dark)
  disc(architecture,'StationStep_'..action,12,.24,frame*CFrame.new(0,.34,0),c.stone)
  disc(architecture,'StationFloor_'..action,10.8,.25,frame*CFrame.new(0,.585,0),c.pale)
  ring('StationBrassBorder',frame*CFrame.new(0,.73,0),10.1,.13,28,c.gold)
  entrance(action,frame*CFrame.new(0,0,-7.8),title)
  marker('Sign_'..action,frame*CFrame.new(0,12,-1),title,subtitle,accent)
  return frame
 end
 local function lantern(frame,accent)
  disc(architecture,'LanternFoot',.65,.3,frame*CFrame.new(0,.15,0),c.stone)
  disc(decor,'LanternPost',.11,3.5,frame*CFrame.new(0,1.9,0),c.gold,Enum.Material.Metal)
  disc(decor,'LanternShade',.65,.2,frame*CFrame.new(0,3.8,0),c.dark,Enum.Material.Metal)
  local bulb=piece(decor,'LanternPearl',Vector3.one*.58,frame*CFrame.new(0,3.5,0),accent,Enum.Material.Neon,Enum.PartType.Ball)
  local light=Instance.new('PointLight');light.Color=accent;light.Range=15;light.Brightness=.6;light.Shadows=false;light.Parent=bulb
 end
 -- Continuous terrace and low curved guard rail keep the walkable area readable.
 disc(architecture,'SanctuaryFoundation',56,3,CFrame.new(center+Vector3.new(0,-1.5,0)),c.dark)
 disc(architecture,'AcademyCourtyard',55,.16,CFrame.new(center+Vector3.new(0,.08,0)),c.stone)
 ring('TerraceTrim',CFrame.new(center+Vector3.new(0,.18,0)),53.8,.22,64,c.gold)
 for i=1,40 do
  local a=i*math.pi*2/40
  local frame=CFrame.new(center+Vector3.new(math.cos(a)*54.8,0,math.sin(a)*54.8))*CFrame.Angles(0,-a,0)
  block(architecture,'TerraceGuard',Vector3.new(.9,3.5,8.7),frame*CFrame.new(0,1.75,0),c.stone)
  if i%5==0 then column(frame,5.5)end
 end
 disc(architecture,'ArrivalMedallion',12,.2,CFrame.new(center+Vector3.new(0,.26,0)),c.pale)
 ring('ArrivalCompass',CFrame.new(center+Vector3.new(0,.38,0)),10.7,.16,32,c.gold)
 for i=1,8 do
  local a=i*math.pi/4
  piece(decor,'CompassPetal',Vector3.new(.55,.08,3.8),CFrame.new(center+Vector3.new(math.sin(a)*5,.38,math.cos(a)*5))*CFrame.Angles(0,a,0),c.dark,nil,'wedge')
 end
 local points={Vector3.new(0,0,151),Vector3.new(-34,0,177),Vector3.new(34,0,177),Vector3.new(0,0,214)}
 for _,point in ipairs(points)do
  local direction=(point-center).Unit
  for distance=13,(point-center).Magnitude-9,3.4 do
   local p=center+direction*distance
   block(decor,'RadialPath',Vector3.new(7,.06,2.85),CFrame.lookAt(p+Vector3.new(0,.2,0),p+direction),Color3.fromRGB(82,91,106))
   for _,side in ipairs({-1,1})do block(decor,'PathEdge',Vector3.new(.12,.07,2.5),CFrame.lookAt(p+Vector3.new(0,.24,0),p+direction)*CFrame.new(side*3.8,0,0),c.gold,Enum.Material.Metal)end
  end
 end
 -- Departure gate: open walk-through arch, concentric stone/brass layers, small runes.
 local portal=CFrame.new(points[1])*CFrame.Angles(0,math.pi,0)
 for step=1,3 do block(architecture,'PortalStep',Vector3.new(19-step*2,.2,9-step),portal*CFrame.new(0,step*.2-.1,0),step==3 and c.pale or c.stone)end
 for _,side in ipairs({-1,1})do column(portal*CFrame.new(side*7,0,2),7.5)end
 arch('PortalVoussoir',portal*CFrame.new(0,7.1,2),7.1,1.9,c.pale)
 arch('PortalInnerBrass',portal*CFrame.new(0,7.1,1.88),6.25,.28,c.gold)
 for i=1,11 do
  local a=i*math.pi/12
  block(decor,'PortalRune',Vector3.new(.12,.44,.08),portal*CFrame.new(math.cos(a)*6.65,7.1+math.sin(a)*6.65,1.01)*CFrame.Angles(0,0,a),c.mint,Enum.Material.Neon)
 end
 ring('DepartureCircle',portal*CFrame.new(0,.63,-1),4,.15,24,c.mint,Enum.Material.Metal)
 entrance('loadout',portal*CFrame.new(0,0,-3),'출전의 문')
 marker('Sign_loadout',portal*CFrame.new(0,16,1),'출전의 문','마법을 준비하고 전장으로',c.mint)
 -- Shop: a curved counter under a stone arcade, books, scrolls, potion bottles.
 local shop=station('shop',points[2],'별빛 교역소','상점 · 준비 중',Color3.fromRGB(218,181,119))
 for _,side in ipairs({-1,1})do column(shop*CFrame.new(side*7.6,.71,4),8.3)end
 arch('ShopArcade',shop*CFrame.new(0,8.8,4),7.6,1.4,c.stone)
 disc(architecture,'ShopCounterFoot',4.5,1.9,shop*CFrame.new(0,1.65,1.6),c.dark)
 disc(architecture,'ShopCounterTop',4.8,.35,shop*CFrame.new(0,2.77,1.6),c.wood,Enum.Material.Wood)
 for i=1,5 do
  local x=(i-3)*1.28;local color=i%2==0 and c.violet or c.mint
  piece(decor,'PotionBottle',Vector3.new(.55,.85,.55),shop*CFrame.new(x,3.36,1.2+math.abs(x)*.18),color,Enum.Material.Glass,Enum.PartType.Ball)
  disc(decor,'PotionNeck',.12,.3,shop*CFrame.new(x,3.89,1.2+math.abs(x)*.18),color,Enum.Material.Glass)
  disc(decor,'PotionStopper',.15,.16,shop*CFrame.new(x,4.11,1.2+math.abs(x)*.18),c.gold,Enum.Material.Wood)
 end
 for _,side in ipairs({-1,1})do
  local stand=shop*CFrame.new(side*6,1.4,1.8)
  disc(architecture,'BookStand',1.2,1.4,stand,c.dark)
  local book=shop*CFrame.new(side*6,2.4,1.8)*CFrame.Angles(math.rad(24),0,0)
  for _,page in ipairs({-1,1})do
   block(decor,'BookCover',Vector3.new(1.1,.12,1.7),book*CFrame.new(page*.56,0,0)*CFrame.Angles(0,0,-page*.12),c.gold,Enum.Material.Fabric)
   block(decor,'OpenPages',Vector3.new(1.04,.14,1.61),book*CFrame.new(page*.55,.12,0)*CFrame.Angles(0,0,-page*.12),c.text,Enum.Material.SmoothPlastic)
  end
 end
 -- Summoning altar: restrained central pearl framed by layered armillary rings.
 local gacha=station('gacha',points[3],'별의 소환 제단','가챠 · 준비 중',c.violet)
 disc(architecture,'SummoningPlinth',5.6,.45,gacha*CFrame.new(0,.94,1.7),c.stone)
 disc(architecture,'SummoningTable',4.7,.45,gacha*CFrame.new(0,1.39,1.7),c.dark)
 ring('SummoningRunes',gacha*CFrame.new(0,1.64,1.7),4.05,.14,24,c.violet,Enum.Material.Metal)
 for i=1,3 do
  local a=i*math.pi*2/3
  local frame=gacha*CFrame.new(math.cos(a)*3.2,1.6,1.7+math.sin(a)*3.2)*CFrame.Angles(0,-a,0)
  piece(decor,'AltarCurvedSupport',Vector3.new(.65,3.1,.95),frame*CFrame.new(0,1.35,0)*CFrame.Angles(0,0,-.26),c.pale,nil,'wedge')
  local pearl=piece(decor,'AltarSmallRune',Vector3.one*.26,frame*CFrame.new(-.4,3.05,0),c.violet,Enum.Material.Neon,Enum.PartType.Ball);pearl.CastShadow=false
 end
 for _,tilt in ipairs({CFrame.Angles(.75,0,.35),CFrame.Angles(-.5,.4,-.9)})do
  local circle=gacha*CFrame.new(0,5.1,1.7)*tilt
  for i=1,20 do
   local a=i*math.pi/10
   block(decor,'ArmillaryArc',Vector3.new(.13,.13,.68),circle*CFrame.new(math.cos(a)*2.1,0,math.sin(a)*2.1)*CFrame.Angles(0,-a,0),c.gold,Enum.Material.Metal)
  end
 end
 piece(decor,'DormantSummoningPearl',Vector3.one*1.55,gacha*CFrame.new(0,5.1,1.7),Color3.fromRGB(111,107,145),Enum.Material.Marble,Enum.PartType.Ball)
 for i=1,6 do
  local a=i*math.pi/3;piece(decor,'AltarFacet',Vector3.new(.42,1.15,.68),gacha*CFrame.new(math.cos(a)*5.3,2.15,1.7+math.sin(a)*5.3)*CFrame.Angles(0,a,.2),c.violet,Enum.Material.SmoothPlastic,'wedge')
 end
 -- Ranking archive: an engraved board with honest server-session scope, no fake names.
 local ranking=station('ranking',points[4],'최고 점수 기록관','현재 서버 기록 확인',Color3.fromRGB(204,185,137))
 for _,side in ipairs({-1,1})do column(ranking*CFrame.new(side*7,.71,4),9)end
 local board=block(architecture,'RankingBoard',Vector3.new(12.7,7,.65),ranking*CFrame.new(0,5.3,4),c.dark)
 for _,side in ipairs({-1,1})do block(decor,'ArchiveFrame',Vector3.new(.22,7.6,.85),ranking*CFrame.new(side*6.55,5.3,4),c.gold,Enum.Material.Metal)end
 for _,y in ipairs({1.55,9.05})do block(decor,'ArchiveFrame',Vector3.new(13.3,.22,.85),ranking*CFrame.new(0,y,4),c.gold,Enum.Material.Metal)end
 arch('ArchiveCrown',ranking*CFrame.new(0,9.6,4),7,1.05,c.stone)
 local surface=Instance.new('SurfaceGui');surface.Name='ArchiveInscription';surface.Face=Enum.NormalId.Front;surface.CanvasSize=Vector2.new(700,380);surface.Parent=board
 local inscription=Instance.new('TextLabel');inscription.Size=UDim2.fromScale(1,1);inscription.BackgroundTransparency=1;inscription.TextColor3=c.text;inscription.Font=Enum.Font.GothamBold;inscription.TextSize=31;inscription.Text='최고 점수 기록\n\n현재 서버 · 이번 접속\n\n기록관 입구에서 확인하세요';inscription.Parent=surface
 -- Warm pools of light, low planters and four route markers finish the courtyard.
 for i=1,8 do
  local a=(i-.5)*math.pi/4;local frame=CFrame.new(center+Vector3.new(math.cos(a)*22,0,math.sin(a)*22))
  lantern(frame,Color3.fromRGB(231,207,156))
 end
 for _,position in ipairs({Vector3.new(-24,0,207),Vector3.new(24,0,207),Vector3.new(-25,0,144),Vector3.new(25,0,144)})do
  local frame=CFrame.new(position);disc(architecture,'GardenUrn',2.1,1.2,frame*CFrame.new(0,.6,0),c.stone)
  disc(decor,'GardenEarth',1.9,.1,frame*CFrame.new(0,1.23,0),c.dark)
  for i=1,5 do local a=i*math.pi*2/5;piece(decor,'SilverleafShrub',Vector3.new(2,1.25,2),frame*CFrame.new(math.cos(a)*.8,1.7,math.sin(a)*.8),Color3.fromRGB(73+i*3,103+i*2,91+i*2),Enum.Material.Grass,Enum.PartType.Ball)end
 end
 hub:SetAttribute('LobbyCenter',center);hub:SetAttribute('SpawnPosition',Vector3.new(0,4,187))
 return CFrame.new(0,4,187)
end
