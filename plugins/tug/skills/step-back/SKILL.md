---
name: step-back
description: >-
  Step back from a feature's product decisions: sketch what the feature would look like with no decisions at all,
  explain where the current decisions have led it, and name the ones adding the most complication. Writes nothing.
  When the user says the feature is getting more complicated than it should be, or is unsure about the set of
  decisions, offer it and wait for a yes; run it when the user agrees or types /tug:step-back.
argument-hint: "[feature]"
---

# Step back: the feature without its decisions

Each product decision narrows the next one, so an agent keeps recommending what fits the earlier choices and a feature
drifts where its first decisions pushed it. This skill sets the decisions aside, asks **"if we had no decisions at
all, what would this feature look like?"**, and shows the user where the decisions have taken it and which of them
cost the most, so they can steer it where it should go.

**It writes nothing**: no files, no decision changes, no commits, no `tug` command but reading (`rules`). Any change the
user wants goes back to `tug:product-spec` as a normal new decision, through its conflict check.

Run `tug rules` and read "Layout" and "Statuses" before reading `tug/` (`tug` is on PATH from the tug
plugin).

## Steps

1. **Only with a yes.** If the user hasn't typed `/tug:step-back`, asked for a step back, or said yes to your offer of
   one, don't step back: ask "Want me to take a step back and look at this feature without its decisions?" and end
   your turn.
2. **Find the feature**: the skill's argument, or the one under discussion. If it is unclear, ask which, as one
   question, and end your turn.
3. **Read the decisions.** At the repository root (`git rev-parse --show-toplevel`), read `tug/README.md`'s index,
   then every `Accepted` or `Partly superseded` decision about the feature (skip `Superseded` ones). Also read any
   decision written earlier in this conversation that isn't in the index yet. **No decisions about it?** Say there
   is nothing to step back from yet and stop.
4. **The clean slate**, in your reply only: the problem, for whom, and the simplest version that solves it, as if
   none of the decisions existed. A few lines, in plain words; no options and no implementation.
5. **Compare.** Say, in plain words, where the decisions have taken the feature against the clean slate, then name the
   **1-3 decisions that add the most complication**, each with its cost in one line ("Decision 004 needs a renumber
   step on every clash"). Say so plainly when the decisions hold up and the complication is in the problem itself.
6. **Hand back.** Name the decisions worth revisiting and offer to continue in `tug:product-spec`:
   - **Plain chat** (no `$OTAQ_TICKET`): one AskUserQuestion with an option per decision worth revisiting
     (`Revisit 004`, `Revisit 006`, each with its cost as the description) and `Keep them all`.
   - **Otaq stage** (`$OTAQ_TICKET` set): the same options with `otaq ask human --stdin` (`--option` / `--note` per
     option, the question text on stdin), then end your turn, so the ticket shows "Asks you".

   A "Revisit" answer continues as `tug:product-spec`'s next open point, so any change is a new decision through its
   conflict check and the old one is marked superseded. `Keep them all` continues `tug:product-spec` where it was.

## Rules

- Offer, don't start: without the user's yes, step 1 only asks.
- Read only. Never edit, create, rename or commit anything.
- Product only: no libraries, APIs or code in the clean slate or the comparison.
