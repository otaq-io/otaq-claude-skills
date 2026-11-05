# otaq-claude-skills

A Claude Code plugin marketplace with two plugins.

| Plugin             | Skills                                                             | Enable it                                   |
| ------------------ | ------------------------------------------------------------------ | ------------------------------------------- |
| `tuq`           | `tuq:product-spec`, `tuq:step-back`, `tuq:tech-spec`, `tuq:milestone-plan` | any repo, any stack (user or project scope) |
| `browser-validate` | `validate-in-browser` (+ the `browser-watch` MCP server)           | front-end repos only (project scope)        |

Each plugin puts its helper commands on the Bash tool's PATH while it is enabled (`tuq`, `tuq-plan`; `vib-browser`,
`vib-paths`), so no skill names a file path. That keeps a skill working when Otaq copies only its `SKILL.md` into a
ticket's worktree.

Project-specific facts never live here. A repo that validates in the browser commits its own thin skill and project
file (for example ski-web's `.claude/skills/ski-validate-in-browser/`), which hands off to
`browser-validate:validate-in-browser`.

## Install

```sh
claude plugin marketplace add https://github.com/otaq-io/otaq-claude-skills.git       # or a local checkout: claude plugin marketplace add ./otaq-claude-skills
claude plugin install tuq@otaq-claude-skills --scope user
claude plugin install browser-validate@otaq-claude-skills --scope project   # inside a front-end repo
```

A repo can offer the marketplace to its team from its committed `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "otaq-claude-skills": {
      "source": { "source": "github", "repo": "otaq-io/otaq-claude-skills" },
      "autoUpdate": true
    }
  },
  "enabledPlugins": {
    "tuq@otaq-claude-skills": true,
    "browser-validate@otaq-claude-skills": true
  }
}
```

After trusting the folder, each teammate still installs once: `claude plugin install <plugin>@otaq-claude-skills
--scope project`.

## Developing

Add the marketplace from your local checkout (`claude plugin marketplace add <path>`): plugins load in place, so an
edit takes effect at the next session or after `/reload-plugins`. The plugins carry no `version`, so every commit is a
new version for git installs.

`browser-validate` needs macOS Google Chrome and `playwright-cli`; `tuq-plan pull` needs `python3` and `otaq`.
