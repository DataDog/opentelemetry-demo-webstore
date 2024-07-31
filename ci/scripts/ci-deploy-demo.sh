#!/usr/bin/env bash

# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

# This script is used to deploy collector on demo account cluster

set -euo pipefail
IFS=$'\n\t'
set -x

clusterName=$CLUSTER_NAME
clusterArn=$CLUSTER_ARN
region=$REGION
namespace=$NAMESPACE
nodeGroup=$NODE_GROUP
values=$VALUES
zookeeper_deployment=$ZOOKEEPER_DEPLOYMENT
orderproducer_deployment=$ORDERPRODUCER_DEPLOYMENT
registry=$REGISTRY

install_demo() {
  release_name="opentelemetry-demo"

  helm uninstall ${release_name} -n ${namespace}
  
  # HELM COMMAND
  helm_cmd="helm --debug upgrade ${release_name} -n ${namespace} open-telemetry/opentelemetry-demo --install \
    -f ./ci/demo-values/values.yaml \
    --set-string default.image.tag="v$CI_COMMIT_SHORT_SHA" \
    --set-string default.image.repository=${REGISTRY}"

  # REPLACEMENTS
  if [ -n "$nodeGroup" ]; then
      sed -i "s/PLACEHOLDER_NODE_GROUP/$nodeGroup/g" ./src/zookeeperservice/${zookeeper_deployment}
      sed -i "s/PLACEHOLDER_NODE_GROUP/$nodeGroup/g" ./src/orderproducerservice/${orderproducer_deployment}
      helm_cmd+=" --set default.schedulingRules.nodeSelector.\"alpha\\.eksctl\\.io/nodegroup-name\"=${nodeGroup}"
  fi
  if [ -n "$values" ]; then
      helm_cmd+=" -f $values"
  fi

  # COMMANDS
  kubectl apply -f ./src/zookeeperservice/${zookeeper_deployment} -n "${namespace}"
  helm --debug repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
  eval $helm_cmd
  kubectl apply -f ./src/orderproducerservice/${orderproducer_deployment} -n "${namespace}"
}

###########################################################################################################

aws eks --region "${region}" update-kubeconfig --name "${clusterName}"
kubectl config use-context "${clusterArn}"

install_demo