results=0

compare_lines() {
    local packet1=$1
    local packet2=$2
    local index=$3
    local array1=()
    local array2=()
    # echo
    # echo "== Pair ${index} =="
    # echo "- Compare "$1" vs "$2""
    split_packet $packet1 array1
    split_packet $packet2 array2

    check_arrays array1 array2 0
    local is_success=$?
    if [[ $is_success -eq 0 ]] || [[ $is_success -eq 2 ]]
    then
        ((results+=index))
        # echo ""
        : # echo "Right order, result is now $results"
        # echo ""
    else
        # echo ""
        : # echo "Wrong order"
        # echo ""
    fi
    return $is_success
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

read_input_to_array() {
    local index=1
    input_array=()
    while read -r line
    do
        # echo "Reading ${line}"
        if test "$line" != ""; then
            # echo "> Adding"
            input_array+=("${line}")
        fi
    (( index++ ))
    done < $1
}

check_nums() { # Takes two string arguments that represent numbers
    local level=$3
    local indent=`printf '%*s' "$level"`
    
    if [[ "$1" -lt "$2" ]]
    then
        # echo "${indent}- Left side is smaller, so inputs are in the right order"
        return 0
    elif [[ "$1" -gt "$2" ]]
    then
        # echo "${indent}- Right side is smaller, so inputs are NOT in the right order"
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
  local level=$3
  local next_level=$((level+2))
  local indent=`printf '%*s' "$level"`
  local next_indent=`printf '%*s' "$next_level"`
  # echo "${indent}- Compare $item1 vs $item2"

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
    check_arrays arr1 arr2 "$next_level"
    local check_success=$?
    return $check_success
  elif [[ $is_list1 -eq 0 ]] && [[ $is_list2 -eq 1 ]]
  then
    # echo "((case 2 L N))"
    # echo "${next_indent}- Mixed types; convert right to [${item2}] and retry comparison"
    check_items $item1 "[$item2]" "$next_level"
    local check_success=$?
    return $check_success
  elif [[ $is_list1 -eq 1 ]] && [[ $is_list2 -eq 0 ]]
  then
    # echo "((case 3 N L))"
    # echo "${next_indent}- Mixed types; convert left to [${item1}] and retry comparison"
    check_items "[$item1]" $item2 "$next_level"
    local check_success=$?
    return $check_success 
  elif [[ $is_list1 -eq 1 ]] && [[ $is_list2 -eq 1 ]]
  then
    # echo "((case 4 N N))"
    check_nums "$item1" "$item2" "$next_level"
    local check_success=$?
    return $check_success
  fi

  echo "Error! ($item1) is list: $is_list1, ($item2) is_list: $is_list2"
  exit 64
}

check_arrays() { # Takes two array references
    local -n list1=$1
    local -n list2=$2
    local len1=${#list1[@]}
    local len2=${#list2[@]}
    local level=$3
    local next_level=$((level+2))
    local indent=`printf '%*s' "$level"`
    local next_indent=`printf '%*s' "$next_level"`

    if [[ $len1 -eq 0 ]] && [[ $len2 -eq 0 ]]
    then
        return 2    
    elif [[ $len1 -eq 0 ]]
    then
        # echo "${next_indent}- Left side ran out of items, so inputs are in the right order"
        return 0
    elif [[ $len2 -eq 0 ]] 
    then
        # echo "${next_indent}- Right side ran out of items, so inputs are NOT in the right order"
        return 1
    fi

    local pos=0
    local item1
    for item1 in "${list1[@]}"  
    do
      if [[ $pos -ge $len2 ]]
      then
        # echo "${next_indent}- Right* side ran out of items, so inputs are NOT in the right order"
        return 1
      fi

      local item2=${list2[$pos]}
      check_items "$item1" "$item2" "$next_level"
      local check_success=$?
      if [[ $check_success -ne 2 ]]
      then
        return $check_success
      fi

      (( pos+=1 ))
    done

    if [[ $len1 -gt $len2 ]]
    then
        # echo "${next_indent}- Right side ran out of items, so inputs are NOT in the right order"
        return 1
    elif [[ $len1 -lt $len2 ]]
    then
        # echo "${next_indent}- Left side ran out of items, so inputs are in the right order"
        return 0
    fi

    # echo "Returning 2 after the loop"
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
      if [[ $c == "," ]] && [[ $bracketCount -eq 1 ]]
      then
        items+=($collect)
        collect=""
      elif [[ $c == "," ]] # $bracketCount > 1
      then
        collect+="${c}"
      elif [[ $c == "[" ]] && [[ $bracketCount -eq 0 ]]
      then
          ((bracketCount+=1))
      elif [[ $c == "[" ]] # $bracketCount > 1
      then
        ((bracketCount+=1))
        collect+="${c}"
      elif [[ $c == "]" ]] && [[ $bracketCount -eq 1 ]] #final item
      then
          ((bracketCount-=1))
          items+=($collect)
          collect=""
      elif [[ $c == "]" ]] # $bracketCount > 1          
      then
          collect+="${c}"
          ((bracketCount-=1))
      else
        collect+="${c}"
      fi      
    done  
}

# read_input "Input.txt"
# echo $results

qsort() {
   local pivot entry smaller=() larger=()
   qsort_ret=()
   (($#==0)) && return 0
   pivot=$1
   shift
   for entry; do
      # This sorts strings lexicographically.
      # [[ $entry < $pivot ]]
      compare_lines "$entry" "$pivot"
      if [[ $? -eq 0 ]]; then
         smaller+=( "$entry" )
      else
         larger+=( "$entry" )
      fi
   done
   qsort "${smaller[@]}"
   smaller=( "${qsort_ret[@]}" )
   qsort "${larger[@]}"
   larger=( "${qsort_ret[@]}" )
   qsort_ret=( "${smaller[@]}" "$pivot" "${larger[@]}" )
}

array=(a c b f 3 5)
# qsort "${array[@]}"
# declare -p qsort_ret
# declare -a qsort_ret='([0]="3" [1]="5" [2]="a" [3]="b" [4]="c" [5]="f")'

# echo "${qsort_ret[*]}"

read_input_to_array "Input.txt"

echo "Length: ${#input_array[@]}"
qsort "${input_array[@]}"
echo "${qsort_ret[*]}"
echo

num=1
for sorted_line in "${qsort_ret[@]}"
do
   echo "[${num}] [${sorted_line}]"
   (( num ++ ))
done