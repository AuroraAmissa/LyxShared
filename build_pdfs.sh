VERSION="$DIRTY_SHORT_REV"
if [ $IS_REALLY_DIRTY != 1 ]; then
    # shellcheck disable=SC2001
    VERSION="$(echo "$VERSION" | sed "s/-dirty//g")"
fi
ZVERSION="v$VERSION"

init_build() {
    echo " - Disabling all branches"
    sed -i -e '/\\branch .*/,+1s/\\selected.*/\\selected 0/' contents/*.lyx RulebookShared/*.lyx || exit 1

    case $1 in
    release)
        activate_branch RulebookShared/Format_Common Release || exit 1
        FILE_VERSION_SUFFIX=""
        ZIP_FILE_SUFFIX=""
    ;;
    playtest)
        activate_branch RulebookShared/Format_Common Playtest || exit 1
        FILE_VERSION_SUFFIX=" Playtest"
        ZIP_FILE_SUFFIX=" - Playtest"
    ;;
    ci)
        if [ ! -z "$GITHUB_RUN_NUMBER" ]; then
            ZVERSION="r$GITHUB_RUN_NUMBER"
        fi
        
        activate_branch RulebookShared/Format_Common CiBuild || exit 1
        FILE_VERSION_SUFFIX=" Draft"
        ZIP_FILE_SUFFIX=" - Draft"
    ;;
    draft)
        FILE_VERSION_SUFFIX=" Draft"
        ZIP_FILE_SUFFIX=" - Draft"
    ;;
    *)
        exit 1
    ;;
    esac
}
activate_branch() {
    sed -i -e '/\\branch '$2'.*/,+1s/\\selected.*/\\selected 1/' "$1.lyx" || exit 1
}

create_build_dirs() {
    mkdir -p /build/.cache /build/.cache/run_home /build/out
    export XDG_CACHE_HOME=/build/.cache
}
render_pdf() {
    # Creates the direct output PDF
    lyx -userdir /build/.cache/run_home -v "contents/$1.lyx" -E pdf4 "$1_Temp.pdf" || exit 1
    
    # Encrypt and recompress the PDF. This isn't really used for any real security, it's just here to avoid accidental modification.
    # Also to encourge anyone who wants to fork or do other weird stuff to *actually* use LyX instead of some weird PDF editor...
    qpdf "$1_Temp.pdf" "$1.pdf" \
        --compress-streams=y --object-streams=generate --coalesce-contents \
        --encrypt "" "pls dont do anything weird with the password :( :(" 256 \
        --extract=y --assemble=n --form=n --annotate=n --modify-other=n --print=full --modify=none --cleartext-metadata "${@:4}" -- || exit 1
    cp "$1.pdf" "/build/out/$2$3.pdf" || exit 1
}

create_source_archive() {
    SOURCE_TEMP="/build/$SOURCE_NAME-$VERSION"
    mkdir -p "$SOURCE_TEMP" || exit 1

    # Copy contents
    cp -r .git * "$SOURCE_TEMP" || exit 1
    rm -rfv "$SOURCE_TEMP/resources/*.xcf" "$SOURCE_TEMP/scripts/init.sh" || exit 1
    rm -rfv "$SOURCE_TEMP/RulebookShared"/{.gitignore,scripts,layouts,hooks} || exit 1

    # Build the tar archive
    mv "$SOURCE_TEMP" . || exit 1
    tar --zstd -cv -f "$1.tar.zst" "$SOURCE_NAME-$VERSION" || exit 1
}
create_archive() {
    mv /build/out "$DIST_NAME$ZIP_FILE_SUFFIX $ZVERSION"
    zip -r "$1.zip" "$DIST_NAME$ZIP_FILE_SUFFIX $ZVERSION" || exit 1
}
