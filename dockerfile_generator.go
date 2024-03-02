package main

import (
	"flag"
	"log"
	"os"
	"text/template"
)

// DockerfileData represents the data structure for template execution
type DockerfileData struct {
	Sections []string
}

func main() {
	var stubPaths []string
	flag.Func("stub", "Path to a Dockerfile stub (this flag can be repeated)", func(stubPath string) error {
		stubPaths = append(stubPaths, stubPath)
		return nil
	})
	basePath := flag.String("base", "templates/base.dockerfile.tmpl", "Path to an alternative base dockerfile template")
	outputPath := flag.String("output", "Dockerfile", "Output Dockerfile path")
	flag.Parse()

	// slice holds the content of each stub
	var sections []string

	// Read each stub file specified by the command-line arguments
	for _, path := range stubPaths {
		content, err := os.ReadFile(path)
		if err != nil {
			log.Fatalf("failed to read Dockerfile stub '%s': %v", path, err)
		}
		sections = append(sections, string(content))
	}

	data := DockerfileData{
		Sections: sections,
	}

	// Parse the base Dockerfile template
	tmpl, err := template.ParseFiles(*basePath)
	if err != nil {
		log.Fatalf("failed to parse base Dockerfile template: %v", err)
	}

	// Create the output file
	outputFile, err := os.Create(*outputPath)
	if err != nil {
		log.Fatalf("failed to create output file: %v", err)
	}
	defer outputFile.Close()

	// Execute the template with the data and write the output to the specified file
	if err := tmpl.Execute(outputFile, data); err != nil {
		log.Fatalf("failed to execute template: %v", err)
	}

	log.Printf("Dockerfile generated successfully at %s", *outputPath)
}
