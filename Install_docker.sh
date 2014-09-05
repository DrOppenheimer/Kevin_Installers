#!/bin/bash

sudo apt-get install docker.io


# From Wolfgang 8-29-14

#to load qiime image into docker:
sudo bash
curl "http://shock.metagenomics.anl.gov/node/896e56b4-7907-49c3-bbce-8acb7cdda83e?download" | docker.io load
# will take a few minutes...

docker.io images

# command to give image a name, e.g. --tag=qiime:1.8.0
#see "docker help tag"
docker.io help

docker.io tag help

something like: docker tag --tag=qiime:1.8.0
7a917e5ee6f4d3adfc6776ed1e0f6f86f62f13dcc1a81771168aae9dc51c6d0f

# use it 
docker.io run -t -i qiime:1.8.0-amd64u /bin/bash


docker.io run -t -i /bin/bash qiime:1.8.0