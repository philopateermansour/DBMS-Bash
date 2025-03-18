#! /bin/bash

function createDatabase() {
    clear
    databasesPath='../databases'
    read -p 'Enter database name: ' databaseName

    isExists=`isDatabaseExists $databaseName`

    if [[ $isExists == 1 ]]
    then
        echo 'Database already exists' >&2
    else
        mkdir "$databasesPath/$databaseName"

        if [[ $? == 0 ]]
        then
            echo 'Database created successfully' >&1
        else
            echo 'An error occurred. Please try again later' >&2
        fi
    fi

    read -p 'Press ENTER to return to the main menu'
}

function isDatabaseExists() {
    databasesPath='../databases'

    for currentDatabase in `ls $databasesPath`
    do
        if [[ -d $databasesPath/$currentDatabase && $currentDatabase == $1 ]]
        then
            echo 1
            break
        fi
    done
}

function listDatabases() {
    clear
    databasesPath='../databases'

    echo 'Your databases:'
    for currentDatabase in `ls $databasesPath`
    do
        echo "- $currentDatabase" >&1
    done

    read -p 'Press ENTER to return to the main menu'
}