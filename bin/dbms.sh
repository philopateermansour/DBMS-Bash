#! /bin/bash

shopt -s extglob
source ../src/config.sh

DBMS_PATH=`dirname "$PWD"`
SELECTED_DATABASE=''

function main() {
    if [[ $1 == "--gui" ]]
    then
        source ../src/database.gui.sh
        initDatabase

        groups "$USER" | grep -qw "$GROUP"
        [[ $? == 0 || $USER == "root" ]] || {
            zenity --error --text="You are not authorized to run this application.\
            \nPlease contact your system administrator." --width=400
            exit 1
        }

        zenity --info --width=400 --text="This database management system provides essential tools for efficient data handling and organization.\
        \n\nDeveloped by:\n- Philopateer Mansour\n- Muhamad Mamoun\n\nThis software is licensed under the MIT License." --title="Software License & Contributors"

        while true; do graphicalMainMenu; done

    elif [[ $1 == "--cli" ]]
    then
        source ../src/database.sh
        initDatabase

        groups "$USER" | grep -qw "$GROUP"
        [[ $? == 0 || $USER == "root" ]] || {
            echo "You are not authorized to run this application." >&2
            echo "Please contact your system administrator." >&2
            exit 1
        }

        clear; echo -e "Software License & Contributors\n\nThis database management system provides essential tools for efficient data handling and organization.\
        \n\nDeveloped by:\n- Philopateer Mansour\n- Muhamad Mamoun\n\nThis software is licensed under the MIT License."
        read -p 'Press ENTER to continue...'

        while true; do terminalMainMenu; done

    else
        echo "Invalid argument, use --gui or --cli only" >&2
        exit 1
    fi
}

function graphicalMainMenu() {
    userInput=`zenity --list --width=500 --height=400\
    --title="Main Menu" --text="Welcome, $USER!" --column="Options"\
    "Create a database" "List all databases" "Connect to a database" "Drop a database" "Add user" "Exit"`
    
    case $userInput in
    "Create a database") createDatabase;;
    "List all databases") listDatabases;;
    "Connect to a database") connectToDatabase;;
    "Drop a database") dropDatabase;;
    "Add user") addDatabaseUser;;
    @("Exit"|"")) echo "Good Bye, $USER."; exit 0;;
    esac
}

function terminalMainMenu() {
    clear
    echo -e "Welcome, $USER!\n\nMain Menu:"
    PS3='Enter your choice number: '

    select userInput in 'Create a database' 'List all databases' 'Connect to a database' 'Drop a database' 'Add user' 'Exit'
    do
        case $REPLY in
        1) createDatabase; break;;
        2) listDatabases; break;;
        3) connectToDatabase; break;;
        4) dropDatabase; break;;
        5) addDatabaseUser; break;;
        6) echo "Good Bye, $USER."; exit 0;;
        *) echo 'Invalid option number, try again...';;
        esac
    done
}

main $1