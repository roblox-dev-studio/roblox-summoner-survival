-- Client engine fixture. Local metadata/UI only; no uploads, live loadout, input or score changes.
local modules=game.Players.LocalPlayer.PlayerScripts.SummonerClient.Modules
local holder=Instance.new('Folder');holder.Name='SkillIconUIFixture';holder.Parent=game.Players.LocalPlayer.PlayerGui
local signal=Instance.new('BindableEvent')
local lobby,hud
local ok,result=xpcall(function()
 local icons=require(modules.flow.SkillIcons)
 assert(icons.Get('aug_meteor_echo').iconKey=='meteor','Specialist augment maps to its parent skill')
 assert(icons.Get('aug_lucky_charm').iconKey=='lucky_charm','Common augment has distinct icon')
 local image=Instance.new('ImageLabel');image.Parent=holder
 local fallback=Instance.new('TextLabel');fallback.Parent=holder
 local ready,entry=icons.Apply(image,'aug_meteor_echo',fallback)
 assert(entry.parentSkill=='meteor'and image.Visible==ready and fallback.Visible==not ready,'Metadata and fallback visibility agree')
 if ready then assert(image.Image:match('^rbxassetid://%d+$'),'Only uploaded Roblox image IDs are used')else assert(image.Image=='','No fake upload/local-file image URL')end
 assert(not icons.Apply(image,'unknown_id',fallback)and image.Image==''and fallback.Visible,'Unknown card remains readable')
 local events={};local sends=0
 local player={PlayerGui=holder,WaitForChild=function(_,name)assert(name=='PlayerGui');return holder end}
 lobby=require(modules.flow.Lobby)({player=player,net={State={OnClientEvent=signal.Event},Action={FireServer=function()sends+=1 end}},hud={Enabled=true},input={SetSuspended=function()end},onPanelChanged=function(open)table.insert(events,open)end})
 assert(not lobby.Gui.Enabled and not lobby.Open(),'Loadout cannot open outside lobby')
 signal:Fire({lobby=true,loadout={'meteor','ice','ward','frost'},activeSkill='fire',spellOptions={{id='meteor',name='Meteor',role='Area',desc='Impact',color={255,180,90}}},activeOptions={{id='fire',name='Fire',desc='Projectile'}}});task.wait()
 assert(not lobby.Gui.Enabled and lobby.Gui:GetAttribute('InLobby'),'Join begins in the walkable hub')
 assert(lobby.Open()and lobby.Gui.Enabled and lobby.Gui:GetAttribute('LoadoutOpen'),'Portal callback opens selection')
 local panel=lobby.Gui.Frame.Panel
 assert(panel.Spells.meteor.IconTile.SkillIcon and panel.Active_fire.IconTile.SkillIcon,'Auto and Q choices contain native image slots')
 lobby.Close();assert(not lobby.Gui.Enabled and not lobby.Gui:GetAttribute('LoadoutOpen'),'Close returns to walkable hub')
 lobby.Open();signal:Fire({lobby=false});task.wait()
 assert(not lobby.Gui.Enabled and not lobby.Gui:GetAttribute('LoadoutOpen')and events[#events]==false,'Combat releases modal controls')
 assert(sends==0,'Catalog inspection and opening do not request gameplay changes')
 local noop=function()end
 hud=require(modules.flow.HUD)({player=player,net={State={OnClientEvent=signal.Event},Action={FireServer=function()sends+=1 end}},input={SetBasicHeld=noop,SetBasicBlocked=noop,FireWave=noop,Dash=noop}})
 signal:Fire({lobby=false,time=120,level=2,xp=0,need=10,hp=150,maxHp=150,kills=1,golem=1,fire=0,ice=1,lightning=0,cooldown=0,offerRevision=1,offers={
  {id='aug_meteor_echo',title='Meteor Echo',desc='Secondary impact',tag='Meteor',rarity='epic',level=1,kind='augment'},
  {id='aug_lucky_charm',title='Lucky Charm',desc='Luck +20',tag='Common',rarity='common',level=1,kind='augment'},
  {id='vitality',title='Vitality',desc='Health boost',tag='Survival',rarity='common',level=1,kind='utility'},
 }});task.wait()
 local cards=hud.Gui:FindFirstChild('AugmentCards',true)
 for i=1,3 do
  local card=cards['Choice'..i];local id=card:GetAttribute('ChoiceId');local metadata=icons.Get(id)
  assert(card.Visible and card.IconTile.SkillIcon.Visible==(metadata~=nil and metadata.robloxAssetId~=nil),'Offer picture uses actual uploaded state')
  assert(card.IconTile.IconFallback.Visible==not card.IconTile.SkillIcon.Visible,'Unavailable and utility cards keep fallback')
  local expected=({'운석','행운','체력'})[i]
  assert(card.IconTile.IconFallback.Text==expected,'Readable fallback label: '..expected)
 end
 assert(sends==0,'Rendering cards does not choose or reroll')
 return {parentIcons=true,commonIcons=true,uploadGating=true,walkableDefault=true,loadoutOpenClose=true,combatCleanup=true,offerCards=3,transactions=0}
end,debug.traceback)
if lobby then lobby.Gui:Destroy()end
if hud then hud.Gui:Destroy()end
signal:Destroy();holder:Destroy()
if not ok then error(result)end
return result
