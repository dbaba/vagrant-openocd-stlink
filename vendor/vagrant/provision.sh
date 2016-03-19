#!/usr/bin/env bash

if [ -z "${OPENOCD_VERSION}" ]; then
  echo "OPENOCD_VERSION is undefined"
  exit 1
fi

if [ -z "${STLINK_VERSION}" ]; then
  echo "STLINK_VERSION is undefined"
  exit 1
fi

if [ -z "${GCC_ARM_URL}" ]; then
  echo "GCC_ARM_URL is undefined"
  exit 1
fi

HOMEDIR=${HOMEDIR:-${HOME}}

GCC_TARBALL=`basename ${GCC_ARM_URL}`
GCC_DIR=`python3 -c "print(\"${GCC_TARBALL}\"[0:\"${GCC_TARBALL}\".rindex('-',0,len(\"${GCC_TARBALL}\")-len('-linux.tar.bz2'))])"`
GCC_RELEASE_DIR=`python3 -c "print(\"${GCC_ARM_URL}\"[len('https://launchpad.net/gcc-arm-embedded/'):\"${GCC_ARM_URL}\".index('/+download')])"`

set -e
dpkg --add-architecture i386
apt-get update
apt-get -qq upgrade
apt-get -qq install build-essential autotools-dev autoconf \
 pkg-config libusb-1.0-0 libusb-1.0-0-dev libftdi1 libftdi-dev \
 git libc6:i386 libncurses5:i386 libstdc++6:i386 scons wget
cd ${HOMEDIR}
if [ ! -d "openocd-${OPENOCD_VERSION}" ]; then
  wget http://downloads.sourceforge.net/project/openocd/openocd/${OPENOCD_VERSION}/openocd-${OPENOCD_VERSION}.tar.gz
  tar xvfz openocd-${OPENOCD_VERSION}.tar.gz
  rm -f openocd-${OPENOCD_VERSION}.tar.gz
  cd openocd-${OPENOCD_VERSION}
  ./configure
  make
  make install
fi
cd ${HOMEDIR}
if [ ! -d "stlink-${STLINK_VERSION}" ]; then
  wget https://github.com/texane/stlink/archive/${STLINK_VERSION}.tar.gz
  mv ${STLINK_VERSION}.tar.gz stlink-${STLINK_VERSION}.tar.gz
  tar xvfz stlink-${STLINK_VERSION}.tar.gz
  rm -f stlink-${STLINK_VERSION}.tar.gz
  cd stlink-${STLINK_VERSION}
  set +e
  ./autogen.sh
  ./configure
  make
  make install || true
  cp 49-stlink*.rules /etc/udev/rules.d/
  udevadm control --reload-rules
  udevadm trigger
fi
cd ${HOMEDIR}
if [ ! -d "/usr/local/${GCC_DIR}" ]; then
  wget ${GCC_ARM_URL}
  tar xjf ${GCC_TARBALL}
  rm -f ${GCC_TARBALL}
  mv ${GCC_DIR} /usr/local/
fi
set +e
grep "${GCC_DIR}" ${HOMEDIR}/.bashrc > /dev/null
if [ "$?" != "0" ]; then
  echo "export PATH=/usr/local/${GCC_DIR}/bin:\$PATH" >> ${HOMEDIR}/.bashrc
  echo "export GCC_ARM_HOME=/usr/local/${GCC_DIR}" >> ${HOMEDIR}/.bashrc
  export PATH=/usr/local/${GCC_DIR}/bin:$PATH
  export GCC_ARM_HOME=/usr/local/${GCC_DIR}
fi
