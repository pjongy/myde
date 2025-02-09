# Dockerfile
FROM --platform=linux/arm64/v8 ubuntu:24.04

SHELL ["/bin/bash", "-c"]

# NOTE: because of qemu buildx issue with amd64 build system, user should be root

#
# Setup download path
ARG INSTALL_PATH=/root/installed
ARG HOME_PATH=/root
ENV INSTALL_PATH=$INSTALL_PATH
ENV HOME_PATH=$HOME_PATH
RUN mkdir -p $INSTALL_PATH

#
# Install default setup
RUN apt-get update
RUN apt-get install -y \
    wget git tmux curl vim \
    zip unzip

#
# Setup zsh
RUN apt-get install -y zsh \
  && wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh \
  && chsh -s `which zsh` \
  && zsh -c "source ~/.zshrc" \
  && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
  && sh -c "usermod -s $(which zsh) $(whoami)"

#
# Setup pyenv build prerequisites
ARG DEBIAN_FRONTEND="noninteractive"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
RUN apt-get install -y make build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

#
# Setup pyenv
RUN git clone https://github.com/pyenv/pyenv.git /opt/.pyenv
RUN update-alternatives --install /usr/bin/pyenv pyenv /opt/.pyenv/bin/pyenv 100 --force

#
# Setup nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh | bash \
  && echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc \
  && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm ' >> ~/.zshrc \
  && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion' >> ~/.zshrc

#
# Install gradle
ENV GRADLE_VERSION=7.1.1
RUN wget -O $INSTALL_PATH/gradle-$GRADLE_VERSION-bin.zip https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip
RUN unzip -d /opt/gradle $INSTALL_PATH/gradle-$GRADLE_VERSION-bin.zip
RUN update-alternatives --install /usr/bin/gradle gradle /opt/gradle/gradle-$GRADLE_VERSION/bin/gradle 100 --force

#
# Setup sdkman (jdk env)
RUN curl -s https://get.sdkman.io | bash
RUN echo "export JAVA_HOME=$HOME_PATH/.sdkman/candidates/java/current" >> ~/.zshrc
RUN echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> ~/.zshrc

#
# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="$PATH:$HOME_PATH/.cargo/bin"


#
# Install languages
COPY --chown=$USERNAME arch/arm/installer/* $INSTALL_PATH/installer/
RUN $INSTALL_PATH/installer/python.sh \
  && $INSTALL_PATH/installer/go.sh \
  && $INSTALL_PATH/installer/node.sh \
  && $INSTALL_PATH/installer/jdk.sh \
  && $INSTALL_PATH/installer/rust.sh \
  && $INSTALL_PATH/installer/dart.sh

#
# Install kubectl
RUN bash -c 'curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"' \
  && chmod +x kubectl \
  && mv ./kubectl /usr/bin/kubectl

#
# Install kafkactl
RUN wget -O $INSTALL_PATH/kafkactl_1.24.0_linux_arm64.deb  https://github.com/deviceinsight/kafkactl/releases/download/v1.24.0/kafkactl_1.24.0_linux_arm64.deb \
  && dpkg -i $INSTALL_PATH/kafkactl_1.24.0_linux_arm64.deb

#
# Install natscli
RUN wget -O $INSTALL_PATH/natscli-0.0.28-arm64.deb https://github.com/nats-io/natscli/releases/download/v0.0.28/nats-0.0.28-arm64.deb \
  && dpkg -i $INSTALL_PATH/natscli-0.0.28-arm64.deb

#
# Install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o $INSTALL_PATH/awscliv2.zip \
  && chmod 755 $INSTALL_PATH/awscliv2.zip \
  && unzip $INSTALL_PATH/awscliv2.zip -d $INSTALL_PATH/awscli \
  && $INSTALL_PATH/awscli/aws/install

#
# Install docker
RUN curl -fsSL https://get.docker.com/ | sh

# Install w3m (cli browser)
RUN apt install -y w3m w3m-img

# Install htop
RUN apt install -y htop

#
# Add httpie (curl alternative)
RUN pip3 install httpie==2.6.0 && apt install -y httpie

#
# Add jless (json cli viewer)
RUN apt install -y libxcb-render0-dev libxcb-shape0-dev libxcb-xfixes0-dev
RUN cargo install jless

#
# Add ouch (CLI tool for compressing and decompressing for various formats)
RUN cargo install ouch

#
# Add jellij (tmux alternative)
RUN cargo install zellij

# Install Rg for fzf
RUN apt install ripgrep -y

#
# Add command alias
RUN echo "alias gittree='git log --oneline --graph --all'" >> ~/.zshrc \
  && echo "alias ptpython='python3 -m ptpython'" >> ~/.zshrc



WORKDIR $HOME_PATH
ENV LC_ALL=C.UTF-8

#
# Install vim-plug
RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

#
# independent LSP support

# kotlin-language-server
RUN wget -O $INSTALL_PATH/kotlin-lsp.zip https://github.com/fwcd/kotlin-language-server/releases/download/1.3.0/server.zip
# TODO: Update kotlin-language-version after release https://github.com/fwcd/kotlin-language-server/pull/343 (for code action)
RUN unzip -d /opt/kotlin-lsp $INSTALL_PATH/kotlin-lsp.zip
RUN cd /opt/kotlin-lsp/server/bin && curl -sSLO https://github.com/pinterest/ktlint/releases/download/0.45.2/ktlint && chmod a+x ktlint
ENV PATH="$PATH:/pot/kotlin-lsp/server/bin"

#
# Apply vim customize
## Append vim config
COPY config/vim/append_vim.conf $HOME_PATH/append_vim.conf
RUN cat ~/append_vim.conf >> ~/.vimrc \
  && rm -f ~/append_vim.conf
## Install plugins
RUN vim --not-a-term --ttyfail -c :PlugInstall -c :q -c :q
RUN echo "colo seoul256" >> ~/.vimrc
## Add ftplugin for lsc
COPY config/vim/ftplugin/* $HOME_PATH/.vim/ftplugin/
COPY config/vim/after/plugin/* $HOME_PATH/.vim/after/plugin/
## Install Vim plugin (delay 30 seconds for wait end of installing not sures complete install)
RUN vim --not-a-term | (sleep 30s && kill -n 9 `pgrep vim`)
## Install vim-gitgutter plugin
RUN mkdir -p ~/.vim/pack/airblade/start && cd ~/.vim/pack/airblade/start && git clone https://github.com/airblade/vim-gitgutter.git

#
# Add manual tmux key bind
COPY config/tmux/append_tmux.conf $HOME_PATH/append_tmux.conf
RUN cat ~/append_tmux.conf >> ~/.tmux.conf \
  && rm -f ~/append_tmux.conf

#
# Add HELP
COPY ./HELP $HOME_PATH/HELP

CMD TERM="xterm-256color" tmux
