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

	msg := foo.ProtoReflect()
	fields := msg.Descriptor().Fields()
	if got, want := fields.Len(), 3; got != want {
		t.Fatalf("field count = %d, want %d", got, want)
	}

	if got, want := msg.Get(fields.Get(0)).String(), "test"; got != want {
		t.Errorf("name = %q, want %q", got, want)
	}

	if got, want := msg.Get(fields.Get(1)).String(), "testdesc"; got != want {
		t.Errorf("description = %q, want %q", got, want)
	}
}
