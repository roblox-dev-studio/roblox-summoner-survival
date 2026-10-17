-- Run on Server: model inspection pauses Studio simulation without removing live states.
local model=Instance.new('Model');model.Name='PreviewPauseCheck'
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Parent=model
local h=Instance.new('Humanoid');h.RequiresNeck=false;h.Parent=model
local ok,result=xpcall(function()
 local a={player={Character=model},over=false}
 local b={player={Character=model},over=false}
 local states={a=a}
 local queries=require(game.ServerScriptService.SummonerServer.Modules.shared.PlayerState)({states=states})
 assert(queries.LiveCount()==1 and not queries.Paused(),'Normal solo round runs')
 a.previewDragon=true;assert(queries.Paused()and queries.LiveCount()==1,'Preview pauses without changing live membership')
 a.previewDragon=false;assert(not queries.Paused(),'Closing resumes the round')
 a.previewSkills=true;assert(queries.Paused()and queries.LiveCount()==1,'Skill viewer pauses without changing membership')
 a.previewSkills=false;assert(not queries.Paused(),'Skill viewer closes cleanly')
 a.offers={{id='test'}};assert(queries.Paused(),'Existing solo choice pause is preserved')
 states.b=b;assert(not queries.Paused(),'Existing multiplayer choice rule is preserved')
 b.previewSkills=true;assert(queries.Paused(),'Studio inspection also pauses a multiplayer test')
 states.b=nil;a.offers=nil;assert(not queries.Paused(),'Removing the inspecting tester releases pause')
 a.over=true;a.previewDragon=true;assert(queries.Paused()and queries.LiveCount()==0,'Inspection after defeat is valid')
 a.previewDragon=false;assert(not queries.Paused(),'Post-defeat inspection closes cleanly')
 return 'PASS: preview open/close, live membership, existing choice pause, multiplayer test pause and departure/post-defeat cleanup'
end,debug.traceback)
model:Destroy();assert(ok,result);return result
