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