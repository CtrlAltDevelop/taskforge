# TaskForge brand

Decision record for phase 44. Tokens in code are the source of truth
(`app/lib/core/ui/tokens/`); this page says why they are what they are.

## Idea
**Calm, dense when you want it, one accent.** Jira is blue and cluttered, ClickUp is purple
and busy. TaskForge is deep *ink* neutrals with one warm *ember* accent, soft borders instead
of shadows, small precise type.

## Mark
An anvil with a spark: work is shaped here. Source: [`brand/taskforge-mark.svg`](brand/taskforge-mark.svg);
all platform icons are drawn from it by `app/tool/make_brand_icons.py`
(Android, iOS, macOS, Windows, Linux, web/PWA incl. maskable, favicon, splash screens, social card). It is two flat shapes,
so it holds at 16 px.

- **Clear space:** at least the height of the spark's top point on every side.
- **Smallest size:** 16 px (favicon), the tile without margin.
- **Wordmark:** "TaskForge", one word, capital T and F, set in Inter SemiBold ([`brand/taskforge-wordmark.png`](brand/taskforge-wordmark.png)). Never "Taskforge" or "Task Forge".
- **Splash:** the bare mark centred on ink `#161618` (iOS launch image and storyboard, Android `launch_background`).
- **Social card:** `app/web/social-card.png` (1200×630), referenced by `og:image` and `twitter:card` in `web/index.html`.
- **Misuse:** no other colours, no gradient, no outline, no stretching or rotation, no spark without the anvil, do not place the tile on ember.

## Colour
Light/dark/high-contrast palettes are in `tokens/colors.dart`; every text/background pair is
asserted ≥ 4.5:1 (UI parts ≥ 3:1) in `test/core/ui/tokens/colors_test.dart`.

| Role | Light | Dark |
|------|-------|------|
| Canvas / surface | `#F7F7F5` / `#FFFFFF` | `#0E0E0F` / `#161618` |
| Text / muted | `#171716` / `#55554F` | `#F4F4F6` / `#B4B4BC` |
| Accent (ember) | `#C2410C` | `#FB923C` |
| Success · Warning · Danger · Info | `#15803D` · `#92400E` · `#B91C1C` · `#1D4ED8` | `#4ADE80` · `#FBBF24` · `#F87171` · `#60A5FA` |

Ten categorical colours (projects, labels, chart series) follow the same file. Status
categories are to do (neutral), in progress (info), done (success), and always carry a
shape and a label; colour is never the only signal.

## Type
Inter (SIL OFL, bundled, no download) with Vazirmatn for Arabic script. Scale 11/12/13/14/16/20/28;
tabular figures for ids, counts and times; a mono face for task keys (`TF-123`).

## Shape and motion
4-pt spacing; radii 4/6/8/12; 1 px hairlines; only two shadows (popover, modal). Dark mode
shows height by lighter surfaces and borders, not shadow.

## Using it
Screens read `context.tf` (colours, density, type), use `Tf*` components and `TfIcons`.
The debug-only gallery at `/debug/gallery` shows every component in every look.
