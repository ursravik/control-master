#!/bin/bash
[[ -f /tmp/yumsuccess ]] && rm /tmp/yumsuccess
[[ -f /tmp/yumresult.txt ]] && rm /tmp/yumresult.txt
[[ -f /tmp/lssecfixes.output ]] && rm /tmp/lssecfixes.output

chmod +x /tmp/lssec/bin/lssecfixes
/tmp/lssec/bin/lssecfixes -t, > /tmp/lssecfixes.output

for i in `cat /tmp/lssecfixes.output | grep RHSA | awk -F',' '{print $5}' | cut -d ":" -f1,2`
do
echo yum update --advisory=$i -y >> /tmp/yumresult.txt
done

grep "Complete!" /tmp/yumresult.txt

if [ $? == 0 ]
then
touch /tmp/yumsuccess
fi

