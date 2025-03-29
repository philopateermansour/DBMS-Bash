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