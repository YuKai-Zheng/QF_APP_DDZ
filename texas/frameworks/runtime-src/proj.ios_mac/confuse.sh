#!/usr/bin/env bash

python ./proj.ios_mac/confuses/code_confuse.py
python ./proj.ios_mac/confuses/delete_comment.py
python ./proj.ios_mac/confuses/image_compress.py
python $PROGRAM_PATH/file_confuse.py
python $PROGRAM_PATH/modify_project.py
