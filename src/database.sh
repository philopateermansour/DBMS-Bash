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

function addDatabaseUser() {
    [[ $USER == "root" ]] || { echo "This function must be run as root." >&2; exit 1; }

    read -p "Enter username: " userName
    [[ -z $userName ]] && { echo "No username provided." >&2; read -p "Press ENTER to return to the main menu"; return; }

    getent passwd "$userName" > /dev/null || { echo "User '$userName' does not exist." >&2; read -p "Press ENTER to return to the main menu"; return; }

    groups "$userName" | grep -qw "$DATABASE_GROUP"
    [[ $? -eq 0 ]] && { echo "User '$userName' is already in the group." >&2; read -p "Press ENTER to return to the main menu"; return; }

    sudo usermod -aG "$DATABASE_GROUP" "$userName" && echo "User '$userName' added to group '$DATABASE_GROUP'."
    read -p "Press ENTER to return to the main menu"
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

    echo "[INFO]: Database setup completed successfully. just make sure that the project path is accessible by the group"
    read -p 'Press ENTER to continue...'
}