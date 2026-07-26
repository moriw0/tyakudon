# Triage Labels

The skills speak in terms of five canonical triage roles. This file maps those roles to the actual label strings used in this repo's issue tracker.

| Label in mattpocock/skills | Label in our tracker | Meaning                                  |
| -------------------------- | -------------------- | ---------------------------------------- |
| `needs-triage`             | `needs-triage`       | Maintainer needs to evaluate this issue  |
| `needs-info`               | `needs-info`         | Waiting on reporter for more information |
| `ready-for-agent`          | `ready-for-agent`    | Fully specified, ready for an AFK agent  |
| `ready-for-human`          | `ready-for-human`    | Requires human implementation            |
| `wontfix`                  | `wontfix`            | Will not be actioned                     |

When a skill mentions a role (e.g. "apply the AFK-ready triage label"), use the corresponding label string from this table.

Edit the right-hand column to match whatever vocabulary you actually use.

## Label existence

All five labels exist in this repo. `gh label list` shows what's currently defined.

## How the loop uses them

`ready-for-agent` means "an AFK agent can complete this ticket on its own" — it is the queue the autonomous loop reads (see `loop.md`). It belongs on implementation tickets only, never on tracking or spec issues.

The loop moves a ticket to `ready-for-human` when it gives up on it, and files anything it finds outside a ticket's scope as a new issue labelled `needs-triage`. It never applies `needs-info` or `wontfix` — those are yours.
