-- Isolated real native GUI rendering; no live server transactions.
local player=game.Players.LocalPlayer
local signal=Instance.new('BindableEvent')
local sent=0
local recap
local ok,result=xpcall(function()
 local modules=player.PlayerScripts.SummonerClient.Modules
 recap=require(modules.flow.RunRecap)({player=player,net={State={OnClientEvent=signal.Event},Action={FireServer=function()sent+=1 end}}})
 local data={revision=101,result='victory',seconds=184,kills=251,level=12,golem=3,
  spells={{id='ice',name='빙결 얼음창',level=5},{id='meteor',name='메테오',level=4},{id='blades',name='비전 결정',level=3},{id='ward',name='수호 결계',level=2}},
  activeSkill='iceRush',activeName='빙하 쇄도',augments={},augmentCount=0,luck=0,rerollsUsed=2,vitality=1,agility=2,magnet=3,fieldBossRewarded=true,bestScore=251,newBest=true,testMode=false}
 signal:Fire({over=true,lobby=false,runResult=data});task.wait(.1)
 local panel=recap.Gui.Veil.Panel
 assert(recap.Gui:GetAttribute('Open')and panel.Outcome.Text=='드래곤 격파!','Victory opens actual GUI')
 assert(panel.Metric1.Value.Text=='03:04'and panel.Metric2.Value.Text=='251','Frozen time/kills rendered')
 assert(panel.Build.Spells.Text:find('빙결 얼음창 5단계',1,true)and panel.Build.EmptyAugments,'Build and empty state rendered')
 assert(panel.Record.Text:find('최고 기록',1,true)and not panel.Close.Visible,'Server best flag and end action')
 signal:Fire({over=false,lobby=true,lastRun=data});task.wait(.1)
 assert(not recap.Gui:GetAttribute('Open')and recap.Gui.LastRun.Visible,'History available after return')
 signal:Fire({over=false,lobby=false});task.wait(.1)
 assert(not recap.Gui.LastRun.Visible and not recap.Gui:GetAttribute('Open'),'New run hides history')
 data=table.clone(data);data.revision=102;data.testMode=true;data.result='defeat';data.augments={{id='ice_twin',name='쌍빙창',count=1,rarity='rare',desc='얼음창 두 발'} };data.augmentCount=1
 signal:Fire({over=true,lobby=false,runResult=data});task.wait(.1)
 assert(panel.Record.Text:find('반영하지 않습니다',1,true),'Test mode explicitly excluded')
 assert(panel.Build.Item_aug_ice_twin.Title.Text:find('쌍빙창',1,true),'Augment row appears')
 assert(sent==0,'Rendering never sends score or reward requests')
 return {victory=true,build=true,history=true,newRun=true,testMode=true,noTransactions=true}
end,debug.traceback)
if recap then recap.Destroy()end;signal:Destroy()
if not ok then error(result)end;return result
