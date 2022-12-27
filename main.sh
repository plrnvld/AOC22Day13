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

check_order_nums() {
    echo "> $1"
    echo "> $2"
    [ "$1" -le "$2" ]
    return
}

split_packet() {
    local packet=$1
    local -n items=$2
    local bracketCount=0    
    
    local collect=""
    
    for (( i=0; i<${#packet}; i++ )); 
    do

      local c=${packet:$i:1}
      echo ">> $c"

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
          echo "BR (first): $bracketCount"
      elif [[ $c == "[" ]] # $bracketCount > 1
      then
        ((bracketCount+=1))
        collect+="${c}"
        echo "BR++ (inside subitem): $bracketCount"
      elif [[ $c == "]" ]] && [[ $bracketCount -eq 1 ]] #final item
      then
          ((bracketCount-=1))
          items+=($collect)
          collect=""
          echo "BR (final): $bracketCount"
      elif [[ $c == "]" ]] # $bracketCount > 1          
      then
          collect+="${c}"
          ((bracketCount-=1))
          echo "BR-- (inside subitem): $bracketCount"
      else
        collect+="${c}"
      fi
      
    done
    
    # items+=("two" "three")    
}

# read_input "$input"

# check_order_nums 4 5
# echo "$?"

# check_order_nums -6 -5
# echo "$?"

# check_order_nums 7 5
#echo "$?"

split_packet "[1,10,311,[1,2,[2]],1]" output

echo "Print result"
echo "${output[*]}"
echo "End print"


