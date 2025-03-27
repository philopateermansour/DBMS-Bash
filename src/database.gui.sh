#! /bin/bash

source ../src/table.gui.sh

function createDatabase() {
    databaseName=`zenity --entry --title="Create a database" --text="Enter database name:"`

    isValid=`validateName "$databaseName"`

    if [[ $isValid == 0 ]]
    then
        zenity --error --text="Invalid name, name must start whith character and contains alphanumeric characters and underscores only"
    else
        isExists=`isDatabaseExists $databaseName`

        if [[ $isExists == 1 ]]
        then
            zenity --error --text='Database already exists'
        else
            mkdir "$DATABASES_PATH/$databaseName"
        fi
    fi
}