#! /bin/bash


function validatePositiveInteger() {

    if  [[ $1 =~ ^[0-9]+$ ]] &&  [ $1 -ne 0 ] 
    then
        echo 1
    else
        echo 0
    fi
}

function validateDataType() {

    if [[ $1 == "str" || $1 == "int" ]] 
    then
        echo 1
    else
        echo 0
    fi
}
function validateName() {
    if [[ $1 =~ ^[a-Z][a-Z0-9_]+$ ]]
    then
        echo 1
    else
        echo 0
    fi
}