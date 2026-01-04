# PROMPT INICIAL PARA CLAUDE CODE

## CRITICAL WORKFLOW REQUIREMENTS

**YOU MUST FOLLOW THESE RULES. THEY ARE NON-NEGOTIABLE.**

1. **NEVER claim something works without running a test to prove it.** After writing any code, immediately write and run a test. If you cannot test it, say so explicitly.

2. **Work modularly.** Complete one module at a time. After each module, report what you built, show test results, and wait for confirmation before proceeding.

3. **Iterate and fix errors yourself.** Do not rely on the user to report errors back to you. Run the code, observe the output, and fix problems before presenting results.

4. **Be explicit about unknowns.** If you're uncertain about something, say so. Don't guess.

5. **Use R properly.** Always test that R packages are installed before using them. Use `here::here()` for all file paths. Test that data files exist before trying to read them.

6. **Read the skill files FIRST.** Before creating any documents (docx, xlsx, pptx, pdf), ALWAYS read the relevant SKILL.md file in /mnt/skills/public/ to learn best practices.

---

## PROJECT INSTRUCTIONS

Read `CLAUDE.md` in this directory. It contains detailed guidance for reorganizing and refactoring R code for an academic paper on difference-in-differences analysis of CSO monitoring effects on public works in Brazil.

**Your task**: Follow the instructions phase by phase, starting with Phase 0 (Project Setup).

**Critical rule**: At each checkpoint marked with 🛑, you must:
1. Summarize what you have completed
2. Present key outputs for review
3. List any issues or concerns
4. **STOP and wait for my explicit approval before proceeding to the next phase**

Do not skip checkpoints. Do not proceed past a 🛑 without my approval.

**Context**:
- Original messy code is in: `~/Documents/DCP/Papers/Obra Transparente/obra_transparente`
- You will copy it to `original/` and then rewrite everything from scratch
- The goal is professional, reproducible R code ready for paper submission
- All work happens in R (not Python)

**Begin now with Phase 0, Task 0.1: Create Project Structure.**
