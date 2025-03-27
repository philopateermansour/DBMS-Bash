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
function connectToDatabase() {
    databases=`ls $DATABASES_PATH`
    databaseName=`zenity --list --title="Databases List" --text="Select Database"\
    --column="Databases" $databases --ok-label="Connect"`

    case $databaseName in
    "") zenity --error --text="No database selected";;
    *) SELECTED_DATABASE=$databaseName;
       zenity --info --text="Connected to $databaseName database";
       while databaseMenu; do :; done;;
    esac   
}

function listDatabases() {
    connectToDatabase
}

function dropDatabase() {
    databases=`ls $DATABASES_PATH`
    databaseName=`zenity --list --title="Databases List" --text="Select Database"\
    --column="Databases" $databases --ok-label="Drop"`

    case $databaseName in
    "") zenity --error --text="No database selected";;
    *) rm -rf "$DATABASES_PATH/$databaseName";
       zenity --info --text="Database $databaseName dropped successfully";;
    esac
}