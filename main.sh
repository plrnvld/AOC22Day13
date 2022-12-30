results=0

compare_lines() {
    local packet1=$1
    local packet2=$2
    local index=$3
    local array1=()
    local array2=()
    # echo "*****"
    echo "- Compare "$1" vs "$2""
    # echo "*****"
    split_packet $packet1 array1
    split_packet $packet2 array2

    check_arrays array1 array2
    local is_success=$?
    if [[ $is_success -eq 0 ]] || [[ $is_success -eq 2 ]]
    then
        ((results+=index))
        echo "===========================> Check[$index] = $is_success, result now $results"
        echo ""
    else 
        echo "===========================> Check[$index] = $is_success"
        echo ""
    fi
}

read_input() {
    local index=1
    local pairs=()
    while read -r line
    do
        if test "$line" != ""; then
            
            pairs+=("$line")
            
            if test "${#pairs[@]}" -eq 2; then 
                compare_lines "${pairs[0]}" "${pairs[1]}" $index
                (( index++ ))
                pairs=()
            fi
        fi
    done < $1
}

check_nums() { # Takes two arguments
    # echo "> $1"
    # echo "> $2"
    if [[ "$1" -lt "$2" ]]
    then
        echo "    - Left side is smaller, so inputs are in the right order"
        return 0
    elif [[ "$1" -gt "$2" ]]
    then
        echo "    - Right side is smaller, so inputs are NOT in the right order"
        return 1
    else
        # echo "    - Same order, returning 2"
        return 2 # Introduce 2, as a sign that further checking is needed
    fi
}

get_index() { # Takes an array reference and a value
    local -n my_array=$1
    local value=$2
    for i in "${!my_array[@]}" 
    do
       if [[ "${my_array[$i]}" = "${value}" ]] 
       then
           return $i
       fi
    done
    return -1
}

check_items() { # Takes two strings that represent a number or a list
  local item1=$1
  local item2=$2
  echo "  - Compare $item1 vs $item2"

  is_list "$item1"
  local is_list1=$?

  is_list "$item2"
  local is_list2=$?
  
  if [[ $is_list1 -eq 0 ]] && [[ $is_list2 -eq 0 ]]
  then
    local arr1=()
    local arr2=()
    # echo "((case 1 L L))"
    split_packet "$item1" arr1
    split_packet "$item2" arr2
    check_arrays arr1 arr2
    local check_success=$?
    if [[ $check_success -ne 2 ]]
    then
        # echo "(case 1) Item $item1 and $item2 are not ordered"
        return $check_success
    else
        : # echo "Continuing from result $check_success, what to do?"
        : # echo "> Index $i of these (${list1[*]}) items"
    fi
  elif [[ $is_list1 -eq 0 ]]
  then
    # echo "((case 2 L N))"
    check_items $item1 "[$item2]"
    local check_success=$?
    return $check_success    
  elif [[ $is_list2 -eq 0 ]]
  then
    check_items "[$item1]" $item2
    local check_success=$?
    return $check_success  
  else
    # echo "((case 4 N N))"
    check_nums "$item1" "$item2"
    local check_success=$?
    if [[ $check_success -ne 2 ]]
    then
        return $check_success
    elif [[ $check_success -eq 2 ]]
    then
       : # echo "Result 2 received, current index $i of (${list1[*]}) items"
    fi
  fi
}

check_arrays() { # Takes two array references
    local -n list1=$1
    local -n list2=$2
    local len1=${#list1[@]}
    local len2=${#list2[@]}
    
    # echo "Length 1: $len1"
    # echo "Length 2: $len2"

    # echo "Looping"
    # echo "${list1[*]}"
    # echo "${list2[*]}"
    # echo "Length 1: $len1"
    # echo "Length 2: $len2"
    # echo "-------"

    if [[ $len1 -eq 0 ]] # left has zero elements, so order correct
    then
        return 2
    fi
    for item1 in "${list1[@]}"  
    do
      get_index list1 "$item1"
      local i=$?
      # echo "   Next item, current index = $i of these (${list1[*]}) items"
    
      if [[ $i -ge $len2 ]]
      then
        echo "    - List 2 ends early"
        return 1
      fi

      local item2=${list2[$i]}
      check_items "$item1" "$item2"
      local check_success=$?
      if [[ $check_success -ne 2 ]]
      then
        echo "Received $check_success"
        return $check_success
      fi

      # echo "> End of one loop code, current index $i of these (${list1[*]}) items"
      # echo "list ($item1)? $is_list1 and list ($item2)? $is_list1"; 
      (( i+=1 ))
    done
    # echo ">> Full loop finished"
    
    return 2
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

read_input "Example.txt"
echo $results

# split_packet "[[[]],[]]" test
# echo "${test[*]}"
# echo "${#test[@]}"

# 3720 too low
# 5729 too high
# it's not 5617