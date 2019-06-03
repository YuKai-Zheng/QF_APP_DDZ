source ~/.bash_profile
rm -rf build/
if test $# -eq 0
then gradle iosGamePrepare
else
#tw代表繁体中文
if [ "$1" = "zh_tr" ]
then
gradle iosTwGamePrepare
elif [ "$1" = "cn" ]
then
gradle iosGamePrepare -PREVIEW_FOLDER="$2" -PCHANNEL_FOLDER="$3" -PCHANNEL_NAME="$4"
else
gradle iosGamePrepare
fi
fi
