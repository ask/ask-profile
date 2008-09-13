if [ "$IS_BASH" -o "$IS_KORN" ]; then
    set -o vi on
    if [ "$IS_KORN" ]; then
        set -o viraw on
    fi
fi
