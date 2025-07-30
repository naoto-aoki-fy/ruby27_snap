#!/bin/bash
# Environment activation for Ruby 2.7 installed from the Snap package

# Prefer the environment file from a specific revision when available
SNAP_YAML=/snap/ruby/308/meta/snap.yaml
SNAP=/snap/ruby/current
if [ -f "$SNAP_YAML" ]; then
  SNAP=/snap/ruby/308
else
  SNAP_YAML="$SNAP/meta/snap.yaml"
fi
SNAP_ARCH=$(dpkg --print-architecture)

# Save current values to allow restoring them later
[ -z "${RUBY27_OLD_PATH+x}" ] && RUBY27_OLD_PATH="${PATH:-}"
[ -z "${RUBY27_OLD_RUBYLIB+x}" ] && RUBY27_OLD_RUBYLIB="${RUBYLIB:-}"
[ -z "${RUBY27_OLD_GEM_HOME+x}" ] && RUBY27_OLD_GEM_HOME="${GEM_HOME:-}"
[ -z "${RUBY27_OLD_GEM_PATH+x}" ] && RUBY27_OLD_GEM_PATH="${GEM_PATH:-}"
[ -z "${RUBY27_OLD_LD_LIBRARY_PATH+x}" ] && RUBY27_OLD_LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}"

if [ -f "$SNAP_YAML" ]; then
  declare -A RUBY27_ENV_VARS
  while IFS=$'\t' read -r key val; do
    [ -z "$key" ] && continue
    RUBY27_ENV_VARS["$key"]="$val"
    if [ -z "${!key+x}" ]; then
      eval "$key=''"
    fi
    eval "export $key=\"$val\""
  done < <(/usr/bin/python3 - "$SNAP_YAML" "$SNAP" "$SNAP_ARCH" <<'EOF'
import sys, yaml
yaml_path, snap_dir = sys.argv[1], sys.argv[2]
with open(yaml_path) as f:
    data = yaml.safe_load(f)
env = {}
env.update(data.get('environment', {}))
for app in data.get('apps', {}).values():
    if isinstance(app, dict) and 'environment' in app:
        env.update(app['environment'])
for k, v in env.items():
    v = v.replace('$SNAP_ARCH', sys.argv[3]).replace('$SNAP', snap_dir)
    print(f"{k}\t{v}")
EOF
)
  : "${RUBY27_ENV_VARS[PATH]:=""}"
  if [ -z "${RUBY27_ENV_VARS[PATH]}" ]; then
    export PATH="$SNAP/bin:$PATH"
  fi
  : "${RUBY27_ENV_VARS[RUBYLIB]:=""}"
  if [ -z "${RUBY27_ENV_VARS[RUBYLIB]}" ]; then
    export RUBYLIB="$SNAP/lib/ruby/2.7.0:$SNAP/lib/ruby/2.7.0/$(uname -m)-linux:${RUBYLIB:-}"
  fi
  : "${RUBY27_ENV_VARS[GEM_HOME]:=""}"
  if [ -z "${RUBY27_ENV_VARS[GEM_HOME]}" ]; then
    export GEM_HOME="$SNAP/lib/ruby/gems/2.7.0"
  fi
  : "${RUBY27_ENV_VARS[GEM_PATH]:=""}"
  if [ -z "${RUBY27_ENV_VARS[GEM_PATH]}" ]; then
    export GEM_PATH="${GEM_HOME:-$SNAP/lib/ruby/gems/2.7.0}"
  fi
  : "${RUBY27_ENV_VARS[LD_LIBRARY_PATH]:=""}"
  if [ -z "${RUBY27_ENV_VARS[LD_LIBRARY_PATH]}" ]; then
    export LD_LIBRARY_PATH="$SNAP/lib:$SNAP/usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH:-}"
  fi
else
  export PATH="$SNAP/bin:$PATH"
  export RUBYLIB="$SNAP/lib/ruby/2.7.0:$SNAP/lib/ruby/2.7.0/$(uname -m)-linux:${RUBYLIB:-}"
  export GEM_HOME="$SNAP/lib/ruby/gems/2.7.0"
  export GEM_PATH="$GEM_HOME"
  export LD_LIBRARY_PATH="$SNAP/lib:$SNAP/usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH:-}"
fi
# exec "$SNAP/bin/ruby" "$@"
