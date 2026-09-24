# CBSE AI Tutor

This repository houses a production-ready, highly token-efficient multi-agent architecture built for **GitHub Copilot** (or any agentic markdown runtime workspace). The platform facilitates an end-to-end learning lifecycle for CBSE curriculum students, balancing immediate short-term concept mastery with long-term memory retention through structured, automated agent hand-offs.

---

## 🏗️ System Architecture & Orchestration (Hub & Spoke)

The system partitions workflows across four highly specialized agents under a centralized **Hub & Spoke** model. The student interacts exclusively with `@tutor`. All sub-agents communicate via strict pseudo-JSON parameters passed through model context protocol instructions.

```mermaid
graph TB
    %% Color Customizations
    classDef orchestrator fill:#2d3748,stroke:#4a5568,stroke-width:2px,color:#fff;
    classDef specialized fill:#1a365d,stroke:#2b6cb0,stroke-width:2px,color:#fff;
    classDef commonStorage fill:#234e52,stroke:#319795,stroke-width:1px,color:#fff,stroke-dasharray: 5, 5;
    classDef studentStorage fill:#2c5282,stroke:#4299e1,stroke-width:1px,color:#fff,stroke-dasharray: 5, 5;
    
    User((🧑‍🎓 Student)) <-->|Invocable Chat Dialogue| Tutor[🤖 tutor.agent.md <br>Master Orchestrator]
    class Tutor orchestrator;

    %% Boot Phase
    Tutor -->|1. Check Spaced Repetition| Booster[🧠 memory-booster.agent.md <br>Cognitive Specialist]
    class Booster specialized;
    Booster <-->|Read / Write Concept Ledger| Schedule[(📄 memory_schedule.md)]
    class Schedule studentStorage;

    %% Learning Phase
    Tutor <-->|2. Relay Conversational Turns| Teach[👩‍🏫 teach-me.agent.md <br>Socratic Teacher]
    class Teach specialized;
    Teach -->|Append Mastered Concept Notes| CommonNotes[(📄 data/common/.../topic.md)]
    class CommonNotes commonStorage;

    %% Assessment Phase
    Tutor -->|3. Delegate Assessment| Quiz[📝 quiz-me.agent.md <br>High-Bar Examiner]
    class Quiz specialized;
    Quiz -->|Write 20-Q Sheet| QnaSheet[(📄 <concept>-qna.md)]
    Quiz -->|Write Hidden Key| HiddenKey[(🔒 .<concept>-key.md)]
    class QnaSheet,HiddenKey studentStorage;

    %% Student Offline Loop
    User -.->|Fills Q01-Q20 in Answer Section| QnaSheet
    Quiz <-->|Token-Efficient Grade| QnaSheet
    Quiz -->|Write Attempt History| Eval[(📄 evaluation.md)]
    class Eval studentStorage;
    
    Eval -.->|If Score &lt; 80%| Tutor
```

---

## ⏱️ Execution Protocol Timeline

This sequence diagram illustrates the lifecycle of an interactive learning block, tracing conversational teaching, in-chat quick checks, single-file assessment, and concept-level retention.

```mermaid
sequenceDiagram
    autonumber
    actor Student as 🧑‍🎓 Student
    participant IDE as 💻 VS Code (Copilot Hook)
    participant Tutor as 🤖 Tutor Agent
    participant Booster as 🧠 Memory Booster
    participant Teach as 👩‍🏫 Teach-Me Agent
    participant Quiz as 📝 Quiz-Me Agent

    Note over Student, Booster: PHASE 0: CONCEPT-LEVEL RETENTION CHECK (BOOT GATE)
    Student->>IDE: Opens Chat Window
    IDE->>IDE: Runs check_due_reviews.ps1 silently across data/students/
    alt Overdue concepts found for student
        IDE->>Tutor: Injects runtime prompt modifier payload
        Tutor-->>Student: "Welcome! Quick 2-min Spaced Repetition check on [Concept]..."
        Tutor->>Booster: Invoke: CONDUCT_REVIEW (3 Flash Questions)
        Booster-->>Student: 3 quick questions in chat
        Student-->>Booster: Answers in chat
        Booster->>Booster: Updates memory_schedule.md (Leitner interval)
    end

    Note over Student, Teach: PHASE 1: ROADMAP & CONCEPT SELECTION
    Student->>Tutor: "Let's study!" (Passes Name, Class, Subject, Chapter)
    Tutor->>Teach: Invoke: PLAN_ROADMAP (Checks common topic.md or reference.pdf)
    Teach-->>Tutor: 4-6 Modular NCERT Concepts
    Tutor-->>Student: Displays Roadmap: "Which concept to learn? (Pick number or 'All')"
    Student-->>Tutor: Selects Concept (or "All" for 1-by-1 sequence)

    Note over Student, Teach: PHASE 2: LIVE SOCRATIC CONVERSATION & IN-CHAT CHECKS
    loop Turn-by-Turn Socratic Dialogue in Chat
        Tutor->>Teach: Relay active concept explanation
        Teach-->>Tutor: Deep concept explanation + 2-3 live quick checks in chat
        Tutor-->>Student: Presents dialogue with cheerful motivation (🌟 🚀)
        Student-->>Tutor: Replies in chat
        Tutor->>Teach: Relay answer for evaluation
        Teach-->>Tutor: Supportive feedback + next check / mastery signal
    end
    Teach->>Teach: Appends mastered concept notes to common topic.md
    Teach-->>Tutor: Returns status: CONCEPT_MASTERED

    Note over Student, Quiz: PHASE 3: ASSESSMENT & EVALUATION (20 QUESTIONS)
    Tutor->>Quiz: Invoke: GENERATE (Concept name)
    Quiz->>Quiz: Extracts details from common topic.md
    Quiz->>Student: Drops '<concept>-qna.md' (e.g. agriculture-qna.md: 20 Qs + Q01-Q20 slots)
    Quiz->>Tutor: Drops secret '.<concept>-key.md'
    Tutor-->>Student: "Quiz ready in <concept>-qna.md. Fill Q01-Q20 & reply 'Done'"
    Note over Tutor, Quiz: Agent completely powers down while student answers
    
    Student->>Student: Fills '<concept>-qna.md' offline
    Student->>Tutor: "Done!"
    
    Tutor->>Quiz: Invoke: GRADE
    Quiz->>Quiz: Reads *only* '## Student Answers' section & '.<concept>-key.md'
    Quiz->>Quiz: Computes score out of 20 (Mastery gate: >= 80%)
    Quiz->>Tutor: Appends outcome to student's evaluation.md

    alt Evaluation Score >= 80% (Mastered)
        Tutor->>Booster: Invoke: LOG_MASTERY (Register concept in Box 1)
        Tutor-->>Student: Celebrates mastery milestone! (🎉 🏆)
        Note over Tutor, Student: If 'All' was chosen, advances to next concept in queue
    else Evaluation Score < 80% (Remediation Needed)
        Tutor->>Tutor: Logs REMEDIATION_NEEDED in state.md
        Tutor-->>Student: "Score: [X]/20. Would you like to 'Revise' or 'Retake'?"
    end
```

---

## 🎯 Key Design Patterns & Teaching Protocols

* **Hub-and-Spoke Invocability:** The student only needs to converse with `@tutor`. Subagents (`teach-me`, `quiz-me`, `memory-booster`) are specialized workers orchestrated by `tutor` behind the scenes.
* **Live In-Chat Socratic Dialogue:** Teaching happens strictly in conversation with the student in the chat window. No offline lesson markdown files (such as `lesson.md`) are dumped on the student.
* **Formative In-Chat Quick Checks:** During instruction, `teach-me` poses 2–3 quick check questions right in the chat to ensure attention and tracking before moving to summative testing.
* **Cheerful & Supportive Persona:** Uses motivating language and emojis (🌟, 🚀, 👏). If an answer is incorrect, it calls it out directly but in a positive, constructive manner with guiding hints.
* **Dynamic Concept-Specific Assessment (`<concept>-qna.md`):** Automatically named after the active concept (e.g., `agriculture-qna.md`, `linear-eq-qna.md`, `atmospheric-layers-qna.md`). Eliminates file switching with questions at top and `Q01:`–`Q20:` slots at bottom.
* **Token-Saving Grading:** `quiz-me` reads only from `## Student Answers` downwards and matches against `.<concept>-key.md`, avoiding re-tokenizing large question prompts.
* **Concept-Level Spaced Repetition:** `memory-booster` schedules and evaluates 3-question flash checks at the granular concept level using the Leitner box interval system (1d ➔ 3d ➔ 7d ➔ 14d).

---

## 🧭 Repository Blueprint & Navigation Links

Select any of the components listed below to jump directly to its definition or script architecture:

### 🤖 Core Workspace Agents
* [🤖 Master Orchestrator](.github/agents/tutor.agent.md) — Manages the state pipeline, coordinates sub-agents, and handles student chat.
* [👩‍🏫 Socratic Teacher](.github/agents/teach-me.agent.md) — Teaches concepts step-by-step in chat with analogies, NCERT grounding, and 2-3 quick checks.
* [📝 High-Bar Examiner](.github/agents/quiz-me.agent.md) — Generates 20-question dynamic sheets (`<concept>-qna.md`) and grades against hidden keys.
* [🧠 Cognitive Memory Specialist](.github/agents/memory-booster.agent.md) — Manages concept-level retention intervals and conducts in-chat flash reviews.

### 🛠️ VS Code Automated Lifecycle Hooks
* [📁 Hook Matrix Properties](.github/hooks/hooks.json) — Registers workspace activation directives to bind session launch triggers.
* [⚙️ Multi-Student PowerShell Verification Script](.github/hooks/scripts/check_due_reviews.ps1) — Aggregates and checks spaced repetition dates across all student subfolders dynamically.

### 📂 Directory Architecture
```text
your-repository/
└── data/
    ├── common/                               # SHARED CANONICAL REPOSITORY
    │   └── <class>/                          # E.g., Class 9, Class 10
    │       └── <subject>/                    # E.g., Science, Geography
    │           └── <topic>/                  # E.g., Atmosphere and Climate
    │               ├── reference.pdf         # Chapter or Subject textbook PDF (if provided)
    │               └── topic.md              # Shared canonical concept notes & syllabus roadmap
    │
    └── students/                             # STUDENT SPECIFIC
        └── <student_name>/                   # E.g., Amey, Abir
            ├── memory_schedule.md            # Spaced repetition tracker (Boxes 1-4, concept-level)
            └── <class>/
                └── <subject>/
                    └── <topic>/
                        ├── state.md          # Personal queue & lifecycle ledger
                        ├── <concept>-qna.md  # E.g. agriculture-qna.md (20 questions + Q01-Q20 slots)
                        ├── .<concept>-key.md # Secure grading criteria
                        └── evaluation.md     # Attempt history table & score breakdown
```
