#!/bin/bash

release_path=$(pwd) # place script in release folder

cd .. || exit 1
repository=$(basename $(pwd))
echo "$repository"
cd exports || exit 1

url="https://github.com/bendnuts/$repository/releases/latest/download"

itch_path=bendn/$repository

function download_and_push() {
    keep=$3
    download_url=$url/$1
    channel=$2
    path="$release_path/$channel"
    if [[ -n $keep ]]; then
        rm -rf "${channel:?}/*"
    fi
    echo "Downloading $download_url"
    wget "$download_url" -qP "$path" &> /dev/null
    # butler push "$path" "$itch_path":"$channel"
    if [[ -n $keep ]]; then
        echo "not removing $channel"
        atool -qX "$path" "$path/$1"
        rm -rf "${path:?}/$1"
    else
        rm -rf "${channel:?}/$1"
    fi
}


download_and_push "Linux.zip" linux keep
download_and_push "HTML.zip" html
download_and_push "Windows.zip" windows
download_and_push "Mac.zip" mac
