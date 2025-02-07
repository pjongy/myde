NODE_VERSION=v22.13.1
source $HOME/.nvm/nvm.sh
nvm install $NODE_VERSION


# typescript-language-server
nvm exec npm install -g typescript-language-server typescript

# svelte-language-server
nvm exec npm install -g svelte-language-server
