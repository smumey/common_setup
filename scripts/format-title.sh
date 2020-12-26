#!/bin/sh
series=$1
cut -d $'\t' -f1-3 - | sed -r \
	-e 's/\b([0-9])\b/0\1/g' \
	-e 's/"(.*)".*/\1/' \
	-e "s/(\w+)\t(\w+)\t(.*)/$series S\1E\2 \3/"
