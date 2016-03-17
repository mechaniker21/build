#!/bin/bash

SDK_VER=23
CUSTOM_VER=123
CUSTOM_NAME=emotion

. ${ANDROID_BUILD_TOP}/vendor/emotion/tools/colors

if [ -z "$OUT" ]; then
    echo -e $red"Please lunch a product before using this command"$rst
    exit 1
else
    OUTDIR=${OUT%/*/*/*}
fi

STUBJAR=${OUTDIR}/target/common/obj/JAVA_LIBRARIES/android_stubs_current_intermediates/classes.jar
FRAMEWORKJAR=${OUTDIR}/target/common/obj/JAVA_LIBRARIES/framework_intermediates/classes.jar
TELEPHONYJAR=${OUTDIR}/target/common/obj/JAVA_LIBRARIES/telephony-common_intermediates/classes.jar
COMMONJAR=${OUTDIR}/target/common/obj/JAVA_LIBRARIES/android-common_intermediates/classes.jar

if [ ! -f $STUBJAR ]; then
make $STUBJAR
fi
if [ ! -f $FRAMEWORKJAR ]; then
make $FRAMEWORKJAR
fi
if [ ! -f $TELEPHONYJAR ]; then
make $TELEPHONYJAR
fi
if [ ! -f $COMMONJAR ]; then
make $COMMONJAR
fi

TMP_DIR=${OUTDIR}/tmp
mkdir -p ${TMP_DIR}
$(cd ${TMP_DIR}; jar -xf ${STUBJAR})
$(cd ${TMP_DIR}; jar -xf ${FRAMEWORKJAR})
$(cd ${TMP_DIR}; jar -xf ${TELEPHONYJAR})
$(cd ${TMP_DIR}; jar -xf ${COMMONJAR})

jar -cf ${OUTDIR}/android.jar -C ${TMP_DIR}/ .

echo -e $grn"android.jar created at ${OUTDIR}/android.jar"$rst
echo -e $ylw"Now attempting to create new sdk platform with it"$rst

if [ -z "$ANDROID_HOME" ]; then
    ANDROID=$(command -v emulator)
    ANDROID_HOME=${ANDROID%/*}
    if [ -z "$ANDROID_HOME" ]; then
        echo -e $red"ANDROID_HOME variable is not set. Do you have the sdk installed ?"$rst
        exit 1
    fi
fi

cp -rf ${ANDROID_HOME}/platforms/android-${SDK_VER} ${ANDROID_HOME}/platforms/android-${SDK_VER}-${CUSTOM_NAME}
rm -f ${ANDROID_HOME}/platforms/android-${SDK_VER}-${CUSTOM_NAME}/android.jar
cp -f ${OUTDIR}/android.jar ${ANDROID_HOME}/platforms/android-${SDK_VER}-${CUSTOM_NAME}/android.jar
sed -i 's/^ro\.build\.version\.sdk=.*/ro.build.version.sdk=123/g' ${ANDROID_HOME}/platforms/android-${SDK_VER}-${CUSTOM_NAME}/build.prop
sed -i 's/^ro\.build\.version\.release=.*/ro.build.version.release=6.0.1-emotion/g' ${ANDROID_HOME}/platforms/android-${SDK_VER}-${CUSTOM_NAME}/build.prop
sed -i 's/AndroidVersion.ApiLevel=23/AndroidVersion.ApiLevel=123/' ${ANDROID_HOME}/platforms/android-${SDK_VER}-${CUSTOM_NAME}/source.properties
sed -i 's/Pkg.Desc=/Pkg.Desc=EMOTION /' ${ANDROID_HOME}/platforms/android-${SDK_VER}-${CUSTOM_NAME}/source.properties

if [ -f ${ANDROID_HOME}/platforms/android-${SDK_VER}-${CUSTOM_NAME}/android.jar ]; then
    echo -e $cya"New SDK platform with custom android.jar created inside ${ANDROID_HOME}"$rst
fi

