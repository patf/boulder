#!/bin/bash
#
# Fetch dependencies of Boulderthat are necessary for development or testing,
# and configure database and RabbitMQ.
#

set -ev

go get \
  github.com/golang/lint/golint \
  github.com/golang/mock/mockgen \
  github.com/golang/protobuf/proto \
  github.com/golang/protobuf/protoc-gen-go \
  github.com/jcjones/github-pr-status \
  github.com/jsha/listenbuddy \
  github.com/kisielk/errcheck \
  github.com/mattn/goveralls \
  github.com/modocache/gover \
  github.com/tools/godep \
  golang.org/x/tools/cmd/stringer \
  golang.org/x/tools/cover &

(wget https://github.com/jsha/boulder-tools/raw/master/goose.gz &&
 mkdir -p $GOPATH/bin &&
 zcat goose.gz > $GOPATH/bin/goose &&
 chmod +x $GOPATH/bin/goose &&
 ./test/create_db.sh) &

(curl -sL https://github.com/google/protobuf/releases/download/v2.6.1/protobuf-2.6.1.tar.gz | \
 tar -xzv &&
 cd protobuf-2.6.1 && ./configure --prefix=$HOME && make && make install) &

# Set up rabbitmq exchange
go run cmd/rabbitmq-setup/main.go -server amqp://boulder-rabbitmq &

# Wait for all the background commands to finish.
wait
