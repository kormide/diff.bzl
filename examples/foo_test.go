package foo_go_proto

import (
	pb "github.com/kormide/diff.bzl/examples/foo_go_proto"
	"testing"
)

func TestFoo(t *testing.T) {
	foo := &pb.Foo{
		Name: "test",
		Description: "testdesc",
	}
	if foo.String() != "name:\"test\"  description:\"testdesc\"" {
		t.Errorf("Foo.String() = %s, want %s", foo.String(), "name:\"test\" description:\"testdesc\"")
	}
}
