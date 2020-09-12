# myde

My development environment

## Run
```
docker run -v "$PWD/myde-volume:/myde" --name myde -it pjongy/myde:{version}
```

It loads tmux as default. <br>
You can use `$ vim .` for use vim like IDE.
```
$ vim .
<in vim> ESC :NERDTree
```
