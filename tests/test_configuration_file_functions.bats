load 'libs/bats-assert/load'
load 'libs/bats-support/load'

source tests/fixtures.sh

source lib/sipfw-common.sh

@test "read_configuration_success_correct_syntax" {
    CONFIGURATION_FILE=$(fake_configuration_file_ok)
    run read_conf
    assert_success
    rm ${CONFIGURATION_FILE}
}

@test "read_configuration_must_fail_with_wrong_syntax" {
    CONFIGURATION_FILE=$(fake_configuration_file_wrong_syntax)
    run read_conf
    assert_failure
    assert_output --partial 'syntax error'
    rm ${CONFIGURATION_FILE}
}

@test "read_configuration_must_fail_with_inexistent_file" {
    CONFIGURATION_FILE=none
    run read_conf
    assert_failure
    assert_output --partial 'Erro ao ler configuração'
}