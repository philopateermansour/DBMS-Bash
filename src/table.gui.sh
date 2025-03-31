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
function createTable() {

    tableName=`zenity --entry --title="Create new table" --text="Enter table name:"`
    isValid=`validateName "$tableName"`
    if [[  $isValid != 1 ]]
    then
        zenity --error --text="Invalid name, name must start with a character and contain alphanumeric characters and underscores only"
        return
    fi
    
    isExists=`isTableExists $tableName`
    
    if [[ $isExists == 1 ]]
    then
        zenity --error --text="Table $tableName already exists"
        return
    fi

    mdFile=".$tableName-md.txt"
    
    noOfColumns=`zenity --entry --title="Create new table" --text="Enter number of columns:"`
    isValid=`validatePositiveInteger $noOfColumns`
    if [[ $isValid == 0 ]]
    then
        zenity --error --text="Invalid number, Number of columns must be a positive number"
        return
    fi

    fullPath=$DATABASES_PATH/$SELECTED_DATABASE
    touch $fullPath/$mdFile

    metadata=""
    primaryKeyColumn=""

    for ((i=1;i<=$noOfColumns;i++))
    do
        while true 
        do
            columnName=`zenity --entry --title="Create new table" --text="Enter column $i name:"` 
            if [[ `validateName $columnName` == 1 ]]
            then
                break
            else
                zenity --error --text="Invalid name, name must start with a character and contain alphanumeric characters and underscores only"
            fi
        done
    
        

        while true 
        do
            columnType=`zenity --list --title="Choose data type" --column="Data type" \
            "str" \
            "int" \
            "float" \
            "char" \
            "bool" \
            "date"`
            if [[ $? == 0 ]]
            then
                break
            else
                zenity --error --text="Invalid data type, you must choose between (str, int, float, char, bool, date)"
            fi
        done

        pkSet=0
        aiSet=0
        uniqueSet=0
        fkReference="0"

        
        if [[ -z $primaryKeyColumn ]] 
        then
            isPrimaryKey=`zenity --question --text="Do you want $columnName to be the primary key (yes for confirmation, anything else to cancel):"`
            if [[ $? == 0 ]] 
            then
                pkSet=1
                primaryKeyColumn="$columnName"
            fi
        fi

        if [[ "$columnType" == "int" ]] 
        then
            isAutoIncrement=`zenity --question --text="Do you want $columnName to auto-increment (yes for confirmation, anything else to cancel):"`
            if [[ $? == 0  ]] 
            then
                aiSet=1
            fi
        fi
        if [[ $pkSet == 0 ]]
        then
            isUnique=`zenity --question --text="Do you want $columnName to be unique (yes for confirmation, anything else to cancel):"`
            if [[ $? == 0 ]]
            then
                uniqueSet=1
            fi
        fi

        metadata+="$columnName:$columnType:$pkSet:$aiSet:$uniqueSet:$fkReference\n"
    done

    echo -e "$metadata" >> $fullPath/$mdFile

    dataFile="$tableName.txt"
    touch $fullPath/$dataFile

    zenity --info --text="Table $tableName created successfully"
}
function deleteFromTable() {

    tables=`ls $DATABASES_PATH/$SELECTED_DATABASE`
    tables=`sed 's/.txt//g' <<< $tables`
    tableName=`zenity --list --title="Tables List" --text="Tables in $SELECTED_DATABASE database"\
    --column="Tables" $tables`
    if [[ $? != 0 ]]
        then
            zenity --error --text="You have to select table."
            return
    fi
    fullPath=$DATABASES_PATH/$SELECTED_DATABASE
    dataFile="$tableName.txt"
    metadataFile=".$tableName-md.txt"


    columns=`awk 'BEGIN{FS=":"}{print $1}' $fullPath/$metadataFile`
    read -r -d ' ' -a columnsArray <<< $columns
    
    while true
    do
        columnName=`zenity --list --title="Columns List" --text="Columns in $tableName" --column="columns" "${columnsArray[@]}"`
        if [[ $? == 0 ]]
        then
            columnNumber=`isColumnExists $tableName $columnName`
            break
        else
            zenity --error --text="You have to select column."
            return
        fi
    done
    
    while true
    do
        columnType=`awk  -v col="$columnName" 'BEGIN{FS=":"}{if ($1 == col) print $2}' $fullPath/$metadataFile`
        if [[ "$columnType" == "int" || "$columnType" == "float" || $columnType == "date" ]] 
        then
            operator=`zenity --list --title="Operators List" --text="select an operator for $columnName" \
            --column="operator" "=" "!=" ">" "<" ">=" "<="`
        else
            operator=`zenity --list --title="Operators List" --text="select an operator for $columnName" \
            --column="operator" "=" "!="`
        fi
        if [[ $? == 0 ]]
        then
            break
        else
            zenity --error --text="You have to select operator."
            return
        fi
    done

    while true
    do
        valueToDelete=`zenity --entry --title="Delete from table" --text="Enter the value to delete:"`
        if [[ -n $valueToDelete ]]
        then
            break
        else
            zenity --error --text="Invalid value, please enter a value (not empty)"
            return
        fi
    done

    awk -v col="$columnNumber" -v val="$valueToDelete" -v op="$operator" -v file="$fullPath/$dataFile.tmp" '
    BEGIN {FS=":"; OFS=":"} 
    {   rowMatched = 0
        if      (op == "="  && $col != val) rowMatched = 1
        else if (op == ">"  && $col <=  val) rowMatched = 1
        else if (op == "<"  && $col >=  val) rowMatched = 1
        else if (op == ">=" && $col < val) rowMatched = 1
        else if (op == "<=" && $col > val) rowMatched = 1
        else if (op == "!=" && $col == val) rowMatched = 1 
        
        if(rowMatched == 1)
            print $0 > file 
    }' "$fullPath/$dataFile"

    if [[ $(wc -l < "$fullPath/$dataFile.tmp") -lt $(wc -l < "$fullPath/$dataFile") ]]
    then
        mv "$fullPath/$dataFile.tmp" "$fullPath/$dataFile"
        zenity --info --text="Record deleted successfully"
    else
        rm "$fullPath/$dataFile.tmp"
        zenity --error --text="Record not found in the specified column"
    fi
}
function insertIntoTable() {
    while true
    do
        tables=`ls $DATABASES_PATH/$SELECTED_DATABASE`
        tables=`sed 's/.txt//g' <<< $tables`
        tableName=`zenity --list --title="Tables List" --text="Tables in $SELECTED_DATABASE database"\
        --column="Tables" $tables`
        if [[ $? == 0 ]]
        then
            break
        else
            zenity --error --text="You have to select table."
            return
        fi
    done
    while true
    do
        if [[ -z $tableName ]]
        then
            zenity --error --text="You have to select table."
            return
        fi
        isValid=`validateName "$tableName"` 
        if [[ $isValid == 1 ]]
        then
            break
        else
            zenity --error --text="Invalid name, name must start with a character and contain alphanumeric characters and underscores only"
            return
        fi
        isExists=`isTableExists $tableName`
        if [[ $isExists == 1 ]]
        then
            break
        else
            zenity --error --text="Table $tableName does not exist in database $SELECTED_DATABASE"

        fi
    done

    fullPath=$DATABASES_PATH/$SELECTED_DATABASE
    metadataFile=".$tableName-md.txt"
    dataFile="$tableName.txt"
    
    columns=()
    types=()
    uniques=()
    ai=()
    pkIndex=-1
    i=-1

    while IFS=: read -r column type primaryKey autoIncrement unique
    do
        columns+=($column)
        types+=($type)
        ((i+=1))
        if [[ $primaryKey == 1 ]]
        then
            pkIndex=$i
        fi
        if [[ $unique == 1 ]]
        then
            uniques+=($i)
        fi
        if [[ $autoIncrement == 1 ]]
        then
            ai+=($i)
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
            value=`zenity --entry --title="Insert into $tableName" --text="Enter value for $columnName ($columnType):"`

            if [[ $columnType == "int" ]] 
            then
                if [[ " ${ai[*]} " =~ " $i " ]]
                then
                    if [[ -z $value ]]
                    then
                        value=`awk -F: -v col="$((i+1))" '
                        {
                            if ($col > max) 
                                max = $col
                        }
                        END{
                            print max + 1
                        }' "$fullPath/$dataFile"`
                    else
                        if [[ $(validateInteger "$value") == 0 ]]
                        then
                            zenity --error --text="Invalid value, you must send number or leave it empty and it will be automatic assignment"
                            return
                        fi
                    fi
                
                elif [[ $(validateInteger "$value") == 0 ]]
                then
                    zenity --error --text="Invalid value, you must send number"
                    return
                fi

            elif [[ $columnType == "str" && $(validateString "$value") == 0 ]] 
            then
                zenity --error --text="Invalid value, string cannot be empty or and can only contain letters, numbers, underscores, and spaces"
                return

            elif [[ $columnType == "float" && $(validateFloat "$value") == 0 ]] 
            then
                zenity --error --text="Invalid value, you must send a float"
                return

            elif [[ $columnType == "bool" && $(validateBoolean "$value") == 0 ]] 
            then
                zenity --error --text="Invalid value, you must send a boolean (true/false)"
                return

            elif [[ $columnType == "date" && $(validateDate "$value") == 0 ]] 
            then
                zenity --error --text="Invalid value, you must send a valid date (MM/DD/YYYY)"
                return

            elif [[ $columnType == "char" && $(validateChar "$value") == 0 ]] 
            then
                zenity --error --text="Invalid value, you must send a single character"
                return
            fi

            if [[ $i -eq $pkIndex ]] 
            then
                if ! awk -F: -v pk="$(($pkIndex + 1))" -v val="$value" '
                {
                if ($pk == val) 
                    exit 1}
                ' "$fullPath/$dataFile"
                then
                    zenity --error --text="Primary key has to be a unique value"
                    continue
                fi
            fi

            for uniqueIndex in "${uniques[@]}"
            do
                if [[ $i == $uniqueIndex ]]
                then
                    if awk -F: -v col="$((uniqueIndex+1))" -v val="$value" '
                    {
                        if ($col == val) 
                            exit 1
                    }
                    ' "$fullPath/$dataFile"
                    then
                        break
                    else
                        zenity --error --text="Value must be unique"
                        continue 2
                    fi
                fi
            done
        

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

    zenity --info --text="Record inserted successfully"

}

function selectFromTable() {
    tables=`ls $DATABASES_PATH/$SELECTED_DATABASE`
    tables=`sed 's/.txt//g' <<< $tables`

    tableName=`zenity --list --title="Tables List" --text="Tables in $SELECTED_DATABASE database"\
    --column="Tables" $tables`

    if [[ -z $tableName ]]
    then
        zenity --error --text="You have to select table."
        return
    fi

    numberOfColumns=`wc -l $DATABASES_PATH/$SELECTED_DATABASE/.$tableName-md.txt | cut -d' ' -f1`
    selectCondition=`zenity --entry --title="Select from table" --text="Enter select condition [e.g. column-name = value]:" --ok-label="Select" --cancel-label="Cancel" --width=400 --height=200`

    columnName=`echo $selectCondition | awk '{print $1}'`
    conditionOperator=`echo $selectCondition | awk '{print $2}'`
    columnValue=`echo $selectCondition | awk '{print $3}'`

    columnNumber=`isColumnExists $tableName $columnName`
    [[ $columnNumber =~ ^[0-9]+$ && $columnNumber -ne 0 ]] && : || {
        zenity --error --text="Column $columnName does not exist in table $tableName"
        return
    }

    [[ $conditionOperator =~ ^(">"|"<"|"="|">="|"<="|"!=")$ ]] && : || {
        zenity --error --text="Invalid condition"
        return
    }

    zenityArgs=()
    Headers=()
    Data=()

    for ((i=0;i<$numberOfColumns;i++))
    do
        currentHeader=`awk -v columnNumber="$i" 'BEGIN{FS=":"}{if (NR == (columnNumber + 1)) print $1}' $DATABASES_PATH/$SELECTED_DATABASE/.$tableName-md.txt`
        data=`awk -v columnNumber="$columnNumber" -v val="$columnValue" -v condition="$conditionOperator" -v selectedIndex="$i" '
        BEGIN {FS=":"}
        {
            rowMatched = 0
            if      (condition == "="  && $columnNumber == val) rowMatched = 1
            else if (condition == ">"  && $columnNumber >  val) rowMatched = 1
            else if (condition == "<"  && $columnNumber <  val) rowMatched = 1
            else if (condition == ">=" && $columnNumber >= val) rowMatched = 1
            else if (condition == "<=" && $columnNumber <= val) rowMatched = 1
            else if (condition == "!=" && $columnNumber != val) rowMatched = 1

            if (rowMatched == 1) print $(selectedIndex+1)
        }' $DATABASES_PATH/$SELECTED_DATABASE/$tableName.txt`

        zenityArgs+=("--column=$currentHeader")
        zenityArgs+=("$data")
    done

    zenity --list --title="Selection Result" --text="SELECT * FROM $tableName WHERE $selectCondition" "${zenityArgs[@]}" --width=800 --height=400
}

function updateTable() {
    tables=`ls $DATABASES_PATH/$SELECTED_DATABASE`
    tables=`sed 's/.txt//g' <<< $tables`
    tableName=`zenity --list --title="Tables List" --text="Tables in $SELECTED_DATABASE database"\
    --column="Tables" $tables`

    if [[ -z $tableName ]]
    then
        zenity --error --text="You have to select table."
        return
    fi

    columnName=`zenity --entry --title="Update table" --text="Enter column name to update:"`

    if [[ -z $columnName ]]
    then
        zenity --error --text="You have to select column."
        return
    fi

    columnNumber=`isColumnExists $tableName $columnName`
    [[ $columnNumber =~ ^[0-9]+$ && $columnNumber -ne 0 ]] && : || {
        zenity --error --text="Column $columnName does not exist in table $tableName"
        return
    }

    oldValue=`zenity --entry --title="Update table" --text="Enter old value:"`
    if [[ -z $oldValue ]]
    then
        zenity --error --text="You have to select old value."
        return
    fi

    newValue=`zenity --entry --title="Update table" --text="Enter new value:"`
    if [[ -z $newValue ]]
    then
        zenity --error --text="You have to select new value."
        return
    fi

    columnDataType=`getColumnDataType $tableName $columnName`
    if [[ "$columnType" == "int" && $(validateInteger "$newValue") == 0 ]] 
    then
        zenity --error --text="Invalid value, you must send number"
        return
    elif [[ "$columnType" == "str" && $(validateString "$newValue") == 0 ]] 
    then
        zenity --error --text="Invalid value, string cannot be empty or and can only contain letters, numbers, underscores, and spaces"
        return
    elif [[ "$columnType" == "float" && $(validateFloat "$newValue") == 0 ]] 
    then
        zenity --error --text="Invalid value, you must send a float"
        return
    elif [[ "$columnType" == "bool" && $(validateBoolean "$newValue") == 0 ]] 
    then
        zenity --error --text="Invalid value, you must send a boolean (true/false)"
        return
    elif [[ "$columnType" == "date" && $(validateDate "$newValue") == 0 ]] 
    then
        zenity --error --text="Invalid value, you must send a valid date (MM/DD/YYYY)"
        return
    elif [[ "$columnType" == "char" && $(validateChar "$newValue") == 0 ]] 
    then
        zenity --error --text="Invalid value, you must send a single character"
        return
    fi

    awk -v col="$columnNumber" -v oldVal="$oldValue" -v newVal="$newValue" '
    BEGIN {FS=":"; OFS=":"}
    {
        if ($col == oldVal) $col = newVal
        print $0
    }' "$DATABASES_PATH/$SELECTED_DATABASE/$tableName.txt" > "$DATABASES_PATH/$SELECTED_DATABASE/$tableName.tmp"
    mv "$DATABASES_PATH/$SELECTED_DATABASE/$tableName.tmp" "$DATABASES_PATH/$SELECTED_DATABASE/$tableName.txt"
    zenity --info --text="Record updated successfully"
}

function getColumnDataType() {
    awk -v fieldName=$2 '
    BEGIN {FS=":"}
    {
        if($1 == fieldName) print $2
    }' $DATABASES_PATH/$SELECTED_DATABASE/.$1-md.txt
}