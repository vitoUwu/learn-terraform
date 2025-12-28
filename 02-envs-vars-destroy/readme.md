# 02 AWS Backend & Lock

Explorado o conceito de environments/workspaces do terraform, backend para state files e .tfvars para diferentes ambientes.
Criamos uma pipeline padrão que será usado por outras pipelines, pois temos uma de development e outra de production, ou seja, menos código duplicado e manutenção facilitada.

O roteiro é o seguinte:

1. Commit na branch "develop"
2. Workflow de develop.yml se inicia rodando a pipeline principal, apenas com inputs diferentes.
3. Configuramos credenciais da AWS.
4. Validamos
5. Planejamos
6. Aplicamos

E ta tudo certo. O interessante é que, por padrão o Terraform salva o state file localmente, ou seja, numa pipeline o state file é sempre perdido e criado novamente, o Terraform nunca sabe do estado atual da infraestrutura.

Pra solucionar, vamos usar um bucket s3 para salvar o estado atual de cada ambiente, assim o Terraform sabe exatamente como a infraestrutura está atualmente, e assim consegue planejar melhor as alterações.

Outro problema que ocorreria em um time maior seriam os commits paralelos, imagina que uma pipeline acabou de iniciar, e ai... Opa! outro commit, outra pipeline rodando, mas ainda não atualizei o estado com a pipeline antiga, isso causaria um probleminha ai, então usamos o DynamoDB como um lock, então sempre que uma pipeline está rodando e entra outra logo em seguida não teremos mais esse problema, pois com o lock a pipeline só continua depois que a primeira terminar de fazer suas coisas.
