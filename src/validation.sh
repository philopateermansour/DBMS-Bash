#! /bin/bash

function isDatabaseExists() {
    for currentDatabase in `ls $DATABASES_PATH`
    do
        if [[ -d $DATABASES_PATH/$currentDatabase && $currentDatabase == $1 ]]
        then
            echo 1
            break
        fi
    done
}

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

function isColumnExists() {
    awk -v fieldName=$2 '
    BEGIN {FS=":"}
    {
        if($1 == fieldName) print NR
    }' $DATABASES_PATH/$SELECTED_DATABASE/.$1-md.txt
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

    if [[ $1 == "str" || $1 == "int" || $1 == "float" || $1 == "char" || $1 == "bool" || $1 == "date" ]] 
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

function validateString() {
    [[ $1 =~ ^[a-zA-Z0-9_\ ]+$ ]] && echo 1 || echo 0
}

function validateInteger() {
    [[ $1 =~ ^([0-9]|[1-9][0-9]*)$ ]] && echo 1 || echo 0
}