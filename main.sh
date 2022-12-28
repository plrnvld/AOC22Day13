input="./Example.txt"

compare_lines() {
    # echo "*****"
    echo "$1"
    echo "$2"
    echo "*****"
}

read_input() {
    local pairs=()
    while read -r line
    do
        if test "$line" != ""; then
            
            pairs+=("$line")
            
            if test "${#pairs[@]}" -eq 2; then 
                compare_lines "${pairs[0]}" "${pairs[1]}"
                pairs=()
            fi
        fi
    done < $1
}

check_nums() { # Takes two arguments
    echo "> $1"
    echo "> $2"
    [[ "$1" -le "$2" ]]
    return
}

check_arrays() { # Takes two array references
    local -n list1=$1
    local -n list2=$2
    local len1=${#list1[@]}
    local len2=${#list2[@]}

    echo "Length 1: $len1"
    echo "Length 2: $len2"

    echo "Looping"
    echo "${list1[*]}"
    echo "${list2[*]}"
    echo "---"

    for (( i=0; i<$len1; i++ ))    
    do
      if [[ $i -ge $len2 ]]
      then
        return 1
      fi

      local item1=${list1[$i]}
      local item2=${list2[$i]}
      local arr1=()
      local arr2=()

      is_list "${list1[$i]}"
      local is_list1=$?

      is_list "${list2[$i]}"
      local is_list2=$?

      if [[ $is_list1 -eq 0 ]] && [[ $is_list2 -eq 0 ]]
      then
        split_packet "$item1" arr1
        split_packet "$item2" arr2
        check_arrays arr1 arr2
        local check_success=$?
        if [[ $check_success -eq 1 ]]
        then
            echo "(case 1) Item $item1 and $item2 are not ordered"
            return 1
        fi
      elif [[ $is_list1 -eq 0 ]]
      then
        local item2_as_list="[$item2]"
        split_packet "$item1" arr1
        split_packet "$item2_as_list" arr2
        check_arrays arr1 arr2
        local check_success=$?
        if [[ $check_success -eq 1 ]]
        then
            echo "(case 2) Item $item1 and $item2 are not ordered"
            return 1
        fi
      elif [[ $is_list2 -eq 0 ]]
      then
        local item1_as_list="[$item1]"
        split_packet "$item1_as_list" arr1
        split_packet "$item2" arr2
        check_arrays arr1 arr2
        local check_success=$?
        if [[ $check_success -eq 1 ]]
        then
            echo "(case 3) Item $item1 and $item2 are not ordered"
            return 1
        fi
      else
        check_nums "$item1" "$item2"
        local check_success=$?
        if [[ $check_success -eq 1 ]]
        then
            echo "(case 4) Item $item1 and $item2 are not ordered"
            return 1
        fi
      fi
    
      # echo "list ($item1)? $is_list1 and list ($item2)? $is_list1"; 
    done
    return 0
}

is_list() { # Takes one string
    local part=$1
    local start=${part:0:1}
    [[ $start == "[" ]]
}

split_packet() { # Takes one string and one array reference
    local packet=$1
    local -n items=$2
    items=()
    local bracketCount=0    
    
    local collect=""
    
    for (( i=0; i<${#packet}; i++ )); 
    do

      local c=${packet:$i:1}
      # echo ">> $c"

      if [[ $c == "," ]] && [[ $bracketCount -eq 1 ]] # next item starts
      then
        items+=($collect)
        collect=""
      elif [[ $c == "," ]] # $bracketCount > 1
      then
        collect+="${c}"
      elif [[ $c == "[" ]] && [[ $bracketCount -eq 0 ]]
      then
          ((bracketCount+=1))
          # echo "BR (first): $bracketCount"
      elif [[ $c == "[" ]] # $bracketCount > 1
      then
        ((bracketCount+=1))
        collect+="${c}"
        # echo "BR++ (inside subitem): $bracketCount"
      elif [[ $c == "]" ]] && [[ $bracketCount -eq 1 ]] #final item
      then
          ((bracketCount-=1))
          items+=($collect)
          collect=""
          # echo "BR (final): $bracketCount"
      elif [[ $c == "]" ]] # $bracketCount > 1          
      then
          collect+="${c}"
          ((bracketCount-=1))
          # echo "BR-- (inside subitem): $bracketCount"
      else
        collect+="${c}"
      fi
      
    done  
}

# read_input "$input"

# check_order_nums 4 5
# echo "$?"

# check_order_nums -6 -5
# echo "$?"

# check_order_nums 7 5
#echo "$?"

# split_packet "[[4,4],4,4,4]" output

# echo "Result"
# echo "${output[*]}"
# echo "${#output[@]}"

# for (( j=0; j<${#output[@]}; j++ ))
# do
#   is_list "${output[$j]}"
#   echo "list (${output[$j]})? $?"; 
# done

packet1="[[4,4],4,4]"
packet2="[[4,4],4,4,4]"

split_packet $packet1 array1
split_packet $packet2 array2

check_arrays array1 array2