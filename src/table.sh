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
    while true
    do
        read -p 'Enter table name: ' tableName
        isExists=`isTableExists $tableName`
        if [[ $isExists == 1 ]]
        then
            break
        else
            echo "Table [$tableName] does not exist in database [$SELECTED_DATABASE]." >&2
        fi
    done

    fullPath=$DATABASES_PATH/$SELECTED_DATABASE
    metadataFile=".$tableName-md.txt"
    dataFile="$tableName.txt"
    
    columns=()
    types=()
    pk=""
    pkIndex=-1
    i=-1
    while IFS=: read -r column type primaryKey _
    do
        columns+=($column)
        types+=($type)
        ((i+=1))
        if [[ $primaryKey == 1 ]]
        then
            pk=$column
            pkIndex=$i
        fi
    done < "$fullPath/$metadataFile"

    values=""
    noOfFields=${#columns[@]}
    for ((i=0; i<$noOfFields; i++))
    do
        columnName="${columns[$i]}"
        columnType="${types[$i]}"
        
        while true 
        do
            read -p "Enter value for $columnName ($columnType): " value

            if [[ $columnType == "int" && ! $value =~ ^[0-9]+$ ]] 
            then
                echo "Invalid value, you must send number" >&2
                continue
            fi

            if [[ $i -eq $pkIndex ]] 
            then
                if ! awk -F: -v pk="$(($pkIndex + 1))" -v val="$value" '
                {
                if ($pk == val) 
                    exit 1}
                ' "$fullPath/$dataFile"
                then
                    echo "Primary key has to be a unique value" >&2
                    continue
                fi
            fi


        if [[ -z "$values" ]]
        then
            values="$value"
        else
            values+=":$value"
        fi 

        break

        done
    done

    echo $values >> "$fullPath/$dataFile"

    echo "Record inserted successfully." >&1
    read -p 'Press ENTER to return to the database menu'

}

function selectFromTable() {
    clear

    while true
    do
        read -p 'Enter table name: ' tableName
        isExists=`isTableExists $tableName`
        if [[ $isExists -eq 1 ]]
        then
            break
        else
            echo "Table [$tableName] does not exist in database [$SELECTED_DATABASE]." >&2
        fi
    done
    
    while true
    do
        read -p 'Enter column name: ' columnName
        columnNumber=`isColumnExists $tableName $columnName`
        if [[ $columnNumber =~ ^[0-9]+$ && $columnNumber -ne 0 ]]
        then
            break
        else
            echo "Column [$columnName] does not exist in table [$tableName]." >&2
        fi
    done

    read -p 'Enter condition value: ' value

    numberOfColumns=`wc -l $DATABASES_PATH/$SELECTED_DATABASE/.$tableName-md.txt`

    awk -v columnCounter="${numberOfColumns[@]:0:1}" '
    BEGIN{
        FS=":"
        for(counter=0; counter<columnCounter; counter++) printf "\b------------------"
        printf "\n"
    }
    {printf "| %-14s ", $1}
    END{
        printf "|\n"
        for(counter=0; counter<columnCounter; counter++) printf "\b------------------"
        printf "\n"
    }
    ' $DATABASES_PATH/$SELECTED_DATABASE/.$tableName-md.txt 

    awk -v value="$value" -v columnNumber=$columnNumber -v columnCounter="${numberOfColumns[@]:0:1}" '
    BEGIN {FS=":"}
    {
        if($columnNumber == value) {
            for(counter=1; counter<=NF; counter++) {
                printf "| %-14s ", $counter
            }

            printf "|\n"
            for(counter=0; counter<columnCounter; counter++) printf "\b------------------"
            printf "\n"
        }
    }
    ' $DATABASES_PATH/$SELECTED_DATABASE/$tableName.txt

    read -p 'Press ENTER to return to the database menu'
}

function deleteFromTable() {
    clear
    read -p 'Enter table name: ' tableName

    isExists=`isTableExists $tableName`

    if [[ $isExists == 1 ]]
    then
        fullPath=$DATABASES_PATH/$SELECTED_DATABASE
        dataFile="$tableName.txt"

        while true
        do
            read -p "Enter the column name to delete by: " columnName
            columnNumber=`isColumnExists $tableName $columnName`
            
            if [[ -n $columnNumber ]]
            then
                break
            else
                echo "Column [$columnName] does not exist in table [$tableName]." >&2
            fi
        done
        
        while true
        do
            read -p "Enter the value to delete: " valueToDelete
            if [[ -n $valueToDelete ]]
            then
                break
            else
                echo "Invalid value, please enter a value (nt empty)" >&2
            fi
        done

        awk -v col="$columnNumber" -v val="$valueToDelete" -v file="$fullPath/$dataFile.tmp" '
        BEGIN {FS=":"; OFS=":"} 
        { if ($col != val) print $0 > file }' "$fullPath/$dataFile"

        if [[ $(wc -l < "$fullPath/$dataFile.tmp") -lt $(wc -l < "$fullPath/$dataFile") ]]
        then
            mv "$fullPath/$dataFile.tmp" "$fullPath/$dataFile"
            echo "Record deleted successfully" >&1
        else
            rm "$fullPath/$dataFile.tmp"
            echo "Record not found in the specified column" >&2
        fi
    else
        echo "Table [$tableName] does not exist in database [$SELECTED_DATABASE]." >&2
    fi
    read -p 'Press ENTER to return to the database menu'
}

function updateTable() {
    clear

    while true
    do
        read -p 'Enter table name: ' tableName
        isExists=`isTableExists $tableName`
        if [[ $isExists -eq 1 ]]
        then
            break
        else
            echo "Table [$tableName] does not exist in database [$SELECTED_DATABASE]." >&2
        fi
    done
    
    while true
    do
        read -p 'Enter column name: ' columnName
        columnNumber=`isColumnExists $tableName $columnName`
        if [[ $columnNumber =~ ^[0-9]+$ && $columnNumber -ne 0 ]]
        then
            break
        else
            echo "Column [$columnName] does not exist in table [$tableName]." >&2
        fi
    done
    
    while true
    do
        read -p 'Enter the old value: ' oldValue
        columnDataType=`getColumnDataType $tableName $columnName`
        if [[ $columnDataType == 'str' ]]
        then
            isValid=`validateString $oldValue`
        elif [[ $columnDataType == 'int' ]]
        then
            isValid=`validateInteger $oldValue`
        fi

        if [[ $isValid -eq 1 ]]
        then
            break
        else
            echo "Invalid value." >&2
        fi
    done
    
    while true
    do
        read -p 'Enter the new value: ' newValue
        columnDataType=`getColumnDataType $tableName $columnName`
        if [[ $columnDataType == 'str' ]]
        then
            isValid=`validateString $newValue`
        elif [[ $columnDataType == 'int' ]]
        then
            isValid=`validateInteger $newValue`
        fi

        if [[ $isValid -eq 1 ]]
        then
            break
        else
            echo "Invalid value." >&2
        fi
    done
    
    awk -v columnNumber=$columnNumber -v oldValue=$oldValue -v newValue=$newValue '
    BEGIN{FS=":"; OFS=":"}
    {
        sub(oldValue,newValue,$columnNumber);
        printf "%s\n", $0
    }' $DATABASES_PATH/$SELECTED_DATABASE/$tableName.txt > temp.txt && mv temp.txt $DATABASES_PATH/$SELECTED_DATABASE/$tableName.txt

    read -p 'Press ENTER to return to the database menu'
}

function getColumnDataType() {
    awk -v fieldName=$2 '
    BEGIN {FS=":"}
    {
        if($1 == fieldName) print $2
    }' $DATABASES_PATH/$SELECTED_DATABASE/.$1-md.txt
}