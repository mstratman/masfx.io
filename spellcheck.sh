#!/bin/bash

echo "PRACTICE FILES"
for f in pages/practice/*.html pages/practice/*/*.html
do
    #echo $f
    aspell -H check $f 
done

for f in pages/practice/*.md pages/practice/*/*.md
do
    #echo $f
    aspell -M check $f
done

echo "QUICKFUZZ FILES"
for f in pages/quickfuzz/*.html pages/quickfuzz/*/*.html
do
    #echo $f
    aspell -H check $f 
done

for f in pages/quickfuzz/*.md pages/quickfuzz/*/*.md
do
    #echo $f
    aspell -M check $f
done


echo "----------------"
echo "other books have not been checked!"
echo "----------------"
