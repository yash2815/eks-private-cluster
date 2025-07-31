#!/bin/bash
echo "Fetching EKS Nodes..."
kubectl get nodes -o wide | awk 'NR==1 || /ip-/{print $1, $6}'
