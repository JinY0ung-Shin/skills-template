# Skills Template 레포 구성 계획

## 목표
누구든 이 레포만 보면 Claude Code skill을 올바르게 만들 수 있는 공용 템플릿 레포

---

## 1단계: README.md - 핵심 가이드 문서

**역할**: 레포 진입점. skill이 뭔지, 어떻게 만드는지, 어떻게 쓰는지 한 문서로 완결

**포함 내용**:
- Skill이란 무엇인가 (한 줄 설명)
- 디렉토리 구조 개요
- SKILL.md 파일 형식 (frontmatter 필드 전체 레퍼런스 테이블)
- 사용 가능한 변수 ($ARGUMENTS, $0, ${CLAUDE_SESSION_ID}, ${CLAUDE_SKILL_DIR})
- 동적 컨텍스트 주입 (`` !`command` `` 구문)
- 설치 방법 (이 레포의 skill을 자기 프로젝트에 복사하는 법)
- 새 skill 만드는 단계별 가이드 (Quick Start)

---

## 2단계: 예제 스킬 디렉토리 구성

실제 동작하는 예제 skill들을 `.claude/skills/` 에 배치. 난이도별로 패턴을 보여줌.

### 2-1. 기본 예제: `review` (가장 단순한 형태)
```
.claude/skills/review/
└── SKILL.md
```
- frontmatter 최소 구성 (name, description만)
- $ARGUMENTS 사용법 데모

### 2-2. 중급 예제: `gen-test` (도구 권한 + 인자 활용)
```
.claude/skills/gen-test/
└── SKILL.md
```
- allowed-tools 설정
- argument-hint 사용
- 여러 인자($0, $1) 활용

### 2-3. 고급 예제: `pr-summary` (동적 컨텍스트 + 서브에이전트 + 보조 파일)
```
.claude/skills/pr-summary/
├── SKILL.md
├── review-checklist.md            # 보조 파일: 리뷰 체크리스트
└── scripts/
    └── collect-metrics.sh         # 스크립트: PR 메트릭 수집
```
- context: fork, agent 설정
- !`command` 동적 컨텍스트 주입
- **보조 파일 참조 패턴**: SKILL.md가 길어질 때 체크리스트/규칙/가이드라인을 별도 .md로 분리하고 SKILL.md에서 참조하는 방법
- **scripts/ 활용 패턴**: 스킬이 실행해야 하는 셸 스크립트(린터, 메트릭 수집, 포맷터 등)를 scripts/에 두고 ${CLAUDE_SKILL_DIR}/scripts/로 경로 참조하는 방법

### 2-4. 제어 예제: `deploy` (수동 전용 + 위험 작업)
```
.claude/skills/deploy/
└── SKILL.md
```
- disable-model-invocation: true
- 사이드이펙트가 있는 작업의 안전한 패턴

---

## 3단계: 스킬 생성 템플릿

빈 템플릿을 제공해서 복사 후 바로 작성 시작 가능하게 함.

```
templates/
├── basic.md          # 최소 구성 템플릿
├── with-tools.md     # 도구 권한 포함 템플릿
└── advanced.md       # 전체 필드 포함 템플릿
```

각 템플릿에 주석으로 각 필드 설명 포함.

---

## 4단계: Frontmatter 필드 레퍼런스 (REFERENCE.md)

README가 길어지는 걸 방지하기 위해 별도 상세 레퍼런스 문서 분리.

**포함 내용**:
- 전체 frontmatter 필드 상세 설명 + 기본값 + 예시
- 자주 하는 실수 / FAQ
- allowed-tools에 쓸 수 있는 도구 목록
- model 필드에 쓸 수 있는 모델 ID 목록
- 스킬 간 우선순위 (Enterprise > Personal > Project > Plugin)
- **보조 파일 가이드**: 언제 보조 파일을 분리해야 하는지 (SKILL.md 500줄 초과, 여러 스킬에서 공통 규칙 참조, 체크리스트/컨벤션/규칙 등 독립적인 문서)
- **scripts/ 가이드**: 언제 스크립트가 필요한지 (반복적인 셸 작업, 외부 도구 호출 래핑, 빌드/배포 자동화 단계, 린터/포맷터 실행)

---

## 파일 구조 최종 요약

```
skills-template/
├── README.md                          # 메인 가이드
├── REFERENCE.md                       # 필드 상세 레퍼런스
├── templates/
│   ├── basic.md                       # 최소 구성 템플릿
│   ├── with-tools.md                  # 도구 권한 포함 템플릿
│   └── advanced.md                    # 전체 필드 포함 템플릿
└── .claude/
    └── skills/
        ├── review/
        │   └── SKILL.md               # 기본 예제
        ├── gen-test/
        │   └── SKILL.md               # 중급 예제
        ├── pr-summary/
        │   ├── SKILL.md               # 고급 예제
        │   ├── review-checklist.md    # 보조 파일 예제
        │   └── scripts/
        │       └── collect-metrics.sh # 스크립트 예제
        └── deploy/
            └── SKILL.md               # 수동 전용 예제
```

---

## 구현 순서

1. 예제 스킬 4개 작성 (실제 동작하는 코드)
2. 템플릿 3개 작성 (복사해서 바로 쓸 수 있는 빈 틀)
3. REFERENCE.md 작성 (상세 필드 레퍼런스)
4. README.md 작성 (Quick Start + 구조 설명 + 예제 안내)
5. 커밋 & 푸시
