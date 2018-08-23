FROM ubuntu:bionic
WORKDIR /app

# Common dependencies.
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --no-install-recommends \
        g++        \
        graphviz   \
        pkg-config \
        zip

# Lua.
ARG LUA=lua5.3
ENV LUA=$LUA
RUN apt-get install --assume-yes --no-install-recommends ${LUA} lib${LUA}-dev

# Build.
COPY . .
RUN LUAC=$(pkg-config --cflags ${LUA}) LUAL=$(pkg-config --libs ${LUA}) make

# Expose and run.
VOLUME /app/output
CMD ${LUA} generate.lua '?'
