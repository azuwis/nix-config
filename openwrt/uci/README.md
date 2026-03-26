## uci-import.js

A ucode script that imports UCI configuration from JSON via stdin. It calls `uci.save()` only (no `uci.commit()`), so changes can be reviewed with `uci changes` before committing.

### JSON Format

```json
{
  "config_name": {
    "section_name": {
      ".type": "section_type",
      "option": "value",
      "list_option": ["val1", "val2"]
    }
  }
}
```

### Operations

- **`.type`**: `"type_name"` — set/create section with given type
- **`.type`**: `"-"` — delete section entirely (for `@type[N]` references, only deletes anonymous sections)
- **`"option": "value"`** — set option (only writes if value changed, to keep `uci changes` clean)
- **`"option": ["a", "b"]`** — set list (converts `option` to `list` if needed; only writes if changed)
- **`"option": "-"`** — delete option
- **`"option+": ["a", "b"]`** — append items to list (skips duplicates)
- **`"option-": ["a", "b"]`** — remove items from list
