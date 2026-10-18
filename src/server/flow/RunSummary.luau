-- Capture detached, server-owned results once. No rewards or persistent storage.
return function(deps)
 local augments,loadouts=deps.augments,deps.loadouts
 local revision=0
 local function capture(s,clock,bestScore,newBest)
  revision+=1
  local spells={}
  for _,id in ipairs(s.loadout or {})do
   table.insert(spells,{id=id,name=augments.Labels[id]or id,level=s[id]or 1})
  end
  local stacks=augments.Summary(s)
  local count=0;for _,entry in ipairs(stacks)do count+=entry.count end
  local test=s.bossTest==true or s.fieldBossTest==true
  return {
   revision=revision,result=s.result,seconds=math.max(0,math.floor((clock.elapsed or 0)-(s.runStartedAt or 0))),
   level=s.level,kills=s.kills,spells=spells,activeSkill=s.activeSkill,
   activeName=loadouts.ActiveNames[s.activeSkill]or s.activeName or '사용 스킬',golem=s.golem,
   augments=stacks,augmentCount=count,luck=augments.Luck(s),
   rerollsUsed=math.clamp(2-(s.rerolls or 2),0,2),
   vitality=s.vitality or 0,agility=s.agility or 0,magnet=s.magnet or 0,
   fieldBossRewarded=s.fieldBossRewarded==true,testMode=test,
   bestScore=not test and bestScore or nil,newBest=not test and newBest==true,
  }
 end
 return {Capture=capture}
end
