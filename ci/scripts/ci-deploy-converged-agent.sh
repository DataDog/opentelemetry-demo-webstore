#!/usr/bin/env bash

# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

# This script is used to deploy collector on demo account cluster

set -euo pipefail
IFS=$'\n\t'

clusterName=$CLUSTER_NAME
clusterArn=$CLUSTER_ARN
region=$REGION
namespace=$NAMESPACE
releaseName=$RELEASE_NAME
nodegroup=$NODE_GROUP

install_agent() {
  # if repo already exists, helm 3+ will skip
  helm repo add datadog https://helm.datadoghq.com

  # --install will run `helm install` if not already present.
  helm_cmd="helm --debug upgrade "${releaseName}" -n "${namespace}" datadog/datadog --install \
    -f ./ci/converged-agent-values/values.yaml \
    --set datadog.tags=env:"${namespace}" \
    --set agents.nodeSelector.\"alpha\\.eksctl\\.io/nodegroup-name\"=${nodegroup} \
    --set agents.image.doNotCheckTag=true"

  eval $helm_cmd
}

###########################################################################################################

aws eks --region "${region}" update-kubeconfig --name "${clusterName}"
kubectl config use-context "${clusterArn}"

install_agent
