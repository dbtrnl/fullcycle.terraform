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