# CBSE AI Tuition Agentic Workspace

This repository houses a production-ready, highly token-efficient multi-agent architecture built for **GitHub Copilot** (or any agentic markdown runtime workspace). The platform facilitates an end-to-end learning lifecycle for CBSE curriculum students, balancing immediate short-term concept mastery with long-term memory retention through structured, automated agent hand-offs.

---

## 🏗️ System Architecture & Orchestration

The system partitions workflows across four highly specialized agents. All sub-agents communicate via strict pseudo-JSON parameters passed through model context protocol instructions.

```mermaid
graph TB
    %% Color Customizations
    classDef orchestrator fill:#2d3748,stroke:#4a5568,stroke-width:2px,color:#fff;
    classDef specialized fill:#1a365d,stroke:#2b6cb0,stroke-width:2px,color:#fff;
    classDef storage fill:#2c5282,stroke:#4299e1,stroke-width:1px,color:#fff,stroke-dasharray: 5, 5;
    
    User((🧑‍🎓 Student)) -->|Invocable Prompt| Tutor[🤖 tutor.agent.md <br>Master Orchestrator]
    class Tutor orchestrator;

    %% Boot Phase
    Tutor -->|1. Check Spaced Repetition| Booster[🧠 memory-booster.agent.md <br>Cognitive Specialist]
    class Booster specialized;
    Booster <-->|Read / Write| Schedule[(📄 memory_schedule.md)]
    class Schedule storage;

    %% Learning Phase
    Tutor -->|2. Delegate Teaching| Teach[👩‍🏫 teach-me.agent.md <br>Socratic Teacher]
    class Teach specialized;
    Teach <-->|Append / Rewrite| Notes[(📄 topic.md)]
    class Notes storage;

    %% Assessment Phase
    Tutor -->|3. Delegate Assessment| Quiz[📝 quiz-me.agent.md <br>Offline Examiner]
    class Quiz specialized;
    Quiz -->|Write Sheet| QuizSheet[(📄 quiz.md)]
    Quiz -->|Write Hidden Key| HiddenKey[(🔒 .hidden_answer_key.md)]
    class QuizSheet,HiddenKey storage;

    %% Student Offline Loop
    User -.->|Fills Plain Lines| Answers[(📄 answers.md)]
    class Answers storage;
    Quiz <-->|Token-Efficient Grade| Answers
    Quiz -->|Write Results| Eval[(📄 evaluation.md)]
    class Eval storage;
    
    Eval -.->|If Score &lt; 90%| Tutor
```

---

## ⏱️ Execution Protocol Timeline

This sequence diagram illustrates the lifecycle of a learning block, explicitly tracing when agents pause, hand off control, and use offline files to compress token expenses.

```mermaid
sequenceDiagram
    autonumber
    actor Student as 🧑‍🎓 Student
    participant Tutor as 🤖 Tutor Agent
    participant Booster as 🧠 Memory Booster
    participant Teach as 👩‍🏫 Teach-Me Agent
    participant Quiz as 📝 Quiz-Me Agent

    Note over Student, Booster: PHASE 0: LONG-TERM RETENTION CHECK
    Student->>Tutor: "Let's study!" (Passes Name, Class, Subject, Topic)
    Tutor->>Booster: Invoke: CHECK_DUE_REVIEWS
    alt Reviews Are Due
        Booster-->>Tutor: Returns due topic array
        Tutor->>Booster: Invoke: CONDUCT_REVIEW
        Booster->>Student: Drops 'review_quiz.md' & Pauses loop
        Student->>Student: Fills plain lines inside 'review_answers.md'
        Student->>Tutor: "Done with flash review!"
        Tutor->>Booster: Invoke: GRADE_REVIEW
        alt Review Passed (3/3)
            Booster->>Booster: Advance topic to next Leitner Box
        else Review Failed (< 3/3)
            Booster->>Booster: Demote to Box 1 (Triggers CONCEPTUAL_REWRITE mode)
        end
    end

    Note over Student, Quiz: PHASE 1: COMPREHENSION & LIVE LEARNING
    Tutor->>Tutor: Scan/Resume 'state.md' from current directory
    alt Fresh Topic
        Tutor->>Teach: Invoke: TEACH mode
    else Memory Remediation Triggered
        Tutor->>Teach: Invoke: CONCEPTUAL_REWRITE mode
    end
    
    loop Socratic Dialogue
        Teach->>Student: Present Analogy & Ask Quick Check Questions
        Student->>Teach: Provide answer text
    end
    Teach->>Teach: Append/Overwrite 'topic.md' notes sheet
    Teach-->>Tutor: Content delivered successfully

    Note over Student, Quiz: PHASE 2: ASSESSMENT & OFFLINE EVALUATION
    Tutor->>Quiz: Invoke: GENERATE mode
    Quiz->>Quiz: Extract layout from 'topic.md'
    Quiz->>Student: Drops bare 'quiz.md' (Questions Only)
    Quiz->>Tutor: Drops secret '.hidden_answer_key.md'
    Tutor-->>Student: "Quiz ready. Write items in 'answers.md' & reply 'Done'"
    Note over Tutor, Quiz: Agent completely powers down to save session context tokens
    
    Student->>Student: Edits 'answers.md' offline (e.g., '1. a')
    Student->>Tutor: "Done!"
    
    Tutor->>Tutor: Resume context ledger state
    Tutor->>Quiz: Invoke: GRADE mode
    Quiz->>Quiz: Read *only* 'answers.md' and '.hidden_answer_key.md'
    Quiz->>Quiz: Compute numerical scoring percentage
    Quiz->>Tutor: Overwrites 'evaluation.md' reporting outcome

    alt Evaluation Score >= 90%
        Tutor->>Booster: Invoke: LOG_MASTERY (Plant seed for spaced repetition)
        Tutor-->>Student: Celebrate mastery milestone!
    else Evaluation Score < 90%
        Tutor->>Tutor: Set state to REMEDIATION_REQUIRED
        Tutor-->>Student: Restarting cycle for weak subsections...
    end
```

---

## 📂 Isolated Folder Data Footprint

The system automatically manages context directory boundaries dynamically. Sub-agents are completely agnostic to specific grade levels and curriculum tracks. The paths follow this structural map:

```text
your-repository/
└── data/
    └── <class>/                # E.g., Class 9, Class 10 (Managed natively by Tutor)
        └── <student_name>/
            ├── memory_schedule.md  # Global Spaced Repetition tracking matrix
            └── <subject>/
                └── <topic>/
                    ├── state.md            # Append-only execution history log
                    ├── topic.md            # Socratic reference concepts & analogies
                    ├── quiz.md             # Empty student test sheet
                    ├── answers.md          # Token-saving student response file (Plain text)
                    ├── .hidden_answer_key.md # Enforced secure valuation criteria
                    └── evaluation.md       # Target breakdown of identified gaps
```

---

## 🎯 Key Token Optimization Design Patterns

* **Plain-Text Assessment Boundary:** The grading sequence ignores the heavy markdown payload of `quiz.md`. It isolates evaluations exclusively by matching `answers.md` alongside the hidden target values, keeping token constraints minimal during execution steps.
* **Plain Lines Input Formatting:** Students respond to questions or short answers using plain text lines (e.g., `1. a` or `2. Answer text`) directly inside the lightweight text file, saving massive context data overhead.
* **Append-Only Ledger Continuity:** `state.md` avoids write conflicts and structural parsing errors by continually writing transactions sequentially to the bottom of the page. The core orchestrator parses the file via trailing configurations to seamlessly restore context states across broken sessions.

---

## 📝 Complete Agent Configuration Definitions

Below are the complete, standalone markdown specifications for each of the 4 system agents. Store them individually inside your `.github/agents/` directory structure.

### 1. `tutor.agent.md`
```markdown
---
name: tutor
description: Core orchestrator for the academic learning workflow. Tracks progress, handles spaced repetition check-ins, and delegates tasks.
tools: [vscode, execute, read, agent, edit, browser]
agents: ['teach-me', 'quiz-me', 'memory-booster']
user-invocable: true
argument-hint: "Provide student details. Example: 'Abir, Class 9, Science, Agriculture'"
---

## Role
You are the primary academic coordinator. Your job is to initialize the student directory, determine where they left off by scanning historical state logs, handle memory retention reviews at boot, and coordinate the active learning cycle.

## Initialization & Routing Protocol
1. On boot, parse the user's string input or prompt context to extract: `studentName`, `class`, `subject`, and `topic`.
2. Construct the root path variable: `studentRootPath = "data/" + class + "/" + studentName`.
3. Construct the active topic path variable: `workspacePath = studentRootPath + "/" + subject + "/" + topic`.

### Phase 0: Long-Term Memory Check (Daily Boot Gate)
Before checking the active topic's `state.md`, invoke `memory-booster` to check for due reviews:
- Call `memory-booster` with arguments: `{"studentRootPath": "${studentRootPath}", "action": "CHECK_DUE_REVIEWS"}`.
- **If reviews are due:** Intercept the user immediately. Output: *"Welcome back! Before we start learning new things today, we need to do a quick Spaced Repetition flash check on past topics to lock them into your long-term memory."* Proceed to invoke `memory-booster` with `action: "CONDUCT_REVIEW"`, then pause execution.
- **If no reviews are due (or once reviews are completed):** Proceed directly to Phase 1.

### Phase 1: Core Session Evaluation
1. Read `${workspacePath}/state.md` if it exists:
   - If the file **does not exist**, execute **Step A (Fresh Start)**.
   - If the file **exists**, read the very last log entry to determine status and execute **Step B (Resume)**.

#### Step A: Fresh Start
1. Create the base tracking directory structure.
2. Initialize `${workspacePath}/state.md` with the append-only log format.
3. Delegate control to `teach-me`, passing a JSON argument string: `{"workspacePath": "${workspacePath}", "mode": "TEACH"}`.

#### Step B: Resume / State Verification
Look at the most recent status entry in `${workspacePath}/state.md`:
- **If status is `AWAITING_QUIZ_COMPLETION`:** 
  - Check if the student says they are finished and verify if `${workspacePath}/answers.md` contains content.
