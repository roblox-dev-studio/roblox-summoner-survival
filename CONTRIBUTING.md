# 참여 방법

버그를 제보할 때 재현 순서, 기대한 동작, 실제 동작, 사용 기기와 Studio Output의 오류를 적어 주세요. 계정 토큰이나 비밀번호는 올리지 마세요.

## 세 사람의 작업 방식

전투·소환 / 적·웨이브·월드 / 성장·게임 흐름으로 작업을 나눕니다.
각자 맡은 기능의 서버 코드와 클라이언트 표현을 함께 개발합니다.
영구 담당은 아직 정하지 않았으며, 작업마다 이슈에 담당자와 리뷰어를 적습니다.
파일 지도는 [ARCHITECTURE.md](docs/ARCHITECTURE.md)를 참고하세요.

1. 이슈에 목표, 수정 영역, 완료 조건 1~3개를 적고 담당자 1명을 정합니다.
2. 최신 `main`에서 `feat/<issue>-<topic>` 또는 `fix/<issue>-<topic>` 브랜치를 만듭니다.
   저장소 쓰기 권한이 없다면 Fork에서 작업합니다.
3. 각 개발자의 AI는 그 개발자의 로컬 복제본에서 작업합니다. 같은 컴퓨터의 여러
   에이전트라면 독립 worktree를 쓰거나 명확히 다른 파일만 맡깁니다.
4. 기능 모듈을 수정합니다. 공유 진입점·네트워크 형식·모델 속성 변경은 관련 팀원에게 먼저 알립니다.
5. 설치기 재생성, 자동 검사, 영향받은 실제 플레이 검사를 합니다.
6. 작은 PR을 만들고 다른 팀원 1명이 리뷰합니다. 승인 후 당번 통합자가 병합합니다.
   통합자는 세 명 중 순번으로 맡으며 별도 전담 인원을 두지 않습니다.
7. 통합자는 합쳐진 `main`으로 설치기를 재생성/검사하고 새 테스트 place에서 확인합니다.
   각자 자기 브랜치가 통과했다는 것만으로 통합이 통과한 것은 아닙니다.

`v1`, `v2`라는 이름의 Script 복사본을 Studio에 쌓지 않습니다. 버전은 Git 커밋과 PR로
추적하고, 실행할 place 파일은 검증한 커밋을 파일명이나 기록에 연결합니다.

## 새 팀원의 첫 실행

필수: Git, Python 3.9 이상, Roblox Studio. AI 도구는 각자의 계정을 사용합니다.
이 하네스는 별도 유료 API, 공용 토큰, 추가 에이전트 서비스를 요구하지 않습니다.

```sh
git clone https://github.com/roblox-dev-studio/roblox-summoner-survival.git
cd roblox-summoner-survival
python3 tools/bootstrap_luau.py
python3 tools/check.py
```

처음 한 번 공식 Luau 0.742 도구를 받아 SHA-256을 확인합니다. `.tools/`는 Git에서 제외됩니다.
이후 소스를 수정하면 다음 명령을 실행합니다.

```sh
python3 tools/build_installer.py
python3 tools/check.py
```

마법/증강 정의 또는 `assets/ui/skill-icons/manifest.json`을 바꿨다면 먼저
`python3 tools/build_skill_catalog.py`를 실행합니다. 생성된 `data/skills.json`,
`docs/SKILL_CATALOG.md`, `SkillIcons.luau`를 직접 수정하지 않습니다.
아이콘의 로컬 PNG·원본 생성 프롬프트·SHA-256과 실제 Roblox 업로드 ID를 구분하여 관리합니다.

검사 범위: 설치기와 소스 일치, 모듈 패키징, Luau 문법, 허용된 Roblox 전역 외 누락 참조,
선택지 처리의 제한된 로직 회귀 시험. 전체 Roblox 타입 검사나 실제 엔진 시험은 아닙니다.
Studio 검사는 [PLAYTEST_CHECKLIST.md](docs/PLAYTEST_CHECKLIST.md)를 사용합니다.

## Studio와 Git을 함께 쓰는 규칙

- 각자 새 Baseplate에서 자기 브랜치를 시험합니다. `install.luau` 전체를 **편집 모드** Command Bar에 실행합니다.
- 이미 설치된 place에 재설치하지 않습니다. 첫 구조 전환은 새 Baseplate에 설치하고 비교합니다.
- 이후 개별 모듈만 갱신할 때는 해당 ModuleScript의 Source를 바꾸되, Play를 멈추고 재시작합니다.
  진입점·폴더 구조가 바뀌면 새 place에서 전체 설치를 다시 검증합니다.
- Team Create는 함께 월드/에셋을 편집할 때 사용합니다. 같은 Script를 Git과 Studio에서 동시에 수정하지 않습니다.
  공동 Studio에 현재 입력·설치·저장·테스트할 사람은 한 명으로 정합니다.
- Studio에서 만든 자산은 재가져오기 가능한 `.rbxmx` 등과 출처·배치 경로를 PR에 포함합니다.
  큰 바이너리는 팀이 정한 저장소/LFS 경로와 버전·해시를 기록하고, 파일만 로컬에 둔 채 납품했다고 하지 않습니다.
- 이번에는 기존 Command Bar 설치 방식을 유지합니다. Rojo 실시간 동기화 도입은 별도 변경으로 검증합니다.

## 충돌·실패 처리

`install.luau` 충돌은 내 것/상대 것 전체 선택으로 해결하지 않습니다.
먼저 `src/`, 진입점, 설치 헤더의 충돌을 해결하고 설치기를 다시 생성합니다.
모르는 팀원 변경을 지우지 말고 작성자에게 연결부 의도를 확인합니다.
회귀가 나면 원인 PR을 `git revert`하는 별도 PR로 되돌리고 마지막 통과 커밋의 설치기를 사용합니다.

## 저장소 관리자 초기 설정

이 문서와 workflow 파일만 추가해도 GitHub 병합 제한이 자동 활성화되지는 않습니다.
workflow가 한 번 실행된 뒤 관리자가 `main` 규칙에 다음을 설정합니다.

- PR을 통해 병합, 다른 팀원 승인 최소 1개, 대화 해결 필수.
- `source-checks` 상태 검사 필수, 가능하면 최신 base 반영 후 병합.
- 강제 push와 브랜치 삭제 제한. 초기에는 관리자도 같은 리뷰 절차 사용.
- 세 사람 계정·쓰기 권한 확인 후 역할 합의. CODEOWNERS는 그 뒤 필요한 경로에만 추가.

CI는 PR 코드를 실행하므로 `pull_request_target`이나 쓰기 토큰·배포 비밀을 제공하지 않습니다.
게임 게시와 결제 설정은 별도 사용자 승인 작업입니다.

설치기만 직접 수정하면 다음 생성 때 덮어써집니다. 설치 절차 변경은 `tools/installer_header.luau`에서 작업하세요. 외부 소재를 추가하면 출처와 이용 조건을 `ASSET_CREDITS.md`에 기록해 주세요.

협동과 모바일은 아직 검증 범위가 제한되어 있으므로 해당 변경은 사용한 테스트 환경을 함께 적어 주세요.

참고: [Roblox 협업](https://create.roblox.com/docs/projects/collaboration),
[서버·클라이언트 경계 검증](https://create.roblox.com/docs/scripting/security/client-server-boundary),
[Codex AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md).

## UI 디자인과 기능 연결

증강 선택창은 [UI_WORKFLOW.md](docs/UI_WORKFLOW.md)의 GUI 원본/슬롯 계약을 따릅니다.
사람이 시안과 Studio GUI를 다듬고, AI는 승인된 모양을 보존하며 상태·입력을 연결합니다.
한 화면의 PC/모바일 검수를 마친 뒤 다른 화면으로 확대합니다. GUI 파일에 스크립트를 넣거나
코드로 사람의 편집을 다시 덮어쓰지 않습니다. Rojo 도입은 별도 이슈로 다룹니다.
