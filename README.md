# myde

My development environment (amd64/arm64)

## Run
Mounting docker.sock volume is for DooD
```
docker run -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v "$PWD/myde-share:/share" --name myde -it pjongy/myde:{version}
```

Mounting host's git config and credentials
```
docker run -v "$HOME/.gitconfig:/home/dev/.gitconfig:ro" \
  -v "$HOME/.git-credentials:/home/dev/.git-credentials:ro" \
  --name myde -it pjongy/myde:{version}
```

## Build
```
$ docker build . -f Dockerfile-arm -t myde:arm64
$ docker build . -f Dockerfile -t myde:amd64
```

It loads tmux as default. <br>
You can use `$ vim .` for use vim like IDE.

## Help (in myde)
```
$ cat ~/HELP
```
