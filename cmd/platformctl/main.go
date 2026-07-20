package main

import (
	"flag"
	"fmt"
	"os"
	"runtime"

	"github.com/kkassim1/kwam-developer-platform/internal/generator"
)

const version = "0.1.0"

func main() {
	if len(os.Args) < 2 {
		usage()
		os.Exit(2)
	}

	switch os.Args[1] {
	case "doctor":
		fmt.Printf("platformctl %s\n", version)
		fmt.Printf("go: %s\n", runtime.Version())
		fmt.Println("status: ready")
	case "new":
		newService(os.Args[2:])
	case "version":
		fmt.Println(version)
	default:
		usage()
		os.Exit(2)
	}
}

func newService(args []string) {
	if len(args) == 0 || args[0] != "service" {
		fmt.Fprintln(os.Stderr, "usage: platformctl new service --name NAME [--owner OWNER] [--output DIR]")
		os.Exit(2)
	}

	flags := flag.NewFlagSet("new service", flag.ExitOnError)
	name := flags.String("name", "", "DNS-compatible service name")
	owner := flags.String("owner", "platform-team", "team that owns the service")
	output := flags.String("output", ".", "parent output directory")
	_ = flags.Parse(args[1:])

	if err := generator.Generate(generator.Options{Name: *name, Owner: *owner, Output: *output}); err != nil {
		fmt.Fprintf(os.Stderr, "create service: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("created %s/%s\n", *output, *name)
	fmt.Println("next: cd into the service and run `go test ./...`")
}

func usage() {
	fmt.Println("platformctl — self-service golden paths")
	fmt.Println("commands: doctor, new service, version")
}
