local folder=Instance.new('Folder');folder.Name='LightSpellsCheck';folder.Parent=workspace
local wall
local ok,result=xpcall(function()
 local root=Instance.new('Part');root.Anchored=true;root.CanCollide=false;root.CFrame=CFrame.new(250,4,0);root.Parent=folder
 local near={pos=Vector3.new(250,4,-15),hp=1000,slow=0};local farther={pos=Vector3.new(250,4,-24),hp=1000,slow=0};local side={pos=Vector3.new(258,4,-15),hp=1000,slow=0}
 local enemies={near,farther,side};local s={player={Character=folder},lightRing=1};local events={}
 local spells=require(game.ServerScriptService.SummonerServer.Modules.combat.LightSpells)({world=folder,enemies=enemies,rootOf=function(state)if not state.over then return root end end,damage=function(e,n)e.hp-=n end,effect={FireAllClients=function(_,kind)events[kind]=(events[kind]or 0)+1 end}})
 local function anchor()for _,v in ipairs(folder:GetChildren())do if v.Name:match('^LightCast_')then return v end end end
 spells.StepPlayer(s,root,.05);local a=anchor();assert(a and near.hp==1000,'Ring warns visually before actual travel')
 for _=1,20 do spells.Step(.05)end
 assert(near.hp==974 and farther.hp==974 and side.hp==1000,'Outbound pierces aligned targets once')
 for _=1,30 do spells.Step(.05)end
 assert(near.hp==948 and farther.hp==948 and not a.Parent,'Return leg hits each target once then cleans up')
 s.lightRingClock=0;spells.StepPlayer(s,root,.05);a=anchor();local pos=a.Position;s.offers={};spells.Step(.5);assert(a.Position==pos,'Offers freeze flight');s.offers=nil;spells.Clear(s)
 s.lightRing=1;s.lightRingClock=0;wall=Instance.new('Part');wall.Anchored=true;wall.Size=Vector3.new(10,10,1);wall.Position=Vector3.new(250,4,-8);wall.Parent=workspace
 local before=near.hp;spells.StepPlayer(s,root,.05);for _=1,50 do spells.Step(.05)end;assert(near.hp==before,'Outbound wall blocks distant ring hits')
 spells.Clear();return {outbound=true,returnHit=true,pause=true,cleanup=true,wall=true}
end,debug.traceback)
if wall then wall:Destroy()end;folder:Destroy();if not ok then error(result)end;return result
