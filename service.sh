#!/system/bin/sh
MODDIR="$(dirname $(readlink -f "$0"))"

until [[ $(getprop sys.boot_completed) -eq 1 ]]; do
	sleep 2
done

sdcard_rw() {
	local test_file="/sdcard/Android/.Redirect_test"
	touch $test_file
	while [[ ! -f $test_file ]]; do
		touch $test_file
		sleep 1
	done
	rm $test_file
}

PROCESS() {
	ps -ef | grep "Cloud_Redirect.sh" | grep -v grep | wc -l
}

ROOTS() {
	chmod 0777 $1
	chown root:root $1
}

Network_Connection() {
	if [[ $(ping -c 1 1.2.4.8) ]] >/dev/null 2>&1; then
		echo 0
	elif [[ $(ping -c 1 8.8.8.8) ]] >/dev/null 2>&1; then
		echo 0
	elif [[ $(ping -c 1 114.114.114.114) ]] >/dev/null 2>&1; then
		echo 0
	else
		echo 1
	fi
}

sdcard_rw

if [[ "$(cat $MODDIR/files/Variable.sh | grep "$PATH")" == "" ]]; then
	echo "" >> $MODDIR/files/Variable.sh
	echo "PATH=\"$PATH:/system/sbin:/sbin/.magisk/busybox:$(magisk --path)/.magisk/busybox\"" >> $MODDIR/files/Variable.sh
fi


[[ -f $MODDIR/Cloud_Redirect.sh ]] && rm -rf $MODDIR/Cloud_Redirect.sh

. $MODDIR/files/Variable.sh

until [[ $(Network_Connection) == 0 ]]; do
	sleep 5
done

cd $MODDIR

if [[ ! -z $(which curl) ]]; then
	curlwget="curl"
	until [[ -f $MODDIR/Redirect.prop ]]; do
		curl -O 'https://gitee.com/Petit-Abba/Third-Party-Redirect/raw/master/Cloud_Redirect.sh' >/dev/null 2>&1
		sleep 2
	done
elif [[ ! -z $(which wget) ]]; then
	curlwget="wget"
	until [[ -f $MODDIR/Redirect.prop ]]; do
		wget 'https://gitee.com/Petit-Abba/Third-Party-Redirect/raw/master/Cloud_Redirect.sh' >/dev/null 2>&1
		sleep 2
	done
fi

ROOTS $MODDIR/files/Author_Information/QQGroup
ROOTS $MODDIR/files/Author_Information/Coolapk
ROOTS $MODDIR/Cloud_Redirect.sh

until [[ $(PROCESS) -ne 0 ]]; do
	nohup sh $MODDIR/Cloud_Redirect.sh &
	sleep 2
done