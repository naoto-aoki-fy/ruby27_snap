# Environment activation for Ruby 2.7 installed from the Snap package
SNAP=/snap/ruby/current

# Save current values to allow restoring them later
[ -z "${RUBY27_OLD_PATH+x}" ] && RUBY27_OLD_PATH="${PATH:-}"
[ -z "${RUBY27_OLD_RUBYLIB+x}" ] && RUBY27_OLD_RUBYLIB="${RUBYLIB:-}"
[ -z "${RUBY27_OLD_GEM_HOME+x}" ] && RUBY27_OLD_GEM_HOME="${GEM_HOME:-}"
[ -z "${RUBY27_OLD_GEM_PATH+x}" ] && RUBY27_OLD_GEM_PATH="${GEM_PATH:-}"
[ -z "${RUBY27_OLD_LD_LIBRARY_PATH+x}" ] && RUBY27_OLD_LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}"

export PATH="$SNAP/bin:$PATH"
export RUBYLIB="$SNAP/lib/ruby/2.7.0:$SNAP/lib/ruby/2.7.0/$(uname -m)-linux:${RUBYLIB:-}"
export GEM_HOME="$SNAP/lib/ruby/gems/2.7.0"
export GEM_PATH="$GEM_HOME"
export LD_LIBRARY_PATH="$SNAP/lib:$SNAP/usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH:-}"
# exec "$SNAP/bin/ruby" "$@"
