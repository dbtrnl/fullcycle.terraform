# fullcycle.terraform

- Desenvolvido em Golang.
- Feito para *provisionar* a infraestrutura
  - VPC, subnet, usergroups, gateway, requisitos de segurança, etc tb são atendidos
  - É multiprovider, funciona com AWS, Google, com cluster Kubernetes, etc

- Idempotência > não realizar novamente operações que já foram feitas
  - Recurso não é criado/comando não é executado se nada foi alterado

- Infra criada de forma *imperativa* (step by step) é complexo
- Terraform é *declarativo*, o YAML é o "resultado final", e o Terraform que se preocupa em
  entregar o resultado final.

## Terraform vs Ansible
*Ansible* - Foco em gerenciamento e automação de configurações
*Terraform* - Foco em provisionar infraestrutura
- É possível fazer ações AWS e mexer com cluster Kubernetes com Ansible
- Há algum overlap entre as ferramentas, mas o Ansible não é tão bom para provisionamento de infra
- É comum usar *ambos em conjunto*

## Gerenciamento de estado
- Terraform sempre mantém um registro do estado e faz comparações para saber o que deve ser criado/alterado
  - Arquivo de *state* é importante, pois sem ele, toda a infra começa a ser provisionada do zero, mesmo que já exista.
  - Importante ver o *plano de ação*
  - Todos os membros do time devem ter o arquivo atualizado pra não dar ruim

## Providers
`registry.terraform.io`

---

## Instalação
- Adicionar chave gpg, repo APT e instalar.

---

## Usando
- Arquivos são feitos com Hashicorp Configuration Language (HCL), que tem semelhanças com JSON
- Iniciar com `terraform init`, irá baixar providers listados nos arquivos **.tf** do projeto
  - Então é criado um arquivo de *lock* e os providers são baixados na pasta *.terraform*

Para aplicar as configurações:
`terraform plan` mostra o plano de ação
`terraform apply` aplica o plano (depois de uma nova etapa de confirmação)

Arquivo **terraform.tfstate** tem o estado atual da infra (com vários tipos de hashes pros resources)

Se algum arquivo for alterado, o Terraform dá um *destroy* e recria o arquivo (ao invés de só editar)
  - Ao alterar, *tfstate* antigo é salvo como *terraform.tfstate.backup*

## Setando variáveis
- Variável vazia pode ser definida com *variable teste {}* e referenciada com *var.teste*
  - Na hora do apply, o valor da var deve ser fornecido

Outra formas de definir variáveis  
- Arquivo **terraform.tfvars** e definir variáveis lá (esse aqruivo é lido por default)
- Bash: exportar variáveis de ambiente prefixo `TF_VAR_` que elas serão aplicadas automaticamente
  - Ou `terraform apply -var "minha_var=teste"`
- Criar arquivo com outro nome (*teste.tfvars*) e passar como parâmetro: `terraform apply -var-file teste.tfvars`

## Data sources
- É o que lê as informações criadas por um *resource* (ou alguma outra informação que já exista)
  - No caso do `local_file`, existe o resource e o data source.

---

# Fundamentos AWS
## VPC
- *Subnets* criadas dentro da VPC podem estar em AZ (*Availability Zones*) diferentes
- **Subnet default é tudo público**
  - Com subnets o aproveitamento dos IPs é melhor
  - É possível definir quais subnets se comunicam com quais, e quais tem acesso à internet, etc
  - Subnet privada não pode ser acessada publicamente (apenas com uma VPN)
- *Route table* - 1 ou mais tabelas de roteamento para uma VPC, falando quais subnets estão associadas
  - IGT (Internet Gateway) - Permite o acesso público
  - *Security Group* para deixar a VPC segura
    - Políticas de Ingress e Egress
      - Ingress determina quem e como acessa a subnet
      - Egress determina quais redes externas os serviços dentro da subnet acessam
- Cluster k8s pode ser criado em uma subnet XYZ com determinadas regras
  - MySQL pode estar em uma subnet privada, e a aplicaçao backend em uma subnet pública

- No módulo será criado uma VPC com 2 subnets, 1 route table e 1 security group

- VPC default (em 2021, na época do video) criava 6 subnets para as 6 AZs do *us-east-1*
  - IPs disponíveis 4091, pq alguns são reservados pela própria AWS (broadcast, etc)
  - [CIDR Blocks](https://aws.amazon.com/pt/what-is/cidr/) p/ entender o range de IPs das subnets
  - Ex: 172.31.0.0/16
    - /16 é a máscara, significa que 0.0 será a subrede?
    - /16 é sempre a máscara 255.255.0.0 ?? 
      - .255.254 ips disponíveis (1 reservado para broadcast) - total = 65536
    - [Calculadora](www.calculator.net/ip-subnet-calculator.html)
    - [Calculadora](https://jodies.de/ipcalc) usada na aula - Calcular com 172.31.0.0/16/20
    - Subnets da VPC da aula:
      - 172.31.0.0/20
      - 172.31.64.0/20
      - 172.31.16.0/20
      - 172.31.32.0/20
      - 172.31.48.0/20
      - 172.31.80.0/20
    - Com máscara de 20, o cálculo resulta em 4094 IPs e não 4091 (então 3 são reservados pela AWS) e permite *16 subnets*

- *Route table default* tem destination local e também destination *0.0.0.0/0* com target *igw-0dea4d77*
  - Significa que qualquer destino tem acesso, e o target é o *Internet gateway* - Ou seja, todas as subnets estão expostas à internet
- *Security Group default* permite todo o tráfego - Qualquer protocolo, qualquer porta, tanto *inbound* quanto *outbound*

---

## Criando user admin na AWS
Não consigo fazer conta AWS (sem cartão de crédito), então foda-se.
Só fazer anotações e anotar o código. `terraform plan` ou `init` não funcionam com provider AWS sem credenciais (erro é bem didático)

- Criou user com *"Programmatic access"* e *"AWS Management console access"*
  - Ao invés de colocar o user num grupo, só deu o *AdministratorAccess*

## Criando o Terraform
- provider AWS usado era 3.54.0, versão atual (Nov/2023) é 5.24.0
  - Versão Terraform >0.13 (exemplos antigos). Versão atual = 1.4.0
  - Criar template básico e dar `terraform init` para baixar providers