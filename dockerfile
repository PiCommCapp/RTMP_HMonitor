FROM ubuntu:24.04

LABEL maintainer="Capp"

ARG DEBIAN_FRONTEND="noninteractive"

# common env
ENV \
    MAKEFLAGS="-j4" \
    PATH="/usr/local/bin:${PATH}" \
    HOME="/root" \
    LANGUAGE="en_GB.UTF-8" \
    LANG="en_GB.UTF-8" \
    ARCH="amd64" \
    TERM="xterm" 

RUN \
    mkdir -p /usr/local/bin/rtmpmonitor && \
    chmod 755 /usr/local/bin/rtmpmonitor



COPY ./app /usr/local/bin/rtmpmonitor
WORKDIR /usr/local/bin/rtmpmonitor

RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    apt-utils \
    locales && \
    echo "**** install packages ****" && \
    apt-get install -y \
    catatonit \
    cron \
    curl \
    gnupg \
    jq \
    netcat-openbsd \
    systemd-standalone-sysusers \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    x264 \
    ffmpeg \
    tzdata && \
    echo "**** generate locale ****" && \
    locale-gen en_GB.UTF-8 && \
    echo "**** cleanup ****" && \
    userdel ubuntu && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf \
      /tmp/* \
      /var/lib/apt/lists/* \
      /var/tmp/* \
      /var/log/*

    python3 -m venv venv && \
    pip install -U --no-cache-dir \
    pip \
    setuptools \
    wheel && \
    pip install --no-cache-dir cmake pyyaml pyvimeo 

# The VOLUME instruction creates a mount point with the specified name and
# marks it as holding externally mounted volumes from native host or other
# containers. The value can be a JSON array, VOLUME ["/var/log/"], or a plain
# string with multiple arguments, such as VOLUME /var/log or VOLUME /var/log
# /var/db. 
#
# * The list is parsed as a JSON array, which means that you must use double
#   quotes (") around words not single-quotes (').
#
# VOLUME <mount_point> ...
# VOLUME [ "<mount_point>", ... ]
VOLUME /srv/data

# ARG variables are not persisted into the built image as ENV variables are. However, ARG variables do
# impact the build cache in similar ways.
#
# ARG <name>[=<default value>]
ARG myvar=testval

# The ENV instruction sets the environment variable <key> to the value
# <value>. This value will be in the environment of all "descendent"
# Dockerfile commands and can be replaced inline in many as well.
#
# The environment variables set using ENV will persist when a container
# is run from the resulting image. You can view the values using docker
# inspect, and change them using docker run --env <key>=<value>.
#
# Environment variables can be used in the following instructions:
# * ADD
# * COPY
# * ENV
# * EXPOSE
# * LABEL
# * USER
# * WORKDIR
# * VOLUME
# * STOPSIGNAL
# * ONBUILD (when combined with one of the supported instructions above)
#
# ENV <key> <value>
# ENV <key>=<value> ...
ENV ENV_VAR "value"

# The EXPOSE instructions informs Docker that the container will listen on
# the specified network ports at runtime. Docker uses this information to
# interconnect containers using links (see the Docker User Guide) and to
# determine which ports to expose to the host when using the -P flag.
#
# EXPOSE <port> [<port>...]
EXPOSE 80

# The SHELL instruction allows the default shell used for the shell form of commands
# to be overridden. The default shell on Linux is ["/bin/sh", "-c"], and on
# Windows is ["cmd", "/S", "/C"]. The SHELL instruction must be written in JSON
# form in a Dockerfile.
#
# The SHELL instruction can appear multiple times. Each SHELL instruction overrides
# all previous SHELL instructions, and affects all subsequent instructions.
#
# SHELL ["executable", "parameters"]
SHELL ["/bin/sh", "-c"]

# The ADD instruction copies new files, directories or remote file URLs from
# <src> and adds them to the filesystem of the container at the path <dest>.
#
# Multiple <src> resource may be specified but if they are files or
# directories then they must be relative to the source directory that is
# being built (the context of the build).
#
# Each <src> may contain wildcards and matching will be done using Go's
# filepath.Match rules.
#
# The <dest> is an absolute path, or a path relative to WORKDIR, into
# which the source will be copied inside the destination container.
#
# All new files and directories are created with a UID and GID of 0.
#
# In the case where <src> is a remote file URL, the destination will have
# permissions of 600. If the remote file being retrieved has an HTTP
# Last-Modified header, the timestamp from that header will be used to set
# the mtime on the destination file.
#
# The copy obeys the following rules:
#
# * The <src> path must be inside the context of the build; you cannot
#   ADD ../something /something, because the first step of a docker build
#   is to send the context directory (and subdirectories) to the docker daemon.
#
# * If <src> is a URL and <dest> does not end with a trailing slash, then a
#   file is downloaded from the URL and copied to <dest>.
#
# * If <src> is a URL and <dest> does end with a trailing slash, then the
#   filename is inferred from the URL and the file is downloaded to
#   <dest>/<filename>. For instance, ADD http://example.com/foobar / would
#   create the file /foobar. The URL must have a nontrivial path so that an
#   appropriate filename can be discovered in this case (http://example.com
#   will not work).
#
# * If <src> is a directory, the entire contents of the directory are copied,
#   including filesystem metadata.
#   - Note: The directory itself is not copied, just its contents.
#
# * If <src> is a local tar archive in a recognized compression format
#   (identity, gzip, bzip2 or xz) then it is unpacked as a directory.
#   Resources from remote URLs are not decompressed. When a directory is
#   copied or unpacked, it has the same behavior as tar -x: the result is
#   the union of:
#   - Whatever existed at the destination path and
#   - The contents of the source tree, with conflicts resolved in favor
#     of "2." on a file-by-file basis.
#
# * If <src> is any other kind of file, it is copied individually along with
#   its metadata. In this case, if <dest> ends with a trailing slash /, it
#   will be considered a directory and the contents of <src> will be written
#   at <dest>/base(<src>).
#
# * If multiple <src> resources are specified, either directly or due to the
#   use of a wildcard, then <dest> must be a directory, and it must end with
#   a slash /.
#
# * If <dest> does not end with a trailing slash, it will be considered a
#   regular file and the contents of <src> will be written at <dest>.
#
# * If <dest> doesn't exist, it is created along with all missing directories
#   in its path.
#
# ADD <src>... <dest>
# ADD ["<src>"... "<dest>"] (this form is required for paths containing
#                            whitespace)
ADD src/file.cpp /usr/include/mylib/file.cpp

# The ONBUILD instruction adds to the image a trigger instruction to be
# executed at a later time, when the image is used as the base for another
# build. The trigger will be executed in the context of the downstream build,
# as if it had been inserted immediately after the FROM instruction in the
# downstream Dockerfile.
#
# How it works:
#
# * When it encounters an ONBUILD instruction, the builder adds a trigger
#   to the metadata of the image being built. The instruction does not
#   otherwise affect the current build.
# * At the end of the build, a list of all triggers is stored in the image
#   manifest, under the key OnBuild. They can be inspected with the docker
#   inspect command.
# * Later the image may be used as a base for a new build, using the FROM
#   instruction. As part of processing the FROM instruction, the downstream
#   builder looks for ONBUILD triggers, and executes them in the same order
#   they were registered. If any of the triggers fail, the FROM instruction
#   is aborted which in turn causes the build to fail. If all triggers
#   succeed, the FROM instruction completes and the build continues as usual.
# * Triggers are cleared from the final image after being executed. In other
#   words they are not inherited by "grand-children" builds.
#
# * Chaining ONBUILD instructions using ONBUILD ONBUILD isn't allowed.
# * The ONBUILD instruction may not trigger FROM or MAINTAINER instructions.
#
# ONBUILD [INSTRUCTION]
ONBUILD RUN /usr/sbin/nologin

# The COPY instruction copies new files or directories from <src> and adds
# them to the filesystem of the container at the path <dest>.
#
# Multiple <src> resource may be specified but they must be relative to the
# source directory that is being built (the context of the build).
#
# Each <src> may contain wildcards and matching will be done using Go's
# filepath.Match rules.
#
# The <dest> is an absolute path, or a path relative to WORKDIR, into which
# the source will be copied inside the destination container.
#
# All new files and directories are created with a UID and GID of 0.
#
# The copy obeys the following rules:
#
# * The <src> path must be inside the context of the build; you cannot
#   COPY ../something /something, because the first step of a docker build
#   is to send the context directory (and subdirectories) to the docker
#   daemon.
#
# * If <src> is a directory, the entire contents of the directory are copied,
#   including filesystem metadata.
#   - Note: The directory itself is not copied, just its contents.
#
# * If <src> is any other kind of file, it is copied individually along with
#   its metadata. In this case, if <dest> ends with a trailing slash /, it
#   will be considered a directory and the contents of <src> will be written
#   at <dest>/base(<src>).
#
# * If multiple <src> resources are specified, either directly or due to the
#   use of a wildcard, then <dest> must be a directory, and it must end with
#   a slash /.
#
# * If <dest> does not end with a trailing slash, it will be considered a
#   regular file and the contents of <src> will be written at <dest>.
#
# * If <dest> doesn't exist, it is created along with all missing directories
#   in its path.
#
# COPY <src>... <dest>
# COPY ["<src>"... "<dest>"] (this form is required for paths containing
#                             whitespace)
COPY src/file.cpp /usr/include/mylib/file.cpp

# The RUN instruction will execute any commands in a new layer on top of
# the current image and commit the results. The resulting committed image
# will be used for the next step in the Dockerfile.
#
# The exec form makes it possible to avoid shell string munging, and to
# RUN commands using a base image that does not contain /bin/sh.
#
# * To use a different shell, other than '/bin/sh', use the exec form
#   passing in the desired shell. For example, RUN ["/bin/bash", "-c",
#   "echo hello"]
# * The exec form is parsed as a JSON array, which means that you must
#   use double-quotes (") around words not single-quotes (').
# * The exec form does not invoke a command shell. This means that normal
#   shell processing like variable substitution does not happen.
#
# Note: To use a different shell, other than ‘/bin/sh’, use the exec form
#       passing in the desired shell. For example, RUN ["/bin/bash", "-c", "echo hello"]
# Note: The exec form is parsed as a JSON array, which means that you must
#       use double-quotes (“) around words not single-quotes (‘).
# Note: Unlike the shell form, the exec form does not invoke a command shell.
#       This means that normal shell processing does not happen. For example,
#       RUN [ "echo", "$HOME" ] will not do variable substitution on $HOME.
#       If you want shell processing then either use the shell form or execute a
#       shell directly, for example: RUN [ "sh", "-c", "echo $HOME" ].
# Note: In the JSON form, it is necessary to escape backslashes. This is particularly
#       relevant on Windows where the backslash is the path separator. The following line
#       would otherwise be treated as shell form due to not being valid JSON, and fail in an
#       unexpected way: RUN ["c:\windows\system32\tasklist.exe"] The correct syntax for this
#       example is: RUN ["c:\\windows\\system32\\tasklist.exe"]
#
# RUN <command> (the command is run in a shell - /bin/sh -c - shell form)
# RUN ["executable", "param1", "param2"] (exec form)
RUN /usr/sbin/nologin

# The WORKDIR instruction sets the working directory for any RUN, CMD,
# ENTRYPOINT, COPY and ADD instructions that follow it in the Dockerfile.
#
# It can be used multiple times in the one Dockerfile. If a relative path
# is provided, it will be relative to the path of the previous WORKDIR
# instruction.
#
# WORKDIR <path>
WORKDIR /path/to/workdir

# The USER instruction sets the user name or UID to use when running the
# image and for any RUN, CMD and ENTRYPOINT instructions that follow it in
# the Dockerfile.
#
# USER <username>
USER nobody

# An ENTRYPOINT allows you to configure a container that will run as an
# executable.
#
# * You can over ride the ENTRYPOINT setting using --entrypoint, but this
#   can only set the binary to exec (no sh -c will be used).
# * The exec form is parsed as a JSON array, which means that you must
#   use double-quotes (") around words not single-quotes (').
# * The exec form does not invoke a command shell. This means that normal
#   shell processing like variable substitution does not happen.
#
# ENTRYPOINT ["executable", "param1", "param2"] (the preferred exec form)
# ENTRYPOINT command param1 param2 (shell form)
ENTRYPOINT top -b

# There can only be one CMD instruction in a Dockerfile. If you list more
# than one CMD then only the last CMD will take effect.
#
# The main purpose of a CMD is to provide defaults for an executing container.
# These defaults can include an executable, or they can omit the executable,
# in which case you must specify an ENTRYPOINT instruction as well.
#
# Note: If CMD is used to provide default arguments for the ENTRYPOINT instruction,
#       both the CMD and ENTRYPOINT instructions should be specified with the
#       JSON array format.
# Note: The exec form is parsed as a JSON array, which means that you must
#       use double-quotes (“) around words not single-quotes (‘).
# Note: Unlike the shell form, the exec form does not invoke a command shell.
#       This means that normal shell processing does not happen. For example,
#       CMD [ "echo", "$HOME" ] will not do variable substitution on $HOME.
#       If you want shell processing then either use the shell form or execute a
#       shell directly, for example: CMD [ "sh", "-c", "echo $HOME" ].
#
# If you would like your container to run the same executable every time,
# then you should consider using ENTRYPOINT in combination with CMD. 
#
# CMD ["executable","param1","param2"] (exec form, this is the preferred form)
# CMD ["param1","param2"] (as default parameters to ENTRYPOINT)
# CMD command param1 param2 (shell form)
CMD /usr/bin/default_cmd

# Both CMD and ENTRYPOINT instructions define what command gets executed when
# running a container. There are few rules that describe their co-operation.
#
# 1. Dockerfile should specify at least one of CMD or ENTRYPOINT commands.
# 2. ENTRYPOINT should be defined when using the container as an executable.
# 3. CMD should be used as a way of defining default arguments for an ENTRYPOINT command
#    or for executing an ad-hoc command in a container.
# 4. CMD will be overridden when running the container with alternative arguments.

# The STOPSIGNAL instruction sets the system call signal that will be sent to the container to exit.
# This signal can be a valid unsigned number that matches a position in the kernel’s syscall table,
# for instance 9, or a signal name in the format SIGNAME, for instance SIGKILL.
#
# STOPSIGNAL signal
STOPSIGNAL SIGTERM

# The HEALTHCHECK instruction tells Docker how to test a container to check that it is still working.
# This can detect cases such as a web server that is stuck in an infinite loop and unable to handle new
# connections, even though the server process is still running.
#
# When a container has a healthcheck specified, it has a health status in addition to its normal status.
# This status is initially 'starting'. Whenever a health check passes, it becomes 'healthy' (whatever state it
# was previously in). After a certain number of consecutive failures, it becomes 'unhealthy'.
#
# The options that can appear before CMD are:
#
# * --interval=DURATION (default: 30s)
# * --timeout=DURATION (default: 30s)
# * --retries=N (default: 3)
#
# The health check will first run 'interval' seconds after the container is started, and then again
# 'interval' seconds after each previous check completes.
#
# If a single run of the check takes longer than 'timeout' seconds then the check is considered to have failed.
#
# It takes 'retries' consecutive failures of the health check for the container to be considered 'unhealthy'.
#
# There can only be one HEALTHCHECK instruction in a Dockerfile. If you list more than one then only the last
# HEALTHCHECK will take effect.
#
# The command’s exit status indicates the health status of the container. The possible values are:
#
# * 0: success - the container is healthy and ready for use
# * 1: unhealthy - the container is not working correctly
# * 2: reserved - do not use this exit code
#
# To help debug failing probes, any output text (UTF-8 encoded) that the command writes on stdout or
# stderr will be stored in the health status and can be queried with docker inspect. Such output should be kept
# short (only the first 4096 bytes are stored currently).
#
# When the health status of a container changes, a health_status event is generated with the new status.
#
# HEALTHCHECK [OPTIONS] CMD command (check container health by running a command inside the container)
# HEALTHCHECK NONE (disable any healthcheck inherited from the base image)
HEALTHCHECK --interval=15 --timeout=60 --retries=5 CMD [ "/usr/bin/my_health_check_script", "arg_1" ]