# 대지 강타 효과 소재와 확인 기록

## 적용한 공개 소재

| 소재 | 출처 | 이용 조건 및 적용 |
| --- | --- | --- |
| GroundSpikes 바위 메시 | clotuder의 [ground slam vfx](https://create.roblox.com/store/asset/12192129638), 메시 ID `967645205` | Creator Store에서 무료 공개된 모델. [Creator Store Terms](https://en.help.roblox.com/hc/en-us/articles/21308223046932-Creator-Store-Terms)에 따른 Roblox 사용 소재이며 CC0로 표시하지 않음. 메시 한 개만 추출하고 자식 객체를 제거하여 `ReplicatedStorage.SummonerVFXAssets.GroundSpikes`로 보관. 로드 성공 확인. |
| 먼지·연기 | Roblox 내장 `rbxasset://textures/particles/smoke_main.dds` | Studio에 포함된 엔진 텍스처를 ParticleEmitter에서 사용. 런타임 로드 성공 확인. |
| 손의 반짝임 | Roblox 내장 `rbxasset://textures/particles/sparkles_main.dds` | Studio에 포함된 엔진 텍스처. 런타임 로드 성공 확인. |
| 화염 파동·화염탄의 불꽃·불씨 | Roblox 내장 `rbxasset://textures/particles/fire_main.dds`, `fire_sparks_main.dds` | 현재 파동·탄환에 사용. 불꽃·불씨 두 텍스처 모두 런타임 Success 확인. |
| 빙결·전기 불꽃 | Roblox 내장 `sparkles_main.dds` 및 직접 생성한 결정·번개 형상 | 얼음 결정, 잔상, 상태 윤곽, 가지가 갈라지는 번개 줄기는 프로젝트에서 작성. 외부 코드나 유료 에셋을 추가하지 않음. |
| 주문의 부드러운 잔광 | Roblox 내장 `rbxasset://textures/particles/forcefield_glow_main.dds` | 런타임 로드 성공 확인. 시전 고리·얼음 결정·낙뢰와 지면 전류 및 Bloom 설정은 직접 작성. |
| 마법형 화염·대시 | Roblox 내장 `sparkles_main.dds` 및 직접 만든 리본·곡선·잔상 | 불꽃 입자 파동·화염 탄환, 캐릭터의 일시적인 푸른 잔상을 직접 구성. 추가 외부 에셋 없음. |

공개 모델의 실제 구성은 메시 2개와 Weld였으며 실행 스크립트는 없었습니다. 실행에 사용하는 템플릿은 순수 MeshPart 한 개이고 충돌·접촉·쿼리를 끈 시각 효과입니다. 충격파, 섬광, 먼지 방출, 지면 균열, 파편 움직임과 타격 타이밍은 이 프로젝트에서 작성했습니다.

## 검토했지만 적용하지 않은 소재

- [Raffaele Picca / RPicster의 파티클 텍스처](https://github.com/RPicster/Godot-particle-and-vfx-textures): 원작자 README와 LICENSE에서 CC0-1.0을 확인했습니다. 그러나 Studio 이미지 업로드 도구가 원본 GitHub 주소를 신뢰 주소로 허용하지 않아 업로드되지 않았으며 게임에는 포함하지 않았습니다.
- [Roblox 공식 Custom particle effects 예제](https://github.com/Roblox/creator-docs/blob/main/content/en-us/tutorials/use-case-tutorials/vfx/custom-particle-effects.md)의 이미지 `3845808160`: 문서에서 용도를 확인했지만 현재 프로젝트의 클라이언트 로드가 실패하여 최종 코드에서는 정상 로드되는 내장 연기로 교체했습니다.
- Creator Store의 여러 파티클 팩도 검색했지만 재업로드 설명이나 불명확한 원작자 표시가 있는 후보는 채택하지 않았습니다.

## 검증

대지 강타 효과의 준비 빛·먼지·충격파·바위 메시를 플레이 모드에서 재생하고 화면으로 확인했습니다. 메시 및 내장 파티클 두 종류의 ContentProvider 로드 상태가 Success임을 확인했습니다. 시각 점검용 반복 재생·정지 프레임·고정 카메라·숨긴 HUD는 플레이 종료로 제거했습니다. 전투 피해·자동 강타 판단·플레이어 화염 파동 규칙은 유지하며 서버에 강타 준비 연출 이벤트만 추가했습니다.

## 재사용한 캐릭터 모션 (2026-10-16)

Quaternius [Universal Animation Library 2](https://quaternius.com/packs/universalanimationlibrary2.html)
Standard에서 이전 AFTERLIGHT 테스트가 R15로 변환한 네 클립을 재사용했습니다.
제공자 페이지와 동봉 원문에서 CC0-1.0을 확인했습니다. 원문은
`assets/animations/Quaternius-LICENSE.txt`, 원본/변환본 SHA-256과 이전 경로는
`assets/animations/manifest.json`에 보존했습니다.

- `Walk_Carry_Loop`: 이동 속도에 맞춘 하체 주기. 물건을 드는 상체 자세는 사용하지 않음.
- `NinjaJump_Start`, `NinjaJump_Idle_Loop`, `NinjaJump_Land`: 점프·공중·착지 하체.
- 클립 데이터 자체는 변경하지 않았으며, 게임에서는 양쪽 Hip/Knee/Ankle만 혼합합니다.
  Root 이동·상체·실제 점프 궤적은 가져오지 않습니다. FPS 팔/카메라 구현도 가져오지 않음.
- Mixamo 걷기/달리기/점프/사망 변환본은 후보로 확인했지만 포함하지 않았습니다.
  [Adobe FAQ](https://helpx.adobe.com/creative-cloud/faq/mixamo-faq.html)는 게임 사용을 허용하지만,
  공개 저장소에서 추출 가능한 모션 데이터 재배포까지 확인된 근거는 확보하지 못했습니다.

이번 새 Baseplate에서 선택적 GroundSpikes import는 생성되지 않았습니다.
위의 과거 로드 성공 기록과 구별하며, 현재 테스트 place는 내장 입자/절차적 파편을 사용합니다.

## 현재 드래곤과 화염 참고 자료 (2026-10-17)

- **Cethiel’s Dragon 3D**, Drummyfish / Cethiel, **CC0-1.0**: https://opengameart.org/content/cethiels-dragon-3d . 원본 ZIP과 SHA-256은 `assets/dragon/`에 보존합니다. 원본의 633개 정점, 1262개 삼각형, 32개 뼈대와 Idle/Walk/Attack/Die 클립을 변환했습니다. 검은 텍스처를 면 꼭짓점 색으로 변환했고, 비행 날갯짓·날개 영역 확장·다리 접기·꼬리 회전과 보스 공격 연출은 추가 작성했습니다. 변환 배율은 36이고 원본 좌우 관절명 _L/_R을 유지합니다. `tools/convert_dragon.py`로 재생성합니다. 이전 수작업 드래곤은 `models/ember_dragon_prototype.luau`에 보관합니다.
- **AetherFX**, holokat / Gene와 기여자, **MIT**: https://github.com/holokat/AetherFX . Fire Bolt / Lesser Fireball의 핵·불꽃 외피·불씨·연기·폭발 레이어 구성을 참고해 Roblox용 `FireArt.luau`로 구현했습니다. 참고 JSON, MIT 원문, 고정 커밋과 파일 해시는 `assets/vfx/aetherfx/`에 보존합니다. 원본 C++ 실행 코드나 외부 바이너리를 실행하지 않습니다.
- **Creator Store Fireball VFX Mesh**, Random_Guy1stRevised: https://create.roblox.com/store/asset/5747839770 . 조사 목적으로 메시 한 개를 가져와 실행 스크립트가 없음을 확인했으나 최종 효과/설치기에는 포함하지 않았습니다.
- 일반 적 모델과 SpellArt 형상은 직접 작성했습니다. Roblox 내장 입자 텍스처를 사용합니다. Dark Souls 3의 모델·텍스처·애니메이션은 가져오지 않았습니다.

8종 보스 공격의 직선 화염·원형 비행 경로·회전 꼬리 궤적·착지 파편과 충격파는 이 프로젝트에서 작성한 절차적 연출입니다. 추가 외부 모델이나 실행 스크립트는 가져오지 않았습니다.

CC0 드래곤의 꼬리 영역에 길이 축 1.65배 변형과 관절 관성을 추가했습니다. 원본 보존 ZIP은 변경하지 않았고 변형은 DragonMesh에서 적용합니다.

현재 추가 변형 배율은 날개 축 (1.90,1.50,1.80), 꼬리 길이 축 2.0입니다. 이전 수치 기록을 대체하며 원본 CC0 ZIP은 그대로 보존합니다.

## 사용자 제공 반짝임 참고 이미지 (2026-10-17)

`magic-wand-sparkle-trails.zip` 안의 JPG를 열어 푸른/보라색 굽이치는 잔광과 작은 반짝임 구성을 참고했습니다. ZIP에는 JPG/EPS만 있고 이용 조건이나 제작자 표시는 제공되지 않았습니다. 원본 JPG/EPS를 게임·설치기·저장소에 포함하지 않았고 EPS를 실행/가져오지 않았습니다. 성운창은 `AetherLanceArt.luau`의 직접 작성한 형상·Beam/Trail과 Roblox 내장 smoke_main/sparkles_main 텍스처만 사용합니다. 참고 파일 이름/해시/사용 범위는 `assets/vfx/user-sparkle-reference/manifest.json`에 기록했습니다.

## 사용자 제공 Light effects set 참고 이미지 (2026-10-18)

사용자의 `light-effects-set.zip`에는 `8148.jpg`/`8148.eps`만 있으며 제작자·라이선스는 제공되지 않았습니다. JPG의 발광 고리·나선·별빛 레이어만 시각 참고했고 원본 파일은 게임/설치기/저장소에 포함하지 않았습니다. EPS를 실행하거나 가져오지 않았습니다. LightArt/GlacialArt는 직접 작성한 Beam·Trail·입체 형상과 Roblox 내장 sparkles_main 텍스처를 사용합니다. 파일 해시와 사용 범위는 assets/vfx/light-effects-reference/manifest.json에 기록합니다.


## 2026-10-18 화염·번개 참고와 직접 만든 불꽃 이미지

[원형 이펙트 01 불꽃](https://www.acon3d.com/ko/product/1000034557)(sozai wo douzo), [화염 PNG 페이지](https://www.pngegg.com/ko/png-dhzhm)(작가 미표시·비상업적 용도 표기), [액션 마법 이펙트 번개](https://www.acon3d.com/ko/product/1000047245)(도토리작가)의 공개 미리보기를 색과 실루엣 참고로 열람했습니다. 상품/PNG 원본을 다운로드·구매·게임에 포함하지 않았습니다. `FlameTexture.luau`는 직접 작성한 곡선·노이즈·색 계산으로128×128 RGBA 불꽃을 생성하고 `FireArt`의 BillboardGui/ImageLabel에서 표시합니다. 신규 `LightningArt`는 직접 작성한 Beam 가지/지면 방전을 사용합니다. 기존 FireArt의 AetherFX MIT 출처와 라이선스는 유지합니다. 참고 범위와 생성기 해시는 `assets/vfx/fire-lightning-reference/manifest.json`에 기록합니다.


2026-10-18 후속 수정: 위의 FlameTexture/BillboardGui 방식은 사용자 요청으로 런타임과 소스에서 제거했습니다. 현재 화염은 Roblox 기본 Fire, 내장 입자·Beam·Trail과 직접 작성한 발광 형상으로 표시하며 화염에 Image APIs가 필요하지 않습니다. 사용자가 제공한 `0c0a9cd9a02d9c328f063e70a39fe458.jpg`는 청백색 번개/보라색 지면 충격의 색감·구성 참고로만 열람했습니다. 작가/사용 조건은 미제공이며 원본은 저장소나 게임에 포함하지 않습니다.


2026-10-18 연결된 화염 참고: 사용자가 첨부한 iStock 미리보기4개(2202275228/Sensvector, 513381956/Mojito_mak, 182842270/ramihalim, 1352338867/dzika_mrowka)의 밝은 내부·주황색 외곽·이어지는 불길을 시각 참고했습니다. 원본/워터마크 이미지는 편집·추출·임포트·재배포하지 않았습니다. FlameSurface는 직접 작성한 절차적 형상/색 애니메이션이며 참고 파일의 해시와 사용 범위는 기존 fire-lightning-reference manifest에 기록했습니다.

2026-10-18 후속 피드백으로 연결된 FlameSurface 메시를 제거했습니다. 현재 화염 파동은 네이티브 Fire/내장 입자와 독립된3줄기 움직임을 사용하며 참고 사진은 포함하지 않습니다.


### Fireball reference silhouette · 2026-10-18

User-provided Fireball.webp and saved PNGEgg png-dhxxq.html (canonical https://www.pngegg.com/ko/png-dhxxq) were viewed/read as visual references only for a bright rounded head and warm tapered tail. Creator/license not established; neither file is imported, uploaded, executed or redistributed. Hashes are recorded in assets/vfx/fire-lightning-reference/manifest.json. Implementation uses existing Roblox built-in textures and original attached beam/particle code.


### Long tapered fire tail · 2026-10-18

png-clipart-flame-fire-flame.png: user supplied visual reference for a long teardrop flame silhouette; creator and license unestablished. Not imported/uploaded/redistributed. Hash recorded in fire-lightning-reference manifest. No new texture asset added.

## 잿빛 해골 병사 · 2026-10-18

[Kay Lousberg / KayKit Character Pack Skeletons 1.0](https://github.com/KayKit-Game-Assets/KayKit-Character-Pack-Skeletons-1.0/tree/15b62b9bad122f72926c10fb14d622c73819fa54), [원본 CC0 라이선스](https://github.com/KayKit-Game-Assets/KayKit-Character-Pack-Skeletons-1.0/blob/15b62b9bad122f72926c10fb14d622c73819fa54/LICENSE.txt). Skeleton_Warrior.glb와 skeleton_texture.png를 사용했습니다. 개인/교육/상업 이용 허용, 출처 표기는 의무가 아니지만 원작자를 기록합니다. 유료 EXTRA 및 최신1.1 파일은 사용하지 않았습니다.

원본 42노드 리그/가중치, Idle·Walking_A·Unarmed_Melee_Attack_Punch_A를 보존해 네이티브 Bone 애니메이션으로 변환했습니다. 원본 텍스처의 팔레트는 정점색으로 베이크했습니다. 캐릭터·모션 데이터만 처리했으며 외부 실행 스크립트는 가져오지 않았습니다. 원본/라이선스/SHA-256/고정 커밋/재현 방법은 assets/enemies/kaykit-skeletons와 tools/convert_skeleton.py에 있습니다.

### 해골 몹 확장과 무기 · 2026-10-18

같은 CC0 [KayKit Skeletons1.0 고정 리비전](https://github.com/KayKit-Game-Assets/KayKit-Character-Pack-Skeletons-1.0/tree/15b62b9bad122f72926c10fb14d622c73819fa54)의 Skeleton_Mage/Rogue/Minion.glb와 Skeleton_Axe/Blade/Shield_Large_A/Shield_Small_A/Staff.gltf 및 대응 bin/원본 팔레트 PNG를 추가했습니다. 캐릭터용/무기용 팔레트 SHA-256이 같음을 확인했습니다. 원본 파일 해시는 기존 manifest.files에 모두 기록했습니다. 유료 EXTRA·외부 스크립트는 사용하지 않았습니다.

기존 skitter/caster/ember 역할에 각각 Rogue/Mage/Minion 외형을 연결하고 brute는 Warrior를 크게 표시합니다. 무기/방패/지팡이는 원본 hand-slot Bone에 붙여 모션을 따라갑니다. 직립 모델은 원본 걷기/달리기/쌍검/시전 클립을 사용합니다. 잿불 뿔사냥개, 폭탄·띠·도화선과 원래 전투 이펙트는 프로젝트에서 직접 구성한 형상입니다.

### 병사 걷기 모션 교체

처음 선택한 Walking_D_Skeletons는 머리/투구가 한쪽으로 기우는 연출을 포함해, 같은 CC0 원본의 Walking_A로 교체했습니다. 원본 GLB/라이선스/해시는 그대로이며 tools/convert_skeleton.py와 manifest.characters.Warrior.clips.Walk에 현재 선택을 기록합니다. 앞선 spine 평균 기울기 보정은 제거했습니다.

## 망령 기마 군단장 · 2026-10-18

- 기수는 위에 기록한 KayKit Skeletons 1.0 CC0 Warrior 원본과 장비를 재사용합니다. 추가 동작은 같은 GLB의 `1H_Melee_Attack_Slice_Horizontal`, `Blocking`, `Block_Attack`, `Sit_Chair_Idle`입니다. 새 네트워크 소재나 제3자 스크립트는 추가하지 않았습니다.
- 군마의 몸·목·두개골·관절 다리·고삐·갈기·꼬리, 왕관·남색 망토와 영혼 궤적은 이 프로젝트에서 작성한 절차 모델입니다. 재현 소스: `src/client/world/CommanderMount.luau`, `FieldBossArt.luau`. 실제 피해/예고는 서버 `FieldBoss.luau`에 있습니다.
- 변환: 기존 `tools/convert_skeleton.py --character Warrior`를 NumPy/Pillow 환경에서 실행합니다. 원본 SHA와 선택 클립은 `assets/enemies/kaykit-skeletons/manifest.json`, 전체 설치는 `python3 tools/build_installer.py`로 재현합니다.

### 2026-10-18 군단장 전용 갑옷/도끼창 교체

현재 군단장 기수·투구·장식깃·흉갑·관절 갑옷·망토·도끼창·모션은 `CommanderMount.luau`의 프로젝트 자체 절차 모델입니다. 앞서 재사용했던 KayKit Warrior 기수/검/방패는 군단장에서 제거했습니다. KayKit 원본은 일반 적에 그대로 사용합니다. 별도 외부 메시·이미지·애니메이션·스크립트는 추가하지 않았습니다. 자산 구조와 재현 경로는 `assets/enemies/commander/manifest.json`에 기록합니다.

사용자가 언급한 ELDEN RING 트리가드는 기마 중갑 기사와 준비/타격의 무게감에 대한 미술·전투 방향 참고입니다. 게임 모델·텍스처·모션 파일은 가져오지 않았습니다. 작품 정보 참고: https://www.bandainamcoent.com/games/elden-ring . 실제 이 게임의 실루엣과 절차 소스가 구현 기준입니다.


## 증강 리본·공유 애니메이터 · 2026-10-18

[Willikk / Roblox](https://github.com/Willikk/Roblox/tree/c77902e8f59cc0ca1f3130906ae51c92d9de310e)의
`.claude/skills/roblox-mesh-vfx/src/shared/VFX`에서 `BeamArc.luau`, `VFXMath.luau`, `Animator.luau` 세 파일을 재사용합니다.
원작자는 Willikk 저장소 기여자이며 고정 리비전은 `c77902e8f59cc0ca1f3130906ae51c92d9de310e`입니다.
원본 README의 License 절은 **MIT, 개인·상업 Roblox 게임에서 사용/수정 가능**이라고 명시합니다.
별도 루트 LICENSE 파일은 해당 리비전에서 발견하지 못했으므로 원본 라이선스 선언이 담긴 README 전체를 그대로 보관했습니다.

사용 위치는 `src/client/combat/vfx/`, 근거/설치 provenance/파일 SHA-256은 `assets/vfx/roblox-mesh-vfx/`입니다.
세 모듈은 로컬 엔진 API를 사용한 곡선 Beam·벡터 계산·공유 프레임 루프이며 검토 후 원본 그대로 포함했습니다.
HTTP 호출, 외부 실행/자동 설치, 숫자 asset require, 원격 loadstring은 없고 다른 동봉 코드/도구는 실행하지 않았습니다.
증강별 돔·운석 궤도·파편·빙하 관문 구성과 풀 제한/수명 관리는 프로젝트의 `AugmentArt`에서 작성했습니다.
새 유료 구매나 이미지·메시·플러그인 업로드는 없습니다.

## 슬라임·결정체와 증강6개 보강 · 2026-10-18

신규 슬라임3종/결정체3종의 외형·모션은 `SlimeMesh.luau`, `CrystalMesh.luau`에 작성한 프로젝트 자체 절차 에셋입니다. 외부 모델·텍스처·실행 코드를 가져오지 않았습니다. 원본 경로·해시·재현은 `assets/enemies/native-families/manifest.json`에 기록합니다. 저장소에 없는 별도 라이선스를 임의 부여하지 않습니다.

증강6개 보강은 기존 MIT 보조 모듈과 이미 쓰던 Roblox 내장 particles/sparkles_main.dds, fire_sparks_main.dds, smoke_main.dds, fire_main.dds를 사용합니다. 새 외부 파일·유료 에셋·업로드는 추가하지 않았습니다.

## 마법 아이콘과 로비 · 2026-10-18

`assets/ui/skill-icons/`의 PNG 19장은 Codex 내장 imagegen으로 이 프로젝트의 스킬 설명을 바탕으로 생성한 이미지입니다.
외부 게임의 그림을 복사하지 않았으며, 실제 프롬프트·생성 시각·원본 파일·크기·SHA-256은 동봉 manifest에 기록합니다.
별도 유료 API 키나 소재 구매는 사용하지 않았습니다. 저장소의 라이선스가 지정되지 않은 상태에서 CC0/MIT 등 별도 라이선스를 임의 부여하지 않습니다.
Roblox 업로드는 아직 하지 않았으므로 `robloxAssetId`는 `null`입니다.

마법 학원 로비의 건축물·결정·마법진·가판대·게시판은 `src/server/world/LobbyWorld.luau`의 프로젝트 자체 절차 모델입니다.
외부 모델·메시·텍스처·동봉 실행 코드를 가져오지 않았습니다. 설치 후 서버 시작 시 네이티브 Instance로 재생성합니다.

### 2026-10-18 정정 · Quaternius CC0 군마/후드 대검 군단장

트리가드 외형 참고는 폐기했습니다. 현재 기수는 프로젝트 자체 후드·철갑·붉은 망토/양손 대검이며 금빛 투구·장식깃·도끼창은 생성하지 않습니다. 트리가드는 돌진과 무기 공격을 섞는 전투 방식만 참고합니다.

- Horse: Quaternius. 저작자 페이지 https://quaternius.com/packs/ultimateanimatedanimals.html , 해당 모델 배포 https://poly.pizza/m/qvTrSG9pZF 에서 CC0 확인. 원본 https://static.poly.pizza/d37dbc87-ca61-4b2c-a2da-d2f0c4240bef.glb . CC0 1.0: https://creativecommons.org/publicdomain/zero/1.0/ . 확인일2026-10-18.
- 실제 원본 `assets/enemies/quaternius-horse/Horse.glb`를 보관합니다. 원본 SHA-256/재질·기하 통계/변환 명령은 해당 manifest.json. 외부 텍스처와 스크립트는 없고 모델의 재질8종을 정점색으로 변환했습니다.
- 변환 `python3 tools/convert_horse.py`(NumPy). 실제 메시/스킨/Idle·Walk·Gallop을 사용하며 단순 형태 참조가 아닙니다. glTF +Z 정면을 Roblox −Z로, 조상 크기/재질 색공간과 Bone 계층을 베이크했습니다. 모듈은 src/client/world/horse 아래에 포함됩니다.

2026-10-18 후속 외형: 후드를 자체 제작 철제 투구(눈틈·코/볼 가리개·청동 테두리·관 장식)로 교체했습니다. 말·기수·무기1.2배 확대. 새 외부 자산은 없습니다.

2026-10-18 재정정 · 해골 기사: 직전 자체 폐쇄 투구/가면/관 장식을 제거했습니다. `CommanderSkull.luau`가 기존 KayKit Skeleton Warrior CC0 데이터 중 head Bone 가중치0.5초과 정점과 그 정점만으로 구성된 면을 추출합니다(1,820정점/1,480삼각형). 두개골·치아·눈구멍과 원본 개방형 뿔 투구의 색/법선을 유지하며 새 외부 다운로드는 없습니다. KayKit 출처·원본·사용조건은 위 Skeletons 항목과 `assets/enemies/kaykit-skeletons/manifest.json`을 따릅니다.

2026-10-18 해골 군마: `SkeletonHorse.luau`의 두개골/치아/갈비뼈/척추/골반/팔다리·꼬리와 철갑은 프로젝트 자체 절차 모델입니다. Quaternius 원본 말 표면은 투명하게 숨기고 CC0 원본 skeleton/Idle·Walk·Gallop을 움직임에 재사용합니다. 갈색 말을 하얗게 재색칠한 모델이 아닙니다. 새 외부 자산은 추가하지 않았습니다.

### 잿빛 왕성 광장 · 2026-10-18

`arena.luau`의 광장/문양·성벽/성문·탑·비석/납골당·예배당·불탄 나무/배경은 프로젝트 자체 절차 모델입니다. Roblox 기본 재질과 `rbxasset://textures/particles/sparkles_main.dds`만 사용하며 외부 모델/이미지/번들 스크립트는 추가하지 않았습니다. 재현 seed/원본 SHA/구역과 충돌 조건은 `assets/maps/ashen-crown/manifest.json`에 기록했습니다.
