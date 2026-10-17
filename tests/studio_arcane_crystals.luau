-- Five stored crystals, staggered launch, homing flight and bounded recharge.
local folder=Instance.new('Folder');folder.Name='CrystalCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local root=Instance.new('Part');root.Anchored=true;root.CanCollide=false;root.Position=Vector3.new(250,4,0);root.Parent=folder
 local near={pos=Vector3.new(250,4,-14),hp=500};local far={pos=Vector3.new(250,4,-25),hp=500}
 local s={player={Character=folder},blades=1};local events={}
 local crystals=require(game.ServerScriptService.SummonerServer.Modules.combat.ArcaneCrystals)({world=folder,enemies={near,far},rootOf=function(state)if not state.over then return root end end,effect={FireAllClients=function(_,kind)events[kind]=(events[kind]or 0)+1 end},damage=function(e,n)e.hp-=n end})
 local function find(prefix)local all={};for _,p in ipairs(folder:GetChildren())do if p.Name:match('^'..prefix)then table.insert(all,p)end end;return all end
 crystals.StepPlayer(s,root,.05)
 assert(#find('CrystalAura_')==1 and #find('CrystalBolt_')==1,'One aura and first individual launch')
 crystals.Step(.1);assert(near.hp==500,'Not instant damage')
 for _=1,5 do crystals.Step(.05)end
 assert(near.hp==486 and far.hp==500,'One target per bolt, no splash or penetration')
 for _=1,4 do crystals.StepPlayer(s,root,.18)end
 local aura=find('CrystalAura_')[1];assert(events.crystalBolt==5 and aura:GetAttribute('Fired')==5,'Exactly five staggered launches empty the fan')
 crystals.StepPlayer(s,root,1);assert(events.crystalBolt==5,'Recharge blocks further launches')
 local bolt=find('CrystalBolt_')[1];local position=bolt.Position;s.offers={};crystals.Step(.3);assert(bolt.Position==position,'Offers freeze flight');s.offers=nil
 local direction=bolt.CFrame.LookVector;near.pos+=Vector3.new(8,0,0);far.pos+=Vector3.new(8,0,0);crystals.Step(.05)
 assert((bolt.CFrame.LookVector-direction).Magnitude>.001,'Launched bolt curves toward its target')
 for _=1,45 do crystals.Step(.05)end;assert(#find('CrystalBolt_')==0,'Flight lifetime is bounded')
 root.CFrame=CFrame.new(254,4,0);crystals.StepPlayer(s,root,.1);assert(aura.CFrame==root.CFrame,'Fan follows character')
 s.blades=3;crystals.StepPlayer(s,root,.1);assert(#find('CrystalAura_')==1 and find('CrystalAura_')[1]:GetAttribute('Level')==3,'Upgrade does not duplicate aura')
 crystals.Clear(s);assert(#find('CrystalAura_')==0 and #find('CrystalBolt_')==0,'Owner cleanup')
 return {five=true,recharge=true,homing=true,singleTarget=true,pause=true,cleanup=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
