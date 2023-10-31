if test -f "$TEST_TARGET_DIRECTORY/GIT-BUILD-DIR"
then
	TEST_TARGET_DIRECTORY="$(cat "$TEST_TARGET_DIRECTORY/GIT-BUILD-DIR")" || exit 1
	# On Windows, we must convert Windows paths lest they contain a colon
	case "$(uname -s)" in
	*MINGW*)
		TEST_TARGET_DIRECTORY="$(cygpath -au "$TEST_TARGET_DIRECTORY")"
		;;
	esac
fi

################################################################
# It appears that people try to run tests without building...
"${GIT_TEST_INSTALLED:-$TEST_TARGET_DIRECTORY}/git$X" >/dev/null
if test $? != 1
then
	if test -n "$GIT_TEST_INSTALLED"
	then
		echo >&2 "error: there is no working Git at '$GIT_TEST_INSTALLED'"
	else
		echo >&2 'error: you do not seem to have built git yet.'
	fi
	exit 1
fi

if test -n "$GIT_TEST_INSTALLED"
then
	GIT_EXEC_PATH=$($GIT_TEST_INSTALLED/git --exec-path)  ||
	error "Cannot run git from $GIT_TEST_INSTALLED."
	PATH=$GIT_TEST_INSTALLED:$TEST_LIB_DIRECTORY/helper:$PATH
	GIT_EXEC_PATH=${GIT_TEST_EXEC_PATH:-$GIT_EXEC_PATH}
else # normal case, use ../bin-wrappers only unless $with_dashes:
	if test -n "$no_bin_wrappers"
	then
		with_dashes=t
	else
		git_bin_dir="$TEST_TARGET_DIRECTORY/bin-wrappers"
		if ! test -x "$git_bin_dir/git"
		then
			if test -z "$with_dashes"
			then
				say "$git_bin_dir/git is not executable; using GIT_EXEC_PATH"
			fi
			with_dashes=t
		fi
		PATH="$git_bin_dir:$PATH"
	fi
	GIT_EXEC_PATH=$TEST_TARGET_DIRECTORY
	if test -n "$with_dashes"
	then
		PATH="$TEST_TARGET_DIRECTORY:$TEST_LIB_DIRECTORY/helper:$PATH"
	fi
fi

GIT_TEMPLATE_DIR="$TEST_TARGET_DIRECTORY"/templates/blt
export GIT_EXEC_PATH GIT_TEMPLATE_DIR

GITPERLLIB="$TEST_TARGET_DIRECTORY"/perl/build/lib
export GITPERLLIB
test -d "$TEST_TARGET_DIRECTORY"/templates/blt || {
	BAIL_OUT "You haven't built things yet, have you?"
}

if ! test -x "$TEST_LIB_DIRECTORY"/helper/test-tool$X
then
	BAIL_OUT 'You need to build test-tool; Run "make helper/test-tool" in the source (toplevel) directory'
fi
