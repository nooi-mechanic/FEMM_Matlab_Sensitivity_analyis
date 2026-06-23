# FEMM SPM 모터 생성

이 저장소는 FEMM에서 사용할 SPM(Surface Permanent Magnet) 모터 모델을 생성하기 위한 MATLAB/Octave 스크립트를 담고 있습니다.

현재 포함된 코드는 해석 결과를 후처리하는 스크립트가 아니라, 모터 형상과 재료, 권선, 경계조건을 정의한 뒤 `.fem` 파일로 저장하는 생성용 스크립트입니다.

## 포함된 파일

- `octave/generate_spm_motor.m`
  - FEMM를 열고 새 문서를 만든 뒤
  - 자석, 코어, 실링 재료를 정의하고
  - SPM 모터 형상을 그린 다음
  - 권선과 공기영역, 경계조건을 설정하고
  - 최종적으로 `spm.fem` 파일로 저장합니다

## 필요한 환경

- [FEMM](https://www.femm.info/wiki/HomePage)
- GNU Octave 또는 MATLAB 호환 실행 환경

참고:

- 이 스크립트는 `openfemm()` 기반 자동화를 전제로 합니다.
- FEMM 자동화는 일반적으로 Windows 환경에서 많이 사용됩니다.
- 현재 코드는 해석 실행이나 결과 추출보다 모델 생성에 초점이 맞춰져 있습니다.

## 사용 방법

1. FEMM가 설치된 환경에서 Octave 또는 MATLAB을 엽니다.
2. `octave/generate_spm_motor.m` 파일을 실행합니다.
3. 실행이 끝나면 작업 결과로 `spm.fem` 파일이 저장됩니다.

예시:

```octave
run("octave/generate_spm_motor.m")
```

## 현재 코드가 하는 일

- 문제 정의 단위를 `millimeters` 기준으로 설정
- 코어 B-H 커브와 자석 재료 정의
- 회전자 자석 및 실링 영역 생성
- 고정자 슬롯과 치 형상 생성
- 3상 권선 블록 라벨 배치
- 외곽 공기영역 및 경계조건 설정
- `spm.fem` 저장

## 아직 포함되지 않은 내용

- 토크, 자속, 인덕턴스 등의 해석 결과 추출
- 파라미터 스윕 자동화
- 민감도 해석용 반복 실행
- 결과 CSV 저장 및 시각화

## 디렉토리 구조

```text
.
├── README.md
└── octave
    └── generate_spm_motor.m
```
