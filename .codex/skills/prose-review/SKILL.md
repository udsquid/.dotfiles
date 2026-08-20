---
name: prose-review
description: Review code against the "code reads like prose" principles — naming, single level of abstraction, comments that explain how instead of why, over- and under-extraction. Use when the user asks to review code for readability or structure, asks to check code against their style rules, or has just finished writing a unit of work and wants it checked before committing.
---

# Prose review

Review code for one question: does each unit read as prose to someone
who does not know this codebase and will not expand any function it
calls?

The checks below are the whole standard. This skill depends on no other
file. Where a project's own style rules — or style instructions already
in the session — conflict with a check, those win.

Report findings. Do not rewrite anything unless the user asks for the
fixes to be applied.

## Scope

Default target: the uncommitted diff (`git diff` and `git diff --cached`).
If the user names a file, branch, or commit range, use that instead.

Review only what the target actually changes. Surrounding code the diff
did not touch is out of scope, however it reads.

## Checks

Run these for every unit the target changes — function, method, class,
Robot Framework keyword. Quote `file:line` and the unit's name for each
finding.

1. **Name against body.** Restate the body in one sentence, in domain
   terms. Needs "and", a list, or two clauses → the unit does too much:
   report SPLIT, and say where the seam is. Sentence does not match the
   name → report RENAME, and propose the name.
2. **Mixed levels.** One body holding both domain intent and mechanism
   (index arithmetic, string building, transport details, error
   plumbing) → report EXTRACT, and name what to pull out.
3. **Comments explaining how.** A comment describing mechanism → report
   EXTRACT, and give the name that replaces the comment. Comments
   explaining why — trade-offs, external constraints, non-obvious
   decisions — are correct. Leave them, and do not report them.
4. **Over-extraction.** A unit called exactly once whose name says no
   more than its body → report INLINE. Idiomatic one-liners are one
   thought, not a mechanism leak: never report a comprehension, a `with`
   block, an `enumerate`/`zip` call, or a dict lookup with a default.
5. **Vocabulary.** A name taken from the data structure or the framework
   where the domain has its own word → report RENAME, and propose the
   domain term.

Callers above callees, where the language's conventions allow: report
once per file, not once per unit.

## Output

Group findings by file. One line each:

`file:line` — SPLIT / RENAME / EXTRACT / INLINE — what is wrong, in one
sentence — the concrete replacement: the new name, or what to pull out.

Then list, by name only, the units you checked and found clean.

If nothing is wrong, say so plainly. Do not manufacture findings to fill
the report.

## Out of bounds

- Anything the linter or formatter already owns: spacing, import order,
  line length, quote style.
- Code outside the target diff.
- Rewriting. Report first; apply only on request.
