-- Client fixture: inspect the real sanctuary and exercise isolated read-only hub UI.
-- It never moves the player, changes real session state, buys, rolls or writes scores.
local actual=workspace:WaitForChild('SummonerLobby')
assert(actual:GetAttribute('LobbyStyle')=='AstralAcademy','Reproducible academy sanctuary installed')
local architecture=actual:FindFirstChild('Architecture');local decor=actual:FindFirstChild('Decor');local interactions=actual:FindFirstChild('Interactions')
assert(architecture and decor and interactions,'Collision, decoration and interaction layers separated')
local actualActions={}
for _,object in ipairs(actual:GetDescendants())do
 assert(not object:IsA('LuaSourceContainer'),'Map contains native instances, no embedded scripts')
 if object:IsA('BasePart')then
  assert(object.Anchored and not object.CanTouch,'Anchored map avoids touch-driven authority')
  if object:IsDescendantOf(decor)or object:IsDescendantOf(interactions)then assert(not object.CanCollide and not object.CanQuery,'Decor/entrances do not block paths')end
 end
 if object:IsA('ProximityPrompt')then
  actualActions[object:GetAttribute('LobbyHubAction')]=true
  assert(object.MaxActivationDistance>=8 and not object.RequiresLineOfSight,'Readable landmark entrance prompts')
 end
end
for _,action in ipairs({'loadout','shop','gacha','ranking'})do assert(actualActions[action],action..' physical entrance exists')end
local foundation=architecture:FindFirstChild('SanctuaryFoundation')
assert(foundation and foundation.Position.Z-foundation.Size.Z*.5>100,'Sanctuary separated from arena boundary')
local holder=Instance.new('Folder');holder.Name='LobbyHubFixture';holder.Parent=game.Players.LocalPlayer.PlayerGui
local world=Instance.new('Folder');world.Name='SummonerLobby';world.Parent=holder
local state=Instance.new('BindableEvent');local respawn=Instance.new('BindableEvent');local removing=Instance.new('BindableEvent')
local prompts={}
for _,action in ipairs({'loadout','shop','gacha','ranking'})do
 local part=Instance.new('Part');part.Anchored=true;part.Parent=world
 local prompt=Instance.new('ProximityPrompt');prompt:SetAttribute('LobbyHubAction',action);prompt.Parent=part;prompts[action]=prompt
end
local player={UserId=71,CharacterAdded=respawn.Event,CharacterRemoving=removing.Event,WaitForChild=function(_,name)assert(name=='PlayerGui');return holder end}
local sends,loadouts,panelEvents=0,0,{}
local hub
local ok,result=xpcall(function()
 hub=require(game.Players.LocalPlayer.PlayerScripts.SummonerClient.Modules.flow.LobbyHub)({player=player,world=world,net={State={OnClientEvent=state.Event},Action={FireServer=function()sends+=1 end}},onLoadout=function()loadouts+=1 end,onPanelChanged=function(value)table.insert(panelEvents,value)end})
 assert(not hub.Gui.Enabled and not hub.Open('shop'),'Hub gated until lobby state')
 for _,prompt in pairs(prompts)do assert(not prompt.Enabled,'Combat does not show lobby prompts')end
 state:Fire({lobby=true,lobbyScores={{userId=71,name='Fixture Scholar',bestScore=142},{userId=72,name='Fixture Archivist',bestScore=810}}});task.wait()
 assert(hub.Gui.Enabled and hub.Open('shop'),'Lobby enables shop view')
 assert(hub.Gui:GetAttribute('Panel')=='shop'and hub.Gui.Veil.Panel.ComingSoon.Status.Text=='상점 준비 중','Shop clearly pending')
 assert(hub.Open('gacha')and hub.Gui.Veil.Panel.ComingSoon.Status.Text=='가챠 준비 중','Gacha clearly pending')
 assert(sends==0,'Shop and gacha never request transactions')
 assert(hub.Open('codex')and hub.Gui.Navigation.Open_codex,'Lobby has a readable spell archive entry')
 local book=hub.Gui.Veil.Panel.SkillCodex
 assert(book.Visible and book:GetAttribute('EntryCount')==41,'All current spells and augments shown')
 assert(not hub.Gui.Veil.Panel.ComingSoon.Visible and not hub.Gui.Veil.Panel.Scores.Visible,'Codex does not overlap other panels')
 assert(book.Entries.Entry_ice_shatter.Condition.Text:find('2단계 이상',1,true),'Server-derived rank requirement')
 assert(book.Entries.Entry_lightning_frozen.Condition.Text:find('서리 폭발',1,true),'Synergy requirement shown')
 assert(book.Entries.Entry_ice.IconTile.Fallback.Visible and book.Entries.Entry_ice.IconTile.Icon.Image=='','Unuploaded image retains fallback')
 book.Search.Text='빙결 얼음창';task.wait(.2)
 assert(book:GetAttribute('EntryCount')>=3 and book.Entries:FindFirstChild('Entry_ice_twin'),'Search matches spell and linked conditions')
 book.Search.Text='there-is-no-such-spell';task.wait(.2);assert(book.Empty.Visible and book:GetAttribute('EntryCount')==0,'Explicit empty result state')
 hub.Close();assert(not book.Visible and not hub.Gui:GetAttribute('Open'),'Closing archive releases the modal')
 hub.Open('codex');book.Search.Text='';task.wait(.2);assert(book:GetAttribute('EntryCount')==41,'Reopening and clearing restores catalogue')
 assert(hub.Open('ranking')and hub.Gui:GetAttribute('ScoreCount')==2,'Read-only actual State score rows rendered')
 assert(not book.Visible and hub.Gui.Veil.Panel.Size.Y.Offset==510,'Other hub panels restore their original size')
 assert(hub.Gui.Veil.Panel.Scores.Score_72.LayoutOrder==1 and hub.Gui.Veil.Panel.Scores.Score_71.BestScore.Text=='142','Leaderboard binds and sorts supplied scores')
 assert(hub.Gui.Veil.Panel.Scope.Text:find('현재 서버',1,true)and hub.Gui.Veil.Panel.Scope.Text:find('영구 저장',1,true),'Ranking scope is explicit')
 state:Fire({lobby=true,lobbyScores={}});task.wait();assert(hub.Gui.Veil.Panel.EmptyScores.Visible and #hub.Gui.Veil.Panel.Scores:GetChildren()==1,'Empty state removes old score rows')
 local menu=Instance.new('ScreenGui');menu.Name='SummonerLobbyUI';menu:SetAttribute('LoadoutOpen',true);menu.Parent=holder;task.wait()
 assert(not hub.Gui.Enabled and not hub.Gui:GetAttribute('Open')and not hub.Open('ranking'),'Loadout menu closes and blocks hub')
 menu:SetAttribute('LoadoutOpen',false);task.wait();assert(hub.Gui.Enabled and hub.Open('loadout')and loadouts==1,'Existing loadout callback invoked exactly once')
 hub.Open('shop');respawn:Fire();task.wait();assert(not hub.Gui:GetAttribute('Open'),'Respawn closes menu')
 hub.Open('codex');state:Fire({lobby=false});task.wait();assert(not hub.Gui.Enabled and not hub.Gui:GetAttribute('Open')and not book.Visible,'Combat transition cleans archive menu')
 assert(not hub.Open('gacha')and not hub.Open('invalid')and sends==0,'No out-of-lobby or invented action path')
 hub.Destroy();hub.Destroy();assert(not hub.Gui.Parent,'Destroy is idempotent')
 for _,prompt in pairs(prompts)do assert(prompt.Enabled,'Original prompt state restored on teardown')end
 state:Fire({lobby=true,lobbyScores={{userId=71,name='After cleanup',bestScore=999}}});respawn:Fire();task.wait();assert(not hub.Gui.Parent,'Disconnected state/respawn callbacks do not recreate UI')
 return {physicalLandmarks=4,nativeMap=true,collisionLayers=true,lobbyGating=true,loadoutCallback=true,comingSoon=true,readOnlyScores=true,noTransactions=true,codexEntries=41,codexSearch=true,derivedConditions=true,menuAndRespawnCleanup=true,teardown=true,panelEvents=#panelEvents}
end,debug.traceback)
if hub then hub.Destroy()end
state:Destroy();respawn:Destroy();removing:Destroy();holder:Destroy()
if not ok then error(result)end;return result
