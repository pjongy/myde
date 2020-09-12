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
# Setup python3.8 (alias to python3, pip3)
ARG PYTHON=python3.8
RUN sudo apt-get install -y \
    $PYTHON \
    ${PYTHON}-distutils \
    python3-pip \
    ${PYTHON}-dev
RUN sudo mv $(which $PYTHON) $(dirname $(which $PYTHON))/python3
RUN alias pip3="python3.8 -m pip"
RUN sudo apt-get install -y zsh
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
RUN sudo chsh -s `which zsh`
RUN zsh -c "source ~/.zshrc"
RUN cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
RUN echo "zsh" >> ~/.bashrc

#
# Setup vim plugin
RUN sudo apt-get install -y \
    exuberant-ctags \
    ack-grep \
    vim
RUN sudo pip3 install pynvim flake8 pylint isort
RUN sudo wget https://raw.githubusercontent.com/fisadev/fisa-vim-config/a9824ee8ce2689b6b89e9fef863dd9109c7f385d/.vimrc && sudo mv .vimrc ~/.vimrc
RUN vim -E -s -u "~/.vimrc" +PlugInstall +qall > /dev/null



WORKDIR /myde

CMD tmux
