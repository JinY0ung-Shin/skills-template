# Skills Template 레포 구성 계획

## 목표
누구든 이 레포만 보면 Claude Code skill을 올바르게 만들 수 있는 공용 템플릿 레포

> Claude Code skills는 [Agent Skills](https://agentskills.io) 오픈 표준을 따르며, Claude Code 전용 확장 필드를 추가로 지원한다.
> Skills는 기존 `.claude/commands/` 시스템을 통합·대체한 상위 시스템이다. SKILL.md 하나에 frontmatter로 모든 제어(인자, 모델, 도구 권한, 서브에이전트, hooks 등)를 선언할 수 있다.

---

## 1단계: README.md - 핵심 가이드 문서

**역할**: 레포 진입점. skill이 뭔지, 어떻게 만드는지, 어떻게 쓰는지 한 문서로 완결

**포함 내용**:
- Skill이란 무엇인가 (한 줄 설명 + Agent Skills 표준 언급)
- Skills vs Commands 관계 (skills가 commands를 통합·대체, 같은 이름이면 skills 우선)
- 디렉토리 구조 개요
- SKILL.md 파일 형식 (frontmatter 필드 요약 테이블)
- 사용 가능한 변수 ($ARGUMENTS, $ARGUMENTS[N], $0~$N, ${CLAUDE_SESSION_ID}, ${CLAUDE_SKILL_DIR})
- 동적 컨텍스트 주입 (`` !`command` `` 구문)
- 설치 방법 (이 레포의 skill을 자기 프로젝트에 복사하는 법)
- 새 skill 만드는 단계별 가이드 (Quick Start)
- 스킬 저장 위치와 우선순위 (Enterprise > Personal > Project, Plugin은 네임스페이스 별도)
- 크로스 툴 호환성 노트: Agent Skills 표준 호환을 위해 name, description을 항상 명시 권장
- 이름 명명 규칙 (최대 64자, 소문자+숫자+하이픈, "anthropic"/"claude" 금지, 연속 하이픈 불가)
- 서드파티 스킬 보안 경고 (스크립트·외부 fetch 포함 스킬은 소프트웨어처럼 감사 필요)

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
- description 작성 가이드라인 (3인칭, 1024자 이내, XML 태그 금지)

### 2-2. 중급 예제: `gen-test` (도구 권한 + 인자 활용)
```
.claude/skills/gen-test/
└── SKILL.md
```
- allowed-tools 설정 (와일드카드 포함: `Bash(git *)`)
- argument-hint 사용
- 여러 인자($0, $1) 활용
- model 오버라이드 데모 (예: `model: haiku` 로 빠른 실행)

### 2-3. 고급 예제: `pr-summary` (동적 컨텍스트 + 서브에이전트 + 보조 파일)
```
.claude/skills/pr-summary/
├── SKILL.md
├── review-checklist.md            # 보조 파일: 리뷰 체크리스트
└── scripts/
    └── collect-metrics.sh         # 스크립트: PR 메트릭 수집
```
- context: fork + agent: Explore 설정 (서브에이전트 타입 지정)
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

### 2-5. 백그라운드 지식 예제: `legacy-context` (Claude 전용 자동 호출)
```
.claude/skills/legacy-context/
└── SKILL.md
```
- user-invocable: false (/ 메뉴에서 숨김, Claude만 자동 호출)
- 레거시 시스템 컨텍스트나 코드베이스 규칙 등 Claude에게만 제공되는 배경 지식 패턴

### 2-6. 안전 검사 예제: `secure-ops` (hooks 포함)
```
.claude/skills/secure-ops/
├── SKILL.md
└── scripts/
    └── security-check.sh          # 보안 검사 스크립트
```
- hooks 설정 (PreToolUse로 Bash 실행 전 보안 검사)
- once: true (세션 당 1회만 실행되는 hook)
- 스킬 스코프 lifecycle hooks 패턴

---

## 3단계: 스킬 생성 템플릿

빈 템플릿을 제공해서 복사 후 바로 작성 시작 가능하게 함.

```
templates/
├── basic.md          # 최소 구성 템플릿 (name, description만)
├── with-tools.md     # 도구 권한 포함 템플릿 (allowed-tools, argument-hint)
├── with-hooks.md     # hooks 포함 템플릿 (PreToolUse, PostToolUse)
└── advanced.md       # 전체 필드 포함 템플릿 (context: fork, agent, hooks, model 등)
```

각 템플릿에 주석으로 각 필드 설명 포함.

---

## 4단계: Frontmatter 필드 레퍼런스 (REFERENCE.md)

README가 길어지는 걸 방지하기 위해 별도 상세 레퍼런스 문서 분리.

**포함 내용**:

### 필드 레퍼런스
- Agent Skills 표준 필드: name, description, license, compatibility, metadata
- Claude Code 확장 필드: argument-hint, disable-model-invocation, user-invocable, allowed-tools, model, context, agent, hooks
- 각 필드별 타입, 기본값, 제약 조건, 예시
- 출처 라벨링 컨벤션: `[core]` Agent Skills 표준 / `[ext]` Claude Code 확장 / `[CLI-only]` CLI 전용 / `[legacy]` 하위호환

### Invocation Control Matrix
- disable-model-invocation × user-invocable 4가지 조합별 동작 차이
  - (default): 사용자 O, Claude O
  - disable-model-invocation: true: 사용자 O, Claude X (description 컨텍스트에서 제거)
  - user-invocable: false: 사용자 X, Claude O
  - 둘 다 설정: 양쪽 다 제한 (비실용적)

### Progressive Disclosure
- 시작 시 name/description만 ~100토큰 로드, 호출 시 전체 SKILL.md 읽음
- description 전체 합산 budget: context window의 2% (fallback 16,000자)
- SLASH_COMMAND_TOOL_CHAR_BUDGET 환경변수로 오버라이드 가능

### 이름 명명 규칙
- 최대 64자, 소문자 영숫자 + 하이픈만
- "anthropic", "claude" 포함 불가
- 하이픈으로 시작/끝 불가, 연속 하이픈(--) 불가
- 디렉토리명이 name과 일치해야 함

### 스킬 저장 위치와 우선순위
- 우선순위: Enterprise > Personal (`~/.claude/skills/`) > Project (`.claude/skills/`)
- Plugin 스킬은 `plugin-name:skill-name` 네임스페이스를 사용하므로 위 우선순위 체인과 충돌하지 않음 (별도 섹션으로 설명)
- 각 위치별 경로, 스코프, 관리 방법
- 모노레포 중첩 디렉토리 자동 발견
- --add-dir 라이브 리로드

### Skills vs Commands vs Agents
- .claude/commands/ → .claude/skills/ 마이그레이션 가이드
- skills가 commands를 통합·대체 (같은 이름이면 skills 우선)
- .claude/agents/ 와의 차이점 (agents는 독립 실행 컨텍스트, skills는 호출 시 컨텍스트 주입)
- 호환성 노트: allowed-tools는 Claude Code CLI 전용, Agent SDK/API에서는 동일하게 적용되지 않음

### Description 작성 가이드
- 3인칭으로 작성 ("Processes..." not "I can...")
- 1024자 이내, XML 태그 금지
- YAML multiline 표기법(>-, |) 주의사항 — 한 줄로 작성 권장

### 검증 및 트러블슈팅
- `skills-ref validate ./my-skill` 로 Agent Skills 표준 준수 여부 검증
- YAML frontmatter 파싱 확인 방법
- `claude --debug` 로 스킬 로드 확인
- `/context` 로 description budget 초과 여부 확인
- 스킬 변경 후 세션 재시작 필요 (--add-dir 제외)
- 흔한 실수: 잘못된 들여쓰기, 필드명 오타, description 누락

### 보안
- 서드파티 스킬은 소프트웨어처럼 감사 필요 (특히 scripts/, !`command`, 외부 fetch)
- allowed-tools 범위를 최소화하는 원칙 (최소 권한)

### 크로스 툴 호환성
- Agent Skills 표준은 name, description을 필수로 요구하지만 Claude Code는 생략 가능 (기본값 추론)
- 이 레포의 모든 예제/템플릿은 최대 호환성을 위해 name, description을 항상 명시

### 기타
- allowed-tools에 쓸 수 있는 도구 목록 + 와일드카드 문법
- model 필드: 공식 모델 개요 페이지 링크 (휘발성 ID 목록 대신 링크)
- "ultrathink" 키워드로 extended thinking 활성화
- 보조 파일 가이드: 분리 시점 (500줄 초과, 공통 규칙, 독립 문서)
- scripts/ 가이드: 필요 시점 (반복 셸 작업, 외부 도구 래핑, 빌드/배포, 린터/포맷터)
- 자주 하는 실수 / FAQ

---

## 파일 구조 최종 요약

```
skills-template/
├── README.md                          # 메인 가이드
├── REFERENCE.md                       # 필드 상세 레퍼런스
├── templates/
│   ├── basic.md                       # 최소 구성 템플릿
│   ├── with-tools.md                  # 도구 권한 포함 템플릿
│   ├── with-hooks.md                  # hooks 포함 템플릿
│   └── advanced.md                    # 전체 필드 포함 템플릿
└── .claude/
    └── skills/
        ├── review/
        │   └── SKILL.md               # 기본 예제
        ├── gen-test/
        │   └── SKILL.md               # 중급 예제 (도구+인자+모델)
        ├── pr-summary/
        │   ├── SKILL.md               # 고급 예제 (fork+agent+동적컨텍스트)
        │   ├── review-checklist.md    # 보조 파일 예제
        │   └── scripts/
        │       └── collect-metrics.sh # 스크립트 예제
        ├── deploy/
        │   └── SKILL.md               # 수동 전용 예제
        ├── legacy-context/
        │   └── SKILL.md               # Claude 전용 백그라운드 지식 예제
        └── secure-ops/
            ├── SKILL.md               # hooks 포함 예제
            └── scripts/
                └── security-check.sh  # 보안 검사 스크립트
```

---

## 구현 순서

1. 예제 스킬 6개 작성 (실제 동작하는 코드)
2. 템플릿 4개 작성 (복사해서 바로 쓸 수 있는 빈 틀)
3. REFERENCE.md 작성 (상세 필드 레퍼런스 + invocation matrix + progressive disclosure + 검증/보안)
4. README.md 작성 (Quick Start + 구조 설명 + 예제 안내 + 명명 규칙 + 보안 경고)
5. 커밋 & 푸시
