# Restore environment variables modified by activate.sh

# Restore original PATH
[ -n "${RUBY27_OLD_PATH+x}" ] && PATH="$RUBY27_OLD_PATH" && export PATH && unset RUBY27_OLD_PATH

# Restore original RUBYLIB
[ -n "${RUBY27_OLD_RUBYLIB+x}" ] && RUBYLIB="$RUBY27_OLD_RUBYLIB" && export RUBYLIB && unset RUBY27_OLD_RUBYLIB

# Restore original GEM_HOME
[ -n "${RUBY27_OLD_GEM_HOME+x}" ] && GEM_HOME="$RUBY27_OLD_GEM_HOME" && export GEM_HOME && unset RUBY27_OLD_GEM_HOME

# Restore original GEM_PATH
[ -n "${RUBY27_OLD_GEM_PATH+x}" ] && GEM_PATH="$RUBY27_OLD_GEM_PATH" && export GEM_PATH && unset RUBY27_OLD_GEM_PATH

# Restore original LD_LIBRARY_PATH
[ -n "${RUBY27_OLD_LD_LIBRARY_PATH+x}" ] && LD_LIBRARY_PATH="$RUBY27_OLD_LD_LIBRARY_PATH" && export LD_LIBRARY_PATH && unset RUBY27_OLD_LD_LIBRARY_PATH

unset SNAP
