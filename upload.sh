#!/bin/bash

rsync -av --delete --exclude-from='no-upload.txt' ./ frozenfractal.com:/var/www/aranami.frozenfractal.com/
