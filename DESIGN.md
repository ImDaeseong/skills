# skills Design

Updated: 2026-09-27

## Purpose

Maintain a public collection of reusable skills with consistent routing, core laws, attribution, packaging, and deterministic validation.

## Stakeholders, concerns, and scenarios

- Skill user: discover the right skill and understand its inputs, outputs, and safety boundary.
- Skill author: change one package without breaking routing or shared contracts.
- Reviewer/redistributor: verify attribution, dependencies, and absence of private data.
- Representative scenario: route a request, load one skill and its declared resources, perform the task, validate the package, and review output or licensing where automation is insufficient.

## Boundaries

- Skills contain reusable instructions and licensed supporting resources, not private workspace data or credentials.
- Runtime dependencies and external tools are declared and pinned where applicable.
- Structural validation does not establish the quality of every model-generated artifact.

## Main components

- Skill directories with `SKILL.md`, optional references, scripts, and agent metadata.
- `_shared/CORE-LAWS.md`: common behavioral rules.
- `ROUTING.md`, `USAGE.md`, and marketplace metadata: discovery and invocation.
- `scripts/validate_workspace.ps1` and related negative tests: packaging and contract guards.

## Key decisions and tradeoffs

- Give each skill a package boundary while centralizing only truly shared laws.
- Validate observable structure and behavior contracts, while leaving subjective artifact quality to domain review.
- Preserve attribution and pinned runtime dependencies even when that adds packaging metadata.

## Verification and human review

Run `scripts/validate_workspace.ps1`, `scripts/validate_links.ps1`, `scripts/test_validators_ignore_scan.ps1`, and the behavior/dependency validation tests. Licensing, redistribution, subjective output quality, and live-tool behavior require human review.

## Evidence basis and limits

The design is informed by [IEEE 1016-2009](https://standards.ieee.org/ieee/1016/4502/), stakeholder views and scenarios from [Kruchten](https://www.cs.ubc.ca/~gregor/teaching/papers/4%2B1view-architecture.pdf), information hiding from [Parnas (1972)](https://doi.org/10.1145/361598.361623), quality objectives from [ISO/IEC 25010:2023](https://www.iso.org/standard/78176.html), and lifecycle security from [NIST SSDF 1.1](https://doi.org/10.6028/NIST.SP.800-218). Structural validation does not establish every generated artifact's quality or legal fitness.
