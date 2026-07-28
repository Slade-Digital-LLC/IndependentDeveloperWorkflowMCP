# Independent Development Workflow Platform - Sequence Diagrams

**Status:** Normative interaction specification  
**Version:** 2.0  
**Date:** 2026-07-27

## 1. Start Feature Work

```mermaid
sequenceDiagram
    actor User
    participant Impl as Implementation OpenCode
    participant MCP as IDWP MCP
    participant Gov as Governance Kernel
    participant SCM as Provider Adapter/Forge

    User->>Impl: Implement feature
    Impl->>MCP: workflow_start(request, repository, session)
    MCP->>Gov: Start/resume workflow
    Gov->>SCM: Inspect branches and capabilities
    SCM-->>Gov: Repository snapshot
    Gov-->>MCP: FeatureBranchId, required branch, plan
    MCP-->>Impl: Required/allowed actions
    Impl->>SCM: Create/push feature branch as implementer
    Impl->>MCP: workflow_register_push(head)
    MCP-->>Impl: Validation required
```

## 2. Feature Review With Findings

```mermaid
sequenceDiagram
    participant Impl as Implementation OpenCode
    participant Gov as Governance
    participant SCM as Provider/Change Request
    participant Rev as Reviewer Service
    participant RAI as Reviewer OpenCode

    Impl->>Gov: workflow_create_change_request
    Gov->>SCM: Create change request to develop
    Impl->>Gov: workflow_request_review
    Gov-->>Rev: Pending review job
    Rev->>Gov: Claim lease
    Gov-->>Rev: Immutable package at SHA A
    Rev->>RAI: Launch isolated review at SHA A
    RAI-->>Rev: Structured blocking findings
    Rev->>SCM: Post Code Review 001 and request changes
    Rev->>Gov: Signed attestation for SHA A
    Gov-->>Impl: ChangesRequired
    Impl->>Gov: Respond Accepted
    Gov->>SCM: Post response in same discussion
    Impl->>SCM: Push fix SHA B
    SCM-->>Gov: Head changed webhook
    Gov-->>Gov: Invalidate SHA A approval and gate
    Impl->>Gov: Record validation for SHA B
    Impl->>Gov: Report fix in same discussion
    Impl->>Gov: Request recheck
    Gov-->>Rev: Recheck job for SHA B
    Rev->>RAI: Fresh OpenCode recheck
    RAI-->>Rev: Accepted
    Rev->>SCM: Post Reviewer Recheck Accepted
    Rev->>Gov: Signed accepted attestation for SHA B
    Gov->>SCM: Publish passing review gate for SHA B
```

## 3. Full Sync to Production

```mermaid
sequenceDiagram
    actor User
    participant Impl as Implementation OpenCode
    participant Gov as IDWP Governance
    participant Rev as Reviewer Service
    participant SCM as Source-Control Provider

    User->>Impl: Sync this code to master
    Impl->>Gov: workflow_promote(destination=Production)
    Gov->>SCM: Ensure feature change request to develop
    Gov->>Rev: Request independent review if required
    Rev->>SCM: Publish review/rechecks
    Gov->>SCM: Integrate feature to develop after gates
    Gov->>SCM: Create release branch from current develop
    Gov->>SCM: Open production change request to master
    alt Release exception valid
        Gov->>SCM: Document exception and pass gate
    else Review required
        Gov->>Rev: Request release review
        Rev->>SCM: Publish review result
    end
    Gov->>SCM: Integrate release to master
    Gov->>SCM: Open master-to-develop sync-back change request
    Gov->>SCM: Apply sync-back review rule/exception
    Gov->>SCM: Integrate sync-back
    Gov->>SCM: Delete eligible remote branches
    Gov-->>Impl: Local finalization plan with expected develop SHA
    Impl->>SCM: Fetch/prune
    Impl->>Impl: Checkout and fast-forward develop; clean workspace
    Impl->>Gov: workflow_finalize_local(evidence)
    Gov-->>Impl: Completed
```

## 4. Recheck Not Accepted

```mermaid
sequenceDiagram
    participant Impl as Implementation
    participant Gov as Governance
    participant Rev as Reviewer Service
    participant SCM as Provider Discussion

    Impl->>Gov: Report fix for finding
    Gov-->>Rev: Recheck job
    Rev->>SCM: Reviewer Recheck Not Accepted with evidence
    Rev->>Gov: Signed ChangesRequired attestation
    Gov-->>Impl: Finding Reopened; gate failing
    Impl->>SCM: Continue same discussion
    Impl->>Gov: New fix and validation
```

## 5. New Commit After Approval

```mermaid
sequenceDiagram
    participant Impl as Implementation
    participant SCM as Provider
    participant Gov as Governance

    Gov->>SCM: Passing gate for approved SHA A
    Impl->>SCM: Push SHA B
    SCM->>Gov: ChangeRequestHeadChanged(A to B)
    Gov->>SCM: Set gate Pending/Failing for SHA B
    Gov->>Gov: Mark review/validation stale
    Gov-->>Impl: Recheck or full review required
```

## 6. Manual Conversation Resolution Attempt

```mermaid
sequenceDiagram
    participant UserOrImpl as User/Implementation
    participant SCM as Provider
    participant Gov as Governance

    UserOrImpl->>SCM: Resolve discussion manually
    SCM->>Gov: DiscussionResolved event
    Gov->>Gov: Finding lacks reviewer acceptance
    Gov->>SCM: Keep gate failing; reopen when supported
    Gov-->>UserOrImpl: Reviewer acceptance still required
```

## 7. Reviewer Crash and Lease Recovery

```mermaid
sequenceDiagram
    participant Rev1 as Reviewer Worker 1
    participant Gov as Governance
    participant Rev2 as Reviewer Worker 2

    Rev1->>Gov: Claim review lease
    Rev1--xRev1: Process/host crashes
    Gov->>Gov: Lease expires; no valid attestation
    Rev2->>Gov: Claim pending/expired job
    Gov-->>Rev2: New lease and same immutable package
    Rev2->>Gov: Submit signed result
    Gov->>Gov: Reject any late result from old lease
```

## 8. Provider Outage

```mermaid
sequenceDiagram
    participant Gov as Governance
    participant SCM as Provider
    participant Op as Operator

    Gov->>SCM: Publish finding/gate/integration
    SCM--xGov: Temporary unavailable
    Gov->>Gov: Record retryable ProviderOperation
    Gov-->>Op: Workflow blocked; retry scheduled
    Gov->>SCM: Idempotent retry
    SCM-->>Gov: Success/existing provider reference
    Gov->>Gov: Reconcile and resume
```

## 9. Usage and Cost Flow

```mermaid
sequenceDiagram
    participant OC as OpenCode Runtime
    participant Tel as Telemetry Ingest
    participant Ledger as IDWP Cost Ledger
    participant UI as Reporting UI

    OC->>Tel: Model request event with session/request/model/tokens/cost
    Tel->>Ledger: Normalize and correlate to WorkRequest and FeatureBranchId
    Ledger->>Ledger: Validate provenance and apply rate card if needed
    Ledger->>Ledger: Store immutable usage/cost version
    UI->>Ledger: Query feature/workflow/model totals
    Ledger-->>UI: Totals plus completeness/reconciliation status
```

## 10. Local Git Advisory Mode

```mermaid
sequenceDiagram
    participant Impl as Implementation
    participant Gov as Governance
    participant Git as Local/Central Git

    Impl->>Gov: Request production promotion
    Gov->>Git: Inspect capabilities
    Git-->>Gov: No protected change requests or discussion enforcement
    Gov-->>Impl: Blocked: provider mode Advisory
    Note over Gov,Impl: Production integration requires forge or equivalent hooks/discussion controls
```
