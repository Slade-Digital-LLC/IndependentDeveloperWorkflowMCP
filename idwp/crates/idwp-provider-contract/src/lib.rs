//! Provider-neutral source-control contract boundary.
//!
//! Provider capabilities and operations begin in Epic 6. The dependency on
//! `idwp-domain` establishes the permitted inward direction only.

#![forbid(unsafe_code)]

#[doc(hidden)]
pub use idwp_domain as domain_boundary;
