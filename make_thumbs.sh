#!/bin/bash

for file in $@
do
    echo $file
    dir=`dirname $file`
    fn=`basename $file`
    thumb="$dir/thumb-$fn"
    cp $file $thumb
    convert $file -resize 50% $thumb
done
