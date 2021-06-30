#!/usr/bin/env bash

DIR="androidRecoverage"

function cleanStuff() {
	rm -f persist.sys.usb.config build.prop ; cd .. ; rmdir $DIR
}

mkdir $DIR
cd $DIR

#Mount essential folders
adb shell mount data
adb shell mount system

#Pull files to bypass
adb pull /data/property/persist.sys.usb.config .
adb pull /system/build.prop .

#Modify files for allow `MTP`
if ! grep -i "mtp," persist.sys.usb.config ; then
	sed -i 's/adb/mtp,&/' persist.sys.usb.config
fi

if ! grep -i "persist.service.adb.enable=1" build.prop ; then
	echo "persist.service.adb.enable=1" >> build.prop
fi

if ! grep -i "persist.service.debuggable=1" build.prop ; then
	echo "persist.service.debuggable=1" >> build.prop
fi

if ! grep -i "persist.sys.usb.config=mtp,adb" build.prop ; then
	echo "persist.sys.usb.config=mtp,adb" >> build.prop
fi


#Push modified files
adb push persist.sys.usb.config /data/property/
adb push build.prop /system/

#Reboot to recovery
adb reboot recovery

# End
cleanStuff

echo "Waiting to reboot"
sleep 60 # 1min its ok

echo -ne "Checking connected devices";for dot in {1..3} ; do echo -ne . ;sleep 1 ; done
echo -ne "\n"
adevice=$(adb devices -l | grep -i product | awk -F':' '{ print $2 }')
[[ ! -z "$adevice" ]] && echo "MTP is correct mounted" || echo "Failed to mount android MTP"