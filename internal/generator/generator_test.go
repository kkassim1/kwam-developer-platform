package generator

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestGenerate(t *testing.T) {
	output := t.TempDir()
	if err := Generate(Options{Name: "orders-api", Owner: "checkout-team", Output: output}); err != nil {
		t.Fatal(err)
	}

	content, err := os.ReadFile(filepath.Join(output, "orders-api", "catalog-info.yaml"))
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(content), "checkout-team") {
		t.Fatalf("owner was not rendered: %s", content)
	}
}

func TestGenerateRejectsUnsafeName(t *testing.T) {
	err := Generate(Options{Name: "../../bad", Owner: "team", Output: t.TempDir()})
	if err == nil {
		t.Fatal("expected invalid name to fail")
	}
}
