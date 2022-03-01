# Dockerfile
FROM ubuntu:22.04

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
RUN sudo apt-get update \
  && sudo apt-get install -y \
    wget git tmux curl vim

#
# Setup zsh
RUN sudo apt-get install -y zsh \
  && wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh \
  && sudo chsh -s `which zsh` \
  && zsh -c "source ~/.zshrc" \
  && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
  && sh -c "sudo usermod -s $(which zsh) $(whoami)"
#
# Setup vim plugin
RUN git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime \
  && sh ~/.vim_runtime/install_awesome_vimrc.sh

#
# Setup pyenv build prerequisites
ARG DEBIAN_FRONTEND="noninteractive"
RUN sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
RUN sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

#
# Setup pyenv
ARG PYTHON_VERSION=3.9.0
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv \
  && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc \
  && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc \
  && $HOME/.pyenv/bin/pyenv install $PYTHON_VERSION \
  && sudo update-alternatives --install /usr/bin/python3 python3 $HOME/.pyenv/versions/$PYTHON_VERSION/bin/python3 100 --force \
  && sudo update-alternatives --install /usr/bin/pip3 pip3 $HOME/.pyenv/versions/$PYTHON_VERSION/bin/pip3 100 --force
# Install vim python plugin
RUN git clone --recursive https://github.com/davidhalter/jedi-vim.git ~/.vim/pack/plugins/start/jedi-vim
# Install ptpython (python console)
RUN python3 -m pip install ptpython

#
# Setup nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh | bash \
  && echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc \
  && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm ' >> ~/.zshrc \
  && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion' >> ~/.zshrc

#
# Setup jabba (jdk env)
RUN curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash && . ~/.jabba/jabba.sh \
  && chmod -R 755 ~/.jabba \
  && ~/.jabba/jabba.sh install openjdk@1.14.0

#
# Install vim-plug
RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

#
# Setup go 1.17
RUN wget -O $INSTALL_PATH/go1.17.linux-amd64.tar.gz https://golang.org/dl/go1.17.linux-amd64.tar.gz \
  && sudo mkdir /usr/go \
  && sudo tar -C /usr/go -xvf $INSTALL_PATH/go1.17.linux-amd64.tar.gz \
  && sudo update-alternatives --install /usr/bin/go go /usr/go/go/bin/go 100 --force \
  && sudo update-alternatives --install /usr/bin/gofmt gofmt /usr/go/go/bin/gofmt 100 --force

#
# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# Rust analyzer (LSP)
RUN git clone https://github.com/rust-analyzer/rust-analyzer.git $INSTALL_PATH/rust-analyzer
ENV PATH="$PATH:/home/$USERNAME/.cargo/bin"
RUN cd $INSTALL_PATH/rust-analyzer && cargo xtask install --server

#
# Dart
RUN sudo apt-get install -y apt-transport-https \
  && sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -' \
  && sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
RUN sudo apt-get update \
  && sudo apt-get install -y dart

#
# Install kubectl
RUN bash -c 'sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"' \
  && sudo chmod +x kubectl \
  && sudo mv ./kubectl /usr/bin/kubectl

#
# Install kafkactl
RUN wget -O $INSTALL_PATH/kafkactl_1.24.0_linux_amd64.deb  https://github.com/deviceinsight/kafkactl/releases/download/v1.24.0/kafkactl_1.24.0_linux_amd64.deb \
  && sudo dpkg -i $INSTALL_PATH/kafkactl_1.24.0_linux_amd64.deb

#
# Install natscli
RUN wget -O $INSTALL_PATH/natscli-0.0.28-amd64.deb https://github.com/nats-io/natscli/releases/download/v0.0.28/nats-0.0.28-amd64.deb \
  && sudo dpkg -i $INSTALL_PATH/natscli-0.0.28-amd64.deb

#
# Install docker
RUN sudo apt-get install -y docker.io

#
# Add command alias
RUN echo "alias gittree='git log --oneline --graph --all'" >> ~/.zshrc \
  && echo "alias ptpython='python3 -m ptpython'" >> ~/.zshrc

COPY --chown=$USERNAME ./HELP /home/$USERNAME/HELP

WORKDIR /home/$USERNAME
ENV LC_ALL=C.UTF-8

# Install w3m (cli browser)
RUN sudo apt install -y w3m w3m-img

# Install htop
RUN sudo apt install -y htop

# Install Rg for fzf
RUN sudo apt install ripgrep -y

#
# Apply vim customize
## Install PaperColor vim theme
RUN git clone https://github.com/NLKNguyen/papercolor-theme $INSTALL_PATH/papercolor-theme
RUN mkdir -p ~/.vim/colors
RUN cp $INSTALL_PATH/papercolor-theme/colors/PaperColor.vim ~/.vim/colors/PaperColor.vim
## Append vim config
COPY --chown=$USERNAME ./append_vim.conf /home/$USERNAME/append_vim.conf
RUN cat ~/append_vim.conf >> ~/.vim_runtime/my_configs.vim \
  && rm -f ~/append_vim.conf
## Install vim plug
RUN vim --not-a-term --ttyfail -c :PlugInstall -c :q -c :q
RUN vim --not-a-term --ttyfail -c :GoInstallBinaries -c :q -c :q

#
# Add manual tmux key bind
COPY --chown=$USERNAME ./append_tmux.conf /home/$USERNAME/append_tmux.conf
RUN cat ~/append_tmux.conf >> ~/.tmux.conf \
  && rm -f ~/append_tmux.conf

CMD tmux
