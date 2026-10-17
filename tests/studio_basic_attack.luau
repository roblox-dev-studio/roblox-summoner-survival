-- A fake participant; real parts/raycast/time, no live session table.
local folder=Instance.new('Folder');folder.Name='BasicAttackCheck';folder.Parent=workspace
local wall
local ok,result=xpcall(function()
 local modules=game.ServerScriptService.SummonerServer.Modules
 local root=Instance.new('Part');root.Anchored=true;root.CanCollide=false;root.CFrame=CFrame.new(250,4,0);root.Parent=folder
 local near={pos=Vector3.new(250,4,-15),hp=500};local far={pos=Vector3.new(250,4,-25),hp=500}
 local side={pos=Vector3.new(257,4,-15),hp=500}
 local s={player={Character=folder},weaponId='starlightWand'};local events={};local paused=false
 local basic=require(modules.combat.BasicAttack)({world=folder,enemies={near,far,side},rootOf=function(state)if not state.over then return root end end,paused=function()return paused end,effect={FireAllClients=function(_,kind)events[kind]=(events[kind]or 0)+1 end},damage=function(e,n)e.hp-=n end})
 s.lobby=true;assert(not basic.Request(s));s.lobby=false;s.offers={};assert(not basic.Request(s));s.offers=nil;paused=true;assert(not basic.Request(s));paused=false
 assert(basic.Request(s)and not basic.Request(s),'Server blocks repeat requests')
 basic.Step(.05);assert(near.hp==500,'Real flight, no instant line damage')
 for _=1,8 do basic.Step(.05)end
 assert(near.hp==487 and far.hp==500 and side.hp==500,'Only first target in facing line receives weapon damage')
 basic.StepPlayer(s,.3);root.CFrame=CFrame.new(250,4,0)*CFrame.Angles(0,math.pi,0);assert(basic.Request(s));for _=1,20 do basic.Step(.05)end
 assert(near.hp==487,'Facing is authoritative; pointer does not redirect shots')
 basic.StepPlayer(s,.3);root.CFrame=CFrame.new(250,4,0);s.weaponId='untrusted-profile';assert(basic.Request(s),'Unknown profile safely falls back')
 s.offers={};local p=folder:FindFirstChild('BasicBolt_',true);for _,v in ipairs(folder:GetChildren())do if v.Name:match('^BasicBolt_')then p=v end end
 local position=p.Position;basic.Step(.2);assert(p.Position==position,'Choice pause freezes projectile');s.offers=nil;basic.Clear(s)
 wall=Instance.new('Part');wall.Name='BasicWall';wall.Anchored=true;wall.Size=Vector3.new(10,10,1);wall.Position=Vector3.new(250,4,-8);wall.Parent=workspace
 basic.StepPlayer(s,.3);assert(basic.Request(s));for _=1,20 do basic.Step(.05)end
 assert(near.hp==487,'Projectile cannot pass through wall')
 basic.Clear();for _,v in ipairs(folder:GetChildren())do assert(not v.Name:match('^BasicBolt_'),'Cleanup removes shots')end
 return {guards=true,cooldown=true,flight=true,singleTarget=true,facing=true,profile=true,pause=true,wall=true,cleanup=true}
end,debug.traceback)
if wall then wall:Destroy()end;folder:Destroy();if not ok then error(result)end;return result
