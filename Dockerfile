FROM ubuntu

RUN apt update
RUN apt install -y curl xz-utils

RUN useradd -m zero
RUN mkdir /nix && chown zero /nix

USER zero

ENV USER=zero

RUN curl -L https://nixos.org/nix/install | sh

ENV PATH="/home/zero/.nix-profile/bin:${PATH}"

COPY --chown=zero:zero . /home/zero/nix-config

WORKDIR /home/zero/nix-config

RUN sh scripts/install-home-manager.sh
