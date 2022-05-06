load 'libs/bats-assert/load'
load 'libs/bats-support/load'

source bin/sipfw

@test "sip_should_create_rule_allowing_sip" {
    CLIENTS=( "CLIENT1,10.0.0.1" )
    IPTABLES=echo

    run sip_rules
    assert_success
    assert_output --partial "-p udp --dport 5060"
    assert_output --partial "--comment CLIENT1"
}

@test "management_should_accept_all_when_no_ports" {
    MANAGEMENT=( "PROVIDER1,10.0.0.1" )
    MANAGEMENT_PORTS=()
    IPTABLES=echo

    run management_rules
    assert_success
    assert_output --partial "--comment PROVIDER1"
    refute_output --partial "--dport"
}

@test "management_should_use_multiport_when_multiple_ports" {
    MANAGEMENT=( "PROVIDER1,10.0.0.1" )
    MANAGEMENT_PORTS=( 22 80 )
    IPTABLES=echo

    run management_rules
    assert_success
    assert_output --partial "--comment PROVIDER1"
    assert_output --partial "-m multiport --dports"
}

@test "management_should_not_use_multiport_when_single_port" {
    MANAGEMENT=( "PROVIDER1,10.0.0.1" )
    MANAGEMENT_PORTS=( 22 )
    IPTABLES=echo

    run management_rules
    assert_success
    assert_output --partial "--comment PROVIDER1"
    assert_output --partial "--dport 22"
    refute_output --partial "-m multiport --dports"
}