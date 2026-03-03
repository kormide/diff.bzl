load("@diff.bzl", "diff")
load("@protobuf//bazel:proto_library.bzl", "proto_library")
load("@rules_go//go:def.bzl", "go_test")
load("@rules_go//proto:def.bzl", "go_proto_library")

proto_library(
    name = "foo_proto",
    srcs = ["foo.proto"],
)

go_proto_library(
    name = "foo_go_proto",
    importpath = "github.com/kormide/diff.bzl/examples/foo_go_proto",
    proto = "foo_proto",
)

filegroup(
    name = "go_codegen",
    srcs = [":foo_go_proto"],
    output_group = "go_generated_srcs",
)

diff(
    name = "go_codegen_diff",
    args = ["--unified"],
    file1 = ":foo.pb.go",
    file2 = ":go_codegen",
)

go_test(
    name = "foo_usage_test",
    srcs = ["foo_test.go"],
    # we want to trigger the validation action to ensure this test can't run
    # if the generated code is not up to date
    # This is an awkward way to do this, maybe improve
    data = [":go_codegen_diff"],
    deps = [":foo_go_proto"],
)
