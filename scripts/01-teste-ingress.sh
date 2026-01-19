#!/bin/bash
# Teste de Conectividade com o Ingress (Load Balancer AWS)
# Esperado: HTTP 200 OK

LB_URL="http://k8s-ingressn-ingressn-bac64c4a39-3f32315b195e2bb7.elb.us-east-2.amazonaws.com"

echo "Testando acesso ao Evaluation Service via Ingress..."
curl -i -X POST "$LB_URL/eval/evaluate?flag_name=minha-flag&user_id=test_user"

echo -e "\n\nTeste concluído."