#!/bin/bash

# Verifica se os argumentos foram fornecidos
if [ $# -ne 2 ]; then
  echo "Uso: $0 <nome-do-dominio> <caminho-do-projeto>"
  exit 1
fi

DOMAIN=$1
PROJECT_DIR=$2

# Gerar a chave privada
openssl genrsa -out "${PROJECT_DIR}/${DOMAIN}.key" 2048

# Gerar o CSR
openssl req -new -key "${PROJECT_DIR}/${DOMAIN}.key" -out "${PROJECT_DIR}/${DOMAIN}.csr" -subj "/CN=${DOMAIN}"

# Copiar certificados para o diretório necessário (por exemplo, para o diretório do Terraform)
# cp "${PROJECT_DIR}/${DOMAIN}.csr" "${PROJECT_DIR}"
# cp "${PROJECT_DIR}/${DOMAIN}.key" "${PROJECT_DIR}"
