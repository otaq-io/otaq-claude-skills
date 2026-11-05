---
name: validate-in-browser
description: "Validate an Otaq ticket's front-end change in a real Chrome as a read-only judge - read the ticket (`otaq prime --validate` or `otaq show`), check the change against its description and for leftovers, serve the app with Otaq Run, load the pages the change touches in one shared Chrome (Chrome DevTools MCP `browser-watch` watches the console and network, playwright-cli drives and takes screenshots), log in from a project file, then give a pass/fail verdict with `otaq check pass|fail --stdin` (or `otaq comment` by hand). Usage: /validate-in-browser [KEY] [--role <role>[,<role>]] [--url <path-or-url>]... [--project <project file>]"
argument-hint: "[KEY] [--role <role>[,<role>]] [--url <path-or-url>]... [--project <file>]"
adapted-from: "Otaq 0.1.0, built-in skill `validate` (plugin/skills/validate/SKILL.md)"
---

# Validate an Otaq ticket in the browser

Adapted from Otaq 0.1.0's built-in `validate` skill: its judge rules are kept (steps 1-6 and 12-14 below); its "Run
the app" is replaced by the browser steps (7-11). When Otaq's `validate` skill changes, merge the change here by hand.

You judge one Otaq ticket's change, either as the **validator** of a Validate stage (a fresh session Otaq started in
the ticket's worktree) or **by hand** (a person or another skill called you on a ticket key). This skill knows no
project: everything about a particular project (its apps, how to log in, which pages a file belongs to, its known
noise) comes from the **project file** passed with `--project`.

**You are a read-only judge.** Never edit, create or delete files in the worktree, never commit, and never fix
anything, not even a typo. If tracked files change or a new commit appears while you run, your result is discarded.
Report what you find; the agent does the fixing. Everything you write (check logs, the browser's profile, its
playwright-cli files, screenshots) goes under `$OTAQ_RESOURCE_DIR`, Otaq's folder for this ticket outside the worktree.
Starting the app with `otaq run start` is not a change.

## Arguments

```text
/validate-in-browser [KEY] [--role <role>[,<role>...]] [--url <path-or-url>]... [--project <file>]
```

| Argument           | Meaning                                                                                                                                                                  |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `KEY`              | The Otaq ticket to judge (`SHOP-40`). Left out: `$OTAQ_TICKET`. Neither set: stop and ask the caller for a key.                                                          |
| `--role a,b`       | Account(s) to check the pages with, by the project file's role names; repeatable. Wins over the project file's `Roles`. Without a project file it is ignored (no login). |
| `--url <x>`        | An extra page to check; repeatable. A path (`/cart`) is joined to the app's URL; a full URL (`http://localhost:3000/cart`) is used as it is.                             |
| `--project <file>` | The project file (see "Project file"). Expand a leading `~` to `$HOME`. A file that doesn't exist: stop and say so.                                                      |

Any other option: stop and say which one you don't know, with this usage line. Never guess what it meant.

**Validate session or by hand?** It is a Validate session when Otaq started you to validate `$OTAQ_TICKET` and
`KEY` is that ticket (or left out). Otherwise it is by hand: the verdict goes to `otaq comment <KEY> --stdin`
instead of `otaq check` (see step 14), and you read the ticket with `otaq show <KEY>` and `otaq comments <KEY>`. By
hand, `otaq run` serves the code of the worktree you are in: when that isn't `KEY`'s branch (`git branch
--show-current` against the branch `otaq show <KEY>` names), say so and ask the caller for the URL of an app running
`KEY`'s code, or to run you in `KEY`'s worktree.

## Project file

A Markdown file, owned by the project's own skill, that tells this skill everything project-specific. It has a `# `
title, an optional intro paragraph, and **only these `## ` sections**, each optional:

| Section    | What it holds                                                                                                                                                                                                           |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Apps`     | The Otaq run apps: each app's run name, its URL path (`/`, `/admin/`), the command it is registered with (for reference only: you never register it), and how to tell which app a changed file or a `--url` belongs to. |
| `Browser`  | Flags for `vib-browser start`(`--allow-third-party-cookies`, `--headed`).                                                                                                                                               |
| `Login`    | The login command and its arguments, what it prints, how to switch to another role, and what you must never do around login.                                                                                            |
| `Accounts` | Role -> the names of the environment variables that hold its credentials. Names only, never values.                                                                                                                     |
| `Pages`    | How a changed file maps to pages (route files, aliases, which files change no page), and the project's route list.                                                                                                      |
| `Roles`    | How a page's guard or route maps to the account to check it with, and which pages are checked logged out.                                                                                                               |
| `Noise`    | The path of the noise file: known console and network noise that doesn't fail a ticket (format below).                                                                                                                  |
| `Notes`    | Free text for you: backends the app needs, what an outage of them looks like, ports, feature flags.                                                                                                                     |

**Read it whole before step 7, then check its headings.** A `## ` heading that is not one of these eight (spelled
exactly so) means the file was written for another version of this skill: **refuse it.** Stop, and give no verdict on
the change: in a Validate session, `otaq check fail --stdin` whose first line is `Not validated: project file <path>
has an unknown section "<name>" (allowed: Apps, Browser, Login, Accounts, Pages, Roles, Noise, Notes); not a finding
against the change.`; by hand, tell the caller the same. Never act on a fact that sits outside these sections.

Follow what the sections say for this project; where a section and this skill disagree on a judge rule (read-only,
pass/fail, credentials), this skill wins.

**The noise file** (named by `Noise`): one entry per line, `<console|network> | <regex> | <why it is noise>`. Only
lines starting `console | ` or `network | ` are entries. The regex is extended (`grep -E`), unanchored unless it says
so. A `console` regex is matched against the message text; a `network` regex against `<METHOD> <url> -> <status or
error>` (`GET http://localhost:4300/api/x -> 404`). Check a message with `grep -E -e '<regex>'` on its text, never by
eye.

**Without `--project`** there is no project file: you know no app and no login.

- Take the app URL from a full `--url`, else from a URL the ticket's description or comments name, else from a Run
  already up for this ticket (`otaq run status` prints its URL). Still none: by hand, ask the caller for it and wait;
  in a Validate session, the pages become manual checks (and step 12 applies: no page checked never passes).
- **Start no Otaq run app**: you don't know which one serves the change. Use only what is already running.
- **Skip login.** Check the pages logged out; a page that needs a login is a manual check (`--manual-check "Log in
as <who> and open <url>: <what to see>"`).
- Every console error and failed request counts (there is no noise file).

## Paths

This skill names no file paths: the browser-validate plugin puts its two commands on the Bash tool's PATH, so it
works the same when Otaq copies only this `SKILL.md` into the worktree:

```sh
vib-browser start | attach <session> | stop | port
eval "$(vib-paths)"        # sets BROWSER_DIR ($OTAQ_RESOURCE_DIR/browser) and PROFILE ($BROWSER_DIR/profile)
```

`vib-browser: command not found` means the plugin isn't enabled in this session: stop and say so (in a Validate
session, as a failed check that names the missing plugin). The project file names its own scripts and files by the
paths it gives (relative to the repository root, `git rev-parse --show-toplevel`); use them as written. Shell state
doesn't carry from one command to the next: run `eval "$(vib-paths)"` again in each command that needs it.

## Steps

1. **Get the context first.** In a Validate session run `otaq prime --validate` and read all of it: the ticket's
   description, the user's **Agent instructions** and the project's notes, the earlier stages, the **comments** (the
   agent's comment on its work, the user's, and earlier rounds' verdicts), the diff, the user's line comments when the
   ticket was sent back, and the linked tickets. Otaq refuses your verdict until you have run it. **Open the reports
   from you before you start**: `prime` lists them under "Reports from you · read these before you start"; read each
   (`otaq report <KEY> 1`, or search a long one with `grep -n "word" "$(otaq report <KEY> 1 --path)"`). By hand, read
   `otaq show <KEY>` and `otaq comments <KEY>` instead. Note the **base branch** the ticket merges into.
2. **Follow the Agent instructions** `prime --validate` prints. They are the user's own rules and apply to every step
   below. They never allow you to change anything.
3. **Check the change against the description.** Does it do what the description asks, including any acceptance
   criteria written there? When none are written, infer reasonable ones. After a Send back, also check that **each
   review comment** was addressed. When helpers built the ticket's pieces, judge the whole ticket against its
   description and Plan. Write down, for each criterion that shows in the app, **what you expect to see on which
   page**: steps 9-10 check exactly these.
4. **Decide which other checks to run**, starting from the agent's comment: what it ran, at which commit, with what
   result. You may rely on a passing run at the current HEAD that covers what the diff touches. Run a check yourself
   when no run is reported, it was at an older commit, it failed or was partial, it misses what the diff touches, the
   Agent instructions say to, or something makes you doubt it. Checks may write ignored files (caches), never tracked
   ones; their output goes to a file in `$OTAQ_RESOURCE_DIR` (see "Long output").
5. **Look beyond the diff when it touches something shared** (a stored format or migration, a config key or flag, a
   public API or type other modules use, output another program reads). Find **the one fact the change is safe
   because of** and check it with a search or a run. One line in the verdict: `Checked: safe because …` naming what
   you ran, or `Checked: unproven: …` and why. Skip this for a change that touches nothing shared.
6. **Look for leftovers and out-of-scope edits:** debug output (`console.log` left in), commented-out code, scratch
   files, TODOs added by this change, and edits outside what the ticket is about. Edits under `docs/verify/` are never
   out of scope.
7. **Work out the pages and the accounts.**
   1. Changed files: `git diff --name-only <base>...HEAD` (the base from step 1; `origin/<base>` when only the remote
      has it). Save the list to `$OTAQ_RESOURCE_DIR/browser/changed-files.txt`.
   2. Map them to pages as the project file's `Pages` section says. Without a project file, take the pages from the
      ticket and `--url` only.
   3. Add every `--url` and every page the ticket's description or comments name.
   4. For each page, its app (from `Apps`) and its account: `--role` when given (each page with each named role),
      else the account `Roles` gives for the page's guard; a page `Roles` says to check logged out gets no login.
   5. **No page found:** don't make one up. Say so in the verdict with a `--manual-check` naming what to open; the
      ticket never passes on no pages checked (step 12).
8. **Serve the apps the pages need** (with a project file; without one, see "Project file").
   - `otaq run status` first. An app already running for this ticket is used as it is; if it was started before the
     change's last commit (compare its start with `git log -1 --format=%ci`), or you can't tell, run
     `otaq run restart <app> --wait --timeout 900` (it stays whoever started it).
   - Otherwise `otaq run start <app> --wait --timeout 900` (a cold build is slow), and **note that you started it**.
     Take the URL it prints; the app's URL path from `Apps` is joined to it.
   - **Never run `otaq run set`** here: a Validate session saves no settings. An app with no run command, a start that
     fails or times out: its pages become `--manual-check` lines (`otaq run log <app> --tail 50 >
"$OTAQ_RESOURCE_DIR/run-<app>.txt"` and name the file).
9. **Start the browser and attach the watcher and the driver**, in this order:
   1. `vib-browser start <flags from the Browser section>`: one headless Chrome for this ticket, its profile in
      `$BROWSER_DIR`.
   2. **Before any navigation**, call `mcp__plugin_browser-validate_browser-watch__list_pages`. The watcher connects on its first call and
      collects nothing logged before it; it should list one `about:blank` page.
   3. `vib-browser attach <KEY>`: attaches the playwright-cli session named after the ticket. From now on drive
      with that session, always from `$BROWSER_DIR` (playwright-cli writes `.playwright-cli/` into its working
      directory, which must never be the worktree), and call the binary directly, never through an unquoted variable:

      ```sh
      eval "$(vib-paths)" && cd "$BROWSER_DIR" && playwright-cli -s=<KEY> goto "<url>"
      ```

   **Watch only with `mcp__plugin_browser-validate_browser-watch__*` tools.** Never use the Chrome DevTools plugin's tools
   (`mcp__plugin_chrome-devtools-mcp_chrome-devtools__*`) or any other browser tool: they act on a different,
   private browser and would report a clean console for pages they never loaded. Drive only with playwright-cli.

   **`browser-watch` is missing** (no `mcp__plugin_browser-validate_browser-watch__list_pages` tool, even after a tool search, or it fails to
   connect after `vib-browser start`): watch with playwright-cli instead, on the same session: after each step
   `playwright-cli -s=<KEY> console warning` (errors and warnings) and `playwright-cli -s=<KEY> requests` (add `--all`
   for messages since before a redirect). Before matching a request against the noise file, rewrite
   playwright-cli's `12. [GET] <url> => [410]` into the noise format `GET <url> -> 410` (`=> [FAILED] net::…` becomes
   `-> FAILED`): `sed -E 's/^ *[0-9]+\. \[([A-Z]+)\] (.*) => \[([^]]+)\].*$/\1 \2 -> \3/'`. Say in the verdict: `Watched with playwright-cli (browser-watch not
available).`

10. **Log in and check each page**, one account at a time (one browser holds one session):
    1. **Log in** with the `Login` section's command, for the page's app and account, with the base URL from step 8.
       It prints a success line or why it failed. Never type a credential, never print, `echo` or write an `Accounts`
       variable or its value, never screenshot or snapshot a filled login form, and never open the login request's
       body (`get_network_request` on it). A login that fails (the backend down, a locked account, unset variables)
       makes that account's pages manual checks (`could not log in as <role>: <what the command printed>`), never a
       fail of the ticket. To change account, do what `Login` says about switching role. Pages checked logged out
       come before any login.
    2. **For each page**: `playwright-cli -s=<KEY> goto "<url>"`, wait until it settles (`playwright-cli snapshot` shows
       the content, not a spinner). Then `mcp__plugin_browser-validate_browser-watch__list_pages` and take the `pageId` of the page now
       showing this URL: `list_console_messages` and `list_network_requests` need it.
    3. **Drive what the ticket asks** (step 3's expectations): click, fill, select with playwright-cli, using the refs
       from `playwright-cli snapshot`; find text with `playwright-cli find "<text>"`. Note whether you **saw** each
       expected behaviour.
    4. **Screenshot each step you checked**:
       `playwright-cli -s=<KEY> screenshot --filename=shots/NN-<page>-<step>.png` (from `$BROWSER_DIR`, so it lands in
       `$OTAQ_RESOURCE_DIR/browser/shots/`). `NN` counts from `01` across the run; `<page>` and `<step>` are short
       slugs (`03-cart-apply-discount.png`). Take screenshots with playwright-cli, not the watcher (it may write only
       to a temp folder).
    5. **Read what the watcher saw**, after each step and before the next `goto` (its lists start again at each
       navigation; pass `includePreservedMessages` / `includePreservedRequests` when the page redirected):
       `mcp__plugin_browser-validate_browser-watch__list_console_messages` with `pageId` and `types: ["error", "warn", "assert"]`, and
       `mcp__plugin_browser-validate_browser-watch__list_network_requests` with `pageId`. Keep the errors, warnings and every request with a
       4xx/5xx status or a network failure, with page, account and step, in `$OTAQ_RESOURCE_DIR/browser/watch.txt`.
    6. **Match each error and failed request against the noise file**: a match is not a finding (count it, don't list
       it). Everything else is a finding for step 12. An error that looks unrelated to the diff still counts: say so
       and propose a noise line for the user to add (you never edit the noise file).
    7. A page that lands somewhere else (a sign-in page, a no-access page, an error page): follow what `Roles` and
       `Notes` say (another account to try, what a backend outage looks like). An outage of a backend the app needs is
       a manual check, never a fail.
11. **Stop what you started**: `vib-browser stop` (always, even after an error), and `otaq run stop <app>` for
    each app **you** started in step 8. Never stop a Run the user or the agent started.
12. **Decide pass or fail.** The ticket **fails** on:
    - an asked-for behaviour (step 3) you didn't see on its page, with the page, account and step;
    - a console **error** on a checked page that no `console` noise line matches;
    - a request with status 4xx or 5xx, or a network failure, on a checked page that no `network` noise line matches;
    - a finding from steps 3-6 (a gap against the description, a failing check, a leftover, a proven breakage).

    It does **not** fail on: warnings (list them); noise-file matches; pages you couldn't reach for a reason outside
    the change (no run command, a build timeout, a backend down, a failed login, a feature flag off): those are
    `--manual-check` lines. **No page checked never passes**: when not one page was checked in the browser, give
    `otaq check fail` whose first line is `Not validated in the browser: <why>; not a finding against the change.`,
    with a `--manual-check` for each page.

    **Prove each finding before it fails the ticket.** A finding against the description needs the file and line, or
    the page, step and screenshot that show it. A suspected breakage needs a run (a page step, a command), named with
    its log. If you tried and it didn't show, or only a new test could show it, it is a **note**, never a failure:
    `Note: Suspected, not proven: … (tried: …)`. A gap covered by a linked ticket, or not asked for by this ticket, is
    a note too (`Note: … covered by SHOP-41`, `Note: Not covered by any ticket: …`).

13. **Write the verdict**, at most 2,000 characters, in this shape (one line each; logs stay in their files):

    ```text
    Fail: /cart (staff), step "apply discount": console error "TypeError: x is undefined" (main.js:1234).
    /cart (staff): GET /api/v1/cart?page=1 -> 500.
    Pass: /checkout (staff) shows the discount line the ticket asks for.
    Warnings (not failing): /cart: "NG0913: image is larger than rendered".
    Checked: safe because … / Note: …
    Watch log: $OTAQ_RESOURCE_DIR/browser/watch.txt; noise matched: 2 (not listed).
    Screenshots: $OTAQ_RESOURCE_DIR/browser/shots/ (01-checkout-staff.png ... 04-cart-apply-discount.png)
    ```

    Start with `Fail:` or `Pass:` and the most important line; then one line per finding (page, account, step, the
    console message or request, or file and line for a code finding); then what passed; then warnings; then `Checked:`
    and `Note:` lines; then the logs and the screenshots folder. Add `Watched with playwright-cli (browser-watch not
available).` when step 9 fell back.

14. **Give the verdict**, then end your turn:
    - **Validate session**: `otaq check pass --stdin` or `otaq check fail --stdin` with the verdict on stdin, and one
      `--manual-check "<exact steps and what to see>"` per page or check you couldn't do (each verdict replaces the
      earlier unticked ones, so list again the ones that still apply):

      ```sh
      otaq check fail --stdin --manual-check "Log in as admin, open /settings: the new toggle shows" <<'VERDICT'
      Fail: /cart (staff), step "apply discount": console error "TypeError: x is undefined" (main.js:1234).
      ...
      VERDICT
      ```

    - **By hand**: the same text to `otaq comment <KEY> --stdin`, with the manual checks as `Manual check: …` lines at
      the end (`otaq comment` takes no `--manual-check`), and a short summary to the caller.

## Long output

```sh
npm test > "$OTAQ_RESOURCE_DIR/unit-tests.log" 2>&1
grep -n "FAIL" "$OTAQ_RESOURCE_DIR/unit-tests.log"
```

- **Send each check's output to a file in `$OTAQ_RESOURCE_DIR`**, never in the worktree: a new file there is a change
  to the agent's work. The browser's files stay in `$BROWSER_DIR` (`$OTAQ_RESOURCE_DIR/browser`).
- **Search it** with `grep` or `tail`; **never print it in full or retype it.**
- **Name it** in your verdict; never attach command output. **Attach only a document you wrote** with
  `--report-file` (at most 20 MB).
- **Reading an earlier report:** `otaq report <KEY> <N>`, or search it:
  `grep -n "expected" "$(otaq report <KEY> <N> --path)"`.

## Rules

- **Change nothing:** don't edit, create or delete files in the worktree, don't commit, don't push, and don't run
  commands that change tracked files or settings (no installs, no migrations, no formatting fixes, no `otaq run set`,
  no edits to the project file or its noise file). Writing into `$OTAQ_RESOURCE_DIR` is the one exception. Before
  the verdict, `git status --porcelain` must print nothing new.
- **Credentials stay in the environment**: read only by the project's login command, by variable name. They never
  appear in a command you type, a log, a screenshot, a snapshot or the verdict.
- Watch with `mcp__plugin_browser-validate_browser-watch__*` only; drive with playwright-cli only, from `$BROWSER_DIR`, session `<KEY>`.
- Stop the browser (`vib-browser stop`) and the Runs you started before the verdict.
- Don't file tickets and don't run `otaq stage next`: the user creates tickets from your notes.
- **Long text always goes through stdin** (`--stdin`), never quoted arguments.
- Always finish a Validate session with `otaq check pass --stdin` or `otaq check fail --stdin`; ending your turn
  without a verdict leaves the ticket waiting for the user.
