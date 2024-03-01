# workspaces
Docker containers for terminal-centric code editing. 

This dockerfile provides and arch-linux based development container with the dev tools I typically want pre-installed.

The editing workflow is based on the [Helix Editor](https://helix-editor.com/).

It should be ready-to-go for editing Go and JS/TS projects. 

To use it, cd into a working code directory, and build the docker container (USER_NAME is optional):

```
docker build --ulimit "nofile=1024:1048576" --build-arg USER_NAME=<user-name> -f Dockerfile.Node -t <image-name> .
```

specify the flavor with `-f` : `Node.Dockerfile, Go.Dockerfile` , etc. 

This DOES NOT copy the current directory contents to the container. 
Instead, mount as a volume at run time: 

```
docker run -it -v $(pwd):/workspace <image-name>
```

To expose ports from the container, e.g. for `npm run dev` :

```
docker run -it -v $(pwd):/workspace -p 3000:3000 <image-name>
```


