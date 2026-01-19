#!/bin/bash
# Script de Carga para Teste do KEDA (Event-Driven)
# Alvo: Analytics Service (via Evaluation -> SQS)

LB_URL="http://k8s-ingressn-ingressn-bac64c4a39-3f32315b195e2bb7.elb.us-east-2.amazonaws.com"

echo "Enchendo a fila SQS para disparar o KEDA..."
echo "Observe os pods subindo no outro terminal."
echo "Pressione CTRL+C para parar."

while true; do 
  curl -s -o /dev/null -X POST "$LB_URL/eval/evaluate?flag_name=minha-flag&user_id=keda_sqs_test"
done