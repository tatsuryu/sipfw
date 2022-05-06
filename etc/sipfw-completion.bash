#!/usr/bin/env/bash
_dothis_completions(){
    local WORDS
    WORDS="add_management rm_management "
    WORDS+="add_pvt rm_pvt "
    WORDS+="add_sip rm_sip "
    WORDS+="show"

    if [ "${#COMP_WORDS[@]}" != "2" ]; then
        return 0
    fi

    COMPREPLY=(
        $(compgen -W "${WORDS}" "${COMP_WORDS[1]}")
    )
}

complete -F _dothis_completions sipfw_mng
