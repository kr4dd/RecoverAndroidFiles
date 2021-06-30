@echo off
cls

set DIR=androidRecoverage

set psuc=persist.sys.usb.config
set bp=build.prop

md %DIR%
cd %DIR%

::Mount essential folders
adb shell mount data
adb shell mount system

::Pull files to bypass
adb pull /data/property/persist.sys.usb.config .
adb pull /system/build.prop .

::Modify files for allow `MTP`
findstr.exe /i mtp,adb %psuc%
if %errorlevel% neq 0 (
    echo mtp,adb > %psuc%
)

findstr.exe /i "persist.service.adb.enable=1" %bp%
if %errorlevel% neq 0 (
	echo persist.service.adb.enable=1 >> %bp%
)

findstr.exe /i "persist.service.debuggable=1" %bp%
if %errorlevel% neq 0 (
	echo persist.service.debuggable=1 >> %bp%
)

findstr.exe /i "persist.sys.usb.config=mtp,adb" %bp%
if %errorlevel% neq 0 (
	echo persist.sys.usb.config=mtp,adb >> %bp%
)

::Push modified files
adb push persist.sys.usb.config /data/property/
adb push build.prop /system/

::Reboot to recovery
adb reboot recovery

::Clean
rm persist.sys.usb.config build.prop
cd ..
rmdir %DIR%

::End
echo Waiting to reboot
timeout /t 60
::1min its ok

echo Checking connected devices...
echo.

echo Checking devices & adb devices -l | findstr.exe /i product