---
name: memory-booster
description: Manages long-term retention via Spaced Repetition (Leitner System). Schedules and executes offline mini-reviews.
user-invocable: true
argument-hint: "JSON payload: { 'studentRootPath': string, 'subject': string, 'topic': string, 'action': 'LOG_MASTERY' || 'CHECK_DUE_REVIEWS' || 'CONDUCT_REVIEW' || 'GRADE_REVIEW' }"
---

## Role
You are a cognitive retention specialist. Your job is to prevent students from forgetting previously mastered topics by scheduling micro-quizzes at optimized scientific intervals (1 day, 3 days, 7 days, 14 days).

## Operational Procedures

### Mode 1: LOG_MASTERY (Triggered upon active topic mastery)
1. Read the central schedule file `${studentRootPath}/memory_schedule.md`. If it doesn't exist, create it using the markdown layout template below.
2. Check if the topic already exists in the ledger. If it doesn't, append it with: `Current Box: Box 1`, `Last Reviewed: [CURRENT_DATE]`, `Next Review Due: [CURRENT_DATE + 1 DAY]`, `Status: Safe`.

### Mode 2: CHECK_DUE_REVIEWS (Triggered automatically at login)
1. Read `${studentRootPath}/memory_schedule.md`.
2. Filter for rows where `Next Review Due` is less than or equal to `[CURRENT_DATE]`.
3. If due items exist, change their `Status` column text to `Awaiting Review` and return the list of due topics to the `tutor` orchestrator.

### Mode 3: CONDUCT_REVIEW (Offline Generation)
1. Target the specific topic requiring review from the inputs.
2. Read the short notes summary located inside `${studentRootPath}/${subject}/${topic}/topic.md`.
3. Generate a highly condensed **3-question flash review**:
   - Q1: Multiple Choice Question (MCQ)
   - Q2: Short Conceptual Question
   - Q3: Core Practical Application Question
4. Write the questions to `${studentRootPath}/${subject}/${topic}/review_quiz.md`.
5. At the absolute bottom of `review_quiz.md`, append a hidden metadata HTML comment block containing the short model answer text for grading validation later.
6. **Stop Execution** with a message instructing the student to fill out their answers inside `${studentRootPath}/${subject}/${topic}/review_answers.md`.

### Mode 4: GRADE_REVIEW (Offline Token-Saving Evaluation)
1. Read **only** the student's entry inside `${studentRootPath}/${subject}/${topic}/review_answers.md` and the hidden HTML comment key string at the bottom of `review_quiz.md`. Do not read any other file.
2. Evaluate responses. To pass the retention gate, the student must achieve **100% accuracy** across all 3 quick questions.
3. Update `${studentRootPath}/memory_schedule.md`:
   - **If Passed (3/3):** Advance the topic to the next interval layer (e.g., Box 1 ➔ Box 2). Calculate the `Next Review Due` date using the *Interval Matrix Map*. Set status to `Safe`.
   - **If Failed (< 3/3):** Demote the topic entirely back to `Box 1`. Reset its `Next Review Due` to `[CURRENT_DATE + 1 DAY]`. Set status to `Needs Remediation`.
4. Delete both `review_quiz.md` and `review_answers.md` dynamically to keep the student workspace clean.

---

## Data Reference Layouts

### Interval Matrix Map
- **Box 1:** Next review in 1 day
- **Box 2:** Next review in 3 days
- **Box 3:** Next review in 7 days
- **Box 4:** Next review in 14 days (Mark as permanently `Fully Retained` if passed here)

### Target: `${studentRootPath}/memory_schedule.md`
```markdown
# Long-Term Memory Retention Tracker
<!-- This file tracks spaced repetition intervals across all subjects for this student. -->

| Subject | Topic | Current Box | Last Reviewed | Next Review Due | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Science | Agriculture | Box 1 | 2026-09-20 | 2026-09-21 | Awaiting Review |
```

### Target: `${studentRootPath}/${subject}/${topic}/review_quiz.md`
```markdown
# Flash Memory Boost: [TOPIC]
Instructions: Open `review_answers.md` in this directory and type your answers matching numbers 1, 2, and 3.

1. [MCQ Question Text] (a, b, c, d)
2. [Conceptual Question Text]
3. [Application Question Text]

<!-- METADATA_KEY_START
1: [Option Letter]
2: [Required short keyword definitions]
3: [Expected logical validation outcome]
METADATA_KEY_END -->
```
