# 모듈 구조와 기능 분담

세 사람 모두 서버·클라이언트를 개발합니다. 작업 하나를 맡으면 해당 기능의 규칙,
화면, 효과와 검증까지 연결합니다. 담당자는 이슈마다 정하고 서로 리뷰합니다.

| 기능 영역 | 수정할 곳 | 범위 |
| --- | --- | --- |
| 전투·마법 | `src/server/combat/`, `src/client/combat/` | 마법, 골렘, 피해, 대시, 입력, 전투 효과 |
| 적·웨이브·월드 | `src/server/world/`, `src/client/world/`, `arena.luau` | 적 생성·추적·접촉 피해, 전장, 카메라 |
| 성장·게임 흐름 | `src/server/flow/`, `src/client/flow/`, `src/client/Theme.luau` | 경험치, 카드, 시작·종료·재시작, HUD |
| 공동 연결부 | 루트 진입점, `src/server/shared/`, `tools/`, `.github/` | 의존성 연결, 공통 모델·조회, 설치·검사 |

현재 전달받은 GitHub 계정은 `hoo9543`, `kcm0147`, `pyj7628`입니다.
앞 두 계정은 조회됐고 `pyj7628`은 2026-10-16 조회에서 404였습니다.
이는 입력 문자열을 영문 키보드로 환산한 값이며 마지막 아이디와 역할 배정은 확인이 필요합니다.
아직 CODEOWNERS를 설정하지 않았습니다. 존재하는 계정이라도 저장소 권한 확인 없이
필수 리뷰어로 지정하지 않습니다.

이 표는 현재 코드 구조다. [새 기획](design/FIRST_VERSION.md)에서 소환수는 후속으로 미뤘으며,
현재 골렘 사용처를 기본 루프에서 분리하는 작업은 M0에 남아 있다.

## Studio 설치 결과

```text
ServerScriptService
└── SummonerServer (server.luau)
    └── Modules (src/server)
        ├── combat: Combat, Movement
        ├── world: Waves
        ├── flow: Progression, Session
        └── shared: Actors, PlayerState
StarterPlayer / StarterPlayerScripts
└── SummonerClient (client.luau)
    └── Modules (src/client)
        ├── combat: Input, Effects
        ├── world: Camera, CharacterMotion, clips (4 CC0 R15 clips)
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
초기화합니다. 클라이언트는 Input → HUD → Effects → Camera → CharacterMotion 순서로 시작합니다.

## 서버 인터페이스

| 모듈 | 공개 함수 | 관리하는 상태 |
| --- | --- | --- |
| Actors | `Block`, `Create` | 절차적 적·골렘 형상 |
| PlayerState | `RootOf`, `LiveCount`, `Paused` | 상태를 조회하며 변경하지 않음 |
| Movement | `RequestDash`, `Step`, `FinishDash` | 대시·무적·이동 복구 |
| Progression | `Sync`, `Drop`, `Choose`, `Collect`, `Need`, `LevelCheck` | XP·카드·강화·경험치 구슬 |
| Combat | `StepPlayer`, `StepProjectiles`, `ClearProjectiles`, `RequestWave` | 공격·골렘 AI·얼음창·적 피해 |
| Waves | `Spawn`, `Step`, `ResetSpawn` | 생성 간격·적 AI·접촉 피해 |
| Session | `AddPlayer`, `RemovePlayer`, `EndPlayer`, `Restart` | 참가·사망·라운드 초기화 |

단일 Heartbeat가 기존 순서를 유지합니다: 라운드 시간/승리 → 적 생성 → 대시 → 얼음창
→ 적 이동·접촉 피해 → 플레이어 경계·골렘·자동 공격 → 경험치 수집 → 0.2초 간격 HUD 동기화.
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
| `fireWave` | 없음 | 상태·쿨다운·정면 범위와 피해를 서버에서 판정 |
| `restart` | 없음 | 요청자 종료 상태 및 모든 참가자 종료 여부 확인 |

`State`는 서버 스냅샷이며 `Progression.Sync`가 필드를 정의하고 `HUD`가 소비합니다.
`Effect`는 `hit`, `golemCharge`, `golemHeavy`, `golemLight`, `dash`, `fire`, `fireWave`,
`lightning`, `iceCast`, `iceHit` 연출을 전송합니다. 클라이언트 효과는 피해를 결정하지 않습니다.
새 이벤트나 필드 변경은 생산자·소비자를 같은 PR 또는 명시적 호환 단계로 배포합니다.

현재 프로토타입에는 `ready` 등 모든 요청을 포괄하는 별도 속도 제한이 없습니다.
이번 구조 분리로 보안·협동 완성도를 보장하지 않습니다. 공개 출시 전에 별도 검증이 필요합니다.

## 보존한 동작과 한계

- 180초 생존, 기존 피해·쿨다운·출현 수치, 경험치 공유, 혼자 선택할 때의 일시 정지를 유지했습니다.
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
