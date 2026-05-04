# CBSE Class 8 Multi-Agent Learning System

A Markdown-based multi-agent system designed to help CBSE Class 8 students learn topics through an interactive teach-quiz-revise cycle.

## Features

- **4 Markdown-Based Agents**: Main (Orchestrator), Teach-Me, Quiz-Me, and Revision Agent
- **File-Based Communication**: All agents communicate via Markdown (.md) files
- **Adaptive Learning**: Repeats quizzes until 90% mastery is achieved
- **Spaced Repetition**: Revision agent focuses on weak areas
- **CBSE NCERT Level**: Content tailored for Class 8 students
- **LLM-Ready**: Agent instructions in Markdown for easy LLM integration

## Project Structure

```
school-tutor-1/
├── agents/
│   ├── main_agent.md       # Orchestrator instructions
│   ├── teach_agent.md      # Teach-Me Agent instructions
│   ├── quiz_agent.md      # Quiz-Me Agent instructions
│   └── revision_agent.md  # Revision Agent instructions
├── utils/
│   └── file_handler.py    # File I/O operations
├── data/                   # Generated files (topic.md, quiz.md, etc.)
├── main.py                 # Python runner
└── README.md
```

## How It Works

1. **Main Agent** asks for Subject and Topic
2. **Teach-Me Agent** creates `topic.md` with explanations and examples
3. **Quiz-Me Agent** generates `quiz.md` with 10 questions
4. Student answers the quiz
5. **Evaluation** creates `evaluation.md` with score and weak areas
6. If score < 90%, **Revision Agent** creates `revision.md`
7. Process repeats until mastery (90%+) is achieved

## File Communication

| File | Created By | Purpose |
|------|-----------|---------|
| `topic.md` | Teach-Me Agent | Lesson content with explanations |
| `quiz.md` | Quiz-Me Agent | 10 questions (5 MCQ + 3 Short + 2 Application) |
| `evaluation.md` | Main Agent | Score, percentage, weak areas |
| `revision.md` | Revision Agent | Focused revision material |
| `state.md` | Main Agent | Progress tracking |

## Usage

```bash
python main.py
```

Then follow the prompts:
1. Enter Subject (e.g., Mathematics)
2. Enter Topic (e.g., Linear Equations)
3. Study the generated `data/topic.md`
4. Answer questions in `data/quiz.md`
5. Review `data/evaluation.md` and `data/revision.md` if needed

## Agent Instructions (Markdown)

Each agent's behavior is defined in a Markdown file:

- **`agents/main_agent.md`**: Orchestration logic, state management, evaluation rules
- **`agents/teach_agent.md`**: How to break down topics, explain concepts, create examples
- **`agents/quiz_agent.md`**: How to generate MCQs, short answers, application questions
- **`agents/revision_agent.md`**: How to create flashcards, retry questions, focus on weak areas

## LLM Integration

To integrate with an LLM:

1. Read the appropriate `.md` file from `agents/` folder
2. Extract the instructions
3. Call LLM with the instructions + input
4. Parse LLM response and write to output file

Example:
```python
# Pseudo-code for LLM integration
teach_instructions = read_file("agents/teach_agent.md")
prompt = f"{teach_instructions}\n\nInput:\nSubject: {subject}\nTopic: {topic}"
response = llm_call(prompt)
write_file("data/topic.md", response)
```

## Technical Details

- **Language**: Python 3.x (minimal - only for orchestration)
- **Agent Definitions**: Markdown (ready for LLM)
- **No external dependencies** (uses only Python standard library)
- **File-based state management** (no database required)

## Future Enhancements

- [ ] Integrate actual LLM (GPT, Claude, etc.)
- [ ] Parse actual student answers from quiz.md
- [ ] Implement proper spaced repetition algorithm
- [ ] Add support for multiple topics per session
- [ ] Add more question types and difficulty levels

## License

Educational use - CBSE NCERT aligned content.
