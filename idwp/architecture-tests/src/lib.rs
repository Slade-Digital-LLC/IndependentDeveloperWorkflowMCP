//! Executable dependency-boundary policy for the IDWP workspace.

#![forbid(unsafe_code)]

use std::collections::{BTreeMap, BTreeSet};

/// A direct package dependency edge.
#[derive(Clone, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub struct DependencyEdge {
    /// Depending package name.
    pub from: String,
    /// Dependency package name.
    pub to: String,
}

/// Validates required packages and all IDWP/root dependency edges.
pub fn validate_edges(
    packages: &BTreeSet<String>,
    edges: &BTreeSet<DependencyEdge>,
) -> Result<(), Vec<String>> {
    const REQUIRED: [&str; 5] = [
        "idwp-domain",
        "idwp-application",
        "idwp-provider-contract",
        "idwp-review-contract",
        "idwp-architecture-tests",
    ];
    let allowed: BTreeMap<&str, BTreeSet<&str>> = BTreeMap::from([
        ("idwp-domain", BTreeSet::new()),
        ("idwp-provider-contract", BTreeSet::from(["idwp-domain"])),
        ("idwp-review-contract", BTreeSet::from(["idwp-domain"])),
        (
            "idwp-application",
            BTreeSet::from([
                "idwp-domain",
                "idwp-provider-contract",
                "idwp-review-contract",
            ]),
        ),
        ("idwp-architecture-tests", BTreeSet::new()),
        ("wshm-core", BTreeSet::new()),
    ]);
    let mut errors = Vec::new();
    for required in REQUIRED {
        if !packages.contains(required) {
            errors.push(format!("required workspace package is missing: {required}"));
        }
    }
    for package in packages {
        if !allowed.contains_key(package.as_str()) {
            errors.push(format!("unclassified workspace package: {package}"));
        }
    }
    for edge in edges {
        let internal = edge.to.starts_with("idwp-") || edge.to == "wshm-core";
        if !internal {
            continue;
        }
        let Some(destinations) = allowed.get(edge.from.as_str()) else {
            continue;
        };
        if !destinations.contains(edge.to.as_str()) {
            errors.push(format!(
                "forbidden dependency edge: {} -> {}",
                edge.from, edge.to
            ));
        }
    }
    if errors.is_empty() {
        Ok(())
    } else {
        Err(errors)
    }
}
