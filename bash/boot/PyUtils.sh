pymod () {
    python -c "import $1; print($1.__file__.replace('.pyc', '.py'))"
}

vimod () {
    ${VISUAL:-${EDITOR:-vi}} $(pymod $1)
}

