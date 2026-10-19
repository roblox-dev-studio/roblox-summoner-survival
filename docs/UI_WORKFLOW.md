# 증강 화면: 사람이 디자인하고 AI가 기능을 연결하는 작업 순서

이번 범위는 증강 선택 화면 한 개입니다. 전체 HUD, 로비, 상점, 결과창 디자인이나
Rojo 도입은 이 변경에 포함하지 않습니다. 현재 원본은 편집·검수용 기준안이며 최종 미술 승인본이 아닙니다.

## 원본과 소유권

| 원본 | 담당하는 내용 |
| --- | --- |
| `assets/ui/augment-choice.rbxmx` | Studio에서 편집하는 네이티브 GUI. 배치, 폰트, 이미지, 배경, 장식, 희귀도 색 |
| `src/client/flow/AugmentChoice.luau` | 서버 상태를 표시하고 선택·재추첨 의도를 전달하는 바인더 |
| `src/client/flow/HUD.luau` | 전투 HUD와 증강 설명창 연결, 선택 중 화면 우선순위 |
| `tools/gui_model.py` | GUI 원본을 설치기 문장으로 변환하고 필수 이름·클래스를 검사 |

담당은 이슈마다 정합니다. UI 담당자가 디자이너 역할을 맡더라도 서버·클라이언트
기능을 개발할 수 있습니다. 사람의 디자인 판단과 AI의 구현 작업을 구분하는 규칙입니다.

## Studio에서 편집하고 게임에서 확인하기

1. 새 테스트 Baseplate에 최신 `install.luau`를 실행합니다. Play를 멈춘 상태여야 합니다.
2. `tools/preview_augment_ui.luau` 내용을 Edit Command Bar에서 실행합니다.
   `StarterGui.AugmentDesignPreview.ChoiceOverlay`가 선택되고 화면에 예시 카드가 나타납니다.
   같은 명령을 다시 실행해도 편집하던 미리보기를 지우지 않습니다.
3. Studio의 Explorer/Properties/UI 편집기로 배치·색·글꼴·장식을 수정합니다.
   부모 Frame과 아래 필수 슬롯의 이름/클래스는 유지합니다. 새 장식 자식은 추가할 수 있습니다.
4. `tools/apply_augment_ui.luau`를 Edit Command Bar에서 실행합니다.
   구조를 검사한 뒤 로컬 `ReplicatedStorage.SummonerUI.ChoiceOverlay`를 갱신합니다.
   실패하면 기존 템플릿을 유지합니다. 기존 PlayerGui의 실행 중 복사본을 편집하지 않습니다.
5. Play로 들어가 레벨업을 확인합니다. 미리보기 ScreenGui의 실행 중 복사본은 HUD가 숨깁니다.
   Edit 미리보기 원본은 그대로 남습니다. 실제 카드 제목/설명은 서버 값으로 바뀝니다.
6. Play를 멈추고 **미리보기 안의 `ChoiceOverlay` Frame만** 선택해 **Save to File**로 저장합니다.
   XML 모델 `.rbxmx`를 선택하고 `assets/ui/augment-choice.rbxmx`에 덮어씁니다.
   ScreenGui 전체나 바이너리 `.rbxm`으로 저장하지 않습니다.
7. 터미널에서 아래 명령을 실행하고 GUI 원본·설치기·화면 사진을 같은 PR에 포함합니다.

```sh
python3 tools/build_installer.py
python3 tools/check.py
```

공동 place에서는 입력·설치·저장 담당을 한 명으로 정합니다. Play 중 수정은 Edit 원본으로
돌아가지 않으며, 로컬 적용만 해서는 Git에 반영되지 않습니다. 재가져오기/새 Baseplate 설치까지
통과해야 다른 팀원에게 인계한 것으로 봅니다.

## 바인딩 계약

```text
ChoiceOverlay (Frame)
├── RarityPalette (Folder)
│   ├── common (Color3Value)
│   ├── rare (Color3Value)
│   └── epic (Color3Value)
└── Modal (Frame)
    ├── Title, Hint, LuckInfo, Status (TextLabel)
    ├── Reroll, InspectBuild (TextButton)
    └── AugmentCards (ScrollingFrame)
        ├── Layout (UIListLayout)
        └── Choice1 / Choice2 / Choice3 (TextButton)
            ├── Title, Description, Tag (TextLabel)
            ├── Border (UIStroke)
            └── IconTile (Frame)
                ├── SkillIcon (ImageLabel)
                └── IconFallback (TextLabel)
```

바인더는 카드 내용·아이콘·희귀도 색·표시 여부·입력 상태·대기 문구를 갱신합니다.
카드 배경, 폰트, 글자 크기, 장식은 재생성하지 않습니다. 희귀도는 색 외에도 이름으로 표시합니다.
짧은 가로 화면에서 Modal 높이가 480 미만이면 LuckInfo를 숨기고 카드 영역을 Hint 아래로
올립니다. 다시 커지면 원본 배치를 복원합니다. 상세 확률 설명은 InspectBuild로 확인합니다.
따라서 이 두 영역의 위치는 반응형 제어 대상이며, 일반 크기의 기준은 GUI 원본입니다.

선택창의 루트 ZIndex 35는 HUD의 귀환 버튼보다 높고, 보유 증강 설명창(40)보다 낮습니다.
HUD는 선택 중 DisplayOrder 100, 닫히면 0입니다. 개발용 미리보기 런처와 터치 조작부가
선택창 위를 가리지 않도록 합니다. 기존 미리보기에서 HUD를 숨기는 동작은 유지합니다.

`choose(id, offerRevision)`와 `reroll(offerRevision)` 계약은 그대로입니다. 요청을 보낸 뒤
동일 제안 번호의 주기 갱신으로 입력 잠금이 풀리지 않습니다. 새 제안 번호 또는 창 닫힘으로
해제하고, 로비/사망 후에는 숨겨진 카드의 이전 ID를 제거합니다. 서버가 최종 검증합니다.

## 이미지와 장식

기존 스킬 PNG 19장은 Roblox 업로드 ID가 아직 연결되지 않아 글자 대체 표시를 사용합니다.
이 PR은 업로드·구매·게시를 수행하지 않습니다. 사용 승인된 이미지 ID를 기존 manifest에
등록한 뒤 `tools/build_skill_catalog.py`와 설치기를 재생성하면 기존 아이콘 슬롯에 연결됩니다.

이미지 프레임에는 `ImageLabel`/`ImageButton`의 `ScaleType=Slice`와 `SliceCenter`를 사용할 수
있습니다. 테두리·아이콘은 이미지, 텍스트와 클릭 영역은 네이티브 GUI로 유지하세요.
원본에는 실행 스크립트를 넣지 않습니다. 지원되지 않는 속성/클래스는 빌드가 명시적으로
실패합니다. 속성을 지워서 억지로 통과시키지 말고 필요한 지원을 작은 변경으로 추가합니다.
현재 사용자 정의 Attributes/Tags와 Studio 스타일시트 계열은 패키징 범위 밖입니다.

## 다음 디자인 작업과 인수 기준

UI 담당자는 참고 이미지 2~3장과 함께 **카드 한 장·선택 화면 하나**를 먼저 완성합니다.
색/타이포/간격/아이콘 스타일과 기본·희귀·영웅, 선택 대기, 재추첨 소진 상태를 정합니다.
AI는 그 시안을 원본에 적용하고 동작을 연결합니다. 승인 전 다른 화면으로 확대하지 않습니다.

- PC와 휴대폰 세로·가로에서 제목/설명과 버튼이 겹치지 않음.
- 긴 설명, 그림 미등록, 카드 1~3장, 재추첨 0회에서도 조작 가능.
- 실제 레벨업 → 재추첨 → 한 장 선택 → 이동/전투 복귀 → 사망/로비/재시작.
- 변경 전후 같은 해상도/카드 상태의 실제 Studio 화면을 비교.
- 자동 검사, 통제된 엔진 fixture, 실제 입력, 실기기 성능, 사람의 미술 승인을 따로 기록.

참고: [DevForum UI 제작 가이드](https://devforum.roblox.com/t/the-ultimate-ui-design-guide/1236916),
[9-slice](https://create.roblox.com/docs/ui/9-slice),
[Studio 테스트](https://create.roblox.com/docs/studio/testing-modes).
