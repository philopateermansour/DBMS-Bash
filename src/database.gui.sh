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
            chmod +t "$DATABASES_PATH/$databaseName"
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
    *)  dbPath="$DATABASES_PATH/$databaseName"
        currentUser=`whoami`
        owner=`ls -ld $dbPath | awk '{print $3}'`
        if [[ $currentUser != $owner ]]
        then
            zenity --error --text="You are not the owner of this database, you can't drop it"
            return
        fi
        rm -rf $dbPath;
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

function addDatabaseUser() {
    [[ $USER == "root" ]] || { zenity --error --text="This function need be run as root"; exit 1; }

    userName=`zenity --entry --title="Add User" --text="Enter username:" --ok-label="Add"`

    [[ -z $userName ]] && { zenity --error --text="No username provided"; return; }

    getent passwd "$userName" > /dev/null || { zenity --error --text="User '$userName' does not exist"; return; }

    groups "$userName" | grep -qw "$DATABASE_GROUP"
    [[ $? -eq 0 ]] && { zenity --error --text="User '$userName' is already in the group"; return; }

    sudo usermod -aG "$DATABASE_GROUP" "$userName" && zenity --info --text="User '$userName' added to group '$DATABASE_GROUP'."
}

function initDatabase() {
    grep -qw "$DATABASE_GROUP" /etc/group
    if [[ $? -ne 0 ]]
    then
        sudo groupadd "$DATABASE_GROUP"
        [[ $? -eq 0 ]] && echo "[INFO]: Database group $DATABASE_GROUP created successfully."
    fi

    if [[ ! -d $DATABASES_PATH ]]
    then
        mkdir "$DATABASES_PATH"
        chown :$DATABASE_GROUP "$DATABASES_PATH"
        [[ $? -eq 0 ]] && echo "[INFO]: Databases directory created successfully."

        chmod +s "$DATABASES_PATH"
        [[ $? -eq 0 ]] && echo "[INFO]: Setgid bit set on $DATABASES_PATH."
    fi

    setfacl -R -m g:$DATABASE_GROUP:rwx "$DATABASES_PATH"
    setfacl -R -m g:$DATABASE_GROUP:rwx "$DBMS_PATH"
    echo "[INFO]: ACL permissions applied to $DATABASES_PATH."
    echo "[INFO]: ACL permissions applied to $DBMS_PATH."

    zenity --info --text="Database setup completed successfully. just make sure that the project path is accessible by the group"
}
