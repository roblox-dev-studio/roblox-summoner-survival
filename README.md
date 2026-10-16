# 소환사 서바이벌 · Roblox Summoner Survival

마법과 소환수로 몰려오는 적을 상대하며 **3분 동안 살아남는 Roblox 게임 프로토타입**입니다. 직접 이동하고 대시하면서, 경험치를 모아 새로운 마법을 배우거나 능력을 강화합니다.

## 시작하기

1. 이 저장소를 ZIP으로 내려받거나 복제합니다.
2. Roblox Studio에서 **새 Baseplate 프로젝트**를 엽니다.
3. Studio의 **Command Bar**를 엽니다. 재생 전 편집 상태에서 실행해야 합니다.
4. [install.luau](install.luau)를 텍스트 편집기로 열고 전체 내용을 Command Bar에 붙여 넣어 실행합니다.
5. 설치 완료 메시지를 확인하고 프로젝트를 저장한 뒤 **▶ Play**를 누릅니다.

설치기는 전장, 서버·클라이언트 스크립트, 통신 이벤트를 생성합니다. 같은 이름의 기존 객체가 있으면 중단하므로 **빈 프로젝트에서 시작하세요**. GitHub 코드를 받아 Studio에서 실행하는 방식이며, Roblox에 배포된 게임 링크는 아직 포함하지 않습니다.

## 조작

| 입력 | 동작 |
| --- | --- |
| WASD | 이동 |
| 마우스 우클릭 드래그 / 휠 | 카메라 회전 / 확대·축소 |
| Q | 전방 화염 파동 · 재사용 대기시간 7초 |
| E | 이동 방향으로 대시 · 재사용 대기시간 3초 |
| 레벨업 카드 클릭 | 마법 습득 또는 능력 강화 |

화염 파동과 대시는 화면 버튼으로도 사용할 수 있습니다. 기본 마법과 소환수 공격은 자동입니다. 혼자 플레이할 때는 레벨업 선택 중 전투가 멈춥니다.

## 구현된 요소

- 독립적으로 적을 찾아 이동하는 골렘과 밀집한 적을 노리는 자동 대지 강타.
- 불꽃과 불씨로 퍼지는 화염 파동, 자동 화염탄.
- 위에서 내려꽂힌 뒤 바닥으로 전류가 퍼지는 연쇄 번개.
- 공중 마법진에서 발사되는 얼음창, 적중 시 밀치기·빙결·둔화.
- 5단계까지 성장하는 마법·골렘과 체력·이동 속도·경험치 수집 범위 강화.
- 경험치 수집, 레벨업 선택지, 승리·패배와 재시작.

현재는 **골렘 효과 확인 모드**가 켜져 있습니다. 1단계에서도 5단계의 외형 효과를 보여주지만 피해량은 실제 단계 기준입니다. 단계별 연출을 사용하려면 [Combat.luau](src/server/combat/Combat.luau)의 `PREVIEW_MAX_GOLEM_EFFECTS`를 `false`로 바꾸세요.

협동용 서버 처리와 경험치 공유의 기반은 있지만 여러 클라이언트를 사용하는 협동 플레이와 모바일 기기 검증은 아직 하지 않았습니다. 드래곤, 보스 전투, 장기 저장, 완성된 진화 시스템은 미구현입니다.

## 소스 구성

| 파일 | 역할 |
| --- | --- |
| [arena.luau](arena.luau) | 전장과 조명 생성 |
| [server.luau](server.luau) | 서버 모듈 연결, 요청 분배, 단일 시뮬레이션 루프 |
| [client.luau](client.luau) | 클라이언트 모듈 시작 |
| [src/server](src/server) | 전투·적·성장·라운드의 서버 규칙 |
| [src/client](src/client) | 입력·효과·HUD·카메라 |
| [install.luau](install.luau) | 빈 Studio 프로젝트용 통합 설치기 |
| [ASSET_CREDITS.md](ASSET_CREDITS.md) | 외부 소재의 출처와 이용 조건 |
| [docs/PLAYTEST_NOTES.md](docs/PLAYTEST_NOTES.md) | 개발 중 플레이 점검 기록 |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 세 기능 영역과 모듈·통신 계약 |
| [AGENTS.md](AGENTS.md) | AI 에이전트 공통 작업 규칙 |

소스 수정 후 Python 3으로 설치기를 다시 생성합니다.

```sh
python3 tools/build_installer.py
python3 tools/check.py
```

검사 도구는 처음 한 번 `python3 tools/bootstrap_luau.py`로 준비합니다.
설치기는 각 진입점 아래 `Modules` 폴더와 ModuleScript를 함께 만듭니다.
**진입점 두 개만 복사하면 실행되지 않습니다.** 기존 단일 스크립트 버전에서 전환할 때는
새 Baseplate에 갱신된 `install.luau` 전체를 설치하세요. 기존 place를 자동 덮어쓰지 않습니다.

## 함께 개발하기

버그와 아이디어는 Issues에, 변경 제안은 Pull Request에 올려 주세요. [CONTRIBUTING.md](CONTRIBUTING.md)에 참여 방법이 있습니다.

Roblox 내장 텍스처와 Creator Store의 바위 메시를 사용합니다. 바위 메시를 불러오지 못해도 기본 파편 효과로 동작합니다. 제3자 소재의 이용 조건은 [ASSET_CREDITS.md](ASSET_CREDITS.md)에 기재되어 있습니다. 프로젝트 코드의 별도 오픈소스 라이선스는 아직 지정하지 않았습니다.
