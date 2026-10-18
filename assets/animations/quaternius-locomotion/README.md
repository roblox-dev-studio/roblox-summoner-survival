# Quaternius locomotion → Roblox R15

2026-10-18에 원작자 Quaternius의 [OpenGameArt 배포](https://opengameart.org/content/universal-animation-library)에서
Standard ZIP을 다운로드했습니다. GLB·동봉 CC0 원문을 보관합니다(라이선스 텍스트의 줄바꿈·행 끝 공백만 정규화). ZIP 주소/해시는 `download.json`,
GLB/변환 클립 해시는 `manifest.json`에 기록합니다. 외부 실행 스크립트는 가져오지 않았습니다.
이는 이전 프로젝트의 모션 복사만으로 끝낸 작업이 아닙니다.

| 원본 클립 | 현재 사용 |
| --- | --- |
| Walk_Loop | 저속 보행 |
| Jog_Fwd_Loop | 이동 속도에 따른 조깅 혼합 |
| Jump_Start | 이륙 구간을 추려 0.2초로 재생 |
| Jump_Loop | 공중 자세 |
| Jump_Land | 0.16초 착지, 이동 중에는 조깅과 혼합 |
| Roll | 원본 회전을 0.55초 공중 구르기로 적용하는 이단점프 연출 |

**Roll은 제공자의 이단점프 전용 원본이 아닙니다.** 구르기 회전을 공중 점프의 시각 표현으로 재활용했습니다.
원본 키의 안무를 새로 만들지 않았으며, 루트 이동은 모든 축에서 제거했습니다. 실제 상승·착지는 Humanoid가 처리합니다.
기존 Universal Animation Library 2의 네 하체 클립은 저장소에 참고용으로 남아 있지만 현재 재생기는 위 여섯 클립을 사용합니다.

`r15-bind-data.json`은 이전 Studio에서 추출한 R15의 관절 C0/C1과 파트 크기입니다.
`tools/convert_player_motion.py`는 실제 GLB의 본 방향을 이 바인드에 맞춰 보정하고 60Hz/1e-5 정밀도로 저장합니다.
Animator와 충돌하지 않도록 프레임 전 복구, PreSimulation 적용을 사용합니다.
현재 Roblox의 `AnimationConstraint`와 기존 `Motor6D` 모두 같은 Transform 데이터를 사용합니다.
AvatarJointUpgrade를 끄거나 RigAttachment를 수정하지 않습니다.

재생성:

```sh
/Applications/Blender.app/Contents/MacOS/Blender --background --python tools/convert_player_motion.py
python3 tools/build_installer.py
python3 tools/check.py
```

변환본은 설치기에 포함되므로 별도 Roblox Animation ID 업로드가 필요하지 않습니다.
각 클라이언트가 서버의 이단점프 승인 속성과 캐릭터 이동 상태로 포즈를 재생합니다.
변환·관절/물리 검사는 실제 화면의 자연스러움 판정과 구분합니다. 세부 결과는 `docs/PLAYTEST_NOTES.md`를 참고하세요.
