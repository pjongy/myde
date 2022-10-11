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

SHELL ["/bin/bash", "-c"]
#
# Setup download path
ARG INSTALL_PATH=/home/$USERNAME/installed
ENV INSTALL_PATH $INSTALL_PATH
RUN mkdir -p $INSTALL_PATH

#
# Install default setup
RUN sudo apt-get update \
  && sudo apt-get install -y \
    wget git tmux curl vim \
    zip unzip

#
# Setup zsh
RUN sudo apt-get install -y zsh \
  && wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh \
  && sudo chsh -s `which zsh` \
  && zsh -c "source ~/.zshrc" \
  && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
  && sh -c "sudo usermod -s $(which zsh) $(whoami)"

#
# Setup pyenv build prerequisites
ARG DEBIAN_FRONTEND="noninteractive"
RUN sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
RUN sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

#
# Setup pyenv
ARG PYTHON_VERSION_MAJOR=3.9
ARG PYTHON_VERSION=$PYTHON_VERSION_MAJOR.0
RUN sudo git clone https://github.com/pyenv/pyenv.git /opt/.pyenv \
  && /opt/.pyenv/bin/pyenv install $PYTHON_VERSION \
  && sudo update-alternatives --install /usr/bin/python3 python3 $HOME/.pyenv/versions/$PYTHON_VERSION/bin/python3 100 --force \
  && sudo update-alternatives --install /usr/bin/pip3 pip3 $HOME/.pyenv/versions/$PYTHON_VERSION/bin/pip3 100 --force \
  && sudo ln -s /usr/share/pyshared/lsb_release.py $HOME/.pyenv/versions/$PYTHON_VERSION/lib/python$PYTHON_VERSION_MAJOR/site-packages/lsb_release.py
ENV PYENV_ROOT="/opt/.pyenv"
ENV PATH="$PATH:$PYENV_ROOT/bin"
# Install ptpython (python console)
RUN python3 -m pip install ptpython

#
# Setup nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh | bash \
  && echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc \
  && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm ' >> ~/.zshrc \
  && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion' >> ~/.zshrc \
  && source $HOME/.nvm/nvm.sh && nvm install --lts

#
# Setup jabba (jdk env)
RUN curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash && . ~/.jabba/jabba.sh \
  && chmod -R 755 ~/.jabba \
  && ~/.jabba/bin/jabba install openjdk@1.14.0
ENV JAVA_HOME /home/dev/.jabba/jdk/openjdk@1.14.0
ENV PATH="$PATH:$JAVA_HOME/bin"

#
# Install gradle
ENV GRADLE_VERSION 7.1.1
RUN wget -O $INSTALL_PATH/gradle-$GRADLE_VERSION-bin.zip https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip
RUN sudo unzip -d /opt/gradle $INSTALL_PATH/gradle-$GRADLE_VERSION-bin.zip
RUN sudo update-alternatives --install /usr/bin/gradle gradle /opt/gradle/gradle-$GRADLE_VERSION/bin/gradle 100 --force

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
ENV PATH="$PATH:/home/$USERNAME/.cargo/bin"

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
RUN sudo apt-get install -y docker.io docker-compose && pip3 install docker-compose

# Install w3m (cli browser)
RUN sudo apt install -y w3m w3m-img

# Install htop
RUN sudo apt install -y htop

#
# Add httpie (curl alternative)
RUN pip3 install httpie==2.6.0 && sudo apt install -y httpie

#
# Add jless (json cli viewer)
RUN sudo apt install -y libxcb-render0-dev libxcb-shape0-dev libxcb-xfixes0-dev
RUN cargo install jless

#
# Add jellij (tmux alternative)
RUN cargo install zellij

# Install Rg for fzf
RUN sudo apt install ripgrep -y

#
# Add command alias
RUN echo "alias gittree='git log --oneline --graph --all'" >> ~/.zshrc \
  && echo "alias ptpython='python3 -m ptpython'" >> ~/.zshrc



WORKDIR /home/$USERNAME
ENV LC_ALL=C.UTF-8

#
# Install vim-plug
RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

#
# LSP support

# kotlin-language-server
RUN wget -O $INSTALL_PATH/kotlin-lsp.zip https://github.com/fwcd/kotlin-language-server/releases/download/1.3.0/server.zip
# TODO: Update kotlin-language-version after release https://github.com/fwcd/kotlin-language-server/pull/343 (for code action)
RUN sudo unzip -d /opt/kotlin-lsp $INSTALL_PATH/kotlin-lsp.zip
RUN cd /opt/kotlin-lsp/server/bin && sudo curl -sSLO https://github.com/pinterest/ktlint/releases/download/0.45.2/ktlint && sudo chmod a+x ktlint
ENV PATH="$PATH:/opt/kotlin-lsp/server/bin"

# gopls
RUN go install golang.org/x/tools/gopls@latest
ENV PATH="$PATH:/home/$USERNAME/go/bin"

# Rust analyzer (LSP) v2022-05-30
RUN git clone https://github.com/rust-analyzer/rust-analyzer.git $INSTALL_PATH/rust-analyzer
RUN cd $INSTALL_PATH/rust-analyzer && git checkout -b build f94fa62d69faf5bd63b3772d3ec4f0c76cf2db57 && cargo xtask install --server

# typescript-language-server
RUN source ~/.nvm/nvm.sh && nvm exec npm install -g typescript-language-server typescript

# python lsp server (pylsp)
RUN python3 -m pip install "python-lsp-server[all]"

#
# Apply vim customize
## Append vim config
COPY --chown=$USERNAME config/vim/append_vim.conf /home/$USERNAME/append_vim.conf
RUN cat ~/append_vim.conf >> ~/.vimrc \
  && rm -f ~/append_vim.conf
## Install plugins
RUN vim --not-a-term --ttyfail -c :PlugInstall -c :q -c :q \
  && echo "colo seoul256" >> ~/.vimrc
## Add ftplugin for lsc
COPY --chown=$USERNAME config/vim/ftplugin/* /home/$USERNAME/.vim/ftplugin/
### Update python path for global (use # for sed delimiter)
ENV PYTHON_PATH=/home/$USERNAME/.pyenv/versions/$PYTHON_VERSION/bin/python3
RUN sed -i "s#PYTHON_PATH#$PYTHON_PATH#g" /home/$USERNAME/.vim/ftplugin/python.vim
## Install Vim plugin (delay 30 seconds for wait end of installing not sures complete install)
RUN vim --not-a-term | (sleep 30s && kill -9 `pidof vim`)

#
# Add manual tmux key bind
COPY --chown=$USERNAME config/tmux/append_tmux.conf /home/$USERNAME/append_tmux.conf
RUN cat ~/append_tmux.conf >> ~/.tmux.conf \
  && rm -f ~/append_tmux.conf

#
# Add HELP
COPY --chown=$USERNAME ./HELP /home/$USERNAME/HELP

CMD tmux
