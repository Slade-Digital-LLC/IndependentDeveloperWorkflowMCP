//! IDWP application orchestration boundary.
//!
//! Application behavior begins after the Epic 3 workspace and quality gates.

#![forbid(unsafe_code)]

#[doc(hidden)]
pub use idwp_domain as domain_boundary;
#[doc(hidden)]
pub use idwp_provider_contract as provider_contract_boundary;
#[doc(hidden)]
pub use idwp_review_contract as review_contract_boundary;
