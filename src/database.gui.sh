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

function databaseMenu() {
    userInput=`zenity --list --width=500 --height=500\
    --title="Database Menu" --text="Connected to $SELECTED_DATABASE database"\
    --column="Options" "Create a table" "List all tables" "Drop a table" "Insert into a table"\
    "Select from a table" "Delete from a table" "Update a table" "Back to main menu"`

    case $userInput in
    "Create a table") createTable;;
    "List all tables") listTables;;
    "Drop a table") dropTable;;
    "Insert into a table") insertIntoTable;;
    "Select from a table") selectFromTable;;
    "Delete from a table") deleteFromTable;;
    "Update a table") updateTable;;
    "Back to main menu") SELECTED_DATABASE=''; return 1;;
    esac
}