#!/bin/sh

cd /dev/shm/
mkdir -p cache vscode-server kube-cache kube-http-cache
chmod 777 ./*

cd /tmp
mkdir -p ryotana-tmp
chmod 777 ./ryotana-tmp
