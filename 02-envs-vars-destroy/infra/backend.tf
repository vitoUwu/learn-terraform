terraform {
  // Estamos definindo um backend para o Terraform armazenar o estado atual da infraestrutura (State Files).
  // Por padrão os state files são armazenados localmente no diretório .terraform.
  // porém como queremos rodar uma pipeline usando Github Actions, precisamos armazenar o estado em outro local.
  // Nesse caso vamos usar um bucket S3 para fazer o armazenamento desse estado, assim em cada pipeline que rodar,
  // o estado da infraestrutura estará disponível para todos os pipelines.
  // Por enquanto só vamos definir o backend, e ele será configurado em tempo de execução da pipeline.
  backend "s3" {}
}
