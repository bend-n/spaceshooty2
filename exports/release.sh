#!/bin/bash

release_path=$(pwd) # place script in release folder

function download_and_push() {
    echo "Downloading $1"
    wget $1 -q -P $2 &> /dev/null
    butler push $2 $3:$4
    if [[ -n $5 ]]; then
        echo "not removing $4"
    else
        rm -rf "${2:?}/"*
    fi
}

cd .. || exit 1
repository=$(basename $(pwd))
echo $repository
cd exports || exit 1

path="https://github.com/bendnuts/$repository/releases/latest/download"

itch_path=bendn/$repository

download_and_push "$path/?inux.zip" "$release_path/linux" "$itch_path" linux true
download_and_push "$path/(html|HTML).zip" "$release_path/html" "$itch_path" html
download_and_push "$path/?indows.zip" "$release_path/windows" "$itch_path" windows
download_and_push "$path/?ac.zip" "$release_path/mac" "$itch_path" mac
