# Publication boundary

This repository is the PUBLIC website repository. It must contain only material approved for worldwide publication.

## PRIVATE → REVIEW → PUBLIC

1. **PRIVATE** — Source archives, application source, working notes, personal data, third-party data, credentials, signing material, and unpublished CrownWords material belong in a private repository or another access-controlled store.
2. **REVIEW** — Proposed website changes are made on a branch and reviewed through a pull request. Automated checks build an explicit public artifact and block private file types or credential-like values.
3. **PUBLIC** — Only reviewed changes merged to `main` may deploy. The Pages workflow publishes the explicit `_site` artifact; it never uploads the repository root.

## Never publish here

- Archives such as ZIP files
- Swift or application source unless separately approved for open-source release
- Environment files, access tokens, passwords, private keys, certificates, provisioning profiles, or signing material
- Personal records, contact lists, legal/financial documents, or third-party data
- Internal tasks, covenant/stewardship notes, drafts, or unpublished content

## Review checklist

- Confirm every changed file is intended for unrestricted public access.
- Confirm images and text contain no personal or third-party data without permission.
- Confirm the public-boundary workflow passes.
- Review the rendered website before merging.
- Merge only after human approval.

Removing a file from the current branch does not erase it from Git history. If a credential or regulated personal data is discovered, revoke/rotate it first and perform a separately reviewed history-remediation process.
