#!/bin/bash                                            

#IFS=$(echo -en "\n")

TRACKED="False"
UNTRACKED="False"
STAGED="False"   
UNSTAGED="False" 

if [[ $# > 1 ]]
then           
   echo "You can specify only one of the following options: --tracked, --untracked, --staged, --unstaged"
   exit 1                                                                                                
fi

if [[ $# == 1 ]]
then
    case $1 in
        --tracked)
            TRACKED="True";
             ;;
        --untracked)
            UNTRACKED="True";
             ;;
        --staged)
            STAGED="True";
             ;;
        --unstaged)
            UNSTAGED="True";
             ;;
        *)
            echo "unrecpognized option: $1";
            exit 1;
        ;;
    esac
fi

if [[ $# == 0 ]]
then
    TRACKED="True"
fi

if [[ $TRACKED == "True" ]]
then
    git status --short --untracked-files=no | awk -F " " '{print $2}'
    exit 0
fi

if [[ $UNTRACKED == "True" ]]
then
    git status --short --untracked-files=all | grep ?? | sed "s:^?? ::g"
fi

if [[ $STAGED == "True" ]]
then
    for file in `git status --short --untracked-files=no | sed "s: :|:g"`
    do
        if [[ `echo ${file:0:1}` != "|" ]]
        then
            echo ${file:3}
        fi
    done
    exit 0
fi

if [[ $UNSTAGED == "True" ]]
then
	 git status --short --untracked-files=no | grep -e "^.M.*" -e "^.D.*" | cut -c 4- | tr -d '"'
fi

exit 0