#!/bin/bash

rm -rf dist/*
./build_assets.sh
./build_pages.pl _site_how_to_solder.json
./build_pages.pl _site_quickfuzz.json
./build_pages.pl _site_index.json
