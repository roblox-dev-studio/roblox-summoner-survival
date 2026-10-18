-- Existing place: read-only map invariants, not a full blank-place installer test.
local arena=workspace:FindFirstChild('SummonerArena');assert(arena and arena:GetAttribute('Theme')=='AshenCrownCourtyard','New courtyard installed')
assert(not workspace:FindFirstChild('SummonerArenaBuilding'),'No partial map left behind')
assert(not arena:FindFirstChild('CornerRuins'),'Previous corner trial removed')
for _,name in ipairs({'BattlePlaza','BrokenRamparts','CommandersGate','Graveyard','BurntChapel','DistantKingdom','InteriorDebris'})do assert(arena:FindFirstChild(name),'Missing region '..name)end
local function behindWall(point)
 for _,p in ipairs(arena.BrokenRamparts:GetDescendants())do if p:IsA('BasePart')and p.Name=='WallBacking'then local v=p.CFrame:PointToObjectSpace(point);if math.abs(v.X)<=p.Size.X/2 and math.abs(v.Y)<=p.Size.Y/2 and math.abs(v.Z)<=p.Size.Z/2 then return true end end end
 return false
end
for _,point in ipairs({Vector3.new(-100,5,7),Vector3.new(100,5,7),Vector3.new(0,5,100)})do assert(behindWall(point),'Unintended perimeter opening is filled')end
assert(not behindWall(Vector3.new(0,5,-100)),'Intentional northern gate stays open')
local physical,parts,boundaries=0,0,0
for _,p in ipairs(arena:GetDescendants())do if p:IsA('BasePart')then
 parts+=1;assert(p.Anchored and not p.CanTouch,'Static environment')
 if p.CanCollide then physical+=1;assert(p.Name=='ArenaFloor'or p.Name=='InvisibleBoundary','Rubble must not block movement')end
 if p.Name=='InvisibleBoundary'then boundaries+=1;assert(p.Transparency==1 and p.CanCollide,'Boundary remains effective')end
end end
assert(physical==5 and boundaries==4 and parts==arena:GetAttribute('PartCount'),'Only floor and four original boundaries collide')
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={arena};params.RespectCanCollide=true
for x=-72,72,18 do for z=-72,72,18 do
 local floor=workspace:Raycast(Vector3.new(x,8,z),Vector3.new(0,-20,0),params)
 assert(floor and floor.Instance.Name=='ArenaFloor'and math.abs(floor.Position.Y)<.01,'Flat safe arena floor')
 assert(not workspace:Raycast(Vector3.new(x,2,z),Vector3.new(0,58,0),params),'Sky attacks unobstructed')
end end
for _,delta in ipairs({Vector3.new(70,0,0),Vector3.new(-70,0,0),Vector3.new(0,0,70),Vector3.new(0,0,-70)})do assert(not workspace:Raycast(Vector3.new(0,3,0),delta,params),'Dash and projectile lanes clear')end
local named=0;for _,p in ipairs(game.Lighting:GetChildren())do if p.Name=='SummonerAtmosphere'then named+=1 end end
assert(named==1,'Map atmosphere is reused')
return {parts=parts,regions=7,flatFloorSamples=81,clearCombat=true,clearSky=true,boundaries=true,nonblockingInteriorDebris=true}
