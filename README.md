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
        rss_server:     # the ansible host providing main rsync_server role
        rss_user: root  # user as which the rsync server runs
        rss_root: /opt/rsync_server  # root path to backups on server

An ssh key will be created and installed at `~/.ssh/{{ client_name }}` on the
client, and the public key will be installed to the server's `authorized_keys`
with `command=` restriction.

### Utilities

#### backup.yml

Install a simple backup script to backup folder to server. `script_dest` can
then be called periodically by cron or systemd timer.

    - include_role:
        name: rsync_server
        tasks_from: backup.yml
      vars:
        script_dest: /usr/local/bin/backup-app.sh
        src: /opt/app/  # Path on client. Mind the trailing slash
        dest: /         # Path on server, relative to root of client's folder
        presync: []     # optional array of shell commands to run before backup
        postsync: []    # optional array of shell commands to run after backup

#### keyscan.yml

These tasks will scan `rss_server` from the client and install the keys to
client's `known_hosts`. This should be done separately, in an initial-setup
play, to ensure the client will talk to the server (otherwise, first connection
may hang on the prompt to add a new host).

    - include_role:
        name: rsync_server
        tasks_from: keyscan.yml

#### sync.yml

Include for each folder the client backs up to run an initial sync for
provisioning new systems. The tasks will only sync if the destination is empty
or does not exist.

    - include_role:
        name: rsync_server
        tasks_from: sync.yml
      vars:
        src: /          # Path on server, relative to root of client's folder
        dest: /opt/app  # Path on client
