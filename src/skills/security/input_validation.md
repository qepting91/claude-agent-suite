# Input Validation & Output Encoding

## Core Principle

**Never trust user input.** All data from external sources must be validated and sanitized.

## Input Validation Checklist

- [ ] **Type Validation:** Ensure data matches expected type (string, int, email, etc.)
- [ ] **Length Validation:** Enforce minimum and maximum length constraints
- [ ] **Format Validation:** Use regex or schemas to validate format (email, phone, UUID)
- [ ] **Range Validation:** Check numeric values are within acceptable bounds
- [ ] **Whitelist Validation:** For enums/options, validate against allowed values only

## Server-Side Validation

**Always validate on the server** - client-side validation is for UX only, not security.

### Python Example (Pydantic)
```python
from pydantic import BaseModel, EmailStr, constr, Field

class CreateUserRequest(BaseModel):
    email: EmailStr
    username: constr(min_length=3, max_length=30, regex="^[a-zA-Z0-9_]+$")
    age: int = Field(ge=13, le=120)
```

### JavaScript/TypeScript Example (Zod)
```typescript
import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email(),
  username: z.string().min(3).max(30).regex(/^[a-zA-Z0-9_]+$/),
  age: z.number().int().min(13).max(120)
});
```

## SQL Injection Prevention

**Always use parameterized queries** - never concatenate user input into SQL strings.

### Good (Parameterized)
```python
cursor.execute("SELECT * FROM users WHERE email = ?", (email,))
```

### Bad (Vulnerable)
```python
cursor.execute(f"SELECT * FROM users WHERE email = '{email}'")
```

## XSS Prevention (Output Encoding)

**Context-aware encoding** - different contexts require different encoding.

- **HTML Context:** Use HTML entity encoding
- **JavaScript Context:** Use JavaScript encoding
- **URL Context:** Use URL encoding
- **CSS Context:** Avoid user input in CSS if possible

### Framework Protection
Most modern frameworks (React, Vue, Angular) auto-escape by default. Be careful with:
- `dangerouslySetInnerHTML` (React)
- `v-html` (Vue)
- `[innerHTML]` (Angular)

## File Upload Security

- **Validate File Type:** Check MIME type AND file extension
- **Limit File Size:** Enforce maximum upload size
- **Scan for Malware:** Use antivirus scanning for user uploads
- **Store Outside Webroot:** Don't serve uploads directly from upload directory
- **Rename Files:** Use UUID or hash for filenames, not user-provided names
