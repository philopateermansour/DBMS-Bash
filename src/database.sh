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
            chmod +t "$DATABASES_PATH/$databaseName"
            echo 'Database created successfully' >&1
        else
            echo 'An error occurred. Please try again later' >&2
        fi
    fi

    read -p 'Press ENTER to return to the main menu'
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
        dbPath="$DATABASES_PATH/$databaseName"
        currentUser=`whoami`
        owner=`ls -ld $dbPath | awk '{print $3}'`
        if [[ $currentUser != $owner ]]
        then
            echo "You are not the owner of this database, you can't drop it" >&2
            read -p 'Press ENTER to return to the main menu'
            return
        fi
        rm -r $dbPath
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
function addUser() {
    if [[ $EUID -ne 0 ]]
    then
        echo "This function need be run as root" >&2
        exit
    fi
    
    read -p "Enter username: " userName

    if [[ -z $userName ]]
    then
        echo "No username provided" >&2
        read -p 'Press ENTER to return to the main menu'
        return
    fi
    
    userExists=` grep "^$userName:" /etc/passwd | awk -F: '{print $1}' `
    
    if [[ -z $userExists ]]
    then
        echo "User $userName does not exist" >&2
        read -p 'Press ENTER to return to the main menu'
        return
    fi

    if groups "$userName" | grep -qw "$GROUP" 
    then
        echo "User $userName is already a user" >&2
        read -p 'Press ENTER to return to the main menu'
        return
    fi

    if  ! grep -qw "$GROUP" /etc/group  
    then
        groupadd "$GROUP"
        echo "Group $GROUP created."
    fi

    usermod -aG "$GROUP" "$userName"
    echo "User $userName added to group $GROUP."

    setfacl -R -m g:$GROUP:rwx "$DBMS_PATH"
    echo "ACL permissions applied to $DBMS_PATH."

    HOME_OWNER=$(ls -ld "..$HOME_DIR" | awk '{print $3}')
    HOME_DIR="/home/$HOME_OWNER"
    setfacl -m g:$GROUP:rx "$HOME_DIR"
    echo "Traversal permissions set on $HOME_DIR."
    echo "Setup complete (just make sure that the project path is accessible by the group)" >&1
    read -p 'Press ENTER to return to the main menu'
}