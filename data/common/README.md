# Reference Textbook Repository (RAG Grounding)

Place your NCERT reference textbooks (PDF format) in this folder hierarchy. The AI agents (`teach-me` and `quiz-me`) automatically search these folders in priority order.

---

## 📂 Folder Layout & Placement Options

### Option 1: Chapter-Specific PDF (Recommended for best fidelity)
Place the PDF inside the specific topic/chapter folder:
```text
data/common/<class>/<subject>/<topic>/reference.pdf
```
* **Example:**
  `data/common/9/geography/atmosphere and climate/reference.pdf`
  *(Alternatively: `atmosphere and climate.pdf`)*

---

### Option 2: Full Subject Textbook PDF (Fallback)
If you have the complete subject textbook in one PDF:
```text
data/common/<class>/<subject>/textbook.pdf
```
* **Example:**
  `data/common/9/science/textbook.pdf`
  `data/common/9/mathematics/textbook.pdf`
  `data/common/10/science/textbook.pdf`

---

## 🔍 How the Agents Use These Files

1. **Chapter PDF First:** When a session starts for `<topic>`, the agent checks if `data/common/<class>/<subject>/<topic>/reference.pdf` exists.
2. **Subject PDF Second:** If no chapter PDF is found, it falls back to `data/common/<class>/<subject>/textbook.pdf`.
3. **Internal Knowledge Fallback:** If neither is present, it uses its built-in CBSE NCERT knowledge base.
