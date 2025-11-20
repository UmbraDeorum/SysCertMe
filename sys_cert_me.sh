#!/bin/bash

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NOCOLOR='\033[0m'

CERTFILE_DER=$1

echo -ne "${GREEN}"
cat <<\EOF

 __              ___         _/\
/ _\_   _ ___   / __\___ _ __| |_  /\/\   ___
\ \| | | / __| / /  / _ \ '__| __|/    \ / _ \
_\ \ |_| \__ \/ /__|  __/ |  | |_/ /\/\ \  __/
\__/\__, |___/\____/\___|_|   \__\/    \/\___|
    |___/

EOF

echo -e "\nChecking for root...${NOCOLOR}"

adb root

echo -e "\n${GREEN}Preparing the device...${NOCOLOR}\n"

adb shell mount -o rw,remount /system
sleep 1

echo -e "${GREEN}Preparing the certificate file...${NOCOLOR}\n"

CERT_HASH=$(openssl x509 -inform DER -in "$CERTFILE_DER" -outform pem | openssl x509 -inform PEM -subject_hash_old | head -1)

openssl x509 -inform DER -in "$CERTFILE_DER" -outform pem -out ${CERT_HASH}.0

echo -e "${GREEN}Pushing and configuring the certificate file...${NOCOLOR}\n"

adb push "$CERT_HASH".0 /system/etc/security/cacerts/
adb shell chmod 644 /system/etc/security/cacerts/${CERT_HASH}.0
adb shell restorecon -F /system/etc/security/cacerts/${CERT_HASH}.0

echo -e "\n${GREEN}Completed adding certificate to system certs! ${NOCOLOR}\n"
echo -e "${CYAN} [o] ${NOCOLOR} $CERTFILE_DER"
echo "  |  "
echo "  v  "
echo -ne "${CYAN} [+] ${NOCOLOR}"
adb shell ls -l /system/etc/security/cacerts/${CERT_HASH}.0 | awk -F" " '{ print $8":\n\n    \033[0;36m[!]\033[0m "$1 }'
echo -ne "${CYAN}    [!] ${NOCOLOR}"
adb shell ls -Z /system/etc/security/cacerts/${CERT_HASH}.0 | awk -F" " '{ print $1}'

echo -e "${GREEN}\nImplementing Chromium Certificate Transparency Bypass...${NOCOLOR}\n"

SPKI_FINGERPRINT=$(openssl x509 -in ${CERT_HASH}.0 -inform pem -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64)
CHROMIUM_BREAKER="chrome --ignore-certificate-errors-spki-list=${SPKI_FINGERPRINT}"
echo -n "$CHROMIUM_BREAKER" > chromium_breaker

adb push chromium_breaker /data/local/chrome-command-line
adb push chromium_breaker /data/local/android-webview-command-line
adb push chromium_breaker /data/local/webview-command-line
adb push chromium_breaker /data/local/content-shell-command-line
adb push chromium_breaker /data/local/tmp/chrome-command-line
adb push chromium_breaker /data/local/tmp/android-webview-command-line
adb push chromium_breaker /data/local/tmp/webview-command-line
adb push chromium_breaker /data/local/tmp/content-shell-command-line

adb shell "chmod 555 /data/local/chrome-command-line"
adb shell "chmod 555 /data/local/android-webview-command-line"
adb shell "chmod 555 /data/local/webview-command-line"
adb shell "chmod 555 /data/local/content-shell-command-line"
adb shell "chmod 555 /data/local/tmp/chrome-command-line"
adb shell "chmod 555 /data/local/tmp/android-webview-command-line"
adb shell "chmod 555 /data/local/tmp/webview-command-line"
adb shell "chmod 555 /data/local/tmp/content-shell-command-line"

adb shell am force-stop com.android.chrome

echo -e "\n${GREEN}Bypass completed...${NOCOLOR}"

echo -e "\n${GREEN}Cleanup...${NOCOLOR}\n\n"

rm ${CERT_HASH}.0
rm chromium_breaker
