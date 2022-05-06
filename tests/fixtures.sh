fake_configuration_file_wrong_syntax(){
    local filename;

    filename=$(mktemp -u)
    cat <<EOF >${filename}
PRIVATE_NETWORKS=()
MANAGEMENT_PORTS=(
MANAGEMENT=()
CLIENTS=()
EOF
    echo ${filename}
}

fake_configuration_file_ok(){
    local filename;

    filename=$(mktemp -u)
    cat <<EOF >${filename}
PRIVATE_NETWORKS=()
MANAGEMENT_PORTS=()
MANAGEMENT=()
CLIENTS=()
EOF
    echo ${filename}
}