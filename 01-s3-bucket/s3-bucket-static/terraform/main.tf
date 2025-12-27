// Declaração do Provedor de nuvem. Nesse caso usando AWS mas poderia ser GCP, Azure, etc.
provider "aws" {
  region = "us-east-1"
}

// Variável reutilizável para o nome do bucket, fazendo com que modificações sejam feitas em um único lugar.
// Quando a variável é declarada no arquivo terraform.tfvars, ela é passada como argumento para o terraform apply.
variable "bucket_name" {
  type = string
}

// Declaração do recurso do bucket. Aqui estamos declarando a criação do bucket S3.
// Resource são "entidades sólidas" ou serviços de um provider, ec2, s3, etc.
// resource <RESOURCE_TYPE> <RESOURCE_NAME>
resource "aws_s3_bucket" "static_site_bucket" {
  bucket = "static-site-${var.bucket_name}"

  // Tags são metadados que podem ser usados para identificar o recurso. Nesse caso, identificar buckets s3 no console da AWS.
  tags = {
    Name = "static-site-${var.bucket_name}"
    Environment = "Production"
  }
}

// Agora vamos definir a configuração do bucket para servir arquivos estáticos.
resource "aws_s3_bucket_website_configuration" "static_site_bucket" {
  bucket = aws_s3_bucket.static_site_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

// Agora vamos definir acessos ao bucket recém criado.
resource "aws_s3_bucket_public_access_block" "static_site_bucket" {
  // Com o recurso anterior criado, podemos usar a referência desse recurso para acessar seus dados.
  // Nesse caso, estamos acessando o ID do bucket criado anteriormente.
  bucket = aws_s3_bucket.static_site_bucket.id

  // Configuração para bloquear o acesso público ao bucket.
  block_public_acls = false
  // Configuração para bloquear a política pública do bucket.
  block_public_policy = false
  // Configuração para ignorar o acesso público ao bucket.
  ignore_public_acls = false
  // Configuração para restringir o acesso público aos buckets.
  restrict_public_buckets = false
  
}

// Agora vamos definir o controle de propriedade do bucket.
resource "aws_s3_bucket_ownership_controls" "static_site_bucket" {
  bucket = aws_s3_bucket.static_site_bucket.id

  // Esse tipo de recurso requer um bloco de "Rule" para funcionar. Cada recurso pede diferentes
  // tipos de configurações, algumas opcionais e outras obrigatórias.
  rule {
    // Configuração para definir o proprietário do objeto.
    // "BucketOwnerPreferred" define que o proprietário do objeto será o proprietário do bucket.
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "static_site_bucket" {
  bucket = aws_s3_bucket.static_site_bucket.id

  // Configuração para definir o ACL do bucket.
  // "public-read" define que o bucket será público e os arquivos serão acessíveis publicamente.
  acl = "public-read"

  // Dependências são recursos que devem ser criados antes do recurso atual.
  // Por padrão o terraform cria os recursos de forma inteligente, ele infere
  // as dependências automaticamente e cria um recurso de cada vez.
  // Mas em alguns casos queremos definir a ordem explicitamente, por conta de que
  // no recurso atual, não temos uma referência clara para outros recursos, então
  // podemos declarar que dependemos de outros recursos para que o terraform crie o recurso atual.
  depends_on = [
    aws_s3_bucket_public_access_block.static_site_bucket,
    aws_s3_bucket_ownership_controls.static_site_bucket,
  ]
}