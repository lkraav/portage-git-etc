#!/bin/bash
# portage/bashrc.d/91-git-etc.sh 0.1

ETC="${PORTAGE_CONFIGROOT%/}/etc"
GITCMD="GIT_DIR=$ETC/.git GIT_WORK_TREE=$ETC GIT_AUTHOR_NAME=Portage GIT_AUTHOR_EMAIL=portage@${HOST} git"
HOST="$(hostname)"
MYPREFIX="[91]"

GitEtcAll() {
    echo "${MYPREFIX} Phase: $EBUILD_PHASE"
}

GitEtcSetup() {
    BashrcdTrue ${ENABLE_91_GIT_ETC} || return 0

    STATUS=$(eval $GITCMD status -uno -s)
    [ -n "${STATUS}" ] && die "${MYPREFIX} Error: $ETC is not clean"
}

GitEtcPostInst() {
    BashrcdTrue ${ENABLE_91_GIT_ETC} || return 0

    etc-update 0</dev/tty 1>/dev/tty || die "${MYPREFIX} Error: etc-update failed!"
    eval $GITCMD add $ETC
    eval $GITCMD commit -q -a -m \"emerge $CATEGORY/$P\"
}

BashrcdPhase all GitEtcAll
BashrcdPhase setup GitEtcSetup
BashrcdPhase postinst GitEtcPostInst
