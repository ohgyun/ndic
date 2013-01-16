#!/bin/bash

# ndic <word>
# Search the word from dictionary

if [[ -z $BASH ]]; then
  cat >&2 <<MSG
Ndic is a bash program, and musb be run with bash.
MSG
  exit 1
fi

main () {
  if [[ -z $1 ]]; then
    echo "usage: ndic <word>"
  fi
  search "$1"
}

search () {
  local url
  local result

  url=`get_url "$1"`
  result=`curl -s "$url"`
  
  print_result "$result"
}

get_url () {
  # use mobile assistant dictionary
  echo "http://m.endic.naver.com/assistDic.nhn?query=${1// /%20}"
}

print_result () {
  local str="$1"
  local regex='<p class="ly_p">([^<]+)</p>'

  while [[ $str =~ $regex ]]; do
    # print result
    echo "${BASH_REMATCH[1]}"

    # delete matched string
    str=${str/"${BASH_REMATCH}"/}
  done
}

main "$@"