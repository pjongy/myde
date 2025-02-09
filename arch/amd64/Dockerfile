# Dockerfile
FROM ubuntu:24.04

ARG USERNAME=dev
ENV USERNAME=$USERNAME
ARG USER_UID=1001
ARG USER_GID=$USER_UID
ARG HOME_PATH=/home/$USERNAME
ENV HOME_PATH=$HOME_PATH

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
ENV INSTALL_PATH=$INSTALL_PATH
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
RUN sudo git clone https://github.com/pyenv/pyenv.git /opt/.pyenv
RUN sudo update-alternatives --install /usr/bin/pyenv pyenv /opt/.pyenv/bin/pyenv 100 --force

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
RUN sudo unzip -d /opt/gradle $INSTALL_PATH/gradle-$GRADLE_VERSION-bin.zip
RUN sudo update-alternatives --install /usr/bin/gradle gradle /opt/gradle/gradle-$GRADLE_VERSION/bin/gradle 100 --force

#
# Setup sdkman (jdk env)
RUN curl -s https://get.sdkman.io | bash
RUN echo "export JAVA_HOME=$HOME_PATH/.sdkman/candidates/java/current" >> ~/.zshrc
RUN echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> ~/.zshrc

#
# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="$PATH:/home/$USERNAME/.cargo/bin"


#
# Install languages
COPY --chown=$USERNAME arch/amd64/installer/* $INSTALL_PATH/installer/
RUN $INSTALL_PATH/installer/python.sh \
  && $INSTALL_PATH/installer/go.sh \
  && $INSTALL_PATH/installer/node.sh \
  && $INSTALL_PATH/installer/jdk.sh \
  && $INSTALL_PATH/installer/rust.sh \
  && $INSTALL_PATH/installer/dart.sh

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
# Install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o $INSTALL_PATH/awscliv2.zip \
  && chmod 755 $INSTALL_PATH/awscliv2.zip \
  && unzip $INSTALL_PATH/awscliv2.zip -d $INSTALL_PATH/awscli \
  && sudo $INSTALL_PATH/awscli/aws/install

#
# Install docker
RUN curl -fsSL https://get.docker.com/ | sudo sh

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
# Add ouch (CLI tool for compressing and decompressing for various formats)
RUN cargo install ouch

# Install Rg for fzf
RUN sudo apt install ripgrep -y

#
# Add command alias
RUN echo "alias gittree='git log --oneline --graph --all'" >> ~/.zshrc



WORKDIR /home/$USERNAME
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
RUN sudo unzip -d /opt/kotlin-lsp $INSTALL_PATH/kotlin-lsp.zip
RUN cd /opt/kotlin-lsp/server/bin && sudo curl -sSLO https://github.com/pinterest/ktlint/releases/download/0.45.2/ktlint && sudo chmod a+x ktlint
ENV PATH="$PATH:/opt/kotlin-lsp/server/bin"


#
# Apply vim customize
## Append vim config
COPY --chown=$USERNAME config/vim/append_vim.conf /home/$USERNAME/append_vim.conf
RUN cat ~/append_vim.conf >> ~/.vimrc \
  && rm -f ~/append_vim.conf
## Install plugins
RUN vim --not-a-term --ttyfail -c :PlugInstall -c :q -c :q
RUN echo "colo seoul256" >> ~/.vimrc
## Add ftplugin for lsc
COPY --chown=$USERNAME config/vim/ftplugin/* /home/$USERNAME/.vim/ftplugin/
COPY --chown=$USERNAME config/vim/after/plugin/* /home/$USERNAME/.vim/after/plugin/
## Install Vim plugin (delay 30 seconds for wait end of installing not sures complete install)
RUN vim --not-a-term | (sleep 30s && kill -9 `pidof vim`)
## Install vim-gitgutter plugin
RUN mkdir -p ~/.vim/pack/airblade/start && cd ~/.vim/pack/airblade/start && git clone https://github.com/airblade/vim-gitgutter.git

#
# Add manual tmux key bind
COPY --chown=$USERNAME config/tmux/append_tmux.conf /home/$USERNAME/append_tmux.conf
RUN cat ~/append_tmux.conf >> ~/.tmux.conf \
  && rm -f ~/append_tmux.conf

#
# Add HELP
COPY --chown=$USERNAME ./HELP /home/$USERNAME/HELP

CMD TERM="xterm-256color" tmux
