FROM jare/alpine-vim:latest

# User config
ENV UID="1000" \
    UNAME="developer" \
    GID="1000" \
    GNAME="developer" \
    SHELL="/bin/bash" \
    UHOME=/home/developer

RUN apk update


RUN apk --no-cache add sudo \
# Create HOME dir
    && mkdir -p "${UHOME}" \
    && chown "${UID}":"${GID}" "${UHOME}" \
# Create user
    && echo "${UNAME}:x:${UID}:${GID}:${UNAME},,,:${UHOME}:${SHELL}" \
    >> /etc/passwd \
    && echo "${UNAME}::17032:0:99999:7:::" \
    >> /etc/shadow \
# No password sudo
    && echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" \
    > "/etc/sudoers.d/${UNAME}" \
    && chmod 0440 "/etc/sudoers.d/${UNAME}" \
# Create group
    && echo "${GNAME}:x:${GID}:${UNAME}" \
    >> /etc/group

# Vim plugins deps
RUN apk --update add \
    bash \
    ctags \
    curl \
    git \
    ncurses-terminfo \
    python \
    cmake \
# Vundle
#    && git clone https://github.com/VundleVim/Vundle.vim.git $UHOME/.vim/bundle/Vundle.vim \
# YouCompleteMe
    && apk add --virtual build-deps \
    build-base \
    #go \
    llvm \
    #perl \
    python-dev \
    python3-dev \
# flake 8
    && pip3 install --upgrade pip \
    && pip3 install flake8 \
    #&& git clone --depth 1  https://github.com/Valloric/YouCompleteMe \
    #$UHOME/bundle/YouCompleteMe/ \
    #&& cd $UHOME/bundle/YouCompleteMe \
    #&& git submodule update --init --recursive \
    #&& $UHOME/bundle/YouCompleteMe/install.py --clang-completer \
    #&& $UHOME/bundle/YouCompleteMe/install.py --gocode-completer \
# Cleanup
#    && apk del build-deps \
    && apk add \
    libxt \
    libx11 \
    libstdc++ \
    && rm -rf \
    /var/cache/* \
    /var/log/* \
    /var/tmp/* \
    && mkdir /var/cache/apk

# Install vim-plug
#RUN apk --no-cache add curl \
#    && mkdir -p \
RUN apk --no-cache add curl \
    && mkdir -p \
    $UHOME/bundle \
    $UHOME/.vim/autoload \
    $UHOME/.vim/plugged \
#    $UHOME/.vim_runtime/temp_dirs \
    && curl -LSso \
    $UHOME/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    ##&& echo "" > $UHOME/.vimrc \
    && curl -LSso \
    $UHOME/.vimrc \
    "https://raw.githubusercontent.com/dfd/vim_files/master/.vimrc" \
    &&  curl -LSso \
    $UHOME/.vim/colors/nightsky.vim --create-dirs \
    "https://raw.githubusercontent.com/dfd/vim_files/master/nightsky.vim" \
    && chown $UID:$GID -R $UHOME/.vim/plugged \
    && chown $UID:$GID -R $UHOME \
    && apk del curl


# Vim wrapper
COPY run /usr/local/bin/
#custom .vimrc stub
RUN mkdir -p /ext  && echo " " > /ext/.vimrc

#COPY .vimrc $UHOME/my.vimrc
#COPY plug.vimrc $UHOME/plug.vimrc
#COPY final.vimrc $UHOME/final.vimrc
#COPY nightsky.vim $UHOME/.vim/colors/

#RUN cat $UHOME/plug.vimrc \
#     >> $UHOME/.vimrc 
#RUN  cat  $UHOME/final.vimrc \
#     >> $UHOME/.vimrc \
#     && rm $UHOME/plug.vimrc \
#     && rm $UHOME/final.vimrc

USER $UNAME



RUN vim +PlugInstall +qall
ENV TERM=xterm-256color

# List of Vim plugins to disable
ENV DISABLE=""

ENTRYPOINT ["sh", "/usr/local/bin/run"]

# sudo docker build -t python_dev_env .
# sudo docker run -ti --rm -v $(pwd):/home/developer/workspace python_dev_env
