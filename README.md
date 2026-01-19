# 🚀 ToggleMaster - Microservices Architecture

> **Tech Challenge - Fase 2 | Pós-Graduação em DevOps & Cloud Computing**

Este repositório contém a implementação completa do **ToggleMaster**, um sistema de gestão de Feature Flags distribuído em microsserviços. O projeto demonstra uma arquitetura *Cloud Native* robusta, focada em escalabilidade híbrida, persistência poliglota e automação de infraestrutura na AWS via Kubernetes (EKS).

---

## 🏛️ Arquitetura da Solução

O sistema foi desenhado para suportar alta demanda de requisições de leitura (avaliação de flags) e ingestão massiva de eventos de auditoria.

### Fluxo de Dados
1. **Ingress (Nginx):** Recebe o tráfego externo via AWS Load Balancer.
2. **Evaluation Service:** Processa a regra da flag (Síncrono).
3. **SQS:** Enfileira o evento de acesso para processamento assíncrono.
4. **Analytics Service:** Consome a fila e persiste no DynamoDB.

---

## 📦 Microsserviços

O projeto segue o padrão **Monorepo**, contendo os seguintes serviços:

| Serviço | Função | Tecnologias Chave |
| :--- | :--- | :--- |
| **🔐 Auth Service** | Gerencia autenticação e emissão de tokens JWT. | Python, JWT |
| **🚩 Flag Service** | CRUD de flags e regras de negócio. | Python, RDS (PostgreSQL) |
| **🎯 Targeting Service** | Gerencia segmentação de usuários. | Python, RDS |
| **⚡ Evaluation Service** | API de alta performance para avaliar flags. | Python, Redis, **HPA (CPU)** |
| **📊 Analytics Service** | Worker assíncrono para processamento de logs. | Python, SQS, DynamoDB, **KEDA** |

---

## ⚙️ Decisões de Arquitetura e Escalabilidade

Um dos principais requisitos deste projeto foi implementar estratégias de auto-scaling eficientes para diferentes cenários de carga.

### 1. HPA (Horizontal Pod Autoscaler) - CPU
Utilizado no **Evaluation Service**.
- **Cenário:** API REST síncrona sensível à latência.
- **Estratégia:** Escala horizontalmente quando o uso médio de CPU dos pods ultrapassa 50%. Garante performance durante picos de tráfego HTTP.

### 2. KEDA (Kubernetes Event-driven Autoscaling) - Eventos
Utilizado no **Analytics Service**.
- **Cenário:** Worker assíncrono consumindo fila SQS.
- **Estratégia:** Escala baseado na métrica de **Lag da Fila (Queue Depth)**. Se a fila acumula mensagens, o KEDA cria novos pods instantaneamente para zerar o backlog, independente do uso de CPU.
- **Configuração:** `minReplica: 1`, `maxReplica: 10`.

---

## 🗄️ Persistência Poliglota (Data Stores)

Utilizamos o conceito de "banco de dados certo para o trabalho certo":

- **🐘 AWS RDS (PostgreSQL):** Dados relacionais, estruturados e críticos (Cadastros de Flags e Usuários).
- **🚀 Amazon ElastiCache (Redis):** Cache de leitura para o Evaluation Service, reduzindo latência e carga no banco relacional.
- **⚡ Amazon DynamoDB:** Banco NoSQL para escrita massiva (High Write Throughput) dos logs de eventos processados pelo Analytics.
- **📨 Amazon SQS:** Desacoplamento entre a API de avaliação e o serviço de análise.

---

## 📂 Estrutura do Repositório

```text
togglemaster-microservices/
├── apps/                    # Código fonte dos microsserviços
│   ├── auth-service/
│   ├── analytics-service/
│   └── ...
│
├── k8s/                     # Manifestos Kubernetes (Infraestrutura)
│   ├── autoscaling/         # Configurações de Escala (KEDA)
│   │   └── analytics-keda.yaml
│   │
│   ├── ingress/             # Entrada de tráfego
│   │   └── main-ingress.yaml
│   │
│   ├── services/            # Deployments e Services das aplicações
│   │   ├── analytics-deployment.yaml
│   │   ├── auth-deployment.yaml
│   │   ├── evaluation-deployment.yaml # (HPA configurado aqui)
│   │   ├── flag-deployment.yaml
│   │   └── targeting-deployment.yaml
│   │
│   ├── 00-namespace.yaml    # Definição do Namespace
│   ├── 01-secrets.yaml      # Credenciais (AWS, Banco)
│   └── 02-configmap.yaml    # Variáveis de ambiente globais
│
├── scripts/                 # Automação de Testes de Carga
│   ├── 02-carga-hpa.sh      # Stress Test para CPU
│   |── 03-carga-keda.sh     # Stress Test para Fila SQS
|   └── ...
│
└── README.md                # Documentação do projeto
