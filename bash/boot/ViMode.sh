if [ "$IS_BASH" ]; then
    set -o vi on
fi

if [ "$IS_KORN" ]; then
    set -o vi on
    set -o viraw on
fi
