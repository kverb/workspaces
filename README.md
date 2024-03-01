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

To use it, you will need docker installed and running (dockerd), clone this repo and build a docker container (USER_NAME is optional):

```
docker build --ulimit "nofile=1024:1048576" --build-arg USER_NAME=<user-name> -f Node.Dockerfile -t <image-name> .
```

specify the flavor with `-f` : `Node.Dockerfile, Go.Dockerfile` , etc. 

This DOES NOT copy the current directory contents to the container. 
Instead, cd into your code directory and mount it as a volume at run time: 

```
docker run -it -v $(pwd):/workspace <image-name>
```

To expose ports from the container, e.g. for `npm run dev` :

```
docker run -it -v $(pwd):/workspace -p 3000:3000 <image-name>
```

Sample of the workspace prompt and helix editor:

https://github.com/kverb/workspaces/assets/1261697/b135bad3-6ae2-4f66-b40c-8c86f69ef49c



