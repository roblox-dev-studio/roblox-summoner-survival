-- Composition root. Install the Modules children together with this script.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local net = RS:WaitForChild("SummonerNet")
local modules = script:WaitForChild("Modules")
local combat = modules:WaitForChild("combat")
local flow = modules:WaitForChild("flow")
local world = modules:WaitForChild("world")
local input = require(combat:WaitForChild("Input"))({player=player,net=net})
local hud = require(flow:WaitForChild("HUD"))({player=player,net=net,input=input})
require(combat:WaitForChild("Effects"))({player=player,net=net,gui=hud.Gui})
local cameraController=require(world:WaitForChild("Camera"))({player=player})
require(world:WaitForChild("CharacterMotion"))()
require(world:WaitForChild("DragonPresentation"))()
require(world:WaitForChild("EnemyPresentation"))()
local skillPreview,enemyPreview,lobby,lobbyHub
local function menuMovement(open)
 input.SetJumpMenuBlocked(open)
 local module=player.PlayerScripts:FindFirstChild('PlayerModule')
 if module then local ok,controls=pcall(function()return require(module):GetControls()end);if ok then if open then controls:Disable()else controls:Enable()end end end
end
local function closeLobbyMenus()if lobbyHub then lobbyHub.Close()end;if lobby then lobby.Close()end end
local dragonPreview=require(world:WaitForChild("DragonPreview"))({player=player,net=net,input=input,hud=hud.Gui,beforeOpen=function()closeLobbyMenus();if skillPreview then skillPreview.Close()end;if enemyPreview then enemyPreview.Close()end end})
lobby=require(flow:WaitForChild("Lobby"))({player=player,net=net,input=input,hud=hud.Gui,camera=cameraController,onPanelChanged=menuMovement,beforeOpen=function()
 if lobbyHub then lobbyHub.Close()end;if skillPreview then skillPreview.Close()end;if enemyPreview then enemyPreview.Close()end;if dragonPreview then dragonPreview.Close()end
end})
lobbyHub=require(flow:WaitForChild('LobbyHub'))({player=player,net=net,onLoadout=function()lobby.Open()end,onPanelChanged=menuMovement})
skillPreview=require(flow:WaitForChild("SkillPreview"))({player=player,net=net,input=input,hud=hud.Gui,dragon=dragonPreview,camera=cameraController,beforeOpen=function()closeLobbyMenus();if enemyPreview then enemyPreview.Close()end end})
enemyPreview=require(world:WaitForChild('EnemyPreview'))({player=player,net=net,input=input,hud=hud.Gui,camera=cameraController,beforeOpen=function()closeLobbyMenus();if skillPreview then skillPreview.Close()end;if dragonPreview then dragonPreview.Close()end end})
net.Action:FireServer("ready")
print("[Summoner] HUD ready")
