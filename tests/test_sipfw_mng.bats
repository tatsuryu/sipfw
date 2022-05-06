load 'libs/bats-assert/load'
load 'libs/bats-support/load'

source tests/fixtures.sh

source lib/sipfw-common.sh
source bin/sipfw_mng

setup(){
    CF=$(fake_configuration_file_ok)
}

teardown(){
    rm ${CF}
}

@test "ip_already_exists_should_fail_when_duplicate" {
    run ip_already_exists 10.1.1.2 10.2.2.1 10.3.2.1 10.1.1.2

    assert_failure
    assert_output --partial "IP já existe! (10.1.1.2)"
}

@test "add_sip_should_increment_clients_array" {
    CONFIGURATION_FILE=${CF}

    run main add_sip provider1 10.1.1.1
    run main add_sip provider2 10.1.1.2
    run cat ${CONFIGURATION_FILE}

    assert_output --partial "PROVIDER1,10.1.1.1"
    assert_output --partial "PROVIDER2,10.1.1.2"
}

@test "add_sip_should_cause_error_when_duplicate_ip" {
    CONFIGURATION_FILE=${CF}

    run main add_sip provider1 10.1.1.1
    run main add_sip provider2 10.1.1.1

    assert_failure
    assert_output --partial "IP já existe!"
}

@test "rm_sip_should_fail_when_removing_inexistent" {
    CONFIGURATION_FILE=${CF}

    run main rm_sip provider1

    assert_failure
    assert_output --partial "provider1 nao encontrado"
}

@test "rm_sip_should_remove_all_entries_for_a_client" {
    CONFIGURATION_FILE=${CF}

    run main add_sip provider1 10.1.1.1
    run main add_sip provider1 10.1.1.2
    run main add_sip provider2 10.1.1.3
    
    run main rm_sip provider1

    assert_success

    run cat ${CONFIGURATION_FILE}

    assert_output --partial "PROVIDER2,10.1.1.3"
    refute_output --partial "PROVIDER1"
    
}

@test "add_management_should_increment_management_array" {
    CONFIGURATION_FILE=${CF}

    run main add_management it 10.1.1.1
    run main add_management it 10.1.1.2
    run cat ${CONFIGURATION_FILE}

    assert_output --partial "IT,10.1.1.1"
    assert_output --partial "IT,10.1.1.2"
}

@test "add_management_should_cause_error_when_duplicate_ip" {
    CONFIGURATION_FILE=${CF}

    run main add_sip it 10.1.1.1
    run main add_sip it 10.1.1.1

    assert_failure
    assert_output --partial "IP já existe!"
}

@test "rm_management_should_remove_specific_ip" {
    CONFIGURATION_FILE=${CF}

    run main add_management it 10.1.1.1
    run main add_management it 10.1.1.2
    run main rm_management 10.1.1.2
    run cat ${CONFIGURATION_FILE}

    assert_output --partial "IT,10.1.1.1"
    refute_output --partial "IT,10.1.1.2"
}

@test "rm_management_should_fail_when_removing_inexistent_ip" {
    CONFIGURATION_FILE=${CF}

    run main rm_management 10.1.1.2

    assert_failure
    assert_output --partial "10.1.1.2 nao encontrado"
}

@test "add_mng_port_should_increment_management_ports_array" {
    CONFIGURATION_FILE=${CF}

    run main add_mng_port 80
    run main add_mng_port 22
    run cat ${CONFIGURATION_FILE}

    assert_output --partial "22"
    assert_output --partial "80"
}

@test "rm_mng_port_should_remove_from_management_ports_array" {
    CONFIGURATION_FILE=${CF}

    run main add_mng_port 80
    run main rm_mng_port 80
    run cat ${CONFIGURATION_FILE}

    refute_output --partial "80"
}

@test "rm_mng_port_should_fail_when_removing_inexistent" {
    CONFIGURATION_FILE=${CF}

    run main rm_mng_port 80

    assert_failure
    assert_output --partial "porta 80 nao encontrada"
}

@test "add_pvt_should_increment_private_networks_array" {
    CONFIGURATION_FILE=${CF}

    run main add_pvt 198.18.0.0/15
    run main add_pvt 198.18.0.0/15
    run cat ${CONFIGURATION_FILE}

    assert_output --partial "198.18.0.0/15"
}

@test "add_pvt_should_remove_from_private_networks_array" {
    CONFIGURATION_FILE=${CF}

    run main rm_pvt 198.18.0.0/15
    run cat ${CONFIGURATION_FILE}

    refute_output --partial "198.18.0.0/15"
}

@test "rm_pvt_should_fail_when_removing_inexistent" {
    CONFIGURATION_FILE=${CF}

    run main rm_pvt 198.18.0.0/15

    assert_failure
    assert_output --partial "endereco 198.18.0.0/15 nao encontrado"
}

@test "apply_action_should_call_svc_restart" {
    CONFIGURATION_FILE=${CF}
    SIPFW_SVC="echo called"

    run main apply

    assert_success
    assert_output "called restart"
}