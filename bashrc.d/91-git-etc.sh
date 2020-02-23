#!/bin/bash
VERSION="0.3"
ETC="${PORTAGE_CONFIGROOT%/}/etc"
GIT_AUTHOR_NAME=Portage
GIT_AUTHOR_EMAIL=portage@${HOSTNAME}
GIT_COMMITTER_NAME="${GIT_AUTHOR_NAME}"
GIT_COMMITTER_EMAIL="${GIT_AUTHOR_EMAIL}"
GIT_DIR=$ETC/.git
GIT_WORK_TREE=$ETC
MY_PREFIX="[91.${VERSION}@${HOSTNAME} ${ROOT}]"
MY_TRIGGER="$PORTAGE_BUILDDIR/.${0##*/}_postinst"

# Until solution, use cmdline `MY_TTY=$(tty) emerge`
# 0 - /dev/null, 1 - pipe, 2 - bingo - sometimes?
# @see https://unix.stackexchange.com/questions/187319/how-to-get-the-real-name-of-the-controlling-terminal
#MY_TTY=$(readlink /proc/self/fd/2)

GitEtcAll() {
    echo "${MY_PREFIX} Phase: $EBUILD_PHASE"
}

GitEtcSetup() {
    BashrcdTrue ${ENABLE_91_GIT_ETC} || return 0

    # Attempt auto-commit
    [[ -e $MY_TRIGGER ]] && GitEtcPostInstClean

    export GIT_DIR GIT_WORK_TREE

    # Maybe rescue. Portage redirects, interactive shell needs controlling terminal.
    # @see https://archives.gentoo.org/gentoo-dev/message/794a56972427311c38b6353a322c7d61
    STATUS=$(git status -unormal -s)
    [[ -n "${STATUS}" && -n "${MY_TTY}" ]] && git-sh 0<"${MY_TTY}" 1>"${MY_TTY}"

    # Dirty worktree fail
    STATUS=$(git status -unormal -s)
    [ -n "${STATUS}" ] && die "${MY_PREFIX} Error: $ETC is not clean"
}

GitEtcPostInst() {
    >> $MY_TRIGGER
}

# Refactor to `post_pkg_postinst()`?
# @see https://github.com/vaeth/portage-bashrc-mv/issues/21
GitEtcPostInstClean() {
    [[ -n "${MY_TTY}" ]] && dispatch-conf 0<"${MY_TTY}" 1>"${MY_TTY}" || die "${MYPREFIX} Error: dispatch-conf failed!"

    export GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL GIT_DIR GIT_WORK_TREE
    git add $ETC
    git commit -q -a -m "emerge ${CATEGORY}/${P}"

    GitEtcCleanTrigger
}

BashrcdPhase all GitEtcAll
BashrcdPhase clean GitEtcSetup
BashrcdPhase postinst GitEtcPostInst

GitEtcCleanTrigger() {
    # @see https://github.com/gentoo/portage/blob/9b1992c050bf9fa698f227e635af5c341e85c9a4/bin/phase-functions.sh#L309
    [[ -e $MY_TRIGGER ]] && rm $MY_TRIGGER && rmdir "$PORTAGE_BUILDDIR" 2>/dev/null
}

register_die_hook GitEtcCleanTrigger
