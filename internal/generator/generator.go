package generator

import (
	"embed"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

//go:embed template/*
var templateFS embed.FS

var validName = regexp.MustCompile(`^[a-z][a-z0-9-]{1,38}[a-z0-9]$`)

type Options struct {
	Name   string
	Owner  string
	Output string
}

func Generate(options Options) error {
	if !validName.MatchString(options.Name) {
		return fmt.Errorf("name must be 3-40 lowercase letters, numbers, or hyphens")
	}
	if strings.TrimSpace(options.Owner) == "" {
		return fmt.Errorf("owner is required")
	}

	target := filepath.Join(options.Output, options.Name)
	if _, err := os.Stat(target); !os.IsNotExist(err) {
		return fmt.Errorf("target already exists: %s", target)
	}

	return fs.WalkDir(templateFS, "template", func(path string, entry fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		relative, _ := filepath.Rel("template", path)
		if relative == "." {
			return os.MkdirAll(target, 0o755)
		}

		destination := filepath.Join(target, strings.TrimSuffix(relative, ".tmpl"))
		if entry.IsDir() {
			return os.MkdirAll(destination, 0o755)
		}

		content, err := templateFS.ReadFile(path)
		if err != nil {
			return err
		}
		rendered := strings.NewReplacer(
			"{{SERVICE_NAME}}", options.Name,
			"{{OWNER}}", options.Owner,
		).Replace(string(content))
		return os.WriteFile(destination, []byte(rendered), 0o644)
	})
}
