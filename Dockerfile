FROM ubuntu:26.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Use the image's built-in `ubuntu` user (uid 1000), so bind mounts and
# Kubernetes `runAsUser: 1000` line up with it.
RUN mkdir /nix && chown ubuntu /nix

USER ubuntu

ENV USER=ubuntu

RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

ENV PATH="/home/ubuntu/.nix-profile/bin:${PATH}"

COPY --chown=ubuntu:ubuntu . /home/ubuntu/nix-config

WORKDIR /home/ubuntu/nix-config

ENV NIX_CONFIG="experimental-features = nix-command flakes"

# packages/base.nix brings its own nix, which collides with the one the
# installer put into the profile; drop that one first and switch using the
# installer's binary straight from the store.
RUN arch=$(dpkg --print-architecture) \
    && nix_bin=$(dirname "$(readlink -f "$(command -v nix)")") \
    && { "$nix_bin/nix-env" --uninstall nix || "$nix_bin/nix" profile remove nix; } \
    && "$nix_bin/nix" run home-manager -- switch -b backup --impure --flake ".#$USER@docker-$arch"

# Single-user Nix needs no daemon; just keep the container alive for
# `docker compose exec`. Kubernetes agent pods override the command anyway.
CMD ["sleep", "infinity"]
