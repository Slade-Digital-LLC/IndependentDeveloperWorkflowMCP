# Independent Development Workflow Platform - Source-Control Provider Contract

**Status:** Normative adapter specification  
**Version:** 2.0  
**Date:** 2026-07-27

## 1. Purpose

IDWP must work across hosted forges and locally hosted Git systems without embedding one provider's terminology or enforcement model into the domain.

GitHub is the first production adapter, not the architecture.

## 2. Provider Layers

Separate three concerns:

1. **Git transport** - commits, refs, fetch, push, ancestry, diff.
2. **Forge collaboration** - change requests, discussions, reviews, webhooks, identities.
3. **Policy enforcement** - protected branches, required gates, merge queue, hooks.

A local Git repository may implement only the first concern. The capability model makes that limitation explicit.

## 3. Required Rust Traits

Names may be adjusted to upstream conventions, but responsibilities must remain separate.

```rust
pub trait RepositoryProvider {
    async fn get_repository(&self, repo: &RepositoryRef) -> Result<RepositorySnapshot>;
    async fn get_branch(&self, repo: &RepositoryRef, branch: &BranchName) -> Result<BranchSnapshot>;
    async fn compare_commits(&self, repo: &RepositoryRef, base: &CommitId, head: &CommitId) -> Result<CommitComparison>;
    async fn create_branch(&self, request: CreateBranchRequest) -> Result<BranchSnapshot>;
    async fn delete_branch(&self, request: DeleteBranchRequest) -> Result<()>;
}

pub trait ChangeRequestProvider {
    async fn create_change_request(&self, request: CreateChangeRequest) -> Result<ChangeRequestSnapshot>;
    async fn get_change_request(&self, reference: &ProviderReference) -> Result<ChangeRequestSnapshot>;
    async fn update_change_request(&self, request: UpdateChangeRequest) -> Result<ChangeRequestSnapshot>;
    async fn integrate_change_request(&self, request: IntegrateChangeRequest) -> Result<IntegrationResult>;
}

pub trait ReviewDiscussionProvider {
    async fn publish_finding(&self, request: PublishFinding) -> Result<DiscussionBinding>;
    async fn reply(&self, request: ReplyToDiscussion) -> Result<MessageReference>;
    async fn set_resolution(&self, request: SetDiscussionResolution) -> Result<DiscussionSnapshot>;
    async fn list_discussions(&self, change_request: &ProviderReference) -> Result<Vec<DiscussionSnapshot>>;
}

pub trait CommitGateProvider {
    async fn publish_gate(&self, request: PublishGate) -> Result<GateReference>;
    async fn get_gate(&self, reference: &GateReference) -> Result<GateSnapshot>;
}

pub trait BranchPolicyProvider {
    async fn inspect_policy(&self, repo: &RepositoryRef, branch: &BranchName) -> Result<BranchPolicySnapshot>;
    async fn plan_policy_change(&self, desired: DesiredBranchPolicy) -> Result<ProviderPlan>;
    async fn apply_policy_change(&self, plan: ProviderPlan) -> Result<BranchPolicySnapshot>;
}

pub trait ProviderWebhookAdapter {
    fn verify(&self, headers: &HeaderMap, body: &[u8]) -> Result<VerifiedDelivery>;
    fn normalize(&self, delivery: VerifiedDelivery) -> Result<Vec<ProviderEvent>>;
}
```

Provider administration must be a separately authorized interface from ordinary workflow operations.

## 4. Neutral Types

Core contracts use:

- `RepositoryRef`;
- `BranchName`;
- `CommitId`;
- `ChangeRequest`;
- `ReviewDiscussion`;
- `ReviewDecision`;
- `CommitGate`;
- `BranchPolicy`;
- `ProviderIdentity`;
- `ProviderEvent`;
- `ProviderReference`.

Provider-specific payloads may appear only as bounded adapter extension data.

## 5. Capability Negotiation

Each adapter reports a `ProviderCapabilitySet` with support level:

- Native;
- Equivalent;
- Advisory;
- Unsupported.

Capabilities include:

- change requests;
- draft state;
- inline findings;
- general discussions;
- thread replies;
- thread resolution;
- formal approval/request-changes;
- required commit gates;
- expected gate source identity;
- branch protection;
- force-push prevention;
- branch deletion prevention;
- merge queue/auto-merge;
- service/application identities;
- signed webhooks and delivery IDs;
- provider-side merge restrictions;
- server-side hooks;
- repository administration API.

Policy decisions record the capability snapshot used.

## 6. Provider Modes

### Enforced

Provider natively enforces all required controls.

### EquivalentControl

Missing native capability is replaced by an independently enforced equivalent, documented and tested.

### Advisory

IDWP can coordinate and report but cannot prevent bypass. Advisory mode must be visibly labeled and cannot promote production code unless policy explicitly allows it for a non-production environment.

### Unsupported

Required operations or security properties are absent.

## 7. GitHub First Adapter

The GitHub adapter should reuse verified wshm functionality where possible, then add:

- separate implementer, workflow, reviewer, and optional integration identities;
- ruleset/branch-protection inspection and configuration;
- expected-source required gate;
- review discussion bindings;
- stale approval invalidation;
- exact-head checks;
- auto-merge/integration only after gate pass;
- webhook normalization and reconciliation;
- no-bypass verification.

GitHub details remain in the adapter crate and deployment profile.

## 8. Existing Upstream Providers

Epic 1 must verify wshm's actual provider matrix. Any existing GitLab or Gitea implementation should be wrapped behind the contract and covered by conformance tests rather than duplicated.

Upstream provider features that do not meet IDWP security semantics may remain available for legacy/advisory use but cannot be described as fully enforced.

## 9. Azure DevOps Adapter

Future adapter maps:

- ChangeRequest -> Azure Repos pull request;
- ReviewDiscussion -> PR thread/comment;
- CommitGate -> branch policy/status/check;
- ProviderIdentity -> service principal/PAT-backed service identity as approved;
- ProviderEvent -> service hook event;
- BranchPolicy -> branch policy configuration.

No Azure DevOps type belongs in the core domain.

## 10. Bitbucket Adapters

Bitbucket Cloud and Bitbucket Data Center/Server are separate adapters because authentication, webhooks, APIs, merge checks, and administration differ.

The roadmap must evaluate:

- required build statuses;
- default reviewers;
- task/comment resolution;
- merge checks;
- branch permissions;
- application/service identities;
- webhook verification.

## 11. Local and Self-Hosted Git

A generic local Git adapter may provide:

- repository and ref inspection;
- branch creation/deletion;
- commit comparison;
- server-side hook installation when authorized;
- local audit references.

It cannot claim native change-request review unless paired with a forge or IDWP-hosted collaboration module.

Production enforcement may require:

- a controlled bare central repository;
- server-side pre-receive hooks managed by the workflow identity;
- protected filesystem permissions;
- an IDWP-hosted change-request/discussion UI;
- signed integration operations;
- no direct write access for implementation actors.

A developer-owned local repository alone is Advisory.

## 12. Normalized Events

Representative `ProviderEvent` types:

- BranchCreated
- BranchUpdated
- BranchDeleted
- ChangeRequestOpened
- ChangeRequestUpdated
- ChangeRequestHeadChanged
- ChangeRequestIntegrated
- ChangeRequestClosed
- ReviewSubmitted
- DiscussionCreated
- DiscussionReplied
- DiscussionResolved
- GateUpdated
- PolicyChanged
- InstallationChanged

Events contain provider references and normalized facts. Raw payloads are protected evidence, not domain events.

## 13. Idempotency and Reconciliation

Every adapter mutation accepts an idempotency key. If the provider lacks native idempotency, the adapter uses provider references and request digests to detect duplicates.

Periodic reconciliation verifies:

- branch heads;
- change-request state;
- reviews and discussions;
- required gates;
- effective branch policy;
- identity installation/permissions;
- merge outcome.

## 14. Provider Conformance Suite

Every adapter must pass tests for supported capabilities:

- create/read/update change request;
- post finding and replies;
- exact discussion binding;
- publish and inspect gate;
- detect head change;
- inspect branch policy;
- integrate with correct commit;
- handle duplicate operations;
- normalize webhooks;
- reconcile missed events;
- accurately report unsupported capabilities.

A mock provider and at least one non-GitHub adapter must compile and pass neutral domain tests before provider neutrality is considered complete.

## 15. Error Contract

Provider errors are normalized into categories such as:

- AuthenticationFailed;
- AuthorizationDenied;
- CapabilityUnavailable;
- PolicyDrift;
- NotFound;
- Conflict;
- StaleVersion;
- RateLimited;
- TemporaryUnavailable;
- ValidationRejected;
- PermanentFailure.

Provider-specific messages remain evidence; workflow logic branches on neutral categories.
