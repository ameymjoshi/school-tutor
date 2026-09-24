# School Tutor — CBSE Multi-Agent Learning System

A multi-agent system that helps school students learn CBSE-aligned subjects through an interactive **teach → quiz → revise** cycle, with spaced repetition (Leitner system) for long-term retention.

Every agent is defined as a Markdown prompt file — there is no application code. The system runs in any environment that supports Copilot-style chat agents (e.g. VS Code), making it fully LLM-agnostic and trivially portable.

## Architecture

Four agents live in `.github/agents/`:

| Agent | Invocable | Role |
|-------|-----------|------|
| `tutor` | Yes | Primary orchestrator. Parses student details, builds the per-student workspace, runs the boot-time review gate, and coordinates the learning loop |
| `teach-me` | No | Interactive Socratic teacher. Explains subtopics one-by-one with real-life analogies and check questions; re-teaches weak areas with fresh analogies |
| `quiz-me` | No | Independent examiner. Generates quizzes, grades answers against a hidden answer key, and produces evaluation reports |
| `memory-booster` | Yes | Retention specialist. Manages the Leitner-box spaced repetition schedule (1 / 3 / 7 / 14 days) and conducts 3-question flash reviews |

## The Learning Loop

1. **Initialize** — The `tutor` agent parses `studentName`, `class`, `subject`, and `topic`, and resolves the workspace to `data/<class>/<studentName>/<subject>/<topic>/`.
2. **Boot gate** — Before any new teaching, `memory-booster` checks for due spaced-repetition reviews. If reviews are due, they run first.
3. **Teach** — `teach-me` splits the topic into subtopics and explains each with an analogy and 2–3 inline check questions. Notes accumulate in `topic.md`.
4. **Quiz** — `quiz-me` generates a mixed-format quiz (`quiz.md`) with a hidden answer key (`.hidden_answer_key.md`) the student never sees. The student writes answers in `answers.md`.
5. **Grade** — `quiz-me` grades strictly and writes `evaluation.md` with the score and identified weak subtopics.
6. **Remediate or master** — Below 90%, `teach-me` re-teaches only the weak subtopics with completely fresh analogies, and the loop repeats. At 90%+ the topic is marked `MASTERED`.
7. **Retain** — `memory-booster` logs the mastered topic into a Leitner schedule. On future sessions, 3-question flash reviews confirm retention; passing advances the interval, failing demotes the topic to Box 1 and can trigger a full conceptual rewrite of the lesson.

## Repository Structure

```
school-tutor/
├── .github/
│   ├── agents/                    # Agent prompt definitions
│   │   ├── tutor.agent.md         # Primary orchestrator (entry point)
│   │   ├── teach-me.agent.md
│   │   ├── quiz-me.agent.md
│   │   └── memory-booster.agent.md
│   └── hooks/
│       ├── hooks.json             # Registers the sessionStart hook
│       └── scripts/
│           └── check_due_reviews.ps1   # Scans schedules, alerts on due reviews
├── data/                          # Student workspaces (state, notes, schedules)
└── doc/dia/                       # Architecture diagrams
```

## Per-Student Workspace

Each student's data is isolated under `data/<class>/<studentName>/`:

| File | Created by | Purpose |
|------|-----------|--------|
| `state.md` | `tutor` | Append-only session ledger (never overwritten) |
| `topic.md` | `teach-me` | Reference notes per subtopic, with analogies |
| `quiz.md` | `quiz-me` | Question sheet only — no answers |
| `.hidden_answer_key.md` | `quiz-me` | Answer key and grading criteria (hidden) |
| `answers.md` | Student | The student's own quiz responses |
| `evaluation.md` | `quiz-me` | Score, percentage, weak subtopics |
| `memory_schedule.md` | `memory-booster` | Leitner tracker across all subjects |
| `review_quiz.md` / `review_answers.md` | `memory-booster` | Ephemeral flash-review files, deleted after grading |

## Session Hook

`hooks.json` registers a `sessionStart` hook that runs `check_due_reviews.ps1`. The script recursively scans `data/` for every student's `memory_schedule.md`, flags topics whose next review date is due or overdue, and surfaces them so reviews happen before new material is introduced.

> Note: the hook script is PowerShell and currently targets Windows environments.

## Usage

In an agent-capable editor (e.g. VS Code with Copilot chat), invoke the `tutor` agent with the student's details:

```
Abir, Class 9, Science, Agriculture
```

The orchestrator takes it from there — teaching, quizzing, grading, remediation, and long-term retention scheduling all run autonomously, pausing only for student input.

## Design Principles

- **Agents as Markdown** — every behavior is a prompt file; no SDK or API code to maintain
- **Academic integrity** — answer keys are hidden from the student's view path
- **Append-only state** — session history is a ledger, never edited
- **Token efficiency** — grading reads only the student's answers and the key, not full lesson files
- **Spaced repetition** — mastered topics are re-verified at scientific intervals (1 / 3 / 7 / 14 days)

## License

Educational use — CBSE NCERT-aligned content.
