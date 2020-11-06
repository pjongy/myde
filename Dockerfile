# Dockerfile
FROM ubuntu:latest

ARG USERNAME=dev
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
RUN echo "zsh" >> ~/.bashrc

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
RUN sudo update-alternatives --install /usr/bin/python3 python3 $HOME/.pyenv/versions/$PYTHON_VERSION/bin/python3 100
RUN sudo update-alternatives --install /usr/bin/pip3 pip3 $HOME/.pyenv/versions/$PYTHON_VERSION/bin/pip3 100

#
# Setup vim plugin
RUN sudo apt-get install -y \
    vim
RUN git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
RUN sh ~/.vim_runtime/install_awesome_vimrc.sh
RUN git clone https://github.com/fatih/vim-go.git ~/.vim/pack/plugins/start/vim-go

#
# Setup openjdk 14
ARG INSTALL_PATH=/home/$USERNAME/installed
RUN mkdir -p $INSTALL_PATH
RUN wget -O $INSTALL_PATH/openjdk-14.tar.gz https://download.java.net/java/GA/jdk14/076bab302c7b4508975440c56f6cc26a/36/GPL/openjdk-14_linux-x64_bin.tar.gz
RUN sudo mkdir /usr/java
RUN sudo tar -xvf $INSTALL_PATH/openjdk-14.tar.gz -C /usr/java/
RUN sudo update-alternatives --install /usr/bin/java java /usr/java/jdk-14/bin/java 100
RUN sudo update-alternatives --install /usr/bin/javac javac /usr/java/jdk-14/bin/javac 100

#
# Setup go 1.15
RUN wget -O $INSTALL_PATH/go1.15.3.linux-amd64.tar.gz https://golang.org/dl/go1.15.3.linux-amd64.tar.gz
RUN sudo mkdir /usr/go
RUN sudo tar -C /usr/go -xvf $INSTALL_PATH/go1.15.3.linux-amd64.tar.gz
RUN sudo update-alternatives --install /usr/bin/go go /usr/go/go/bin/go 100
RUN sudo update-alternatives --install /usr/bin/gofmt gofmt /usr/go/go/bin/gofmt 100

WORKDIR /home/$USERNAME
ENV LC_ALL=C.UTF-8

CMD tmux
