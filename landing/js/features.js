// Every TaskForge feature, one entry per roadmap phase (docs/phases/).
// Wording follows each phase doc's "Feature" paragraph.

export const GROUPS = [
  { id: 'work', label: 'Work items' },
  { id: 'views', label: 'Views' },
  { id: 'collab', label: 'Collaboration' },
  { id: 'plan', label: 'Planning & tracking' },
  { id: 'auto', label: 'Speed & automation' },
  { id: 'trust', label: 'Teams & security' },
  { id: 'reach', label: 'Reach & integrations' },
  { id: 'product', label: 'Product & design' },
];

export const FEATURES = [
  // Work items
  { g: 'work', p: '05', t: 'Projects', d: 'Projects with a short key like WEB, a description and per-project switches for optional features.' },
  { g: 'work', p: '06', t: 'Tasks', d: 'Title, description, assignee, priority, due date and status, listed fast over paginated gRPC.' },
  { g: 'work', p: '07', t: 'Custom workflows', d: 'Statuses in categories with optional transition rules, edited in a visual workflow editor.' },
  { g: 'work', p: '08', t: 'Subtasks', d: 'Nest subtasks to any depth with progress roll-up and tree-aware moves.' },
  { g: 'work', p: '09', t: 'Dependencies', d: 'Blocks, blocked by, relates to, duplicates, with cycle protection and a blocked indicator.' },
  { g: 'work', p: '10', t: 'Custom fields', d: 'Text, number, select, multi-select, date, checkbox, URL, user and money fields on any project.' },
  { g: 'work', p: '28', t: 'Recurring tasks', d: 'Tasks that repeat daily, weekly, monthly, on a custom schedule or after completion.' },
  { g: 'work', p: '33', t: 'Intake forms', d: 'Shareable forms that create tasks, usable by clients and people outside the workspace.' },
  { g: 'work', p: '35', t: 'Templates', d: 'Save a task, a subtask tree or a whole project and start new ones from it.' },

  // Views
  { g: 'views', p: '11', t: 'List view', d: 'A virtualized table with sortable, resizable columns, grouping and show/hide.' },
  { g: 'views', p: '12', t: 'Board view', d: 'Kanban columns by status or any field, drag and drop, WIP limits, lazy columns.' },
  { g: 'views', p: '13', t: 'Calendar', d: 'Month, week and day by start and due date, with drag to reschedule.' },
  { g: 'views', p: '13b', t: 'Workspace calendar', d: 'One calendar across every project you can open, coloured by project.' },
  { g: 'views', p: '15', t: 'Timeline (Gantt)', d: 'Bars on a time axis with dependency arrows, drag to reschedule, critical path.' },
  { g: 'views', p: '14', t: 'Filters and TFQL', d: 'A visual filter builder that compiles to a readable query language, saved and shareable in every view.' },

  // Collaboration
  { g: 'collab', p: '16', t: 'Realtime sync', d: 'Every open view updates live over WebSocket, with presence: who is viewing this task.' },
  { g: 'collab', p: '17', t: 'Comments and mentions', d: 'Threaded rich-text comments, @mentions, reactions and edit history.' },
  { g: 'collab', p: '42', t: 'Task chat', d: 'Each task’s comment stream also shows a message for every change made to it.' },
  { g: 'collab', p: '43', t: 'Chat spaces', d: 'Channels per workspace and project, private groups and direct messages with @ alerts.' },
  { g: 'collab', p: '18', t: 'Attachments', d: 'Files and images on tasks and comments with progress, preview and secure download.' },
  { g: 'collab', p: '23', t: 'Docs (wiki)', d: 'Nested pages, a block editor, links to tasks and page history.' },
  { g: 'collab', p: '19', t: 'Notifications', d: 'In-app inbox, push and email with per-event preferences, quiet hours and digests.' },
  { g: 'collab', p: '20', t: 'Global search', d: 'One box for tasks, comments, projects, people and docs, respecting permissions.' },

  // Planning
  { g: 'plan', p: '21', t: 'Time tracking', d: 'Start/stop timer, manual entries, estimates and timesheets.' },
  { g: 'plan', p: '22', t: 'Sprints', d: 'Backlog, planning, start and complete, carry-over and a burndown chart.' },
  { g: 'plan', p: '34', t: 'Goals (OKRs)', d: 'Goals with key results that update from tasks or by hand.' },
  { g: 'plan', p: '36', t: 'Workload', d: 'Work per person per day or week against capacity, with drag to rebalance.' },
  { g: 'plan', p: '26', t: 'Dashboards', d: 'Widgets (charts, counters, lists) driven by saved filters.' },

  // Speed
  { g: 'auto', p: '24', t: 'Automations', d: 'When this happens, if that matches, do these actions. Unlimited runs, run history, dry-run.' },
  { g: 'auto', p: '25', t: 'Command palette', d: 'Cmd/Ctrl+K to run any action or jump anywhere, plus customizable shortcuts.' },

  // Trust
  { g: 'trust', p: '01', t: 'Authentication', d: 'Sign up, sign in and refresh that behave the same on REST, gRPC and WebSocket.' },
  { g: 'trust', p: '02', t: 'Workspaces', d: 'Create several, switch between them; everything belongs to exactly one.' },
  { g: 'trust', p: '03', t: 'Members and invites', d: 'Invite by email or link, manage the member list.' },
  { g: 'trust', p: '04', t: 'Roles and permissions', d: 'A permission matrix and a “why can’t I do this?” explainer.' },
  { g: 'trust', p: '37', t: '2FA and SSO', d: 'TOTP with recovery codes, single sign-on through OIDC and optional SAML.' },
  { g: 'trust', p: '39', t: 'DPoP token binding', d: 'Every request carries a proof, so a stolen token is useless without the device key.' },
  { g: 'trust', p: '40', t: 'Named sessions', d: 'Each session gets a readable device name; see, rename and revoke them.' },
  { g: 'trust', p: '27', t: 'Audit log', d: 'An immutable record of who did what and when, plus per-task history.' },

  // Reach
  { g: 'reach', p: '00', t: 'One app, three transports', d: 'REST, gRPC and WebSocket from one codebase, started locally with one command.' },
  { g: 'reach', p: '29', t: 'Import and export', d: 'Bring projects from Jira, ClickUp and CSV; export everything as JSON and CSV.' },
  { g: 'reach', p: '41', t: 'ClickUp import', d: 'Pull spaces, lists, tasks and comments with an API token, no export file.' },
  { g: 'reach', p: '30', t: 'Offline mode', d: 'Browse cached data and edit offline; changes queue and sync when you reconnect.' },
  { g: 'reach', p: '31', t: 'Languages and RTL', d: 'Persian/Dari, Pashto and Arabic with right-to-left layout and local dates and numbers.' },
  { g: 'reach', p: '32', t: 'API tokens and webhooks', d: 'A public REST API with personal and service tokens, plus outgoing webhooks.' },
  { g: 'reach', p: '38', t: 'Self-host in one command', d: 'Docker compose deploy and automated release builds for web, Android, iOS and desktop.' },

  // Product
  { g: 'product', p: '44', t: 'Design system', d: 'One brand, palette, type scale and Tf* component library under every screen.' },
  { g: 'product', p: '45', t: 'App shell', d: 'Workspace sidebar, breadcrumbs, quick actions, and a bottom bar on phones.' },
  { g: 'product', p: '46', t: 'Work views, rebuilt', d: 'List, board, calendar and timeline on the design system.' },
  { g: 'product', p: '47', t: 'Task detail', d: 'A wide task modal with the description, fields and chat side by side.' },
  { g: 'product', p: '48', t: 'Home and onboarding', d: 'A day summary, a two-minute first-run flow and designed empty states.' },
  { g: 'product', p: '49', t: 'Motion and accessibility', d: 'Reduced-motion support, accessibility passes and a visual-regression gate.' },
];

// Steps of the scroll story. `layout` names a 3D arrangement in scene.js.
export const STORY = [
  {
    layout: 'list',
    kicker: 'List',
    title: 'Dense when you want it',
    text: 'A virtualized table that stays smooth at thousands of rows. Sort, resize and group columns, add a task with one line and press Enter.',
    points: ['Custom fields as columns', 'Saved filters in TFQL', 'Subtasks nested to any depth'],
  },
  {
    layout: 'board',
    kicker: 'Board',
    title: 'Kanban that survives workflow changes',
    text: 'Columns are statuses or any field. Dragging sends one move request with a stable rank, so two people can reorder at once.',
    points: ['WIP limits and swimlanes', 'Columns load lazily', 'Blocked cards show a lock'],
  },
  {
    layout: 'calendar',
    kicker: 'Calendar',
    title: 'Time, laid out',
    text: 'Month, week and day by start and due date, or one workspace calendar across every project, coloured by project.',
    points: ['Drag to reschedule', 'Colour and hide-done toggles', 'Right-to-left layout and local dates'],
  },
  {
    layout: 'timeline',
    kicker: 'Timeline',
    title: 'A Gantt chart without the ceremony',
    text: 'Tasks become bars with dependency arrows. Move a bar and what it blocks follows; the critical path is highlighted.',
    points: ['Typed dependencies, cycle-safe', 'Drag a bar to move it, an end to resize', 'Zoom from days to quarters'],
  },
  {
    layout: 'chart',
    kicker: 'Dashboards',
    title: 'Numbers from the same tasks',
    text: 'Widgets driven by saved filters: counters, bars, pies, workload per person and goals with key results.',
    points: ['Time tracking and timesheets', 'Workload against capacity', 'Pin a dashboard to Home'],
  },
  {
    layout: 'sphere',
    kicker: 'Live and everywhere',
    title: 'Always current, even offline',
    text: 'Changes arrive over WebSocket as they happen. Lose your connection and edits queue locally, then sync in order when you are back.',
    points: ['Presence on every task', 'Idempotent offline outbox', 'iOS, Android, macOS, Windows, Linux, web'],
  },
];

export const GAPS = [
  ['Paywalls on automations, time tracking, dashboards, audit', 'All free, self-hosted, no seat limits'],
  ['Slow UI on big projects', 'Paginated streaming, local cache, optimistic updates'],
  ['Weak or missing offline mode', 'Local-first cache with queued changes that sync on reconnect'],
  ['Too many clicks, maze-like admin', 'Command palette and keyboard shortcuts everywhere'],
  ['Notification overload', 'Per-event channels, quiet hours and digests'],
  ['Poor right-to-left support', 'Persian, Arabic and Pashto from the start'],
  ['Lock-in and painful export', 'Import from Jira, ClickUp and CSV; full export'],
];
