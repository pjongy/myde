# Dockerfile
FROM ubuntu:latest

ARG USERNAME=dev
ENV USERNAME $USERNAME
ARG USER_UID=1000
ARG USER_GID=$USER_UID

#
# Add work user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
USER $USERNAME

#
# Setup download path
ARG INSTALL_PATH=/home/$USERNAME/installed
ENV INSTALL_PATH $INSTALL_PATH
RUN mkdir -p $INSTALL_PATH

#
# Install default setup
RUN sudo apt-get update
RUN sudo apt-get install -y \
    wget \
    git \
    tmux \
    curl

#
# Setup zsh
RUN sudo apt-get install -y zsh
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
RUN sudo chsh -s `which zsh`
RUN zsh -c "source ~/.zshrc"
RUN cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
RUN sh -c "sudo usermod -s $(which zsh) $(whoami)"
#
# Setup vim plugin
RUN sudo apt-get install -y \
    vim
RUN git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
RUN sh ~/.vim_runtime/install_awesome_vimrc.sh

#
# Setup pyenv build prerequisites
ARG DEBIAN_FRONTEND="noninteractive"
RUN sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
RUN sudo apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python-openssl

#
# Setup pyenv
ARG PYTHON_VERSION=3.9.0
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
RUN $HOME/.pyenv/bin/pyenv install $PYTHON_VERSION
RUN sudo update-alternatives --install /usr/bin/python3 python3 $HOME/.pyenv/versions/$PYTHON_VERSION/bin/python3 100 --force
RUN sudo update-alternatives --install /usr/bin/pip3 pip3 $HOME/.pyenv/versions/$PYTHON_VERSION/bin/pip3 100 --force
# Install vim python plugin
RUN git clone --recursive https://github.com/davidhalter/jedi-vim.git ~/.vim/pack/plugins/start/jedi-vim
#
# Setup nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh | bash
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
RUN echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm ' >> ~/.zshrc
RUN echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion' >> ~/.zshrc

#
# Setup jabba (jdk env)
RUN curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash && . ~/.jabba/jabba.sh
RUN chmod -R 755 ~/.jabba
RUN ~/.jabba/jabba.sh install openjdk@1.14.0

#
# Setup go 1.17
RUN wget -O $INSTALL_PATH/go1.17.linux-amd64.tar.gz https://golang.org/dl/go1.17.linux-amd64.tar.gz
RUN sudo mkdir /usr/go
RUN sudo tar -C /usr/go -xvf $INSTALL_PATH/go1.17.linux-amd64.tar.gz
RUN sudo update-alternatives --install /usr/bin/go go /usr/go/go/bin/go 100 --force
RUN sudo update-alternatives --install /usr/bin/gofmt gofmt /usr/go/go/bin/gofmt 100 --force
# Install vim go plugin
RUN git clone https://github.com/fatih/vim-go.git ~/.vim/pack/plugins/start/vim-go
RUN vim -c :GoInstallBinaries -c :q

#
# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# Rust analyzer (LSP)
RUN git clone https://github.com/rust-analyzer/rust-analyzer.git $INSTALL_PATH/rust-analyzer
ENV PATH="$PATH:/home/$USERNAME/.cargo/bin"
RUN cd $INSTALL_PATH/rust-analyzer && cargo xtask install --server

#
# LaguageClient-neovim (for LSP)
RUN git clone --depth 1 https://github.com/autozimu/LanguageClient-neovim.git ~/.vim_plugins/language_client_vim
RUN cd ~/.vim_plugins/language_client_vim && ./install.sh
RUN echo "set runtimepath+=~/.vim_plugins/language_client_vim" >> ~/.vim_runtime/my_configs.vim
RUN echo "let g:LanguageClient_serverCommands = {'rust': ['rust-analyzer']}" >> ~/.vim_runtime/my_configs.vim

#
# Install vim FZF plugin
RUN sudo apt install ripgrep -y
RUN git clone https://github.com/junegunn/fzf.git ~/.vim/pack/packages/start/fzf
RUN git clone https://github.com/junegunn/fzf.vim.git ~/.vim/pack/packages/start/fzf.vim
RUN vim -c ':call fzf#install()' -c :q
#
# Install ptpython (python console)
RUN python3 -m pip install ptpython
#
# Install kubectl
RUN bash -c 'sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"'
RUN sudo chmod +x kubectl
RUN sudo mv ./kubectl /usr/bin/kubectl

#
# Add command alias
RUN echo 'alias gittree="git log --oneline --graph --all"' >> ~/.zshrc
RUN echo 'alias ptpython="python3 -m ptpython"' >> ~/.zshrc

COPY --chown=$USERNAME ./HELP /home/$USERNAME/HELP

WORKDIR /home/$USERNAME
ENV LC_ALL=C.UTF-8

#
# Add manual tmux key bind
RUN echo 'bind-key -T copy-mode v send-keys -X begin-selection' >> ~/.tmux.conf
RUN echo 'bind-key -T copy-mode y send-keys -X copy-selection' >> ~/.tmux.conf

# Install w3m (cli browser)
RUN sudo apt install -y w3m w3m-img

#
# Set vim config
RUN echo "set tabstop=4" >> ~/.vim_runtime/my_configs.vim
RUN echo "set expandtab" >> ~/.vim_runtime/my_configs.vim
RUN echo "set shiftwidth=4" >> ~/.vim_runtime/my_configs.vim
RUN echo "let g:snipMate = { 'snippet_version' : 1 }" >> ~/.vim_runtime/my_configs.vim
RUN echo "set number" >> ~/.vim_runtime/my_configs.vim
# PaperColor theme
RUN git clone https://github.com/NLKNguyen/papercolor-theme $INSTALL_PATH/papercolor-theme
RUN mkdir -p ~/.vim/colors
RUN cp $INSTALL_PATH/papercolor-theme/colors/PaperColor.vim ~/.vim/colors/PaperColor.vim
RUN echo "let g:PaperColor_Theme_Options = {'theme': {'default.dark': {'override' : {'linenumber_fg' : ['#ffffff', '255']}}}}" >> ~/.vim_runtime/my_configs.vim
RUN echo "colorscheme PaperColor" >> ~/.vim_runtime/my_configs.vim
RUN echo "vnoremap <C-r> \"hy:%s/<C-r>h//gc<left><left><left>" >> ~/.vim_runtime/my_configs.vim
RUN echo "command! -nargs=* -range RsDef :call LanguageClient_textDocument_definition()" >> ~/.vim_runtime/my_configs.vim


CMD tmux
