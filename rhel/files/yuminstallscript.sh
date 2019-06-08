#!/bin/bash
[[ -f /tmp/yumsuccess ]] && rm /tmp/yumsuccess
yum update libblkid  -y > /tmp/yumresult.txt
grep "Complete!" /tmp/yumresult.txt
if [ $? == 0 ]
then
touch /tmp/yumsuccess
fi

