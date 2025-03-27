#! /bin/bash

source ../src/validation.sh

function listTables() {
    tables=`ls $DATABASES_PATH/$SELECTED_DATABASE`
    tables=`sed 's/.txt//g' <<< $tables`
    tableName=`zenity --list --title="Tables List" --text="Tables in $SELECTED_DATABASE database"\
    --column="Tables" $tables`
}

function dropTable() {
    tables=`ls $DATABASES_PATH/$SELECTED_DATABASE`
    tables=`sed 's/.txt//g' <<< $tables`
    tableName=`zenity --list --title="Tables List" --text="Select Table"\
    --column="Tables" $tables --ok-label="Drop"`

    case $tableName in
    "") zenity --error --text="No table selected";;
    *)  rm -f "$DATABASES_PATH/$SELECTED_DATABASE/$tableName.txt";
        rm -f "$DATABASES_PATH/$SELECTED_DATABASE/.$tableName-md.txt";
        zenity --info --text="Table $tableName dropped successfully";;
    esac
}