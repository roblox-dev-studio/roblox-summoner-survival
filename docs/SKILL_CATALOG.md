# 스킬·증강 카탈로그

> 자동 생성 파일. 직접 수정하지 마세요. `python3 tools/build_skill_catalog.py`로 재생성합니다.

현재 코드 기준 자동 마법 **9개**, Q 사용 스킬 **4개**, 기본 공격·골렘·대시 **3개**, 증강 **25개**입니다.
자동 마법은 4칸에 장착합니다. 기본 공격·골렘·대시는 기본 제공이며 자동 마법 선택 칸을 사용하지 않습니다.

이 문서는 현재 활성 스킬을 정리합니다. `active`는 구현/선택 또는 기본 제공 여부이며 플레이어의 현재 장착 상태가 아닙니다.
피해·쿨다운 규칙의 원본은 서버 Luau입니다. 설명과 증강 조건은 실제 모듈을 실행해 내보내며 수치를 별도로 작성하지 않습니다.
기본 공격·골렘·대시 설명은 기존 미리보기 문구입니다. 골렘의 ‘5단계 최대 연출’은 표시 설정이며 실제 피해 단계와 다릅니다.

## 갱신과 확인

```sh
python3 tools/bootstrap_luau.py  # 도구가 없는 최초 1회
python3 tools/build_skill_catalog.py
python3 tools/build_skill_catalog.py --check
```

`Loadout`의 선택 목록, `Augments`의 이름·설명·희귀도·조건, `Weapons`의 기본 무기, `AugmentStyles`의 변형 설명을 대조합니다.
이름/ID/부모 스킬 또는 명단이 어긋나면 실패합니다. 생성 결과는 JSON·이 문서·클라이언트 아이콘 매핑에 함께 반영됩니다.

## 이미지 연결

고유 이미지 제작 범위는 전체 스킬 16개 + 공통 증강 3개, 총 **19개**입니다. 전용 증강 22개는 **부모 스킬 이미지 + 희귀도/변형명 배지**를 사용합니다. 별도 이미지 22개를 제작했다는 뜻이 아닙니다.
기본 공격·골렘·대시도 각 전용 이미지를 포함합니다. 이 세 스킬은 기본 제공이며 자동 마법 장착 칸을 추가로 사용하지 않습니다.
PNG가 있어도 Roblox에 업로드하기 전 `robloxAssetId`는 `null`입니다. 업로드 후 `assets/ui/skill-icons/manifest.json`의 해당 ID만 갱신하고 재생성합니다.
`SkillIcons.Apply(imageLabel, id, fallback)`는 유효한 업로드 ID가 있을 때만 이미지를 표시합니다. 없는 경우 기존 UI 대체 표시를 유지하며 로컬 경로나 임의 ID를 이미지 URL로 쓰지 않습니다.

| 상태 | 의미 |
| --- | --- |
| pending_generation | PNG 생성 대기 |
| local_ready_unpublished | 로컬 PNG 준비, Roblox 미업로드 |
| uploaded | 로컬 원본과 업로드 ID 연결 |

## 자동 마법

| ID · 이름 | 코드의 설명 | 단계 강화 설명 | 아이콘 · 상태 |
| --- | --- | --- | --- |
| `lightRing` · 성운 광륜 | 빛나는 초승달이 곡선을 그리며 날아갔다가 돌아오며 다시 타격합니다. | 피해 +8 · 주기 -0.25초 | [lightRing](../assets/ui/skill-icons/lightRing.png) · local_ready_unpublished |
| `ice` · 빙결 얼음창 | 마법진에서 얼음창을 쏘아 적을 밀치고 얼립니다. | 피해 +8 · 빙결 +0.1초 · 둔화 +0.4초 | [ice](../assets/ui/skill-icons/ice.png) · local_ready_unpublished |
| `lightning` · 연쇄 번개 | 하늘에서 내려꽂힌 번개가 주변 적에게 이어집니다. | 피해 +7 · 연쇄 타깃 +1 | [lightning](../assets/ui/skill-icons/lightning.png) · local_ready_unpublished |
| `meteor` · 메테오 | 거대한 운석이 하늘에서 낙하해 밀집한 적을 강타합니다. | 피해 +22 · 반경 +1 · 주기 -0.3초 | [meteor](../assets/ui/skill-icons/meteor.png) · local_ready_unpublished |
| `blades` · 비전 결정 | 등 뒤의 결정 5개가 한 발씩 적을 추적한 뒤 다시 충전됩니다. | 결정 피해 +4 · 재충전 -0.35초 | [blades](../assets/ui/skill-icons/blades.png) · local_ready_unpublished |
| `skyLances` · 천공의 창 | 적 머리 위 마법진에서 긴 마법 창들이 차례로 내려꽂힙니다. | 창 피해 +8 · 주기 -0.4초 | [skyLances](../assets/ui/skill-icons/skyLances.png) · local_ready_unpublished |
| `frost` · 서리 폭발 | 몸에서 냉기 파동이 퍼져 가까운 적을 한꺼번에 얼립니다. | 피해 +8 · 반경 +1 · 빙결 +0.2초 | [frost](../assets/ui/skill-icons/frost.png) · local_ready_unpublished |
| `missile` · 추적 마탄 | 보스와 체력이 높은 적을 우선 추적하는 마탄입니다. 범위 피해는 없습니다. | 피해 +7 · 짝수 단계에 탄환 +1 | [missile](../assets/ui/skill-icons/missile.png) · local_ready_unpublished |
| `ward` · 수호 결계 | 주기적으로 보호막을 펼칩니다. 흡수량을 다 쓰면 깨집니다. | 흡수량 +12 · 주기 -0.3초 | [ward](../assets/ui/skill-icons/ward.png) · local_ready_unpublished |

## Q 사용 스킬

| ID · 이름 | 코드의 설명 | 단계 강화 설명 | 아이콘 · 상태 |
| --- | --- | --- | --- |
| `fire` · 화염탄 | 정면 불꽃 탄환 · 적중 범위 피해 · 7초 | — | [fire](../assets/ui/skill-icons/fire.png) · local_ready_unpublished |
| `thunder` · 뇌창 | 정면으로 날아가는 번개 창 · 관통 · 7초 | — | [thunder](../assets/ui/skill-icons/thunder.png) · local_ready_unpublished |
| `aetherLance` · 성운창 | 아지랑이 빛의 창 · 관통 · 7초 | — | [aetherLance](../assets/ui/skill-icons/aetherLance.png) · local_ready_unpublished |
| `iceRush` · 빙하 쇄도 | 정면 얼음 기둥 · 빙결 · 7초 | — | [iceRush](../assets/ui/skill-icons/iceRush.png) · local_ready_unpublished |

## 기본 공격

| ID · 이름 | 코드의 설명 | 단계 강화 설명 | 아이콘 · 상태 |
| --- | --- | --- | --- |
| `basic` · 기본 공격 · 별빛 마법탄 | 작은 빛의 탄환 · 누르고 연속 발사 | — | [basic](../assets/ui/skill-icons/basic.png) · local_ready_unpublished |

## 소환수

| ID · 이름 | 코드의 설명 | 단계 강화 설명 | 아이콘 · 상태 |
| --- | --- | --- | --- |
| `golem` · 골렘 대지 강타 | 현재 게임과 같은 5단계 최대 연출 | 내려찍기·강타 피해와 범위 증가 | [golem](../assets/ui/skill-icons/golem.png) · local_ready_unpublished |

## 이동

| ID · 이름 | 코드의 설명 | 단계 강화 설명 | 아이콘 · 상태 |
| --- | --- | --- | --- |
| `dash` · 대시 | 이동 궤적과 잔상 | — | [dash](../assets/ui/skill-icons/dash.png) · local_ready_unpublished |

## 증강 25개

| ID · 이름 | 부모 · 조건 | 희귀도 · 최대 중첩 | 코드의 설명 | 아이콘 방식 |
| --- | --- | --- | --- | --- |
| `ice_twin` · 쌍빙창 | ice 1단계 이상 | 희귀 · 1 | 얼음창을 2발 발사. 다른 적을 우선하고 각 발은 피해 75%. | `ice` 부모 + 배지 |
| `ice_shatter` · 빙쇄 | ice 2단계 이상 | 영웅 · 1 | 얼음창 적중 시 반경 5에 50% 파편 피해와 짧은 빙결. | `ice` 부모 + 배지 |
| `lightning_fork` · 갈래 번개 | lightning 1단계 이상 | 희귀 · 1 | 연쇄 번개의 최대 타깃 +2. 같은 적은 한 번만 타격. | `lightning` 부모 + 배지 |
| `lightning_frozen` · 빙결 전도 | lightning 2단계 이상 + ice / frost 중 하나 장착 | 영웅 · 1 | 빙결 또는 둔화 중인 적에게 연쇄 번개 피해 +60%. | `lightning` 부모 + 배지 |
| `meteor_wide` · 거대 운석 | meteor 1단계 이상 | 희귀 · 1 | 메테오 폭발 반경 +35%. 예고와 폭발도 함께 확대. | `meteor` 부모 + 배지 |
| `meteor_echo` · 운석의 여진 | meteor 2단계 이상 | 영웅 · 1 | 메테오 착탄 0.65초 후 같은 지점에 50% 피해의 후속 폭발. | `meteor` 부모 + 배지 |
| `blades_volley` · 칠성 결정 | blades 1단계 이상 | 희귀 · 1 | 충전되는 비전 결정 5개 → 7개. 순서대로 발사. | `blades` 부모 + 배지 |
| `blades_pierce` · 관통 결정 | blades 2단계 이상 | 영웅 · 1 | 각 결정이 적을 한 번 더 관통. 같은 적 재타격 없음. | `blades` 부모 + 배지 |
| `frost_wide` · 광역 한파 | frost 1단계 이상 | 희귀 · 1 | 서리 폭발 탐지·피해·빙결 반경 +30%. | `frost` 부모 + 배지 |
| `frost_echo` · 이중 서리 | frost 2단계 이상 | 영웅 · 1 | 서리 폭발 0.6초 후 현재 위치에서 50% 피해의 추가 냉기 파동. | `frost` 부모 + 배지 |
| `ward_reservoir` · 깊은 결계 | ward 1단계 이상 | 희귀 · 1 | 수호 결계 흡수량 +50%, 지속시간 5초 → 7초. | `ward` 부모 + 배지 |
| `ward_pulse` · 결계 해방 | ward 2단계 이상 | 영웅 · 1 | 결계 소진·만료 시 반경 8에 최초 흡수량의 75% 피해. 취소 시 발동 안 함. | `ward` 부모 + 배지 |
| `missile_salvo` · 추적 탄막 | missile 1단계 이상 | 희귀 · 1 | 추적 마탄 시전마다 탄환 +2. 각 탄환은 한 대상만 타격. | `missile` 부모 + 배지 |
| `missile_hunter` · 거수 사냥꾼 | missile 2단계 이상 | 영웅 · 1 | 추적 마탄이 정예·필드보스·드래곤에게 피해 +50%. | `missile` 부모 + 배지 |
| `skyLances_rain` · 칠성 창우 | skyLances 1단계 이상 | 희귀 · 1 | 천공의 창 5자루 → 7자루. 추가 두 창은 대각선에 낙하. | `skyLances` 부모 + 배지 |
| `skyLances_execute` · 천공의 심판 | skyLances 2단계 이상 | 영웅 · 1 | 체력 50% 이하 적에게 천공의 창 피해 +50%. | `skyLances` 부모 + 배지 |
| `lightRing_twin` · 쌍월 | lightRing 1단계 이상 | 희귀 · 1 | 광륜을 좌우 12도로 2개 발사. 각각 기존 피해의 70%. | `lightRing` 부모 + 배지 |
| `lightRing_return` · 귀환의 칼날 | lightRing 2단계 이상 | 영웅 · 1 | 돌아오는 광륜 피해 +75%. 출발·귀환 각각 적당 1회. | `lightRing` 부모 + 배지 |
| `fire_blast` · 작열 화염탄 | 선택 Q: fire | 희귀 · 1 | Q 화염탄 폭발 반경 5 → 7. 착탄 범위가 화면에 표시됨. | `fire` 부모 + 배지 |
| `thunder_chain` · 뇌창 전도 | 선택 Q: thunder | 영웅 · 1 | Q 뇌창 적중 시 근처 최대 2명에 50% 전류. 시전당 추가 타격 2회 제한. | `thunder` 부모 + 배지 |
| `aether_execute` · 성운 처형 | 선택 Q: aetherLance | 희귀 · 1 | 체력 50% 이하 적에게 Q 성운창 피해 +50%. | `aetherLance` 부모 + 배지 |
| `iceRush_wide` · 빙하 대로 | 선택 Q: iceRush | 희귀 · 1 | Q 빙하 쇄도 폭 +50%. 기둥 연출과 판정 함께 확대. | `iceRush` 부모 + 배지 |
| `quick_cast` · 신속 시전 | 공통 | 일반 · 3 | 자동 마법 재사용 주기 -8%p. 최대 3회, Q·골렘·비행 시간 제외. | `quick_cast` 공통 전용 |
| `active_focus` · 집중된 주문 | 공통 | 일반 · 2 | Q 재사용 주기 -15%p. 최대 2회, 7초 → 최저 4.9초. | `active_focus` 공통 전용 |
| `lucky_charm` · 행운의 부적 | 공통 | 일반 · 3 | 행운 +20. 다음 무작위 카드의 희귀·영웅 등급 가중치 증가. | `lucky_charm` 공통 전용 |

조건 열의 자동 마법 최소 단계는 `Augments.Eligible`을 실행해 확인한 값입니다. 실제 후보는 장착 상태와 기존 획득 횟수까지 서버에서 검증합니다.
생존·수집 카드와 성장 완료 회복 카드는 위 25개 증강과 별도이며 이 증강 이미지 수에 포함하지 않습니다.

## 구현 위치

| 스킬 | 정의 · 관련 구현 |
| --- | --- |
| `lightRing` | [Loadout.luau](../src/server/flow/Loadout.luau) · [LightSpells.luau](../src/server/combat/LightSpells.luau) · [LightArt.luau](../src/client/combat/LightArt.luau) · [AugmentArt.luau](../src/client/combat/AugmentArt.luau) |
| `ice` | [Loadout.luau](../src/server/flow/Loadout.luau) · [Combat.luau](../src/server/combat/Combat.luau) · [Effects.luau](../src/client/combat/Effects.luau) · [AugmentArt.luau](../src/client/combat/AugmentArt.luau) |
| `lightning` | [Loadout.luau](../src/server/flow/Loadout.luau) · [Combat.luau](../src/server/combat/Combat.luau) · [LightningArt.luau](../src/client/combat/LightningArt.luau) · [AugmentArt.luau](../src/client/combat/AugmentArt.luau) |
| `meteor` | [Loadout.luau](../src/server/flow/Loadout.luau) · [AreaSpells.luau](../src/server/combat/AreaSpells.luau) · [AreaArt.luau](../src/client/combat/AreaArt.luau) · [AugmentArt.luau](../src/client/combat/AugmentArt.luau) |
| `blades` | [Loadout.luau](../src/server/flow/Loadout.luau) · [ArcaneCrystals.luau](../src/server/combat/ArcaneCrystals.luau) · [ProjectileArt.luau](../src/client/combat/ProjectileArt.luau) · [AugmentArt.luau](../src/client/combat/AugmentArt.luau) |
| `skyLances` | [Loadout.luau](../src/server/flow/Loadout.luau) · [SkyLances.luau](../src/server/combat/SkyLances.luau) · [SkyLanceArt.luau](../src/client/combat/SkyLanceArt.luau) · [AugmentArt.luau](../src/client/combat/AugmentArt.luau) |
| `frost` | [Loadout.luau](../src/server/flow/Loadout.luau) · [AreaSpells.luau](../src/server/combat/AreaSpells.luau) · [AreaArt.luau](../src/client/combat/AreaArt.luau) · [AugmentArt.luau](../src/client/combat/AugmentArt.luau) |
| `missile` | [Loadout.luau](../src/server/flow/Loadout.luau) · [HomingMissiles.luau](../src/server/combat/HomingMissiles.luau) · [ProjectileArt.luau](../src/client/combat/ProjectileArt.luau) · [AugmentArt.luau](../src/client/combat/AugmentArt.luau) |
| `ward` | [Loadout.luau](../src/server/flow/Loadout.luau) · [AreaSpells.luau](../src/server/combat/AreaSpells.luau) · [AreaArt.luau](../src/client/combat/AreaArt.luau) · [AugmentArt.luau](../src/client/combat/AugmentArt.luau) |
| `fire` | [Loadout.luau](../src/server/flow/Loadout.luau) · [ActiveSpells.luau](../src/server/combat/ActiveSpells.luau) · [FireArt.luau](../src/client/combat/FireArt.luau) · [AugmentArt.luau](../src/client/combat/AugmentArt.luau) |
| `thunder` | [Loadout.luau](../src/server/flow/Loadout.luau) · [ActiveSpells.luau](../src/server/combat/ActiveSpells.luau) · [ActiveArt.luau](../src/client/combat/ActiveArt.luau) · [AugmentArt.luau](../src/client/combat/AugmentArt.luau) |
| `aetherLance` | [Loadout.luau](../src/server/flow/Loadout.luau) · [ActiveSpells.luau](../src/server/combat/ActiveSpells.luau) · [AetherLanceArt.luau](../src/client/combat/AetherLanceArt.luau) · [AugmentArt.luau](../src/client/combat/AugmentArt.luau) |
| `iceRush` | [Loadout.luau](../src/server/flow/Loadout.luau) · [ActiveSpells.luau](../src/server/combat/ActiveSpells.luau) · [GlacialArt.luau](../src/client/combat/GlacialArt.luau) · [AugmentArt.luau](../src/client/combat/AugmentArt.luau) |
| `basic` | [SkillPreview.luau](../src/client/flow/SkillPreview.luau) · [BasicAttack.luau](../src/server/combat/BasicAttack.luau) · [Weapons.luau](../src/server/combat/Weapons.luau) · [LightArt.luau](../src/client/combat/LightArt.luau) |
| `golem` | [SkillPreview.luau](../src/client/flow/SkillPreview.luau) · [Combat.luau](../src/server/combat/Combat.luau) · [Effects.luau](../src/client/combat/Effects.luau) |
| `dash` | [SkillPreview.luau](../src/client/flow/SkillPreview.luau) · [Movement.luau](../src/server/combat/Movement.luau) · [Effects.luau](../src/client/combat/Effects.luau) |

전체 필드·해시·증강 부모/조건·기본 무기 프로필은 [data/skills.json](../data/skills.json)을 참고하세요.
