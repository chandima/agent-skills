---
name: sst
description: SST infrastructure patterns for AWS deployments including Functions, Buckets, Databases, Queues, and Pulumi integration. Use when building serverless infrastructure with SST.
---

# SST Infrastructure

SST (Serverless Stack) patterns for AWS infrastructure as code with type-safe resource linking.

## Core Philosophy

- All infrastructure lives in `sst.config.ts`
- Never configure AWS manually
- Use SST components, fall back to Pulumi AWS when needed
- Type-safe resource access via `Resource` import

## Project Structure

### Drop-in Mode (Single Config)

```typescript
// sst.config.ts
export default $config({
  app(input) {
    return {
      name: "my-app",
      removal: input?.stage === "production" ? "retain" : "remove",
      home: "aws",
    };
  },
  async run() {
    const bucket = new sst.aws.Bucket("Uploads");
    new sst.aws.Astro("Web", {
      link: [bucket],
    });
  },
});
```

### Monorepo (Split Config)

```typescript
// sst.config.ts
export default $config({
  app(input) { /* ... */ },
  async run() {
    await import("./infra/storage");
    await import("./infra/database");
    await import("./infra/web");
  },
});

// infra/storage.ts
export const bucket = new sst.aws.Bucket("Uploads");

// infra/web.ts
import { bucket } from "./storage";
new sst.aws.Astro("Web", {
  link: [bucket],
});
```

## Local Development

Use `concurrently` to run SST and Astro dev in parallel:

```json
{
  "scripts": {
    "dev": "concurrently \"sst dev\" \"astro dev\"",
    "build": "astro build",
    "remove": "sst remove --stage dev"
  },
  "devDependencies": {
    "concurrently": "^9.2.1"
  }
}
```

## Component Selection

| Need | Component | When |
|------|-----------|------|
| Web app | `sst.aws.Astro` | Default for Astro sites |
| API routes | `sst.aws.Function` | Short tasks (<15s) |
| File storage | `sst.aws.Bucket` | Uploads, assets |
| Relational data | `sst.aws.Postgres` | Default database |
| Key-value | `sst.aws.Dynamo` | High-scale, simple queries |
| Background jobs | `sst.aws.Queue` | Async processing |
| Event fan-out | `sst.aws.Bus` | Multiple subscribers |
| Scheduled tasks | `sst.aws.Cron` | Periodic jobs |
| Live updates | `sst.aws.Realtime` | WebSockets |

## Resource Linking

```typescript
// Define resources
const bucket = new sst.aws.Bucket("Uploads");
const database = new sst.aws.Postgres("Database", { vpc });

// Link to Astro
new sst.aws.Astro("Web", {
  link: [bucket, database],
});
```

```typescript
// Access in code
import { Resource } from "sst";

// Type-safe access
const bucketName = Resource.Uploads.name;
const dbHost = Resource.Database.host;
```

## Secrets Management

```bash
# Set secret per stage
sst secret set StripeKey sk_live_xxx --stage production
sst secret set StripeKey sk_test_xxx --stage dev
```

```typescript
// Reference in config
const stripe = new sst.Secret("StripeKey");

new sst.aws.Function("Webhook", {
  handler: "src/webhook.handler",
  link: [stripe],
});

// Access in code
import { Resource } from "sst";
const client = new Stripe(Resource.StripeKey.value);
```

## Stage-Aware Configuration

```typescript
export default $config({
  app(input) {
    return {
      name: "my-app",
      removal: input?.stage === "production" ? "retain" : "remove",
      home: "aws",
    };
  },
  async run() {
    const isProd = $app.stage === "production";
    
    const database = new sst.aws.Postgres("Database", {
      vpc,
      scaling: {
        min: isProd ? "2 ACU" : "0.5 ACU",
        max: isProd ? "16 ACU" : "2 ACU",
      },
    });
  },
});
```

## Pulumi Integration

Use `transform` to customize underlying resources:

```typescript
const bucket = new sst.aws.Bucket("Uploads", {
  transform: {
    bucket: (args) => {
      args.forceDestroy = $app.stage !== "production";
      args.tags = { CostCenter: "engineering" };
    },
  },
});
```

Use raw Pulumi when SST lacks a component:

```typescript
import * as aws from "@pulumi/aws";

const logGroup = new aws.cloudwatch.LogGroup("AppLogs", {
  retentionInDays: 30,
});
```

## Anti-Patterns

```typescript
// Bad: Hardcoded credentials
new S3Client({ credentials: { ... } });

// Good: SST handles credentials
const client = new S3Client({});

// Bad: Hardcoded resource names
const bucketName = "my-app-uploads-bucket";

// Good: Use Resource
import { Resource } from "sst";
const bucketName = Resource.Uploads.name;

// Bad: Environment variables for resources
environment: { BUCKET_NAME: bucket.name }

// Good: Linking
link: [bucket]
```

## Deployment

```bash
sst dev                      # Local development
sst deploy --stage dev       # Deploy to stage
sst deploy --stage production
sst remove --stage pr-123    # Cleanup PR environment
```

## References

See `.apm/instructions/sst.instructions.md` for complete patterns including:
- Async processing (Queues, Event Bus)
- Realtime/WebSocket setup
- Database configuration
- Cron job patterns
