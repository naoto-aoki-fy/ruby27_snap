SNAP=/opt/ruby27
export PATH="$SNAP/bin:$PATH"
export RUBYLIB="$SNAP/lib/ruby/2.7.0:$SNAP/lib/ruby/2.7.0/$(uname -m)-linux:$RUBYLIB"
export GEM_HOME="$SNAP/lib/ruby/gems/2.7.0"
export GEM_PATH="$GEM_HOME"
export LD_LIBRARY_PATH="$SNAP/lib:$SNAP/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
# exec "$SNAP/bin/ruby" "$@"
