# myde

My development environment

## Run
Mounting docker.sock volume is for DooD
```
docker run -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v "$PWD/myde-share:/share" --name myde -it pjongy/myde:{version}
```

It loads tmux as default. <br>
You can use `$ vim .` for use vim like IDE.

## Help (in myde)
```
$ cat ~/HELP
```
