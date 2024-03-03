# workspaces
Docker containers for terminal-centric code editing. 

These dockerfiles provide an arch-linux-based development container with the dev tools I typically want pre-installed, including but not limited to:

- tig
- git-delta
- jq
- tmux (TODO: add configs and plugins)
- fish

The editing workflow is based on the [Helix Editor](https://helix-editor.com/).

It should be ready-to-go for editing Go and JS/TS projects. 

To use it, you will need docker installed and running (dockerd), clone this repo and build a docker image (USER_NAME is optional):

```
docker build --ulimit "nofile=1024:1048576" --build-arg USER_NAME=<user-name> -t <image-name> .
```

## Customize with template stubs

You can create your own dockerfile stubs to extend the packages installed, add custom configuration, or overwrite the base dockerfile.
Two stubs are provided in the `templates/` dir along with a go program that injects the stubs into the base template.
E.g., to create a dockerfile flavored for Node.js development, use the helper script to generate a custom composed dockerfile:

```
go run dockerfile_generator.go -stub templates/node.dockerfile.tmpl -output Node.Dockerfile
```

You can combine multiple stubs together by chaining: `-stub templates/node.dockerfile.tmpl -stub templates/go.dockerfile.tmpl`

specify the flavor with `-f` : `Node.Dockerfile, Go.Dockerfile` , etc. when building:

```
docker build -f Node.Dockerfile -t <image-name> .
```

You can specify an alternative base template by passing `-base path/to/base.tmpl` to the `dockerfile_generator.go` program.


## Using the containers

This DOES NOT copy the current directory contents to the container, nor does it clone a working repo.
Instead, cd into your code directory and mount it as a volume to /workspace at run time to use the container for editing:

```
docker run -it --name <container-name> -v $PWD:/workspace -d <image-name> 
docker attach <container-name>
```

This will drop you into a fish shell pre-configured with the tools and flavor-specific settings or packages.

To expose ports from the container, e.g. for `npm run dev` :

```
docker run -it --name {container-name} -v $PWD:/workspace -p 3000:3000 -d {image-name} 
```

Sample of the workspace prompt and helix editor:

[![asciicast](https://asciinema.org/a/644983.svg)](https://asciinema.org/a/644983)





