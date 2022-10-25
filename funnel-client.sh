#!/bin/bash

ACTION=$1
TASK_ID=$2

if [ -z "$ACTION" ];
then
    ACTION='list'
fi

IP=

if [ -z "$VIEW" ];
then
    VIEW=MINIMAL
    #VIEW=BASIC
    #VIEW=FULL
fi

function new {
curl "http://$IP:8000/v1/tasks" -H  "accept: application/json" -H  "Content-Type: application/json" \
	-X POST -d @hello-world.json
}

function list {
curl "http://$IP:8000/v1/tasks?view=$VIEW" -H  "accept: application/json" -H  "Content-Type: application/json" \
	-sq | jq .
}

function view {
curl "http://$IP:8000/v1/tasks/$TASK_ID?view=$VIEW" -H  "accept: application/json" -H  "Content-Type: application/json" \
	-sq | jq .
}

if [ "$ACTION" == 'new' ];
then
    new
elif [ "$ACTION" == 'list' ];
then
    list
elif [ "$ACTION" == 'view' ];
then
    if [ -z "$TASK_ID" ];
    then
	    echo "Use: $0 view <TASK_ID>" >&2
	    exit 2
    fi
    view "$TASK_ID"
fi

