GO_VERSION_MAJOR=1.21
GO_VERSION=$GO_VERSION_MAJOR.5

wget -O $INSTALL_PATH/go$GO_VERSION_MAJOR.linux-amd64.tar.gz https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz \
  && sudo mkdir -p /usr/go \
  && sudo tar -C /usr/go -xvf $INSTALL_PATH/go$GO_VERSION_MAJOR.linux-amd64.tar.gz

sudo update-alternatives --remove-all go
sudo update-alternatives --remove-all gofmt
sudo update-alternatives --install /usr/bin/go go /usr/go/go/bin/go 100 --force
sudo update-alternatives --install /usr/bin/gofmt gofmt /usr/go/go/bin/gofmt 100 --force

# go lsp server
go install golang.org/x/tools/gopls@latest
sudo update-alternatives --remove-all gopls
sudo update-alternatives --install /usr/bin/gopls gopls $HOME/go/bin/gopls 100 --force
