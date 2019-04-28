#!/bin/bash

if [[ -z $BASH ]]; then
  cat >&2 <<MSG
Ndic is a bash program, and musb be run with bash.
MSG
  exit 1
fi

# variables
word=''
meanings=()
is_debug=false
is_speakable=false

main () {
  if [[ -z $1 ]]; then
    print_help
    exit 1
  fi

  # reset option index
  OPTIND=1

  # parse arguments
  while getopts 'hdsc' opt; do
    case $opt in
      h) # help
        print_help
        exit 0
        ;;
      d) # turn on debug
        is_debug=true
        ;;
      s) # speak word
        is_speakable=true
        ;;
      c) # get the clipboard
        word=$(pbpaste)
        echo "$word"
        ;;
      *)
        print_help
        exit 1
        ;;
    esac
  done

  # set word if empty
  [[ -z "$word" ]] && word=${@:$OPTIND}

  debug "WORD: $word"

  if [[ $word ]]; then
    search # search only if the word is not empty
  fi
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
  speak_word
}

get_url () {
  # use mobile assistant dictionary
  echo "https://endic.naver.com/searchAssistDict.nhn?query=${word// /%20}"
}

print_result () {
  local str="$1"
  local regex='<span class="fnt_k20"><strong>([^<]+)</strong></span>'

  debug "HTML: $str"

  while [[ $str =~ $regex ]]; do
    # print meaning
    echo "${BASH_REMATCH[1]}"

    # store meaning to array
    meanings+=("${BASH_REMATCH[1]}")

    # delete matched string
    str=${str/"${BASH_REMATCH}"/}
  done
}

speak_word () {
  # If the results exists, try to speak the word.
  if [[ ${is_speakable} = true && ${#meanings[@]} > 0 ]]; then
    if [[ $(uname) =~ Darwin* ]]; then # macOS
      say "${word}" 2> /dev/null
    # Linux, BSD
    elif hash spd-say 2> /dev/null; then
      spd-say -t female1 "${word}" 2> /dev/null
    elif hash espeak 2> /dev/null; then
      espeak "${word}" 2> /dev/null
    elif hash festival 2> /dev/null; then
      echo "${word}" | festival --tts 2> /dev/null
    fi
  fi
}

print_help () {
  cat <<MSG

Usage: ndic [-hds] <word>

Description:
  Find the meaning of <word> in English-Korean Dictionary.
  (Powered by Naver)

Options:
  -h  Show help message
  -d  Turn on debug mode
  -s  Speak the word
  -c  Search by clipboard contents

Examples:
  $ ndic nice
  [형용사](기분) 좋은, 즐거운, 멋진
  [명사]니스 ((프랑스 남동부의 피한지))

  $ ndic "good thing" # use quotes if a word has spaces
  [구어] 좋은 일; 좋은 착상; 행운; 경구; 진미; 사치품

  $ ndic -s nice # search and speak the word

  $ ndic -c # search by clipboard contents

MSG
}

main "$@"
