# Technical Documentation — ORDS Layer

## Module
- **Module name**: `uat_api_v1`
- **Base path**: `/uat/api/v1/`
- **Schema**: `staging_paas`

## Endpoints

### LOV
| Method | Path | Source Type | Description |
|---|---|---|---|
| GET | `/lov/:type` | QUERY | Returns LOV entries by type |

### Use Cases
| Method | Path | Source Type | Description |
|---|---|---|---|
| GET | `/usecases` | QUERY | List use cases (optional filters: domainStream, enabled) |
| GET | `/usecases/:code` | QUERY | Get single use case by code |

### Issues
| Method | Path | Source Type | Description |
|---|---|---|---|
| GET | `/issues` | PL/SQL | Search issues with filters + paging + sorting (returns JSON with meta) |
| POST | `/issues` | PL/SQL | Create new issue |
| GET | `/issues/:id` | QUERY | Get full issue detail |
| PATCH | `/issues/:id` | PL/SQL | Partial update (non-status fields) |

### Workflow
| Method | Path | Source Type | Description |
|---|---|---|---|
| POST | `/issues/:id/transition` | PL/SQL | Execute workflow action (PROPOSE_SOLUTION, SEND_TO_RETEST, CONFIRM_RESOLUTION, REOPEN_FAIL, CLOSE) |

### Comments
| Method | Path | Source Type | Description |
|---|---|---|---|
| GET | `/issues/:id/comments` | QUERY | List comments for an issue |
| POST | `/issues/:id/comments` | PL/SQL | Add comment |

### Attachments
| Method | Path | Source Type | Description |
|---|---|---|---|
| GET | `/issues/:id/attachments` | QUERY | List attachments for an issue |
| GET | `/attachments/:attId/content` | PL/SQL | Download attachment binary |

### Status History
| Method | Path | Source Type | Description |
|---|---|---|---|
| GET | `/issues/:id/statusHistory` | QUERY | List status change history |

## GET /issues Query Parameters

### Filters (equality / IN-list)
`status`, `severity`, `priority`, `recordType`, `domainStream`, `environment`, `solutionType`, `assignee`, `createdBy`, `retestAssignedTo`, `useCaseCode`

Multi-value supported with comma separator: `status=NEW,TRIAGE`

### Search
`q` — text search on title (min 3 chars, case-insensitive LIKE)

### Date ranges
`createdFrom`, `createdTo`, `updatedFrom`, `updatedTo` (ISO-8601 or YYYY-MM-DD)

### Aging
`ageDaysMin` — minimum age in days

### Pagination
`page` (default 1), `pageSize` (default 20, max 100)

### Sorting
`sort` — format: `field:dir[,field2:dir2]` (default: `createdOn:desc`)

Allowed fields: `createdOn`, `updatedOn`, `severity`, `priority`, `status`, `domainStream`, `environment`, `assignee`

## Response Format

### Success (list)
```json
{
  "data": [...],
  "meta": { "page": 1, "pageSize": 20, "total": 53, "totalPages": 3, "sort": "createdOn:desc" }
}
```

### Success (mutation)
```json
{
  "data": { "issueId": 123, "status": "NEW" }
}
```

### Error
Raises `ORA-20000` with format: `ERROR_CODE: message`

## Authentication
- User identity passed via `userName` query parameter (simplified for UAT)
- Production: OAuth2 / SSO via ORDS security module

## Script
`ords/uat_api_v1_module.sql` — Run after DB scripts to register all ORDS endpoints.
