#! /bin/bash

source ../src/table.sh

function createDatabase() {
    clear
    while true
    do
        read -p 'Enter database name: ' databaseName
        isValid=`validateName "$databaseName"`

        if [[ $isValid == 0 ]]
        then
            echo "Invalid name, name must start whith character and contains alphanumeric characters and underscores only" >&2
        else
            break
        fi
    done

    isExists=`isDatabaseExists $databaseName`

    if [[ $isExists == 1 ]]
    then
        echo 'Database already exists' >&2
    else
        mkdir "$DATABASES_PATH/$databaseName"

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
    for currentDatabase in `ls $DATABASES_PATH`
    do
        if [[ -d $DATABASES_PATH/$currentDatabase && $currentDatabase == $1 ]]
        then
            echo 1
            break
        fi
    done
}

function listDatabases() {
    clear
    echo 'Your databases:'

    for currentDatabase in `ls $DATABASES_PATH`
    do
        echo "- $currentDatabase" >&1
    done

    read -p 'Press ENTER to return to the main menu'
}

function connectToDatabase() {
    clear
    read -p 'Enter database name you want to connect to: ' databaseName
    
    isExists=`isDatabaseExists $databaseName`

    if [[ $isExists == 1 ]]
    then
        SELECTED_DATABASE=$databaseName
        echo "Connected to $databaseName database"

        while true
        do
            clear
            echo -e "Connected to Database: $databaseName database\nDatabase Menu:"
            PS3='Enter your choice number: '

            select userInput in 'Create Table' 'List Tables' 'Drop Table' 'Insert into Table' 'Select from Table' 'Delete from Table' 'Update Table' 'Back to Main Menu'
            do
                case $REPLY in
                1) createTable; break;;
                2) listTables; break;;
                3) dropTable; break;;
                4) insertIntoTable; break;;
                5) selectFromTable; break;;
                6) deleteFromTable; break;;
                7) updateTable; break;;
                8) SELECTED_DATABASE=''; return;;
                *) echo 'Invalid option number, try again...';;
                esac
            done
        done
    else
        echo 'Database does not exist' >&2
        read -p 'Press ENTER to return to the main menu'
    fi    

}

function dropDatabase() {
    clear
    read -p 'Enter database name you want to drop: ' databaseName

    isExists=`isDatabaseExists $databaseName`

    if [[ $isExists == 1 ]]
    then
        rm -r "$DATABASES_PATH/$databaseName"
        if [[ $? == 0 ]]
        then
            echo "Database $databaseName dropped" >&1
        else
            echo "Try again later, Because there is an error occured" >&2
        fi
    else
        echo 'Database does not exist' >&2
    fi

    read -p 'Press ENTER to return to the main menu'
}