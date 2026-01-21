---
applyTo: "**/*.schema.json"
description: "JSON Schema conventions for Draft-04 compatibility and maintainable schema definitions"
---

# JSON Schema Standards

## Schema Version

### Use Draft-04 for Maximum Compatibility
- Default to Draft-04 unless a newer feature is required
- Document schema version in every file

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "User",
  "description": "A user account in the system",
  "type": "object"
}
```

### When to Use Newer Drafts
- Draft-07: Need `if/then/else`, `const`, or content encoding
- Draft 2019-09: Need `$defs`, `dependentRequired`, or `unevaluatedProperties`
- Draft 2020-12: Need `prefixItems` for tuple validation

## Schema Structure

### Required Metadata
Every schema should include:
- `$schema` - The JSON Schema draft version
- `title` - Human-readable name (PascalCase)
- `description` - Clear explanation of purpose

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "CreateUserRequest",
  "description": "Request payload for creating a new user account",
  "type": "object",
  "properties": { ... }
}
```

### Property Documentation
Document every property with:
- `description` - What the property represents
- `examples` - Valid example values (Draft-06+)
- `default` - Default value if applicable

```json
{
  "properties": {
    "email": {
      "type": "string",
      "format": "email",
      "description": "Primary email address for account communications",
      "examples": ["user@example.com"]
    },
    "role": {
      "type": "string",
      "enum": ["admin", "user", "guest"],
      "description": "User's permission level in the system",
      "default": "user"
    }
  }
}
```

## Definitions and References

### Use `definitions` for Reusable Schemas
- Place shared schemas in `definitions` (Draft-04) or `$defs` (Draft 2019-09+)
- Use descriptive names matching the type name

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "Order",
  "type": "object",
  "definitions": {
    "Address": {
      "type": "object",
      "properties": {
        "street": { "type": "string" },
        "city": { "type": "string" },
        "country": { "type": "string" }
      },
      "required": ["street", "city", "country"]
    },
    "LineItem": {
      "type": "object",
      "properties": {
        "productId": { "type": "string" },
        "quantity": { "type": "integer", "minimum": 1 }
      },
      "required": ["productId", "quantity"]
    }
  },
  "properties": {
    "shippingAddress": { "$ref": "#/definitions/Address" },
    "billingAddress": { "$ref": "#/definitions/Address" },
    "items": {
      "type": "array",
      "items": { "$ref": "#/definitions/LineItem" }
    }
  }
}
```

### Reference Patterns
- Use relative `$ref` for same-file definitions: `"$ref": "#/definitions/Address"`
- Use file paths for external schemas: `"$ref": "./address.schema.json"`
- Avoid deeply nested references (max 2 levels)

## Type Definitions

### String Constraints
```json
{
  "type": "string",
  "minLength": 1,
  "maxLength": 255,
  "pattern": "^[a-zA-Z0-9_-]+$",
  "format": "email"
}
```

Common formats: `email`, `uri`, `date-time`, `date`, `time`, `uuid`, `hostname`, `ipv4`, `ipv6`

### Number Constraints
```json
{
  "type": "number",
  "minimum": 0,
  "maximum": 100,
  "exclusiveMinimum": true,
  "multipleOf": 0.01
}
```

### Array Constraints
```json
{
  "type": "array",
  "items": { "$ref": "#/definitions/Item" },
  "minItems": 1,
  "maxItems": 100,
  "uniqueItems": true
}
```

### Object Constraints
```json
{
  "type": "object",
  "properties": { ... },
  "required": ["id", "name"],
  "additionalProperties": false
}
```

## Validation Patterns

### Required vs Optional Properties
- List all required properties explicitly
- Use `additionalProperties: false` for strict validation

```json
{
  "type": "object",
  "properties": {
    "id": { "type": "string" },
    "name": { "type": "string" },
    "nickname": { "type": "string" }
  },
  "required": ["id", "name"],
  "additionalProperties": false
}
```

### Nullable Fields
In Draft-04, use `type` array:
```json
{
  "deletedAt": {
    "type": ["string", "null"],
    "format": "date-time",
    "description": "Timestamp when the record was soft-deleted, null if active"
  }
}
```

### Enums with Descriptions
```json
{
  "status": {
    "type": "string",
    "enum": ["draft", "published", "archived"],
    "description": "Content lifecycle status: draft (work in progress), published (visible to users), archived (hidden but preserved)"
  }
}
```

## Composition

### allOf (Intersection)
Combine schemas - all must validate:
```json
{
  "allOf": [
    { "$ref": "#/definitions/BaseEntity" },
    { "$ref": "#/definitions/Timestamps" },
    {
      "type": "object",
      "properties": {
        "customField": { "type": "string" }
      }
    }
  ]
}
```

### oneOf (Discriminated Union)
Exactly one schema must validate:
```json
{
  "oneOf": [
    {
      "type": "object",
      "properties": {
        "type": { "enum": ["email"] },
        "address": { "type": "string", "format": "email" }
      },
      "required": ["type", "address"]
    },
    {
      "type": "object",
      "properties": {
        "type": { "enum": ["sms"] },
        "phoneNumber": { "type": "string", "pattern": "^\\+[1-9]\\d{1,14}$" }
      },
      "required": ["type", "phoneNumber"]
    }
  ]
}
```

### anyOf (Union)
At least one schema must validate - use sparingly, prefer `oneOf` for clarity.

## File Organization

### Naming Conventions
- Use kebab-case for file names: `user-profile.schema.json`
- Match title to primary type: `UserProfile`
- Use suffixes for variants: `user-create.schema.json`, `user-update.schema.json`

### Directory Structure
```
schemas/
├── common/
│   ├── address.schema.json
│   ├── pagination.schema.json
│   └── error.schema.json
├── users/
│   ├── user.schema.json
│   ├── user-create.schema.json
│   └── user-update.schema.json
└── orders/
    ├── order.schema.json
    └── line-item.schema.json
```
