if test ! -f "$TEST_TARGET_DIRECTORY"/GIT-BUILD-OPTIONS
then
	echo >&2 'error: GIT-BUILD-OPTIONS missing (has Git been built?).'
	exit 1
fi
. "$TEST_TARGET_DIRECTORY"/GIT-BUILD-OPTIONS
