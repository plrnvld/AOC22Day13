input="./Example.txt"

compare_lines() {
    echo "*****"
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

read_input "$input"