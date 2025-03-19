#! /bin/bash

function isTableExists() {
    fullPath=$DATABASES_PATH/$SELECTED_DATABASE
    for currentTable in `ls $fullPath/`
    do
        if [[ -f "$fullPath/$currentTable" && $currentTable == $1.txt ]]
        then
            echo 1
            break
        fi
    done
}

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
    if [[ "$1" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]
    then
        echo 1
    else
        echo 0
    fi
}

function validateForeignKey() {
    
    isExists=`isTableExists $1`
    if [[ $isExists == 1 ]] && grep -q "$2" "$DATABASES_PATH/$SELECTED_DATABASE/.$1-md.txt"
    then
        echo 1
    else
        echo 0
    fi
}