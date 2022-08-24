SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
if lsb_release -i | grep -qi manjaro ; then
  bash $SCRIPTPATH/_init/arch.sh
else
  echo no script for installing your os. please add one to ./bin/_init
fi
