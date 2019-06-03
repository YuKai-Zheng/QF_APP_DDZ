#/bin/sh
source /.bash_profile
rm -rf build/
if test $# -eq 0
  then gradle iosGamePrepare
else
  #tw代表繁体中文
  if [ "$1" = "zh_tr" ]
    then gradle iosTwGamePrepare
  else
    gradle zhaiosGamePrepare
  fi
fi
