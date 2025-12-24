# Publishing Guide

This guide outlines the steps for publishing a new version of phlex to Hex.

## Prerequisites

1. **Hex account**: You must have a Hex account and be added as a maintainer
2. **GitHub CLI**: For creating GitHub releases (optional but recommended)
3. **Clean git state**: All changes must be committed

## Pre-Release Checklist

Before publishing, ensure:

- [ ] All tests pass (`mix test`)
- [ ] Code is formatted (`mix format`)
- [ ] Credo passes (`mix credo --strict`)
- [ ] Dialyzer passes (`mix dialyzer`)
- [ ] CHANGELOG.md is updated
- [ ] Version is bumped in `mix.exs`
- [ ] All changes are committed to git

## Publishing Steps

### Option 1: Using the Release Script (Recommended)

The release script automates the entire process:

```bash
./usr/bin/release.exs
```

This script will:
1. Run all quality checks
2. Build the package
3. Prompt for confirmation
4. Publish to Hex
5. Create git tag
6. Create GitHub release

### Option 2: Manual Process

If you prefer to do it manually:

```bash
# 1. Run quality checks
mix quality

# 2. Update version in mix.exs
# Edit mix.exs and update the version number

# 3. Update CHANGELOG.md
# Add a new entry for the version

# 4. Commit changes
git add mix.exs CHANGELOG.md
git commit -m "Bump version to X.Y.Z"

# 5. Build package
mix hex.build

# 6. Review the generated .tar file
# Check that it contains what you expect

# 7. Publish to Hex
mix hex.publish

# 8. Create git tag
git tag vX.Y.Z
git push --tags

# 9. Create GitHub release (optional)
gh release create vX.Y.Z --generate-notes
```

## Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** version when you make incompatible API changes
- **MINOR** version when you add functionality in a backwards compatible manner
- **PATCH** version when you make backwards compatible bug fixes

## Post-Release

After publishing:

1. Verify the package on [hex.pm](https://hex.pm/packages/phlex)
2. Check that documentation is generated correctly
3. Update any example applications if needed
4. Announce the release (if significant)

## Troubleshooting

### "Package already exists"

This means the version you're trying to publish already exists. Bump the version number in `mix.exs`.

### "Unauthorized"

You need to authenticate with Hex:

```bash
mix hex.auth
```

### "Git working directory not clean"

Commit or stash all changes before releasing.

### Dialyzer warnings

Dialyzer warnings don't block publishing but should be addressed. Review warnings and fix them in the next release.

## Next Steps After Publishing

1. Update the progress tracking document
2. Update the todo list
3. Create a summary of changes for the team
4. Monitor for any issues reported by users

