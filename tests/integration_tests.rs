//! Integration tests for AD-Stack

use ad_stack::api::create_router;
use axum::{
    body::Body,
    http::{Request, StatusCode},
};
use tower::util::ServiceExt;

#[tokio::test]
async fn test_health_endpoint() {
    let app = create_router();

    let response = app
        .oneshot(Request::builder().uri("/health").body(Body::empty()).unwrap())
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
}

#[tokio::test]
async fn test_api_endpoints() {
    let app = create_router();

    // Test users endpoint
    let response = app
        .clone()
        .oneshot(Request::builder().uri("/api/v1/users").body(Body::empty()).unwrap())
        .await
        .unwrap();
    assert_eq!(response.status(), StatusCode::OK);

    // Test groups endpoint
    let response = app
        .oneshot(Request::builder().uri("/api/v1/groups").body(Body::empty()).unwrap())
        .await
        .unwrap();
    assert_eq!(response.status(), StatusCode::OK);
}