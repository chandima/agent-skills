---
name: patterns
description: System design and architecture patterns. Covers layered architecture, clean architecture, microservices vs monolith decisions, event-driven patterns, and trade-off analysis frameworks.
---

# Architecture Patterns

System design patterns and frameworks for building scalable, maintainable software.

## Core Principles

1. **Simplicity First** - Simplest solution that meets requirements. Avoid speculative generality.
2. **Separation of Concerns** - Single, well-defined responsibility per component.
3. **Design for Failure** - Graceful degradation, error handling, observability.
4. **Make It Testable** - DI, clear interfaces, pure functions.
5. **Evolve, Don't Revolution** - Incremental over big-bang. Strangler pattern.

## Trade-off Analysis Framework

| Factor | Questions |
|--------|-----------|
| **Complexity** | How much does this add? Is it justified? |
| **Scalability** | Will this work at 10x, 100x scale? |
| **Maintainability** | Can new developers understand this? |
| **Performance** | What are latency/throughput characteristics? |
| **Cost** | Infrastructure and development costs? |
| **Risk** | What could go wrong? How to mitigate? |
| **Time** | Implementation time? Opportunity cost? |

## Layered Architecture

```
┌─────────────────────────────────┐
│         Presentation            │  ← UI, API endpoints
├─────────────────────────────────┤
│         Application             │  ← Use cases, orchestration
├─────────────────────────────────┤
│           Domain                │  ← Business logic, entities
├─────────────────────────────────┤
│        Infrastructure           │  ← Database, external services
└─────────────────────────────────┘
```

**Key Rule**: Dependencies flow downward. Lower layers don't know about upper layers.

## Clean Architecture

```
              ┌─────────────────┐
              │    Entities     │  ← Enterprise business rules
              ├─────────────────┤
              │   Use Cases     │  ← Application business rules
              ├─────────────────┤
              │   Adapters      │  ← Controllers, gateways
              ├─────────────────┤
              │  Frameworks     │  ← DB, web, external
              └─────────────────┘
              
Dependencies point INWARD →
```

**Principles**:
- Domain at center, no external dependencies
- Use cases orchestrate domain logic
- Adapters connect to external world
- Dependency inversion via interfaces

## Microservices vs Monolith

| Monolith | Microservices |
|----------|---------------|
| Simple deployment | Independent scaling |
| Easy debugging | Technology diversity |
| Shared database | Service isolation |
| Team coordination | Team autonomy |
| Lower latency (in-process) | Network overhead |
| **Start here** | **Evolve to this** |

### Decision Guide

**Stay Monolith When**:
- Team < 10 developers
- Domain not well understood
- Scaling needs are uniform
- Debugging/tracing complexity matters

**Consider Microservices When**:
- Independent scaling requirements
- Different tech stacks needed
- Team autonomy is priority
- Domain boundaries are clear

## Event-Driven Architecture

### When to Use
- Loose coupling between services
- Eventual consistency acceptable
- Need audit trail / event sourcing
- Complex workflows across services

### Patterns

| Pattern | Use Case |
|---------|----------|
| **Event Notification** | "Something happened" - fire and forget |
| **Event-Carried State** | Include data, reduce queries |
| **Event Sourcing** | Audit trail, replay capability |
| **CQRS** | Separate read/write models |

## API Design Patterns

### REST Resource Design
```
GET    /users           # List
POST   /users           # Create
GET    /users/:id       # Read
PUT    /users/:id       # Replace
PATCH  /users/:id       # Partial update
DELETE /users/:id       # Delete
```

### Versioning Strategies
| Strategy | Example | Pros/Cons |
|----------|---------|-----------|
| URL path | `/v1/users` | Clear, easy routing |
| Header | `Accept: application/vnd.api+json;v=1` | Cleaner URLs, harder discovery |
| Query param | `?version=1` | Simple, but ugly |

## Caching Patterns

| Pattern | Description | Use Case |
|---------|-------------|----------|
| **Cache-Aside** | App manages cache explicitly | General purpose |
| **Read-Through** | Cache handles miss automatically | Simplified app logic |
| **Write-Through** | Write to cache and DB synchronously | Consistency critical |
| **Write-Behind** | Write to cache, async to DB | High write throughput |

### Cache Levels
1. **Browser/Client** - HTTP caching headers
2. **CDN/Edge** - Static assets, public API
3. **Application** - Redis, Memcached
4. **Database** - Query cache, materialized views

## Database Patterns

### Choosing a Database
| Type | Best For | Examples |
|------|----------|----------|
| Relational | Transactions, complex queries | PostgreSQL, MySQL |
| Document | Flexible schema, JSON | MongoDB, CouchDB |
| Key-Value | Caching, sessions | Redis, DynamoDB |
| Graph | Relationships | Neo4j, Neptune |
| Time-Series | Metrics, logs | InfluxDB, TimescaleDB |

### Scaling Patterns
- **Read Replicas** - Scale reads, async replication
- **Sharding** - Horizontal partitioning by key
- **CQRS** - Separate read/write stores

## Analysis Framework

### Evaluating Existing Architecture
1. **Current State** - Structure, pain points, tech debt
2. **Requirements** - Functional + non-functional (scalability, latency)
3. **Gap Analysis** - Where current falls short
4. **Recommendations** - Prioritized, with trade-offs

### Designing New Systems
1. **Understand Problem** - Users, use cases, success metrics
2. **Define Constraints** - Technical, business, team
3. **Explore Options** - Multiple approaches, trade-offs
4. **Document Decision** - ADR, diagrams, guidelines

## Architecture Decision Record (ADR)

```markdown
# ADR-001: [Title]

## Status
[Proposed | Accepted | Deprecated | Superseded]

## Context
[What problem are we solving? What constraints?]

## Decision
[What we decided to do]

## Consequences
[What are the results? Positive and negative]
```

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Big Ball of Mud | No structure | Introduce boundaries gradually |
| Golden Hammer | One solution for everything | Right tool for the job |
| Premature Optimization | Complexity without need | Measure first, optimize second |
| Distributed Monolith | Microservices without benefits | Define clear boundaries |
| Anemic Domain Model | Logic in services, not entities | Rich domain objects |
