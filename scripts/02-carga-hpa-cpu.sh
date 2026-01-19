#!/bin/bash
# Script de Carga para Teste de HPA (CPU)
# Alvo: Evaluation Service

LB_URL="http://k8s-ingressn-ingressn-bac64c4a39-3f32315b195e2bb7.elb.us-east-2.amazonaws.com"

echo "Iniciando carga massiva para estressar CPU..."
echo "Pressione CTRL+C para parar."

while true; do 
  curl -s -o /dev/null -X POST "$LB_URL/eval/evaluate?flag_name=minha-flag&user_id=hpa_cpu_test"
done