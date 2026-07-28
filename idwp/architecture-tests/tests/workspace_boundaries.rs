use std::collections::BTreeSet;

use cargo_metadata::MetadataCommand;
use idwp_architecture_tests::{validate_edges, DependencyEdge};

#[test]
fn checked_in_workspace_obeys_dependency_policy() {
    let metadata = MetadataCommand::new()
        .manifest_path("../../Cargo.toml")
        .exec()
        .expect("workspace metadata must load");
    let workspace_ids: BTreeSet<_> = metadata.workspace_members.iter().collect();
    let packages: BTreeSet<_> = metadata
        .packages
        .iter()
        .filter(|package| workspace_ids.contains(&package.id))
        .map(|package| package.name.to_string())
        .collect();
    let workspace_names: BTreeSet<_> = packages.iter().map(String::as_str).collect();
    let edges: BTreeSet<_> = metadata
        .packages
        .iter()
        .filter(|package| workspace_ids.contains(&package.id))
        .flat_map(|package| {
            package
                .dependencies
                .iter()
                .filter(|dependency| workspace_names.contains(dependency.name.as_str()))
                .map(|dependency| DependencyEdge {
                    from: package.name.to_string(),
                    to: dependency.name.to_string(),
                })
        })
        .collect();
    if let Err(errors) = validate_edges(&packages, &edges) {
        panic!("architecture violations:\n{}", errors.join("\n"));
    }
}

#[test]
fn domain_to_provider_is_rejected() {
    let packages = required_packages();
    let edges = BTreeSet::from([DependencyEdge {
        from: "idwp-domain".to_owned(),
        to: "idwp-provider-contract".to_owned(),
    }]);
    assert_eq!(
        validate_edges(&packages, &edges).unwrap_err(),
        ["forbidden dependency edge: idwp-domain -> idwp-provider-contract"]
    );
}

#[test]
fn idwp_to_upstream_root_is_rejected() {
    let packages = required_packages();
    let edges = BTreeSet::from([DependencyEdge {
        from: "idwp-application".to_owned(),
        to: "wshm-core".to_owned(),
    }]);
    assert_eq!(
        validate_edges(&packages, &edges).unwrap_err(),
        ["forbidden dependency edge: idwp-application -> wshm-core"]
    );
}

#[test]
fn root_to_idwp_is_rejected() {
    let packages = required_packages();
    let edges = BTreeSet::from([DependencyEdge {
        from: "wshm-core".to_owned(),
        to: "idwp-application".to_owned(),
    }]);
    assert_eq!(
        validate_edges(&packages, &edges).unwrap_err(),
        ["forbidden dependency edge: wshm-core -> idwp-application"]
    );
}

#[test]
fn missing_and_unclassified_packages_fail_closed() {
    let mut packages = required_packages();
    packages.remove("idwp-review-contract");
    packages.insert("idwp-unknown".to_owned());
    let edges = BTreeSet::from([DependencyEdge {
        from: "idwp-unknown".to_owned(),
        to: "idwp-domain".to_owned(),
    }]);
    let errors = validate_edges(&packages, &edges).unwrap_err();
    assert!(errors.iter().any(|error| error.contains("is missing")));
    assert!(errors.iter().any(|error| error.contains("unclassified")));
}

fn required_packages() -> BTreeSet<String> {
    [
        "idwp-domain",
        "idwp-application",
        "idwp-provider-contract",
        "idwp-review-contract",
        "idwp-architecture-tests",
        "wshm-core",
    ]
    .into_iter()
    .map(str::to_owned)
    .collect()
}
