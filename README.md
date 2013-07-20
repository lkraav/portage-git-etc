portage-git-etc
===============

portage-git-etc is a bashrc hook for Gentoo portage, which automatically commits all changes made to /etc during
emerges, including deletions.

This hook cannot be used for unattended emerges, because we want to be able to link all filesystem changes to
the related package. Therefore, we call etc-update after every package, which in case of configuration updates will
pause emerge and wait for user input.

To maintain stability, ideally you would have no outstanding changes in /etc when emerging packages.


Requirements
============

This hook is built on top of bashrc.d implementation from https://github.com/vaeth/portage-bashrc-mv/
