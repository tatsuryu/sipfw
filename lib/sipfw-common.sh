#!/usr/bin/env bash
#
# Auxiliary funtions to sipfw
#

read_conf(){
    source ${CONFIGURATION_FILE} || {
        err "Erro ao ler configuração" >&2
        return 1
    }
}

write_conf() {
  cat > ${CONFIGURATION_FILE} <<EOC
PRIVATE_NETWORKS=( `echo ${PRIVATE_NETWORKS[@]} \
  | sed -r 's/(^| )/\n\t/g' \
  | sort \
  | uniq`
)

MANAGEMENT_PORTS=( `echo ${MANAGEMENT_PORTS[@]} \
  | sed -r 's/(^| )/\n\t/g' \
  | sort \
  | uniq`
)

MANAGEMENT=( `echo ${MANAGEMENT[@]} | sed -r 's/(^| )/\n\t/g' | sort`
)

CLIENTS=( `echo ${CLIENTS[@]} | sed -r 's/(^| )/\n\t/g' | sort`
)
EOC
}

err() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}
