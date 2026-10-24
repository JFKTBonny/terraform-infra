# 16. Built-in functions

```hcl
locals {
  config = {
    name = "web"
  }

  a = upper("hello")                        # "HELLO"
  b = lower("HELLO")                        # "hello"
  c = replace("a-b-c", "-", "_")            # "a_b_c"
  d = join(",", ["a", "b", "c"])            # "a,b,c"
  e = split(",", "a,b,c")                   # ["a", "b", "c"]
  f = length(["a", "b", "c"])               # 3
  g = merge({ a = 1 }, { b = 2 })           # { a = 1, b = 2 }
  h = lookup(local.config, "size", "small") # "small" (key missing → default)
  i = concat(["a"], ["b", "c"])             # ["a", "b", "c"]
  j = cidrsubnet("10.0.0.0/16", 8, 1)       # "10.0.1.0/24"
  k = coalesce("", "fallback")              # "fallback"
  l = try(local.config.size, "none")        # "none"
  m = jsonencode({ key = "value" })         # "{\"key\":\"value\"}"
  n = format("%s-%03d", "web", 7)           # "web-007"
  o = flatten([["a"], ["b", "c"]])          # ["a", "b", "c"]
  p = distinct(["a", "a", "b"])             # ["a", "b"]
  q = contains(["a", "b"], "a")             # true
  r = keys({ a = 1, b = 2 })                # ["a", "b"]
  s = timestamp()                           # current UTC time (changes every run)
}
```

**Files and templates:**

```hcl
locals {
  script = file("${path.module}/scripts/setup.sh")

  rendered = templatefile("${path.module}/templates/init.sh.tftpl", {
    name = "web"
    port = 8080
  })
}
```

**templates/init.sh.tftpl**

```bash
#!/bin/bash
echo "Starting ${name} on port ${port}"
```

**Try functions interactively:**

```bash
terraform console
```

```
> cidrsubnet("10.0.0.0/16", 8, 2)
> upper("test")
> exit
```

---

← [Import and refactoring](15-import-and-refactoring.md) · [Index](README.md) · [Testing](17-testing.md) →
