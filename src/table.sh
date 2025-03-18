#! /bin/bash

source ../src/validation.sh

function isTableExists() {
    fullPath=$DATABASES_PATH/$SELECTED_DATABASE
    for currentTable in `ls $fullPath/`
    do
        if [[ -f "$fullPath/$currentTable" && $currentTable == $1.txt ]]
        then
            echo 1
            break
        fi
    done
}

function createTable() {
    clear
    while true 
        do
            read -p 'Enter table name: ' tableName
            if [[ `validateName $tableName` == 1 ]]
            then
                break
            else
                echo "Invalid name, name must start whith character and contains alphanumeric characters and underscores only" >&2
            fi
        done

    isExists=`isTableExists $tableName`
    
    if [[ $isExists == 1 ]]
    then
        echo "Table $tableName already exists" >&1
        read -p 'Press ENTER to return to the database menu'
        return 
    fi

    mdFile=".$tableName-md.txt"
    read -p 'Enter number of columns: ' noOfColumns

    isValid=`validatePositiveInteger $noOfColumns`
    if [[ $isValid == 0 ]]
    then
        echo 'Invalid number, Number of columns must be a positive number' >&2
        read -p 'Press ENTER to return to the database menu'
        return 
    fi

    fullPath=$DATABASES_PATH/$SELECTED_DATABASE
    touch $fullPath/$mdFile

    names=""
    types=""
    primaryKeySet=0

    for ((i=1;i<=$noOfColumns;i++))
    do

        while true 
        do
            read -p "Enter column $i name: " columnName
            if [[ `validateName $columnName` == 1 ]]
            then
                names+="$columnName:"
                break
            else
                echo "Invalid name, name must start whith character and contains alphanumeric characters and underscores only" >&2
            fi
        done

        while true 
        do
            read -p "Enter column $i data type (str or int): " columnType
            if [[ `validateDataType $columnType` == 1 ]]
            then
                types+="$columnType:"
                break
            else
                echo "Invalid data type, you must choose between str or int" >&2
            fi
        done
        
        if [ $primaryKeySet == 0 ] 
        then
            read -p "Do you want $columnName be the primary key (yes for confirmation any thing else to cancel): " isPrimaryKey
            if [[ $isPrimaryKey =~ ^[yY](es)? ]] 
            then
                primaryKeySet=1
                primaryKeyColumn="$columnName"
            fi
        fi
    done

    echo ${names::-1} >> $fullPath/$mdFile
    echo ${types::-1} >> $fullPath/$mdFile
    if [[ $primaryKeySet == 1 ]]
    then
        echo "PK:$primaryKeyColumn" >> $fullPath/$mdFile
    fi

    dataFile="$tableName.txt"
    touch $fullPath/$dataFile

    echo "Table $tableName created successfully" >&1
    read -p 'Press ENTER to return to the database menu'
}

function listTables() {
    echo "Tables List:" >&1

    ls $DATABASES_PATH/$SELECTED_DATABASE/*.txt | \
    awk 'BEGIN{FS="/"}
    {
        print "-", substr($4, 0, (length($4) - 4))
    }'

    read -p 'Press ENTER to return to the database menu'
}

function dropTable() {
    read -p 'Enter table name: ' tableName

    isExists=`isTableExists $tableName`

    if [[ $isExists == 1 ]]
    then
        rm $DATABASES_PATH/$SELECTED_DATABASE/$tableName.txt
        rm $DATABASES_PATH/$SELECTED_DATABASE/.$tableName-md.txt

        if [[ $? == 0 ]]
        then
            echo "Table $tableName dropped successfully" >&1
        else
            echo 'An error occurred. Please try again later' >&2
        fi
    else
        echo "Table [$tableName] does not exist in database [$SELECTED_DATABASE]." >&2
    fi

    read -p 'Press ENTER to return to the database menu'
}

function insertIntoTable() {
    clear
}

function selectFromTable() {
    clear
}

function deleteFromTable() {
    clear
}

function updateTable() {
    clear
}