if [[ -v SNAP_PATH_SAVED ]]; then
    echo "SNAP_PATH_SAVED is already defined" 1>&2
    return 1
else
    export SNAP_PATH_SAVED="$PATH"
    PATH="/snap/bin:$PATH"
fi

snap_deactivate() {
    if [[ -v SNAP_PATH_SAVED ]]; then
        PATH="$SNAP_PATH_SAVED"
        unset SNAP_PATH_SAVED
        unset -f snap_deactivate
    else
        echo "SNAP_PATH_SAVED is not defined" 1>&2
    fi
}
