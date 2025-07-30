#!/bin/bash
# Environment activation for Ruby 2.7 installed from the Snap package

# Prefer the environment file from a specific revision when available
SNAP_YAML=/snap/ruby/current/meta/snap.yaml
SNAP=/snap/ruby/current
if [ -f "$SNAP_YAML" ]; then
  SNAP=/snap/ruby/current
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
  env_lines=$(yq -r '
      def all_env:
        (.environment // {}) as $e
        | reduce (.apps[]? | .environment? // {}) as $a ($e; . * $a);
      all_env | to_entries[] | "\(.key)\t\(.value)"
    ' "$SNAP_YAML" 2>/dev/null || true)
  if [ -z "$env_lines" ]; then
    echo "error: \$env_lines is empty" 1>&2
    return 1
  fi
  while IFS=$'\t' read -r key val; do
    [ -z "$key" ] && continue
    val="${val//\$SNAP_ARCH/$SNAP_ARCH}"
    val="${val//\$SNAP/$SNAP}"
    RUBY27_ENV_VARS["$key"]="$val"
    if [ -z "${!key+x}" ]; then
      eval "$key=''"
    fi
    eval "export $key=\"$val\""
  done <<<"$env_lines"
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
  echo "error: $SNAP_YAML not found" 1>&2
  return 1
fi

# Define a function to restore the previous environment
deactivate() {
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
  unset SNAP RUBY27_ENV_VARS
  unset -f deactivate
}
