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

read_input "$input"

check_order_nums 4 5
echo "$?"

check_order_nums -6 -5
echo "$?"



check_order_nums 7 5
echo "$?"