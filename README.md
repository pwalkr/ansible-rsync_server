[![Build Status](https://travis-ci.org/pwalkr/ansible-rsync_server.svg?branch=master)](https://travis-ci.org/pwalkr/ansible-rsync_server)

# Ansible role for rsync backup server

This provides a client-driven solution to backups. The server runs `rsync`, and
clients will register a key and backup path on the server. After setup, clients
can freely `rsync` to/from their path on the server.

The main tasks simply install rsync and create a folder to be used as the root
for client-specific backups. Example setup with variables and their defaults:

    - include_role:
        name: rsync_server
      vars:
        rss_root: /opt/rsync_server  # root path for client backups
        rss_user: root               # user as which to run

Clients will install a command-restricted ssh key to `rss_user`'s
`authorized_keys` file and create a client-specific subdirectory in `rss_root`.
Running as the default (`root`) will provide the most flexibility for clients
to back up files as any uid/gid and any permissions.

**Important:** the `rss_root` and `rss_user` should be consistent between all
clients using a particular server.

## Clients

Clients install rsync, create an ssh key if necessary, and then register with
the server host. Setup with defaults (or "optional" if not required):

    - include_role:
        name: rsync_server
        tasks_from: client.yml
    - vars:
        client_name:    # name of backup set
        client_key:     # (optional) public key to identify this client
        rss_server:     # the ansible host providing main rsync_server role
        rss_user: root  # user as which the rsync server runs
        rss_root: /opt/rsync_server  # root path to backups on server

If `client_key` is not defined, a `client_name` ssh key will be created and
installed at `~/.ssh/{{ client_name }}`. The public key will be installed to the
server's `authorized_keys`.

### Utilities

**keyscan.yml**: these tasks will scan `rss_server` from the client and install
the keys to client's `known_hosts`. This should be done separately, in an
initial-setup play, to ensure the client will talk to the server (otherwise,
first connection may hang on the prompt to add a new host).

    - include_role:
        name: rsync_server
        tasks_from: keyscan.yml
    - vars:
        rss_server:  # the ansible host providing main rsync_server role
