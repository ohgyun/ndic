#!/bin/bash

# ndic <word>
# Search the word from dictionary

if [[ -z $BASH ]]; then
  cat >&2 <<MSG
Ndic is a bash program, and musb be run with bash.
MSG
  exit 1
fi

word=''
is_debug=false

main () {
  if [[ -z $1 ]]; then
    print_help 
    exit 1
  fi

  # reset option index
  OPTIND=1

  # parse arguments
  while getopts 'hd' opt; do
    case $opt in
      h)
        print_help
        exit 0
        ;;
      d) is_debug=true
        ;;
      *) echo 'invalid options error...';;
    esac
  done

  word=${@:$OPTIND}

  debug "WORD: $word"

  search
}

debug () {
  if $is_debug; then
    echo "$@"
  fi
}

search () {
  local url result

  url=`get_url`
  result=`curl -s "$url"`
  
  debug "URL: $url"

  print_result "$result"
}

get_url () {
  # use mobile assistant dictionary
  echo "http://m.endic.naver.com/assistDic.nhn?query=${word// /%20}"
}

print_result () {
  local str="$1"
  local regex='<p class="ly_p">([^<]+)</p>'

  debug "HTML: $str"

  while [[ $str =~ $regex ]]; do
    # print result
    echo "${BASH_REMATCH[1]}"

    # delete matched string
    str=${str/"${BASH_REMATCH}"/}
  done
}

print_help () {
  cat <<MSG

Usage: ndic [-hd] <word>

Description:
  Find the meaning of <word> in English-Korean Dictionary.
  (Powered by Naver)

Options:
  -h  Show help message
  -d  Turn on debug mode

MSG
}

main "$@"