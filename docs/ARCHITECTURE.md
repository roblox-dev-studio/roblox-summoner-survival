# 모듈 구조와 기능 분담

세 사람 모두 서버·클라이언트를 개발합니다. 작업 하나를 맡으면 해당 기능의 규칙,
화면, 효과와 검증까지 연결합니다. 담당자는 이슈마다 정하고 서로 리뷰합니다.

| 기능 영역 | 수정할 곳 | 범위 |
| --- | --- | --- |
| 전투·소환 | `src/server/combat/`, `src/client/combat/` | 마법, 골렘, 피해, 대시, 입력, 전투 효과 |
| 적·웨이브·월드 | `src/server/world/`, `src/client/world/`, `arena.luau` | 적 생성·추적·접촉 피해, 전장, 카메라 |
| 성장·게임 흐름 | `src/server/flow/`, `src/client/flow/`, `src/client/Theme.luau` | 경험치, 카드, 시작·종료·재시작, HUD |
| 공동 연결부 | 루트 진입점, `src/server/shared/`, `tools/`, `.github/` | 의존성 연결, 공통 모델·조회, 설치·검사 |

현재 전달받은 GitHub 계정은 `hoo9543`, `kcm0147`, `pyj7628`입니다.
앞 두 계정은 조회됐고 `pyj7628`은 2026-10-16 조회에서 404였습니다.
이는 입력 문자열을 영문 키보드로 환산한 값이며 마지막 아이디와 역할 배정은 확인이 필요합니다.
아직 CODEOWNERS를 설정하지 않았습니다. 존재하는 계정이라도 저장소 권한 확인 없이
필수 리뷰어로 지정하지 않습니다.

## Studio 설치 결과

```text
ServerScriptService
└── SummonerServer (server.luau)
    └── Modules (src/server)
        ├── combat: Combat, Movement
        ├── world: Waves, Boss
        ├── flow: Progression, Session
        └── shared: Actors, PlayerState, EnemyModels
StarterPlayer / StarterPlayerScripts
└── SummonerClient (client.luau)
    └── Modules (src/client)
        ├── combat: Input, Effects, SpellArt, FireArt
        ├── world: Camera, CharacterMotion, clips (4 CC0 R15 clips), DragonMesh, DragonPresentation, DragonPreview, dragon (Geometry, Rig, Idle, Walk, Attack, Die)
        ├── flow: HUD
        └── Theme
ReplicatedStorage
├── SummonerNet: State, Action, Effect
└── SummonerVFXAssets (선택적 외부 메시)
Workspace
├── SummonerArena (arena.luau에서 편집 모드에 생성)
├── SummonerRuntime (서버 실행 중 생성)
└── SummonerLocalEffects (클라이언트 실행 중 생성)
```

모듈은 생성 함수에 의존성을 전달합니다. `server.luau`가 같은 상태 테이블과 난수
생성기를 연결합니다. 참조 중인 테이블을 다른 테이블로 교체하지 말고 `table.clear`로
초기화합니다. 클라이언트는 Input → HUD → Effects → Camera 순서로 시작합니다.

## 서버 인터페이스

| 모듈 | 공개 함수 | 관리하는 상태 |
| --- | --- | --- |
| Actors | `Block`, `Create` | 절차적 적·골렘 형상 |
| PlayerState | `RootOf`, `LiveCount`, `Paused` | 상태를 조회하며 변경하지 않음 |
| Movement | `RequestDash`, `Step`, `FinishDash` | 대시·무적·이동 복구 |
| Progression | `Sync`, `Drop`, `Choose`, `Collect`, `Need`, `LevelCheck` | XP·카드·강화·경험치 구슬 |
| Combat | `StepPlayer`, `StepProjectiles`, `ClearProjectiles`, `RequestWave` | 공격·골렘 AI·얼음창·적 피해 |
| Boss | `Step`, `Resolve`, `Reset` | 보스 생성·추적·예고·공격·승패, 일반 적의 피해 경로 공유 |
| Waves | `Spawn`, `Step`, `ResetSpawn` | 생성 간격·적 AI·접촉 피해 |
| Session | `AddPlayer`, `RemovePlayer`, `EndPlayer`, `Restart` | 참가·사망·라운드 초기화 |

단일 Heartbeat가 기존 순서를 유지합니다: 라운드 시간/보스 진행 → 적 생성 → 대시 → 얼음창
→ 적 이동·접촉 피해 → 플레이어 경계·골렘·자동 공격 → 경험치 수집 → 보스 승패 확정 → 0.2초 간격 HUD 동기화.
고정 간격은 최소 0.05초, 한 번에 반영하는 dt 상한은 0.15초입니다.
모듈마다 별도 Heartbeat를 추가해 이 순서를 우회하지 않습니다.

현재는 공통 상태 레코드를 직접 공유합니다. 완전한 데이터 캡슐화나 ECS 전환은
이번 범위가 아닙니다. 적 레코드(`hp`, `pos`, `slow`, `frozen`, `knockback` 등)나
플레이어 레코드를 바꾸면 양쪽 사용처와 테스트를 함께 변경해야 합니다.

## 네트워크 계약

`SummonerNet.Action`은 클라이언트 의도입니다. 기존 요청 이름과 데이터 형식은 유지합니다.

| 요청 | 추가 인자 | 서버 검증/처리 |
| --- | --- | --- |
| `ready` | 없음 | 등록된 플레이어에게 상태 전송 |
| `choose` | 선택지 `id` 문자열 | 현재 서버가 제공한 선택지에 포함되는지 확인 |
| `dash` | 수평 이동용 Vector3 | 상태·쿨다운 검증, X/Z 유효성 확인 후 정규화/정면 대체 |
| `fireWave` | 수평 조준 방향 Vector3 (기존 인자 생략도 허용) | 벡터 유효성·상태·쿨다운 확인, 서버가 30스터드/반각 35도 범위와 피해 판정 |
| `restart` | 없음 | 요청자 종료 상태 및 모든 참가자 종료 여부 확인 |

`State`는 서버 스냅샷이며 `Progression.Sync`가 필드를 정의하고 `HUD`가 소비합니다.
`Effect`는 `hit`, `golemCharge`, `golemHeavy`, `golemLight`, `dash`, `fire`, `fireWave`,
`lightning`, `iceCast`, `iceHit` 연출을 전송합니다. 클라이언트 효과는 피해를 결정하지 않습니다.
새 이벤트나 필드 변경은 생산자·소비자를 같은 PR 또는 명시적 호환 단계로 배포합니다.

현재 프로토타입에는 `ready` 등 모든 요청을 포괄하는 별도 속도 제한이 없습니다.
이번 구조 분리로 보안·협동 완성도를 보장하지 않습니다. 공개 출시 전에 별도 검증이 필요합니다.

## 보존한 동작과 한계

- 초기 구조 분리 시 180초 생존과 기존 수치를 유지했습니다. 현재 전투 규칙은 아래 보스전 변경 항목을 참고합니다.
- `Combat.luau`의 `PREVIEW_MAX_GOLEM_EFFECTS=true`도 유지했습니다. 시각 미리보기와 실제 피해 레벨은 다릅니다.
- Combat과 Effects 내부는 기존 알고리즘을 옮겼습니다. 주문을 추가할 때 필요해진 부분부터 더 나누면 됩니다.
- 기존 플레이 검증 기록은 이전 단일 스크립트의 기록입니다. 새 구조의 통과 증거로 재사용하지 않습니다.

## 재사용 모션의 경계

`world/CharacterMotion`은 모든 현재 플레이어의 R15 관절을 각 클라이언트에서 표시합니다.
서버 속도·루트 위치·피해를 바꾸지 않습니다. PreAnimation에서 이전 프레임의 관절 값을
복원하고 Animator 처리 뒤 PreSimulation에서 여섯 하체 관절만 혼합합니다.
정지/메뉴 선택/대시/사망은 덧씌우기를 해제하며 캐릭터 교체 시 이전 참조를 정리합니다.
R6는 기본 Animate를 유지합니다. 협동에서 다른 플레이어 표시와 서로 다른 아바타 비율은
추가 검증이 필요합니다. 클라이언트 모듈은 현재 10개(기존 5 + 제어기 1 + 클립 4)입니다.

클립 추가 시 CC0 등 배포 가능한 출처와 해시를 manifest에 적고,
`tests/test_motion_assets.py`의 데이터 검사를 갱신합니다. 출처 확인·변환 성공·엔진 재생·
시각 품질을 구별해서 `PLAYTEST_NOTES.md`에 기록합니다.

## 2026-10-17 보스전·Q 조준 변경

서버 모듈은 EnemyModels를 포함해 9개, 클라이언트는 SpellArt를 포함해 11개입니다. `server.luau`가 120초 일반 전투와 90초 보스 제한 시간을 관리합니다. `clock.phase`는 survival/boss/victory/defeat이며 `clock.boss`는 현재 보스 레코드입니다. 보스도 enemies의 `isBoss=true` 레코드로 등록되며 Combat에서 모든 기존 주문과 소환수 피해를 받습니다. Waves는 보스의 이동을 처리하지 않고, Boss가 추적·고정된 공격 예고·한 공격당 1회 피해를 처리합니다. 보스는 빙결·밀치기에 면역이고 둔화 시 이동 속도는 80%입니다. 돌진은 경로 전체를 검사하여 빠른 이동 중 충돌 누락을 줄입니다.

보스 등장 시 일반 적은 경험치 구슬을 남기고 사라지고, 일반 적 생성은 중단됩니다. 보스 체력은 솔로 2200, 추가 참가자당 70% 증가가 시작값입니다. 체력 절반에서 균열 갈래가 3→5개로 늘고 회복 시간이 줄어듭니다. 피해 적용 후 Boss.Resolve에서 처치·시간 초과를 확정하므로 마지막 타격과 시간 초과가 겹치면 처치가 우선입니다. Session의 재시작·전원 이탈은 보스와 예고 객체도 초기화합니다. 영구 재화 보상은 아직 없습니다.

State에는 `phase`와 선택적 `boss={hp,maxHp,stage}`를 추가했고 `time`은 현재 구간의 남은 시간입니다. Input은 Q/버튼을 누른 순간 캐릭터의 정면 벡터를 제출합니다. 서버가 벡터를 검증하고 같은 방향으로 화염 파동의 연출과 피해를 처리합니다. 마우스·카메라 조준과 방향 화살표는 제거했습니다. Q/게임패드 R2가 공격, E/게임패드 B가 대시입니다.

원본 `models/ember_dragon.luau`는 ReplicatedStorage.EmberDragonModel로 설치되는 시각 모델 생성기입니다. 서버 전용 Boss 규칙은 계속 서버 진입점 아래에 있습니다. 외형 시연 스크립트는 기본 설치에서 제외했고 기존 Studio 시연 모델은 ServerStorage.WardenShowroom에 보관했습니다.

경험치 자동 흡입 기본 반경은 수평 18스터드 + 자석 단계당 3입니다. 감지되면 gem.collector에 대상을 유지하고, 이동 속도보다 빠르게 따라오며 가까워지면 1회 지급합니다. 수집자가 사망·이탈하거나 카드를 선택 중이면 다른 유효한 근처 참가자를 찾습니다. 경험치는 기존대로 살아 있는 참가자에게 공유합니다.

## 드래곤·마법 연출·적 종류 업데이트

현재 보스 모델은 잿불 비룡 아그니스입니다. Boss의 공격은 eruption(3/5개 반경 4.5 화염 원), breath(입 위치에서 길이 32, 반각 27/32도), dive(폭 10의 이동 경로)입니다. 모든 공격은 방향·위치를 고정한 예고 후 각각 22/17/20 피해를 공격당 한 번 적용합니다. 이전 석상 기사 모델 소스는 보관하지만 기본 설치에 사용하지 않습니다. 보스 등장 때 Waves.ResetSpawn으로 남아 있는 적 탄환도 정리합니다.

Waves는 kind별 체력·속도·행동을 관리하고 Actors.Create의 네 번째 인자로 EnemyModels에 kind를 전달합니다. stalker/skitter/brute/caster/ember 다섯 종류이며, 15/35/50/75초에 새로운 종류가 순차 해금됩니다. caster는 0.8초 준비 후 속도 22의 서버 판정 탄환(피해 6)을 발사합니다. ember는 근처에서 정지해 반경 6, 준비 1.2초의 폭발(피해 12)을 사용하며 빙결 중 도화선은 멈춥니다. 탄환은 최대 20개, 일반 적은 최대 58개입니다. 이 수치는 성능 측정 결과가 아닌 현재 제한값입니다.

SpellArt는 클라이언트 연출만 담당합니다. Effects가 FireWave를 위임하고 dragonBreath/dragonEruption/dragonDive/dragonArrival/enemyExplosion 이벤트를 전달합니다. Beam·Attachment·입자 기반 Q 초승달과 드래곤 화염 효과는 수명이 끝나면 연결과 객체를 정리합니다. Q의 정면 발사와 경험치 자석 동작은 유지합니다. 신규 모델은 직접 작성한 부품/메시 설정으로 재생성되며, 외부 모델 에셋에 의존하지 않습니다.

## 현재 CC0 드래곤 렌더링과 비행 공격

클라이언트 모듈은 현재 20개입니다. EmberDragonModel은 서버 위치·포즈 앵커이며, DragonPresentation이 서버 Root/Animation/PoseProgress를 따라 단일 클라이언트 메시를 표시합니다. DragonMesh는 CC0 원본 메시와 32개 뼈대를 24 FPS로 스키닝합니다. Runtime Mesh / Image APIs 설정이 필요하며, 실패 시 DragonMeshStatus=Failed와 명시적인 Output 경고가 남습니다. 성공 시 Ready입니다. 위의 절차적 드래곤 설명은 이전 시안이며 현재 메시 구현으로 대체됐습니다.

공격 순서: 지상 breath → airBreath(고도 20, 예고한 6개 지점 쓸기) → dive(실제 위치 이동과 착지) → eruption → tail. 비행 고도 >8이면 Q 지상 공격은 닿지 않고, 자동 주문은 기존 거리 판정을 따릅니다. tail은 뒤쪽 반경 9, 16 피해이며 공중 브레스는 예고한 지면에 18 피해를 공격당 1회 적용합니다. 공격 후 회복 시간과 대시 무적은 서버가 처리합니다. FireArt는 화염탄·Q·지상/공중 브레스의 입자 연출만 담당합니다. 원본·라이선스·변환 경로는 ASSET_CREDITS와 assets manifest에 보존합니다.

## 난도·장판 조정 (2026-10-17 후속)

현재 일반 적 기본 체력은 floor((26 + elapsed × 0.35) × 종류 계수)로 연속 증가합니다. 생성 간격은 max(0.36, 1.1 − elapsed × 0.0038)/인원 계수, 속도는 (9 + min(4.8, elapsed/36)) × 종류 계수, 동시 상한은 60입니다. 시작 수치는 유지하고 후반 압박을 소폭 높였습니다.

드래곤 솔로 체력은 2400, 이동 속도 7.5, 일반 회복 시간은 1단계 2.5/2단계 1.9초입니다(돌진 후 3.2초). 폭발 장판 반경은 6.5/7, 공중 쓸기 각 지점은 5.5/6, 착지는 7, 꼬리는 10입니다. 각 공격의 a.radius를 예고·효과·피해에 공유하며 착지의 기존 예고/피해 불일치도 수정했습니다. 폭발 예고는 1.65초, 꼬리 예고는 1.4초입니다. 피해량은 유지합니다. 시각 잔재는 후속 지속 피해를 주지 않습니다.

## 드래곤 관절 변환 수정과 이동 동기화

원본은 관절과 채널 모두 _L/_R 이름을 씁니다. 변환기가 이를 .L/.R로 바꿔 다리/날개 트랙을 누락시키던 오류를 제거했습니다. 변환 때 Walk의 양쪽 앞/뒷다리·날개 트랙을 필수로 확인합니다. 현재 Idle 28, Walk 31, Attack 32, Die 31트랙이며 정적 관절은 원본에서도 채널이 생략됩니다. 변환 배율은 30→36으로 몸체 20% 확대입니다.

DragonPresentation은 실제 수평 이동 거리 /12 × 원본 주기 1.66667로 gaitTime을 누적하여 걸음과 이동을 맞춥니다. DragonMesh는 비행 시 양쪽 날개 관절을 별도로 펼치고 날개 영역을 중심 관절에서 1.7배 확장하며, 다리를 접고 돌진 시 몸체를 앞으로 기울입니다. tail에는 꼬리 관절의 회전을 추가했습니다. 이는 루트의 서버 위치·피해 규칙을 바꾸지 않는 클라이언트 포즈입니다. CPU 스키닝은 24 FPS를 유지합니다.

새 Effect dragonCharge(model, duration)는 브레스 전 입 주변 불씨·빛을 보여줍니다. 클라이언트 DragonMouth(Vector3) 속성은 원본 jaw_upper 관절의 실제 시각 위치이며 피해 판정에 사용하지 않습니다. 지상 브레스 settings에 model 참조를 전달해 입에서 시작하고, 공중 브레스도 같은 속성을 사용합니다. 서버의 예고/피해 시작 위치는 확대된 모델에 맞춰 (0,19.2,-10.2)로 보정했습니다. FireArt 제트 두께와 SpellArt 돌진 잔상을 확대했습니다. 기존 상단 소형 HUD·정면 Q·경험치 자석은 유지합니다.

## 빠른 보스 패턴과 모서리 HUD (2026-10-17 후속)

현재 드래곤 속도는 11.5입니다. 등장 준비 1.6초, 일반 공격 후 회복 1단계 1.5/2단계 1.1초, 돌진 후 1.9초입니다. 지상 브레스는 준비 1초/전체 2.05초/사거리 40/반각 32 또는 38도입니다. 지면 폭발은 준비 1.15초/전체 1.95초/반경 8 또는 9, 중심 간격 10입니다. 공중 공격은 준비 1.25초/쓸기 1.45초/전체 3.95초/반경 7 또는 7.5, 지점 간격 7입니다. 돌진은 준비 1초/비행 0.7초/거리 36/경로 반폭 7/착지 반경 9/전체 2.2초입니다. 꼬리는 준비 0.9초/전체 1.7초/반경 12입니다. 피해량·체력·기본 라운드 시간은 이번 조정에서 유지합니다. 서버의 sweepDuration/travelDuration을 효과 이벤트에도 전달해 실제 이동과 연출이 일치하게 합니다.

HUD의 EncounterPanel(타이머/현재 구간)과 BossPanel은 오른쪽 위에 정렬합니다. PlayerPanel은 왼쪽 아래의 체력·경험치·레벨·처치·자동 스킬·골렘 상태를 묶습니다. 중앙 하단 스킬 패널은 별도로 생성하지 않습니다. PlayerPanel의 폭은 오른쪽 아래 공격/대시 버튼 공간을 고려하여 뷰포트 크기에 맞춥니다. 강화 선택과 종료 화면의 동작은 유지합니다.

## 현재 8종 연속 공격과 착지 강타

이 절이 앞선 난도 수치 기록을 대체합니다. 순서는 breath → airBreath → dive → eruption → tail → flameCross → airCross → airRing입니다. 긴 추적 조건(best<=38)을 없애 멀어도 즉시 다음 공격을 시작합니다. 시작 포효 1초, 패턴 사이 회복 0.35초(2단계 0.2초), 짧은 접근 속도 16입니다. 체력은 2400을 유지했습니다.

| 패턴 | 현재 동작과 범위 | 피해 |
| --- | --- | --- |
| breath | 예고 0.8초, 길이 55, 반각 45/50도, 5갈래 입자 제트 | 17, 1회 |
| eruption | 예고 0.9초, 반경 12/14, 간격 18의 원 3/5개 | 22, 겹쳐도 1회 |
| dive | 준비 0.75초, 46스터드/0.55초 이동, 경로 반폭 11, 착지 반경 16 | 경로/착지 합쳐 20 1회 |
| tail | 예고 0.75초 동안 최대 30스터드 접근, 반경 22/24, 0.6초 몸체 360도 회전 | 20, 1회 |
| flameCross | 길이 72/폭 18의 교차 직선, 0.85/1.35초에 각각 활성 | 교차해도 22 1회 |
| airBreath | 이동하며 고도 24, 반경 10/11의 7개 화염 지점 | 20, 1회 |
| airCross | 공중에서 길이 76/폭 20의 두 직선, 0.85/1.45초 활성 | 22, 1회 |
| airRing | 잠근 표적 주위 반경 25에 원 8개, 각 반경 10/11, 폐곡선 브레스 | 20, 1회 |

세 공중 패턴 모두 이륙 0.85초 + 공격 1.4초 + 가속 하강 0.7초 뒤 착지합니다. 이동 목표는 공격 시작 시점의 표적 근처에 고정하고 수평 위치는 smoothstep으로 보간합니다. 착지 0.95초 전 황금색 원으로 반경 18/22를 경고하며, 내려찍기는 별도 hit 기록으로 26 피해를 1회 적용합니다. 즉 공중 화염에 맞아도 이어지는 착지에는 다시 맞을 수 있습니다. 경고 이후 목표를 쫓아 위치를 바꾸지 않습니다. 직선 화염은 평면 직사각형 판정이며 예고 사각형과 동일합니다. 각 줄은 활성화 시 자기 예고만 제거합니다.

새 Effect: dragonFireLine(from, finish, {halfWidth, model, duration}), dragonTailSpin(model, radius, duration), dragonSlam(point, radius). 모두 서버 판정 이후 표시하는 효과이며 클라이언트 피해 권한은 없습니다. FireArt는 직선 전체의 바닥 화염과 입에서 쓸어내리는 제트를, SpellArt는 회전 궤적과 착지 이중 충격파/먼지/12개 파편을 재생합니다. 기존 공개 소재 외 추가 외부 에셋은 없습니다.

DragonPresentation은 Root를 지수 보간하며 회전 속도에 따라 작은 비행 기울기를 추가합니다. DragonMesh는 비행 자세를 앞으로 기울이고, 착지 구간에 정규화한 progress를 받아 잠깐 눌렸다 복구합니다. 서버 피해와 예고는 보간된 시각 메시가 아니라 실제 Root/공격 데이터에 기초합니다. 모서리 HUD/몸 방향 Q/자석/원본 걸음 모션은 유지합니다.

## 꼬리 공격의 가속·감속과 확인용 체력

현재 tail은 접근/준비 0.85초, 회전 1.35초, 전체 2.4초입니다. 후반 준비 중 몸을 반대쪽으로 18도 비틀고, 회전은 quintic smootherstep(6p^5−15p^4+10p^3)을 사용해 시작·종료 각속도가 0이 되도록 합니다. 중심 회전 구간에서만 빠르게 휘두르며 진행률 0.28 이후 20 피해를 1회 적용합니다. 공격 범위 22/24는 유지합니다. pose progress는 회전 구간의 0~1이며 tailWindup과 tail 모드 사이에 꼬리 관절 각도를 보간해 관성 느낌을 추가합니다. SpellArt의 궤적은 일정 속도로 돌지 않고 Root의 실제 뒷방향을 따라갑니다.

꼬리 정점은 tail1~3의 가중치에 대해 중심 관절에서 꼬리 축 방향으로 1.65배 늘립니다. 몸통과 발/날개 형상은 같은 방식으로 확대하지 않습니다. Session의 STARTING_HEALTH=150은 사용자 요청의 패턴 확인용 시작값이며 참가/재시작에 동일하게 적용됩니다. 체력 강화당 +15 규칙은 유지합니다.

## 현재 공격 간격·날개 비율 미세 조정

공격 사이 회복은 1단계 0.7초, 2단계 0.5초입니다. 각 준비 시간은 0.15초 늘려 브레스 0.95초, 폭발 1.05초, 지상 교차 1초, 공중 이륙 1초, 꼬리 준비 1초, 돌진 준비 0.9초입니다. 후속 구간 길이는 유지하도록 전체 시간도 함께 늘렸습니다. 꼬리 회전의 가속/감속 1.35초, 돌진 비행 0.55초와 모든 공격 반경/피해는 그대로입니다.

DragonMesh의 날개 영역은 중심 관절 기준 가로 1.18배, 세로 1.08배, 앞뒤 1.10배 비율을 추가합니다. 접힌 상태와 비행 상태에 모두 적용하고, 기존 비행 전개 변형은 유지합니다. 몸통·다리·긴 꼬리와 시작 체력150은 이번 조정에서 바뀌지 않았습니다.

## 현재 큰 날개와 긴 꼬리 비율

반복 피드백에 따라 DragonMesh 날개 축 배율을 (1.18,1.08,1.10)에서 (1.90,1.50,1.80)으로 확대했습니다. 비행 전개 시 가로 폭은 약 46.68→75.16으로 커지고 날개막도 넓어집니다. 꼬리 길이 축 배율은 1.65→2.0으로 약21% 추가 연장했습니다. 원본 보존 기하·몸통·다리 크기와 전투 판정/공격 간격/시작 체력150은 유지합니다. 변형은 원본 관절 가중치로 날개와 꼬리 영역에만 적용합니다.

## 개발용 드래곤 외형 뷰어

클라이언트 모듈은 현재 21개입니다. client.luau가 DragonPreview에 player/net/input/hud를 전달합니다. RunService:IsStudio()인 경우만 별도 ScreenGui를 생성합니다. 왼쪽 위 버튼 또는 V로 WorldModel/ViewportFrame/전용 Camera를 열며, 기존 DragonMesh 렌더러와 데이터를 그대로 사용합니다. 실제 전장이나 드래곤은 이동/복제하지 않습니다. 최초 표시 메시를 캐시하고 닫혀 있을 때는 포즈/카메라를 갱신하지 않습니다. GUI 제거 시 메시·입력/렌더 연결을 정리합니다.

서버 Action previewDragon(boolean)은 Studio에서만 수락하고 그 외 환경과 잘못된 타입은 거절합니다. s.previewDragon이 있으면 PlayerState.Paused가 true여서 기존 단일 Heartbeat의 전투/타이머가 정지합니다. Studio 다중 참가자 테스트도 함께 멈춥니다. live membership은 바꾸지 않으며 상태 동기화는 계속 보냅니다. 검사 중 공격/대시/강화/재시작 요청은 차단하고 ready/닫기 요청은 허용합니다. 사망 뒤에도 열고 닫을 수 있습니다. 이탈 시 Session이 해당 states 항목을 제거하므로 검사 일시정지도 해제됩니다.

입력 모듈의 SetSuspended는 로컬 공격/대시를 막으며 뷰어는 기본 이동 Controls를 잠시 비활성화합니다. 닫을 때 HUD 표시·이동 컨트롤·이전 GUI 선택을 복구합니다. 기본/걷기/비행/꼬리 모션, 자동회전·정면/측면·재생 정지를 지원합니다. 궤도 카메라는 뷰포트의 가로세로 비율을 고려하며 드래그/휠로 조절합니다. 실제 게임 Camera는 교체하지 않습니다. Mesh/Image APIs 설정은 동일하게 필요합니다.

## 로비·장착 마법·대형 메테오 (현재)

- Session이 참가자를 `lobby=true`로 생성합니다. PlayerState.RootOf/LiveCount는 로비 참가자를 전투에서 제외하므로 첫 출발 전 타이머·웨이브·경험치가 진행되지 않습니다. LobbyWorld는 전투 런타임 밖 z=150에 절차적 대기 공간을 만듭니다.
- Loadout은 공개 설명 Options, 기본 3종 Defaults, 정확한 1~3 정수 키·서로 다른 허용 ID를 검사하는 Validate를 제공합니다. 클라이언트는 State의 spellOptions만 받아 그립니다. 서버 규칙은 복제하지 않습니다.
- `startRound(ids: string[3])`: 로비·캐릭터 준비·요청 간격 .5초·현재 전투 부재를 확인하고 queued로 표시합니다. 전원 queued면 선택 마법만 rank1로 부여하고 전장으로 이동합니다. `cancelReady()`는 로비의 준비만 취소합니다. 이탈 후 남은 인원이 모두 준비됐다면 출발합니다.
- 전투 종료 후 restart는 기존 전원 종료 검증을 유지하고 로비로 돌려보냅니다. 선택만 서버 메모리에 유지하며 성장·XP·보호막·타이머는 초기화합니다. 서버를 나가면 선택은 유지되지 않습니다.
- Progression은 장착 마법 + 골렘만 선택지에 포함합니다. State에는 lobby/queued/loadout/spellOptions/lobbyMessage/shield/blades/frost/ward를 추가했습니다. 중력 구체는 현재 선택/공격/성장 경로에서 제거했습니다.
- AreaSpells는 서버 시뮬레이션 시계에서 메테오/검무/서리/결계를 처리합니다. 별도 Heartbeat나 지연 콜백 피해를 쓰지 않습니다. ClearProjectiles(source)는 지연 주문과 보호막도 취소합니다.
- `areaCast(anchorName,kind)`는 고유 이름 문자열을 보냅니다. 신규 Instance보다 Remote가 먼저 도착하는 실제 엔진 문제를 확인하여 AreaArt가 런타임 객체를 제한 시간 내 찾아 사용합니다. Elapsed/Duration/Radius/Level이 복제되며 제거 시 렌더 연결을 정리합니다. 클라이언트는 피해를 판정하지 않습니다.
- `meteorHit(position,radius)`는 대형 폭발, `frostHit(position,radius)`는 냉기 파동, `wardHit(position,broken)`는 보호막 타격입니다. 검무는 서버가 3개 회전 위치와 적의 거리를 비교하고 적마다 .65초 타격 간격을 둡니다. 서리는 보스 빙결을 건너뜁니다. PlayerDamage는 Waves/Boss의 기존 무적·단일타격 검증 뒤 보호막을 먼저 소진합니다.
- 모듈 추가: server flow/Loadout, shared/PlayerDamage, world/LobbyWorld; client flow/Lobby. 진입점과 Source 전체를 함께 설치해야 합니다.

## Q 선택과 주문 연출 재작업

Loadout.ActiveOptions/ActiveNames/ValidateActive가 fireWave/thunder/iceRush만 허용합니다. Action의 startRound는 자동 마법 3종 배열 다음 인자로 Q ID를 받습니다. 생략 시 기존 선택 또는 fireWave를 유지하므로 기존 호출은 호환됩니다. Session은 activeSkill/activeName을 저장하고 로비에 activeOptions를 전송합니다. HUD는 선택된 이름을 표시하며 Input의 Q/R2/화면 버튼은 기존 fireWave 의도를 그대로 사용합니다. Combat.RequestWave의 기존 상태/쿨다운/방향 검증 뒤 선택에 따라 ActiveSpells로 분기합니다.

ActiveSpells는 0.4초 준비를 공유 시뮬레이션에서 진행하고, 출발 시 고정한 origin/direction으로 한 번 판정합니다. thunder는 길이52/반폭4 및 공중 허용, iceRush는 길이34/반폭6의 지상 공격·일반 적 빙결/밀치기이며 보스 빙결은 제외합니다. activeCast(anchorName,kind)로 준비 포탈을 표시하고 activeStrike(origin,direction,settings)로 낙뢰/빙하 기둥을 표시합니다. ClearProjectiles(source)는 준비 중 Q도 취소합니다. 피해는 서버만 적용합니다.

메테오는 Duration 3.2초, 시작 높이76, 감소 속도가 줄어드는 낙하 곡선으로 외형을 더 오래 보여줍니다. 비전 연검은 3줄 × (6+단계×2) 파편을 서버/클라이언트 동일 위상·각속도1.7·반경(11+단계×.7)으로 회전시킵니다. 파편별 근접거리2.1, 적별 .65초 타격 간격은 파편 수에 관계없이 적용됩니다. 서리 준비는 .75초이며 피해/범위/빙결 수치는 유지하고 응축·다중 파동·큰 결정·안개를 보강했습니다.

## 스킬 이펙트 갤러리

클라이언트 flow/SkillPreview가 Studio 전용 UI·카메라·입력 복구를 관리하며 combat/PreviewScene이 별도의 로컬 Workspace.SkillPreviewStage(x=6000,z=6000)를 만듭니다. 실제 파티클/Trail/Beam/PointLight를 재사용하기 위해 별도 월드 공간과 Scriptable 카메라를 사용합니다. 실제 캐릭터·적·장착·피해·XP에는 접근하지 않습니다.

Effects는 `deps.folder`와 `listen=false`를 선택적으로 받고 `Play(kind,a,b,c)` / `Disconnect()`를 반환합니다. 일반 전투는 기존 Remote 구독을 유지하며 갤러리는 구독 없이 같은 렌더러만 사용합니다. AreaArt의 직접 앵커 지원과 동일하게 ActiveArt.Charge/Effects.iceProjectile도 로컬 앵커 Instance를 받을 수 있습니다. 일반 전투의 문자열 이름 방식은 유지합니다. PreviewScene은 local anchor.Elapsed/Launched와 이벤트 큐만 진행합니다. 초기화 시 앵커를 제거하여 연결된 렌더 콜백을 정리하고 기존 효과 폴더를 재사용합니다.

새 Action `previewSkills(bool)`는 기존 previewDragon과 동일하게 Studio + boolean 검증 후 서버 상태에 기록합니다. PlayerState.Paused는 두 플래그 중 하나라도 참이면 멈춥니다. 해당 상태에서는 다른 gameplay Action을 거절하며 닫기 요청은 계속 허용합니다. 플레이 중이 아니거나 이미 패배해도 연출은 볼 수 있습니다. 서버에 미리보기 stage/투사체/피해 객체를 만들지 않습니다.

SkillPreview와 DragonPreview는 명시적인 Close/beforeOpen 콜백으로 서로 닫고 전환합니다. Lobby는 SkillPreview.Open 동안 메뉴를 숨기며 종료 시 카메라 타입·피사체·FOV·시점, 입력, 이전 선택과 로비/HUD를 복구합니다. 기본 Roblox 체력 재생 스크립트는 갤러리가 제어하지 않습니다.

## 무제한 보스전·수직 검진·뇌창·단일 대상 마탄 (이전 구현)

Boss.Resolve의 시간 초과 패배 분기를 제거했습니다. bossLimit 설정은 사용하지 않으며 보스가 살아 있으면 경과 시간이 얼마든 전투가 계속됩니다. 사망/처치/재시작 규칙은 유지합니다. State.time은 보스전에서 경과 시간이고 HUD는 제한 없음/∞로 표시합니다. 공략 시간 초과 결과 문구는 제거했습니다.

blades ID는 기존 장착 호환을 위해 유지하고 이름은 비전 검진으로 변경했습니다. (6+단계)자루의 긴 수직 검이 y축 각속도1.3/반경(11+단계*.7)로 회전합니다. 서버와 클라이언트는 같은 위치를 사용하며 적마다 .65초 피해 제한을 유지합니다. 파편 연검/연결선 방식은 사용하지 않습니다.

thunder ID는 뇌창으로 변경했습니다. ActiveSpells가 준비 .4초 후 48스터드/초로 최대52를 비행하는 실제 서버 앵커를 움직입니다. 이전/다음 위치의 3D 선분 거리2.4 안에서 각 적을 한 번씩 타격하며 지형 Raycast에 막힙니다. 낮게 쏘므로 높은 공중 드래곤에 자동으로 닿지 않습니다. ProjectileArt는 같은 앵커로 긴 축·실제 꼭짓점이 있는 창날·전류·꼬리를 표시합니다. activeCast 포탈은 Launched가 참이면 정리됩니다. thunderSpear(anchorName)/thunderHit(position)는 시각 이벤트입니다.

HomingMissiles는 Combat.StepPlayer에서 발사, 공유 StepProjectiles에서 비행을 처리합니다. 보스>높은 체력 우선으로58 이내 목표를 고르고 각 마탄이 한 대상에만 피해를 줍니다. 등급별 2~4발, 44스터드/초, 생존 시간3.5초, 선택 중 정지/사망·이탈 정리/대상 사망 시 재탐색입니다. homingMissile(anchorName)/missileHit(position)는 클라이언트 시각 이벤트입니다. 새 missile ID를 장착/성장/State/HUD/갤러리에 함께 연결했습니다.

## 2026-10-17 비전 결정·뇌창 외형·시작 카메라 (초기 구현)

- `blades` ID는 유지하고 비전 결정으로 교체했습니다. Combat이 새 `ArcaneCrystals`를 명시적으로 구성합니다. AreaSpells의 회전 검 피해는 제거했습니다. 작은 어깨 결정은 3/4/5개이며 가장 가까운 45스터드 이내 적을 발사 순간 조준합니다. 주기 max(.35,.85-단계*.07), 속도60, 수명1.2초, 피해9+단계*4의 직선 단일 타격입니다. 추적 마탄과 달리 유도/범위 피해가 없습니다. 서버 선분 판정·지형 충돌·선택 중 정지·재시작/퇴장 정리를 처리합니다.
- 클라이언트 AreaArt가 작은 어깨 결정을 표시하고 ProjectileArt가 `crystalBolt`/`crystalHit`를 표시합니다. 앵커 이름 전달 방식을 유지합니다. 미리보기도 같은 렌더러를 사용합니다. 뇌창은 닫힌 입체 창날·금색 장식·전류 고리·동적 Beam·입자를 추가했고 피해/쿨다운은 유지했습니다.
- Camera 팩토리가 Reset/Suspend/Restore를 반환하며 Lobby와 SkillPreview가 같은 인스턴스를 받습니다. 캐릭터 생성과 전투 진입 시 짧은 렌더 단계 초기화로 뒤24/위14, FOV70 시점을 설정한 뒤 Custom/줌8~85로 넘깁니다. 미리보기는 기존 정상 시점의 거리/각도를 복구하며 유효하지 않은 스냅샷은 기본 시점으로 초기화합니다.

## 2026-10-17 다섯 결정·천공의 창·혼합 무리 (현재)

- ArcaneCrystals의 blades ID는 유지합니다. 결정은 모든 단계에서 5개이며 등 뒤 부채꼴 위치를 서버/미리보기/AreaArt에서 동일하게 계산합니다. Fired 속성으로 발사한 결정을 숨기고 5발 이후 4.4-단계*.35초 충전합니다. 발사 간격 .18초, 사거리48 이내 가까운 최대5개 목표를 분배하고 속도48/수명2초/지수 대신 dt*7 방향 보간의 유도탄을 사용합니다. 피해10+단계*4, 선분1.3 판정이며 첫 한 적에만 피해를 주고 벽에 막힙니다. 기존 missile은 강한 적 우선의 별도 주문입니다.
- 새 자동 마법 skyLances는 Loadout/Session/Progression의 장착·강화·State와 HUD/SkillPreview에 연결했습니다. Combat은 SkyLances를 명시적으로 구성하고 ClearProjectiles에서 함께 취소합니다. 54 이내 밀집한 적을 선정하고 이동하는 일반 적은 속도*1.3초만큼 예상합니다. 중심/네 방향5스터드의 다섯 지점 위44에서 .9초 준비 후 .16초 간격으로 .85초 동안 가속 낙하합니다. 실제 세로 선분 반경3.3 판정, 창마다 적별1회, 피해25+단계*8, 쿨다운11-단계*.4초. 정지/사망/퇴장/재시작은 기존 서버 시뮬레이션과 같은 경로입니다.
- SkyLanceArt는 areaCast(anchorName,skyLances)의 Elapsed를 읽어 공중 이중 마법진과 5개 창을 렌더합니다. skyLanceHit(point,3.3)은 좁은 지면 파동입니다. 미리보기는 같은 렌더러와 낙하 식을 재사용하며 피해는 없습니다. 뇌창은 17길이 금속 창대와 금빛 마디, 전체 약24길이로 늘렸습니다. Q 판정/쿨다운은 유지했습니다.
- Waves는 max(.28,.8-elapsed*.0035)/인원계수로 생성하고 상한84를 적용합니다. 18초마다 양쪽에서3개씩 추가 무리, 거미12/갑각수28/돌진형32/마도사42/폭발형60초 해금. 돌진형 charger는 .85초 주황색 경로 예고 후 방향을 고정해 속도34로 .65초 돌진하고 4.5초 쉽니다. 접촉 피해12, 빙결 중 준비/이동은 멈춥니다. 거미는 접근 중 측면 이동, 마도사는 근거리 횡이동을 추가했습니다.
- 65초 이후 생성 번호9의 배수는 정예로 크기1.2/체력1.75배와 금빛 표식을 주며 Combat의 처치 경로에서 경험치3개를 생성합니다. 보스전은 기존처럼 일반 생성이 중단됩니다. 새로운 외부 자산은 없습니다.

## 2026-10-17 다섯 빛과 별도 Q 성운창

- blades는 OrbitLight 모델5개(둥근 LightCore/LightHalo/SoftAura와 작은 입자)로 표시합니다. Wedge 결정과 결정탄의 네모 날개는 제거했습니다. 서버/AreaArt/PreviewScene의 위치 식은 sin(angle)*4.2, 3.2+cos(angle)*1.7, z1.8로 일치시켜 머리 위에 간격을 확보했습니다. Fired에 맞춰 형상·입자·조명을 함께 숨깁니다. 피해/충전 규칙은 유지합니다.
- 기존 thunder와 별도로 aetherLance를 ActiveOptions/ValidateActive에 추가했습니다. 로비는 사용 스킬 수에 맞춰 버튼 너비를 계산하며 네 버튼이 패널 안에 들어갑니다. Session의 기존 선택/상태 동기화 계약을 재사용하고 ActiveSpells는 새 ID도 검증합니다. 성운창은 기존 뇌창과 준비/비행/피해/벽 충돌/취소 규칙을 공유하는 시각 변형입니다. 새 클라이언트 의도나 피해 권한은 없습니다.
- ProjectileArt는 aetherLance를 명시적인 하위 렌더러 AetherLanceArt로 전달합니다. 0.4초 준비 중 흐릿한 잔광에서 가는 본체를 드러내고 청색/보라색 곡선 Beam·내장 연무/별빛 입자·Trail로 비행을 표시합니다. 기존 thunder의 넓은 창날/금속 창대/금색 장식/고리를 복구해 유지합니다. ActiveArt는 성운창에서만 별도 포탈을 생략합니다.
- Effect aetherSpear(anchorName)/aetherHit(position)를 추가했습니다. SkillPreview/PreviewScene에 독립 항목을 추가하고 실제 렌더러를 재사용합니다. 사용자 참고 ZIP은 JPG 열람만 했고 원본 자산을 포함하지 않았습니다.

성운창 판정 폭 후속 조정: ActiveSpells의 선분 거리 계산에서 aetherLance만 수평 좌표를 .5배로 정규화합니다. 가로 반폭2.4→4.8, 수직 반경2.4 유지. 이펙트/속도/사거리/피해/쿨다운과 thunder 판정은 유지합니다.

드래곤 체력 후속 조정(2026-10-17): 기본 체력2400→2880(+20%). 협동 인원당 +70% 배율과 체력50%의 2단계 전환 규칙은 유지합니다.

## 2026-10-18 최종 통합 상태

이 절이 아래 기능의 현재 동작입니다. 앞 절의 과거 슬롯 수/화염 파동 설명은 이전 구현이며, 시각 조정 이력과 관찰 결과는 PLAYTEST_NOTES.md에 남깁니다.

### 로비와 성장

Loadout.SlotCount=4: 1~4 연속 정수 키에 서로 다른 허용 ID 네 개만 수락합니다. 자동 마법은 ice/lightning/meteor/blades/skyLances/frost/missile/ward/lightRing 아홉 종류입니다. 기본 조합은 ice/meteor/blades/lightRing. 레벨업 카드는 세 개이며 장착 마법과 골렘/생존 강화만 제시합니다. 화염탄은 자동 발사/강화 목록에서 제외됐고 별빛 소용돌이는 폐기됐습니다.

Q 옵션은 fire/thunder/aetherLance/iceRush 네 종류이며 기본은 fire(화염탄)입니다. fireWave 장착 요청은 거부합니다. 기존 Action fireWave와 Combat.RequestWave는 호환을 위해 일반 Q 입력의 내부 이름으로 유지합니다. 화염 파동의 절차적 렌더러는 나중에 개선할 수 있게 남아 있지만 게임 선택/미리보기/효과 분배에서는 사용하지 않습니다.

### 기본 공격과 성운 광륜

basicAttack Action은 대상/피해/프로필 인자가 없는 발사 의도입니다. 로비·사망·선택·미리보기·정지와 서버 쿨다운을 검사하고 캐릭터 정면으로 발사합니다. 좌클릭/F/R1/화면 버튼 홀드는 .1초마다 의도를 보내며 서버가 .3초 간격을 보장합니다. 해제·포커스 이탈·캐릭터 제거·메뉴 진입 시 홀드를 정리하고 터치는 시작한 포인터와 해제를 짝짓습니다.

Weapons.starlightWand는 피해13/속도80/거리52/반경1.6/간격.3이며 잘못된 프로필 ID는 기본값으로 대체합니다. BasicAttack은 실제 이동 선분의 첫 적 한 명과 벽을 검사합니다. 무기 인벤토리/획득은 미구현입니다.

LightSpells는 공유 StepPlayer/StepProjectiles에 연결됩니다. 성운 광륜은 속도34로 거리38까지 완만하게 휘며 나갔다가 현재 주인 위치로 귀환합니다. 반경3.3 판정, 적별 출발/귀환 각1회 피해18+단계*8, 쿨다운4.8-단계*.25초, 최대4초 생존입니다. 출발/귀환 모두 벽을 검사하고 선택 중 정지·사망/복귀 시 정리합니다. LightArt는 지표면에 평행한 초승달, 2→8rad/s 수평 회전, 양 끝 빛 꼬리를 표시합니다.

### Q와 이펙트

ActiveSpells.fire는 즉시 정면 발사되는 서버 투사체입니다. 속도58/거리42/충돌반경2.4/쿨다운7초이며 첫 적 또는 벽 충돌 때 반경5에 피해75를 줍니다. 서버 앵커를 fireProjectile(anchorName) 효과로 전달하고 FireArt.Projectile이 따라갑니다. 사망/복귀/범위/충돌 시 앵커를 제거합니다. 갤러리도 로컬 앵커를 사용해 같은 렌더러를 재생합니다.

화염탄 최종 외형은 첫 붉은 외곽 버전으로 복원했습니다: 작은 주황 중심(.22*size, 투명도.8), 붉은 외피(.52*size, 투명도.9), 회전하는 표면 불꽃, 뒤로 휘는 3개 텍스처 불길/얇은 내부 빛과 11개 꼬리 입자층입니다. 꼬리는 머리 크기 인자의3.2~4.3배입니다. 별도 참조 이미지를 붙이지 않고 내장 텍스처와 절차적 형상을 사용합니다. 잔광 .14초, 작은 잔불 .08~.16초, 도착 시 본체 즉시 숨김/잔여 루트 .18초 정리입니다. 고정 바닥 불길/추가 폭발은 없습니다. 드래곤 전용 화염은 변경하지 않았습니다.

빙하 쇄도는 .4초 준비 후 .075초 간격의 일곱 열이 가까운 곳부터 생성됩니다. 길이34/반폭6, 열마다 실제 피해 판정, 적별 한 번의 피해와 일반 적 빙결/밀치기, 보스 빙결 면역입니다. GlacialArt는 일곱 큰 결정/옆 결정, 지면 생성 섬광, 서리와 작은 파편을 표시하고2초 안에 정리합니다. 성운창만 수평 판정 폭을 넓혔으며 원래 뇌창 범위는 유지합니다.

LightningArt는 하늘의 흰 중심/푸른 코로나, 굵은 하단 보조 전류, 지면 방전과 청색/보라색 확산 고리를 사용합니다. 기존 연쇄 피해 규칙과 .85초 효과 수명을 유지합니다.

결계 앵커는 OwnerUserId를 기록합니다. AreaArt는 해당 캐릭터 위치를 매 프레임 직접 사용하고, 소유자가 없는 갤러리는 고정 앵커를 사용합니다. 피해 흡수 규칙은 동일합니다.

Effect 계약 추가: lightCast(anchorName,kind), lightHit(position,kind), basicBolt(anchorName), basicHit(position), fireProjectile(anchorName). 클라이언트는 피해를 계산하지 않습니다. 새 모듈은 src/에서 관리하며 install.luau는 생성합니다.

### 도전 중단과 검증

인자 없는 returnToLobby Action만 허용합니다. Session은 현재 상태 동일성/로비/복귀 중/재시작 중을 검사하고 대시·발사체·선택·미리보기를 정리합니다. 조합/Q 선택은 같은 접속 중 보존합니다. 동료가 싸우고 있으면 본인만 로비로 재생성하고, 마지막 전투 참가자라면 적·구슬·보스·시간을 전체 초기화합니다. 영구 보상은 지급하지 않습니다. HUD 오른쪽 위 버튼은 카드 선택 중에도 접근 가능하며 패배 화면도 같은 복귀 경로를 사용합니다.

자동 검사, 기존 연결 Studio 엔진 fixture, 단일 클라이언트 UI 조작은 확인했습니다. 새 Baseplate 전체 설치, 실제 두 클라이언트/모바일/패드/최대 부하 성능과 최종 미적 평가는 미검증입니다. 구체적인 검증 기록은 PLAYTEST_NOTES.md를 참고하세요.
