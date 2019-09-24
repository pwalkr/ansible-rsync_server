#!/bin/sh

# Start/stop sshd to ensure environment is set up (init script sets things up)
service ssh start
service ssh stop
`which sshd` -D
