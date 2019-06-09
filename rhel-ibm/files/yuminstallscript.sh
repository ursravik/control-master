#!/bin/bash
[[ -f /tmp/yumsuccess ]] && rm /tmp/yumsuccess
[[ -f /tmp/yumresult.txt ]] && rm /tmp/yumresult.txt
yum update -y > /tmp/yumresult.txt
grep "Complete!" /tmp/yumresult.txt
if [ $? == 0 ]
then
touch /tmp/yumsuccess
fi

