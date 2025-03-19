#! /bin/bash

source ../src/validation.sh


function createTable() {
    clear
    while true 
        do
            read -p 'Enter table name: ' tableName
            if [[ `validateName $tableName` == 1 ]]
            then
                break
            else
                echo "Invalid name, name must start with a character and contain alphanumeric characters and underscores only" >&2
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

    metadata=""
    primaryKeyColumn=""

    for ((i=1;i<=$noOfColumns;i++))
    do
        clear
        while true 
        do
            read -p "Enter column $i name: " columnName
            if [[ `validateName $columnName` == 1 ]]
            then
                break
            else
                echo "Invalid name, name must start with a character and contain alphanumeric characters and underscores only" >&2
            fi
        done

        while true 
        do
            read -p "Enter column $i data type (str or int): " columnType
            if [[ `validateDataType $columnType` == 1 ]]
            then
                break
            else
                echo "Invalid data type, you must choose between str or int" >&2
            fi
        done

        pkSet=0
        aiSet=0
        uniqueSet=0
        fkReference="0"

        if [[ "$columnType" == "int" ]] 
        then
            read -p "Do you want $columnName to auto-increment (yes for confirmation, anything else to cancel): " isAutoIncrement
            if [[ $isAutoIncrement =~ ^[yY]([eE]?[sS]?)$ ]] 
            then
                aiSet=1
            fi
        fi
        
        if [[ -z $primaryKeyColumn ]] 
        then
            read -p "Do you want $columnName to be the primary key (yes for confirmation, anything else to cancel): " isPrimaryKey
            if [[ $isPrimaryKey =~ ^[yY]([eE]?[sS]?)$ ]] 
            then
                pkSet=1
                primaryKeyColumn="$columnName"
            fi
        fi

        read -p "Do you want $columnName to be unique (yes for confirmation, anything else to cancel): " isUnique
        if [[ $isUnique =~ ^[yY]([eE]?[sS]?)$ ]] 
        then
            uniqueSet=1
        fi

        read -p "Do you want $columnName to be a foreign key (yes for confirmation, anything else to cancel): " isForeignKey
        if [[ $isForeignKey =~ ^[yY]([eE]?[sS]?)$ ]] 
        then
            while true 
            do
                read -p "Enter the referenced table: " foreignKeyTable
                read -p "Enter the referenced column: " foreignKeyColumn
                if [[ `validateForeignKey $foreignKeyTable $foreignKeyColumn` == 1 ]]
                then
                    fkReference="$foreignKeyTable.$foreignKeyColumn"
                    break
                else
                    echo "Invalid key, make sure of the table and key" >&2
                fi
            done
        fi

        metadata+="$columnName:$columnType:$pkSet:$aiSet:$uniqueSet:$fkReference\n"
    done

    echo -e "$metadata" >> $fullPath/$mdFile

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