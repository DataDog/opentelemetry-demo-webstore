#!/usr/bin/env bash

# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

# This script is used to deploy collector on demo account cluster

set -euo pipefail
IFS=$'\n\t'
set -x

clusterName=$1
clusterArn=$2
namespace=$3
install_agent() {
  # Set the namespace and release name
  release_name="datadog-agent"

  # if repo already exists, helm 3+ will skip
  helm --debug repo add datadog https://helm.datadoghq.com

  # --install will run `helm install` if not already present.
  helm --debug upgrade "${release_name}" -n "${namespace}" datadog/datadog --install \
    -f ./ci/datadog-agent-values.yaml --set datadog.apiKey=$DD_API_KEY

}

###########################################################################################################

aws eks --region us-east-1 update-kubeconfig --name "${clusterName}"
kubectl config use-context "${clusterArn}"

install_agent