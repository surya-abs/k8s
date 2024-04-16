#!/bin/bash

namespace="monitoring"

# Create the monitoring namespace
kubectl create namespace $namespace

# Add Prometheus Helm chart repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus and Grafana using Helm in the specified namespace
helm install prometheus prometheus-community/kube-prometheus-stack -n $namespace

# Wait for a few seconds to allow the resources to be created
sleep 10

namespace="monitoring"

# Get the NodePort of the Prometheus service
prometheus_node_port=$(kubectl get svc -n $namespace prometheus-kube-prometheus-prometheus -o jsonpath="{.spec.ports[0].nodePort}")

# Get the NodePort of the Grafana service
grafana_node_port=$(kubectl get svc -n $namespace prometheus-grafana -o jsonpath="{.spec.ports[0].nodePort}")

# Get the IP address of one of your nodes (assuming your cluster has at least one node)
node_ip=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}")

# Display information for accessing Prometheus and Grafana
echo "Prometheus is accessible at: http://${node_ip}:${prometheus_node_port}"
echo "Grafana is accessible at: http://${node_ip}:${grafana_node_port}"

# Optionally, open Prometheus and Grafana in the default browser
# Uncomment the following lines if you want to open the services in the default browser
#xdg-open "http://${node_ip}:${prometheus_node_port}"
#xdg-open "http://${node_ip}:${grafana_node_port}"

# Change the Prometheus service to NodePort in the specified namespace
kubectl patch svc -n $namespace prometheus-kube-prometheus-prometheus --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]'

# Change the Grafana service to NodePort in the specified namespace
kubectl patch svc -n $namespace prometheus-grafana --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]'
