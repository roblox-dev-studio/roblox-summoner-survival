-- Client fixture: deliberately stale server anchor must not move the owner's shield.
local p=game.Players.LocalPlayer
local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart');assert(root,'Character required')
local folder=Instance.new('Folder');folder.Name='WardFollowCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local a=Instance.new('Part');a.Name='StaleWardAnchor';a.Size=Vector3.one*.1;a.Transparency=1;a.Anchored=true;a.CanCollide=false;a.Position=root.Position-Vector3.new(80,0,0)
 a:SetAttribute('Duration',5);a:SetAttribute('Elapsed',.1);a:SetAttribute('Radius',4);a:SetAttribute('Level',1);a:SetAttribute('OwnerUserId',p.UserId);a.Parent=folder
 require(p.PlayerScripts.SummonerClient.Modules.combat.AreaArt)({folder=folder}).Cast(a,'ward')
 task.wait(.12)
 local dome=folder:FindFirstChild('GuardianDome',true);assert(dome and(dome.Position-root.Position).Magnitude<.001,'Shield follows rendered owner, not stale anchor')
 a.Position-=Vector3.new(30,0,0);task.wait(.08)
 assert((dome.Position-root.Position).Magnitude<.001,'Further server anchor movement cannot drag owner shield behind')
 a:SetAttribute('OwnerUserId',nil);task.wait(.08)
 assert((dome.Position-a.Position-Vector3.new(0,2.6,0)).Magnitude<.001,'Unowned gallery anchors keep their own location')
 a:Destroy();task.wait(.05);assert(not dome.Parent,'Anchor removal cleans the whole shield')
 return {ownerFollow=true,staleAnchor=true,previewFallback=true,cleanup=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
