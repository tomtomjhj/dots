# docker build -t texlive --build-arg USER_NAME=$USER --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) .
# docker run --rm -it --detach-keys='ctrl-s,ctrl-q' -v $(pwd):$HOME --name texlive texlive bash

# based on https://github.com/dante-ev/docker-texlive
FROM registry.gitlab.com/islandoftex/images/texlive:latest

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=dumb

WORKDIR /home

RUN mkdir -p /usr/share/man/man1

RUN apt-get update -q

RUN apt-get install -qqy -o=Dpkg::Use-Pty=0 git curl wget
RUN apt-get install -qqy -o=Dpkg::Use-Pty=0 bibtool
# RUN apt-get install -qqy -o=Dpkg::Use-Pty=0 ghostscript fig2ps
# RUN apt-get install -qqy -o=Dpkg::Use-Pty=0 graphviz
# RUN apt-get install -qqy -o=Dpkg::Use-Pty=0 inkscape

RUN curl -s https://api.github.com/repos/jgm/pandoc/releases/latest | grep -o "https.*amd64.deb" | wget -O pandoc.deb -qi - && \
    dpkg -i pandoc.deb && rm pandoc.deb

RUN apt-get --purge remove -qy .\*-doc$ && \
    rm -rf /var/lib/apt/lists/* && apt-get clean

ARG USER_NAME
ARG USER_ID
ARG GROUP_ID
RUN addgroup --gid $GROUP_ID $USER_NAME
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID $USER_NAME
USER $USER_NAME
WORKDIR /home/$USER_NAME
