# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

FROM registry.ddbuild.io/images/mirror/golang:1.22-alpine AS builder


WORKDIR /usr/src/app/

RUN apk update \
    && apk add --no-cache make protobuf-dev

COPY ./src/productcatalogservice/go.sum tools/go.sum
COPY ./src/productcatalogservice/go.mod tools/go.mod
COPY ./src/productcatalogservice/tools.go tools/tools.go

WORKDIR /usr/src/app/tools

RUN go mod download \
    && go list -e -f '{{range .Imports}}{{.}} {{end}}' tools.go | CGO_ENABLED=0 xargs go install -mod=readonly

WORKDIR /usr/src/app/

COPY ./src/productcatalogservice ./src/productcatalogservice
COPY ./pb ./pb

RUN protoc -I ./pb ./pb/demo.proto --go_out=./src/productcatalogservice --go-grpc_out=./src/productcatalogservice 

WORKDIR /usr/src/app/src/productcatalogservice
RUN go build -ldflags "-s -w" -o /go/bin/productcatalogservice/ ./



FROM registry.ddbuild.io/images/mirror/alpine:latest AS release

WORKDIR /usr/src/app/

COPY ./src/productcatalogservice/products/ ./products/
COPY --from=builder /go/bin/productcatalogservice/ ./

EXPOSE ${PRODUCT_SERVICE_PORT}
ENTRYPOINT [ "./productcatalogservice" ]
