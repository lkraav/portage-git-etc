# portage/bashrc.d/91-git-etc.sh 0.1

echo Phase: $EBUILD_PHASE
ETC="${ROOT}etc"
GITCMD="GIT_DIR=$ETC/.git GIT_WORK_TREE=$ETC git"

case "$EBUILD_PHASE" in
    "setup")
        STATUS=$(eval $GITCMD status -uno -s)
        [ -n "${STATUS}" ] && die "Error: $ETC is not clean"
    ;;
    "postinst")
    ;;     
esac

post_pkg_postinst() {
    etc-update 0</dev/tty 1>/dev/tty || die "Error: etc-update somehow failed!"
    eval $GITCMD add $ETC
    eval $GITCMD commit -q -a -m \"emerge $CATEGORY/$P\"
}
