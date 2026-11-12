"""Real-shaped samples of each tool's export, small enough to read."""

import csv
import io
import json


def _csv(header: list[str], *rows: dict[str, str]) -> str:
    out = io.StringIO()
    writer = csv.writer(out, lineterminator="\n")
    writer.writerow(header)
    for row in rows:
        cells = []
        taken: dict[str, int] = {}
        for name in header:
            nth = taken.get(name, 0)
            taken[name] = nth + 1
            cells.append(row.get(name if nth == 0 else f"{name}#{nth}", ""))
        writer.writerow(cells)
    return out.getvalue()


JIRA_HEADER = [
    "Summary", "Issue key", "Issue id", "Issue Type", "Status", "Priority", "Assignee",
    "Reporter", "Created", "Updated", "Due date", "Labels", "Labels", "Description", "Sprint",
    "Sprint", "Parent id", "Custom field (Story point estimate)", "Original estimate",
    "Comment", "Comment", "Outward issue link (Blocks)", "Inward issue link (Blocks)",
    "Outward issue link (Relates)", "Attachment",
]  # fmt: skip

# An epic, a story under it, a sub-task under the story, and a task with a dangling parent/link.
JIRA_CSV = _csv(
    JIRA_HEADER,
    {
        "Summary": "Checkout epic",
        "Issue key": "WEB-1",
        "Issue id": "10001",
        "Issue Type": "Epic",
        "Status": "To Do",
        "Priority": "High",
        "Assignee": "alice@acme.test",
        "Reporter": "bob@old.test",
        "Created": "12/Nov/24 10:30 AM",
        "Updated": "13/Nov/24 9:00 AM",
        "Due date": "30/Nov/24",
        "Labels": "payments",
        "Description": "h2. Goal\n* take cards",
        "Outward issue link (Blocks)": "WEB-2",
    },
    {
        "Summary": "Card form",
        "Issue key": "WEB-2",
        "Issue id": "10002",
        "Issue Type": "Story",
        "Status": "In Progress",
        "Priority": "Medium",
        "Assignee": "bob@old.test",
        "Reporter": "alice@acme.test",
        "Created": "14/Nov/24 11:00 AM",
        "Updated": "15/Nov/24 11:00 AM",
        "Labels": "payments",
        "Labels#1": "ui",
        "Description": "A *bold* story with [a link|https://x.test]",
        "Sprint": "Sprint 1",
        "Sprint#1": "Sprint 2",
        "Parent id": "10001",
        "Custom field (Story point estimate)": "5",
        "Original estimate": "7200",
        "Comment": "15/Nov/24 12:00 PM;acc-77;First comment",
        "Comment#1": "16/Nov/24 1:00 PM;acc-78;Second comment",
        "Attachment": "15/Nov/24;alice;spec.pdf;https://files.test/spec.pdf",
    },
    {
        "Summary": "Validate the card",
        "Issue key": "WEB-3",
        "Issue id": "10003",
        "Issue Type": "Sub-task",
        "Status": "Done",
        "Priority": "Low",
        "Assignee": "alice@acme.test",
        "Reporter": "alice@acme.test",
        "Created": "16/Nov/24 9:00 AM",
        "Updated": "16/Nov/24 9:30 AM",
        "Parent id": "10002",
    },
    {
        "Summary": "Dangling",
        "Issue key": "WEB-4",
        "Issue id": "10004",
        "Issue Type": "Task",
        "Status": "Closed",
        "Priority": "Lowest",
        "Created": "17/Nov/24 9:00 AM",
        "Parent id": "10999",
        "Outward issue link (Blocks)": "WEB-99",
    },
)

JIRA_JSON = json.dumps(
    {
        "expand": "names",
        "issues": [
            {
                "id": "20001",
                "key": "API-1",
                "fields": {
                    "summary": "Design the API",
                    "description": {
                        "type": "doc",
                        "content": [
                            {
                                "type": "paragraph",
                                "content": [
                                    {"type": "text", "text": "Use "},
                                    {"type": "text", "text": "REST", "marks": [{"type": "strong"}]},
                                ],
                            }
                        ],
                    },
                    "status": {"name": "In Review"},
                    "priority": {"name": "Highest"},
                    "assignee": {"displayName": "Alice A", "emailAddress": "alice@acme.test"},
                    "reporter": {"displayName": "Carol", "emailAddress": "carol@old.test"},
                    "created": "2024-11-12T10:30:00.000+0000",
                    "updated": "2024-11-13T10:30:00.000+0000",
                    "duedate": "2024-12-01",
                    "labels": ["backend", "api"],
                    "customfield_10016": 8,
                    "customfield_10020": [
                        {
                            "id": 1,
                            "name": "Sprint 9",
                            "state": "closed",
                            "boardId": 4,
                            "startDate": "2024-11-01T00:00:00.000Z",
                            "endDate": "2024-11-14T00:00:00.000Z",
                        }
                    ],
                    "comment": {
                        "comments": [
                            {
                                "id": "9001",
                                "author": {
                                    "displayName": "Carol",
                                    "emailAddress": "carol@old.test",
                                },
                                "body": "Looks <b>good</b>",
                                "created": "2024-11-13T11:00:00.000+0000",
                            }
                        ]
                    },
                    "issuelinks": [
                        {
                            "type": {
                                "name": "Blocks",
                                "inward": "is blocked by",
                                "outward": "blocks",
                            },
                            "outwardIssue": {"id": "20002", "key": "API-2"},
                        }
                    ],
                    "attachment": [
                        {"filename": "design.png", "size": 1234, "content": "https://j.test/a"}
                    ],
                },
            },
            {
                "id": "20002",
                "key": "API-2",
                "fields": {
                    "summary": "Implement the API",
                    "status": {"name": "To Do"},
                    "parent": {"id": "20001", "key": "API-1"},
                    "created": "2024-11-14T10:30:00.000+0000",
                    "issuelinks": [
                        {
                            "type": {
                                "name": "Blocks",
                                "inward": "is blocked by",
                                "outward": "blocks",
                            },
                            "inwardIssue": {"id": "20001", "key": "API-1"},
                        }
                    ],
                },
            },
            {"id": "20003", "key": "API-3", "fields": {"description": "no summary"}},
        ],
    }
)

CLICKUP_CSV = (
    "Task ID,Task Name,Task Content,Status,Date Created,Due Date,Start Date,Date Updated,"
    "Assignees,Priority,Tags,Parent ID,Time Estimated,Comments\n"
    'abc1,Plan launch,"## Plan\n- one\n- two",open,1731400000000,1732000000000,,1731500000000,'
    '"[Alice A, Dave D]",high,"[launch, q4]",,7200000,"Looks fine"\n'
    "abc2,Write copy,Short text,in progress,1731400100000,,,,[Dave D],urgent,[launch],abc1,,\n"
    "abc3,Ship it,,complete,1731400200000,,,,,low,,abc1,,\n"
)

CLICKUP_JSON = json.dumps(
    {
        "tasks": [
            {
                "id": "t1",
                "name": "Plan launch",
                "markdown_description": "# Plan\n**now**",
                "status": {"status": "open"},
                "priority": {"priority": "high"},
                "assignees": [{"username": "Alice A", "email": "alice@acme.test"}],
                "tags": [{"name": "launch"}],
                "date_created": "1731400000000",
                "due_date": "1732000000000",
                "time_estimate": 3600000,
                "comments": [
                    {
                        "id": "c1",
                        "comment_text": "hello",
                        "user": {"username": "Dave"},
                        "date": "1731401000000",
                    }
                ],
                "dependencies": [{"task_id": "t2", "depends_on": "t1", "type": 0}],
                "attachments": [{"title": "plan.pdf", "size": 10, "url": "https://c.test/p"}],
            },
            {"id": "t2", "name": "Write copy", "status": {"status": "open"}, "parent": "t1"},
        ]
    }
)

GENERIC_CSV = (
    "Name;Details;State;Owner;Due\n"
    "Fix login;It breaks;Open;alice@acme.test;2024-12-01\n"
    "Fix logout;;Done;nobody@x.test;2024-12-02\n"
    ";no title here;Open;;\n"
)
