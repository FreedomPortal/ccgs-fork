---
paths:
  - "src/tools/**"
---

# Internal Tools / Pipeline Code Rules

- Tools must be **idempotent** — running the same tool twice on the same input produces the same output
- No tool may write to `src/` or `assets/` without an explicit `--output` flag or user confirmation
- Tools must handle missing input files gracefully (clear error message, non-zero exit code)
- Pipeline tools must log what they read and write — silent success is fine, silent failure is not
- No hardcoded absolute paths — use project-relative paths or config-driven roots
- Tools that modify asset files must create a backup or be reversible
- Every tool needs a `--dry-run` flag if it writes or deletes files
- Tool CLIs must print usage on `--help`
- Do not import gameplay or engine modules — tools are standalone; shared logic goes in `src/core/`

## Examples

**Correct** (idempotent, reversible, dry-run):

```python
def export_sprites(input_dir: Path, output_dir: Path, dry_run: bool = False) -> None:
    for src in input_dir.glob("*.png"):
        dest = output_dir / src.name
        if dry_run:
            print(f"[dry-run] would copy {src} → {dest}")
        else:
            shutil.copy2(src, dest)
            print(f"copied {src} → {dest}")
```

**Incorrect** (hardcoded path, no dry-run, silent on error):

```python
def export_sprites():
    for f in os.listdir("C:/project/assets/raw"):  # VIOLATION: absolute path
        shutil.copy(f, "C:/project/assets/out")    # VIOLATION: no dry-run, no logging
```
