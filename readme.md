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
    participant IDE as 💻 VS Code (Copilot Hook)
    participant Tutor as 🤖 Tutor Agent
    participant Booster as 🧠 Memory Booster
    participant Teach as 👩‍🏫 Teach-Me Agent
    participant Quiz as 📝 Quiz-Me Agent

    Note over Student, Booster: PHASE 0: LONG-TERM RETENTION CHECK (DYNAMIC MULTI-CHILD)
    Student->>IDE: Opens Chat Window
    IDE->>IDE: Runs .ps1 script silently across all files under data/
    alt Overdue items found for a student
        IDE->>Tutor: Injects runtime prompt modifier payload
        Tutor-->>Student: "Welcome! [Name] has memory reviews due. Launching flash quiz..."
    end

    Note over Student, Quiz: PHASE 1: COMPREHENSION & LIVE LEARNING
    Student->>Tutor: "Let's study!" (Passes Name, Class, Subject, Topic)
    Tutor->>Tutor: Scan/Resume 'state.md' from corresponding directory
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

## 🎯 Key Token Optimization Design Patterns

* **Plain-Text Assessment Boundary:** The grading sequence ignores the heavy markdown payload of `quiz.md`. It isolates evaluations exclusively by matching `answers.md` alongside the hidden target values, keeping token constraints minimal during execution steps.
* **Plain Lines Input Formatting:** Students respond to questions or short answers using plain text lines (e.g., `1. a` or `2. Answer text`) directly inside the lightweight text file, saving massive context data overhead.
* **Append-Only Ledger Continuity:** `state.md` avoids write conflicts and structural parsing errors by continually writing transactions sequentially to the bottom of the page. The core orchestrator parses the file via trailing configurations to seamlessly restore context states across broken sessions.

---

## 🧭 Repository Blueprint & Navigation Links

Select any of the components listed below to jump directly to its definition or script architecture in your workspace folder hierarchy:

### 🤖 Core Workspace Agents
* [🤖 Master Orchestrator](.github/agents/tutor.agent.md) — Manages the state pipeline and targets student folder logic.
* [👩‍🏫 Socratic Teacher](.github/agents/teach-me.agent.md) — Explains subtopics incrementally with customized real-world analogies.
* [📝 Offline Examiner](.github/agents/quiz-me.agent.md) — Generates assessment criteria blueprints and scores raw student outputs.
* [🧠 Cognitive Memory Specialist](.github/agents/memory-booster.agent.md) — Logs learning milestones and tracks long-term retention gates.

### 🛠️ VS Code Automated Lifecycle Hooks
* [📁 Hook Matrix Properties](.github/hooks/hooks.json) — Registers workspace activation directives to bind session launch triggers.
* [⚙️ Multi-Student PowerShell Verification Script](.github/hooks/scripts/check_due_reviews.ps1) — Aggregates and checks spaced repetition dates across all dynamic student subfolders locally.

### 📂 Isolated Folder Data Footprint
```text
your-repository/
└── data/
    └── <class>/                # E.g., Class 9, Class 10
        └── <student_name>/     # Dynamically handles multi-child sibling entries
            ├── [memory_schedule.md]   # Central Spaced Repetition matrix for this child
            └── <subject>/
                └── <topic>/
                    ├── state.md       # Append-only session ledger
                    ├── topic.md       # Socratic reference concepts & analogies
                    ├── quiz.md        # Raw student test sheet
                    ├── answers.md     # Lightweight text file for responses
                    ├── evaluation.md  # Detailed itemized performance maps
                    └── .hidden_answer_key.md # Enforced secure valuation criteria
```
