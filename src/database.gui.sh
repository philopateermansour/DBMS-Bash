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
function addUser() {
    if [[ $EUID -ne 0 ]]
    then
        zenity --error --text="This function need be run as root" 
        return
    fi
    
    userName=`zenity --entry --title="Add User" --text="Enter username:" --ok-label="Add"`

    if [[ -z $userName ]]
    then
        zenity --error --text="No username provided"
        return
    fi
    
    userExists=` grep "^$userName:" /etc/passwd | awk -F: '{print $1}' `
    
    if [[ -z $userExists ]]
    then
        zenity --error --text="User $userName does not exist"
        return
    fi

    if groups "$userName" | grep -qw "$GROUP" 
    then
        zenity --error --text="User $userName is already a user"
        return
    fi

    if  ! grep -qw "$GROUP" /etc/group  
    then
        groupadd "$GROUP"
        zenity --info --text="Group $GROUP created."
    fi

    usermod -aG "$GROUP" "$userName"
    zenity --info --text="User $userName added to group $GROUP."

    setfacl -R -m g:$GROUP:rwx "$DBMS_PATH"
    zenity --info --text="ACL permissions applied to $DBMS_PATH."

    HOME_OWNER=$(ls -ld "..$HOME_DIR" | awk '{print $3}')
    HOME_DIR="/home/$HOME_OWNER"
    setfacl -m g:$GROUP:rx "$HOME_DIR"
    zenity --info --text="Traversal permissions set on $HOME_DIR."
    
    zenity --info --text="Setup complete (just make sure that the project path is accessible by the group)"


    


}