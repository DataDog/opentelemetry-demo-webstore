# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0


FROM registry.ddbuild.io/images/mirror/golang:1.22-alpine AS builder
WORKDIR /usr/src/app/

RUN apk update \
    && apk add --no-cache make protobuf-dev

WORKDIR /usr/src/app

RUN apk update \
    && apk add --no-cache make protobuf-dev

COPY ./src/accountingservice/go.sum tools/go.sum
COPY ./src/accountingservice/go.mod tools/go.mod
COPY ./src/accountingservice/tools.go tools/tools.go

WORKDIR /usr/src/app/tools

RUN go mod download \
    && go list -e -f '{{range .Imports}}{{.}} {{end}}' tools.go | CGO_ENABLED=0 xargs go install -mod=readonly

WORKDIR /usr/src/app/

COPY ./src/accountingservice ./src/accountingservice
COPY ./pb ./pb

RUN protoc -I ./pb ./pb/demo.proto --go_out=./src/accountingservice --go-grpc_out=./src/accountingservice
WORKDIR /usr/src/app/src/accountingservice
RUN go build -ldflags "-s -w" -o /go/bin/accountingservice/ ./



# -----------------------------------------------------------------------------

FROM alpine

WORKDIR /usr/src/app/

COPY --from=builder /go/bin/accountingservice/ ./

ENTRYPOINT [ "./accountingservice" ]
