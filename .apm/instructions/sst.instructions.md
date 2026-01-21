---
applyTo: "**/sst.config.ts"
description: "SST infrastructure patterns for AWS deployments with Astro, Functions, and Pulumi integration"
---

# SST Standards

## File Structure

### Single Config (Drop-in Mode)

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
    // All infrastructure defined here
    const bucket = new sst.aws.Bucket("Uploads");
    new sst.aws.Astro("Web", {
      link: [bucket],
    });
  },
});
```

### Split Config (Monorepo)

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
    await import("./infra/storage");
    await import("./infra/database");
    await import("./infra/api");
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

## Local Development with Concurrently

SST + Astro projects should use `concurrently` to run both processes in parallel:

```json
// package.json
{
  "scripts": {
    "dev": "concurrently \"sst dev\" \"&& npm run dev\"",
    "remove": "sst remove --stage dev",
    "build": "astro build",
    "preview": "astro preview",
    "astro": "astro",
    "sst": "sst"
  },
  "devDependencies": {
    "concurrently": "^9.2.1"
  }
}
```

This runs SST (for infrastructure/live Lambda dev) and Astro dev server simultaneously.

## Core Components

### Astro Sites

```typescript
// Basic Astro deployment
new sst.aws.Astro("Web");

// With custom domain
new sst.aws.Astro("Web", {
  domain: "myapp.com",
});

// With subdomain and path
new sst.aws.Astro("Web", {
  domain: {
    name: "app.myapp.com",
    redirects: ["www.myapp.com"],
  },
});

// With linked resources
new sst.aws.Astro("Web", {
  link: [bucket, database, queue],
  environment: {
    PUBLIC_API_URL: api.url,
  },
});

// With custom build (monorepo)
new sst.aws.Astro("Web", {
  path: "packages/web",
  buildCommand: "pnpm build",
});
```

### Functions

```typescript
// Basic function
new sst.aws.Function("MyFunction", {
  handler: "packages/functions/src/handler.main",
});

// With configuration
new sst.aws.Function("MyFunction", {
  handler: "packages/functions/src/handler.main",
  runtime: "nodejs20.x",
  timeout: "30 seconds",
  memory: "512 MB",
  link: [bucket, database],
  environment: {
    LOG_LEVEL: "debug",
  },
});

// With VPC access (for RDS, ElastiCache)
new sst.aws.Function("MyFunction", {
  handler: "packages/functions/src/handler.main",
  vpc,
  link: [database],
});

// With URL (public HTTP endpoint)
const fn = new sst.aws.Function("MyFunction", {
  handler: "packages/functions/src/handler.main",
  url: true,
});
// Access via fn.url
```

### Buckets

```typescript
// Basic bucket
const bucket = new sst.aws.Bucket("Uploads");

// With public access
const publicBucket = new sst.aws.Bucket("Assets", {
  public: true,
});

// With CORS for direct uploads
const uploadBucket = new sst.aws.Bucket("Uploads", {
  cors: {
    allowOrigins: ["https://myapp.com"],
    allowMethods: ["GET", "PUT", "POST"],
    allowHeaders: ["*"],
  },
});

// With notifications
const bucket = new sst.aws.Bucket("Uploads");
bucket.notify("packages/functions/src/bucket/handler.main", {
  events: ["s3:ObjectCreated:*"],
  filterPrefix: "uploads/",
});
```

### Databases

```typescript
// Postgres (recommended default)
const vpc = new sst.aws.Vpc("Vpc");
const database = new sst.aws.Postgres("Database", { vpc });

// With configuration
const database = new sst.aws.Postgres("Database", {
  vpc,
  scaling: {
    min: "0.5 ACU",
    max: "4 ACU",
  },
});

// DynamoDB (for high-scale key-value)
const table = new sst.aws.Dynamo("Table", {
  fields: {
    pk: "string",
    sk: "string",
    gsi1pk: "string",
    gsi1sk: "string",
  },
  primaryIndex: { hashKey: "pk", rangeKey: "sk" },
  globalIndexes: {
    gsi1: { hashKey: "gsi1pk", rangeKey: "gsi1sk" },
  },
});
```

## Async Processing

### Queues

```typescript
// Basic queue
const queue = new sst.aws.Queue("EmailQueue");

// Subscribe a function
queue.subscribe("packages/functions/src/email/send.handler");

// With configuration
queue.subscribe("packages/functions/src/email/send.handler", {
  batch: {
    size: 10,
    window: "20 seconds",
  },
});

// FIFO queue (ordered, exactly-once)
const fifoQueue = new sst.aws.Queue("OrderQueue", {
  fifo: true,
});

// With dead-letter queue
const dlq = new sst.aws.Queue("EmailDLQ");
const queue = new sst.aws.Queue("EmailQueue", {
  dlq: dlq.arn,
});
```

### Sending to Queue

```typescript
// In your function
import { Resource } from "sst";
import { SQSClient, SendMessageCommand } from "@aws-sdk/client-sqs";

const client = new SQSClient({});

await client.send(
  new SendMessageCommand({
    QueueUrl: Resource.EmailQueue.url,
    MessageBody: JSON.stringify({
      to: "user@example.com",
      template: "welcome",
    }),
  }),
);
```

### Event Bus

```typescript
// Create bus
const bus = new sst.aws.Bus("EventBus");

// Subscribe functions to events
bus.subscribe("packages/functions/src/events/order.created.handler", {
  pattern: {
    source: ["myapp.orders"],
    detailType: ["order.created"],
  },
});

bus.subscribe("packages/functions/src/events/order.shipped.handler", {
  pattern: {
    source: ["myapp.orders"],
    detailType: ["order.shipped"],
  },
});
```

### Publishing Events

```typescript
import { Resource } from "sst";
import {
  EventBridgeClient,
  PutEventsCommand,
} from "@aws-sdk/client-eventbridge";

const client = new EventBridgeClient({});

await client.send(
  new PutEventsCommand({
    Entries: [
      {
        EventBusName: Resource.EventBus.name,
        Source: "myapp.orders",
        DetailType: "order.created",
        Detail: JSON.stringify({ orderId: "123", userId: "456" }),
      },
    ],
  }),
);
```

### Cron Jobs

```typescript
// Every minute
new sst.aws.Cron("CleanupJob", {
  job: "packages/functions/src/cron/cleanup.handler",
  schedule: "rate(1 minute)",
});

// Daily at midnight UTC
new sst.aws.Cron("DailyReport", {
  job: "packages/functions/src/cron/report.handler",
  schedule: "cron(0 0 * * ? *)",
});

// With linked resources
new sst.aws.Cron("SyncJob", {
  job: {
    handler: "packages/functions/src/cron/sync.handler",
    link: [database, bucket],
    timeout: "5 minutes",
  },
  schedule: "rate(15 minutes)",
});
```

## Realtime (WebSockets)

### Setup

```typescript
const realtime = new sst.aws.Realtime("Updates", {
  authorizer: "packages/functions/src/realtime/auth.handler",
});

realtime.subscribe("packages/functions/src/realtime/connect.handler", {
  filter: {
    route: ["$connect"],
  },
});

realtime.subscribe("packages/functions/src/realtime/disconnect.handler", {
  filter: {
    route: ["$disconnect"],
  },
});

realtime.subscribe("packages/functions/src/realtime/message.handler", {
  filter: {
    route: ["$default"],
  },
});

// Link to web app
new sst.aws.Astro("Web", {
  link: [realtime],
});
```

### Authorizer

```typescript
// packages/functions/src/realtime/auth.ts
export async function handler(event) {
  const token = event.queryStringParameters?.token;

  // Validate token
  const user = await verifyToken(token);

  return {
    isAuthorized: !!user,
    context: {
      userId: user?.id,
    },
  };
}
```

### Publishing Messages

```typescript
import { Resource } from "sst";
import {
  ApiGatewayManagementApiClient,
  PostToConnectionCommand,
} from "@aws-sdk/client-apigatewaymanagementapi";

const client = new ApiGatewayManagementApiClient({
  endpoint: Resource.Updates.endpoint,
});

await client.send(
  new PostToConnectionCommand({
    ConnectionId: connectionId,
    Data: JSON.stringify({ type: "notification", message: "Hello!" }),
  }),
);
```

## Resource Linking

### Linking Pattern

```typescript
// Define resources
const bucket = new sst.aws.Bucket("Uploads");
const database = new sst.aws.Postgres("Database", { vpc });
const queue = new sst.aws.Queue("JobQueue");

// Link to web app
new sst.aws.Astro("Web", {
  link: [bucket, database, queue],
});

// Link to function
new sst.aws.Function("Processor", {
  handler: "packages/functions/src/process.handler",
  link: [bucket, database],
});
```

### Accessing Linked Resources

```typescript
// In any linked function or Astro API route
import { Resource } from "sst";

// Type-safe access to resource properties
console.log(Resource.Uploads.name); // Bucket name
console.log(Resource.Database.host); // RDS host
console.log(Resource.Database.database); // Database name
console.log(Resource.JobQueue.url); // SQS URL
```

## Pulumi AWS Integration

### Using Pulumi Resources

```typescript
import * as aws from "@pulumi/aws";

// When SST doesn't have a built-in component
const logGroup = new aws.cloudwatch.LogGroup("AppLogs", {
  retentionInDays: 30,
  tags: {
    Environment: $app.stage,
  },
});

// CloudWatch alarm
const alarm = new aws.cloudwatch.MetricAlarm("HighErrors", {
  comparisonOperator: "GreaterThanThreshold",
  evaluationPeriods: 1,
  metricName: "Errors",
  namespace: "AWS/Lambda",
  period: 300,
  statistic: "Sum",
  threshold: 10,
  alarmActions: [snsTopic.arn],
});
```

### Transform Props

Use `transform` to customize underlying Pulumi resources:

```typescript
// Customize the S3 bucket created by sst.aws.Bucket
const bucket = new sst.aws.Bucket("Uploads", {
  transform: {
    bucket: (args) => {
      args.forceDestroy = $app.stage !== "production";
      args.tags = {
        ...args.tags,
        CostCenter: "engineering",
      };
    },
  },
});

// Customize Lambda function
new sst.aws.Function("MyFunction", {
  handler: "src/handler.main",
  transform: {
    function: (args) => {
      args.reservedConcurrentExecutions = 10;
    },
    role: (args) => {
      args.managedPolicyArns = [
        ...(args.managedPolicyArns || []),
        "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
      ];
    },
  },
});
```

## Stages and Deployment

### Stage-Aware Configuration

```typescript
export default $config({
  app(input) {
    return {
      name: "my-app",
      removal: input?.stage === "production" ? "retain" : "remove",
      home: "aws",
      providers: {
        aws: {
          region: "us-east-1",
          profile: input?.stage === "production" ? "prod" : "dev",
        },
      },
    };
  },
  async run() {
    const isProd = $app.stage === "production";

    // Different config per stage
    const database = new sst.aws.Postgres("Database", {
      vpc,
      scaling: {
        min: isProd ? "2 ACU" : "0.5 ACU",
        max: isProd ? "16 ACU" : "2 ACU",
      },
    });

    // Conditional resources
    if (isProd) {
      new sst.aws.Cron("Backup", {
        job: "src/backup.handler",
        schedule: "rate(1 day)",
      });
    }
  },
});
```

### Deployment Commands

```bash
# Local development
sst dev

# Deploy to stage
sst deploy --stage dev
sst deploy --stage staging
sst deploy --stage production

# Remove stage
sst remove --stage pr-123
```

## Secrets Management

### Defining Secrets

```typescript
// Secrets are defined separately, not in sst.config.ts
// Set via CLI: sst secret set StripeKey sk_live_xxx

// Reference in config
const stripe = new sst.Secret("StripeKey");

new sst.aws.Function("Webhook", {
  handler: "src/webhook.handler",
  link: [stripe],
});
```

### Using Secrets

```bash
# Set secret for a stage
sst secret set StripeKey sk_live_xxx --stage production
sst secret set StripeKey sk_test_xxx --stage dev

# List secrets
sst secret list --stage production
```

```typescript
// In function code
import { Resource } from "sst";

const stripeClient = new Stripe(Resource.StripeKey.value);
```

## Anti-Patterns

### Avoid These Patterns

```typescript
// Bad: Hardcoded stage checks
if (process.env.STAGE === "production") { ... }

// Good: Use $app.stage
if ($app.stage === "production") { ... }

// Bad: Manual AWS credentials
new S3Client({
  credentials: {
    accessKeyId: "...",
    secretAccessKey: "...",
  },
});

// Good: SST handles credentials automatically
const client = new S3Client({});

// Bad: Hardcoded resource names
const bucketName = "my-app-uploads-bucket";

// Good: Use Resource
import { Resource } from "sst";
const bucketName = Resource.Uploads.name;

// Bad: Not linking resources
new sst.aws.Function("Handler", {
  handler: "src/handler.main",
  environment: {
    BUCKET_NAME: bucket.name,  // Manual, not type-safe
  },
});

// Good: Proper linking
new sst.aws.Function("Handler", {
  handler: "src/handler.main",
  link: [bucket],  // Type-safe Resource access
});
```

## Common Patterns

### API Routes in Astro + SST

```typescript
// sst.config.ts
const bucket = new sst.aws.Bucket("Uploads");

new sst.aws.Astro("Web", {
  link: [bucket],
});
```

```typescript
// src/pages/api/upload.ts
import type { APIRoute } from "astro";
import { Resource } from "sst";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";

export const POST: APIRoute = async ({ request }) => {
  const formData = await request.formData();
  const file = formData.get("file") as File;

  const client = new S3Client({});
  await client.send(
    new PutObjectCommand({
      Bucket: Resource.Uploads.name,
      Key: file.name,
      Body: Buffer.from(await file.arrayBuffer()),
      ContentType: file.type,
    }),
  );

  return new Response(JSON.stringify({ success: true }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
};
```
