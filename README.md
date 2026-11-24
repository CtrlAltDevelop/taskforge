# TaskForge

A free, self-hostable alternative to **Jira** and **ClickUp** — no paywalled basics,
fast, offline-capable, and consistent on web, mobile and desktop.

- **Website:** <https://ctrlaltdevelop.github.io/taskforge/>
- **Client:** Flutter (web, mobile, desktop)
- **Backend:** Django Ninja (REST) + gRPC (typed data/streaming) + WebSocket (realtime)

## Start here

1. [docs/00-vision-and-gaps.md](docs/00-vision-and-gaps.md) — what Jira/ClickUp get wrong and how we fix it
2. [docs/01-architecture.md](docs/01-architecture.md) — how the three transports fit together
3. [docs/02-roadmap.md](docs/02-roadmap.md) — ordered list of phases
4. [docs/phases/](docs/phases/) — one document per phase, one feature each

## Screenshots

Captured from the running web app against a seeded demo workspace (`make seed`; demo data only).

| Home | List |
|------|------|
| ![Home](docs/screenshots/home-light.png) | ![List](docs/screenshots/list-light.png) |
| **Board** | **Task** |
| ![Board](docs/screenshots/board-light.png) | ![Task with comment](docs/screenshots/task-modal-light.png) |
| **Dark mode** | **Persian (right to left)** |
| ![Board, dark](docs/screenshots/board-dark.png) | ![Board, Persian](docs/screenshots/board-fa-rtl.png) |

### macOS

The desktop app (`make macos`) on the same demo workspace, over native gRPC.

| Home | List | Board |
|------|------|-------|
| ![Home on macOS](docs/screenshots/macos-home.png) | ![List on macOS](docs/screenshots/macos-list.png) | ![Board on macOS](docs/screenshots/macos-board.png) |

### iOS

The same seeded workspace in the iOS Simulator (iPhone 18 Pro Max), over native gRPC.

| Home | List | Board |
|------|------|-------|
| ![Home on iOS](docs/screenshots/ios-home.png) | ![List on iOS](docs/screenshots/ios-project.png) | ![Board on iOS](docs/screenshots/ios-board.png) |

### iPad

The same seeded workspace on an iPad Pro 13-inch in the Simulator, over native gRPC.

| | | |
|---|---|---|
| ![Home on iPad](docs/screenshots/ipad-home.png) | ![List on iPad](docs/screenshots/ipad-list.png) | ![Board on iPad](docs/screenshots/ipad-board.png) |
| ![Task and chat on iPad](docs/screenshots/ipad-task.png) | ![Calendar on iPad](docs/screenshots/ipad-calendar.png) | ![Timeline on iPad](docs/screenshots/ipad-timeline.png) |
| ![Sprints on iPad](docs/screenshots/ipad-sprints.png) | ![Dashboards on iPad](docs/screenshots/ipad-dashboards.png) | ![Chat on iPad](docs/screenshots/ipad-chat.png) |
| ![Inbox on iPad](docs/screenshots/ipad-inbox.png) | ![My work on iPad](docs/screenshots/ipad-my-work.png) |  |

Status: **planning complete; phase 00 (foundation) implemented.** See [AGENTS.md](AGENTS.md#commands) to run it.

## Licence

[GNU AGPL-3.0](LICENSE). You may use, modify and self-host TaskForge freely; if you run a modified
version as a network service, you must offer its source to your users. See also
[CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md).
