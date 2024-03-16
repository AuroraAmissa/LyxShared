#!/usr/bin/env bash

update_layout() {
    # Select the correct layout file to include
    layout_file="build/LyxLayout.ins"
    if [[ "$1" == *"Format_Common.lyx"* ]]; then
        layout_file="build/LyxLayoutSystem.ins"
    fi
    if [[ "$1" == *"Format_Sheets.lyx"* ]]; then
        layout_file="build/LyxLayoutSheetsSystem.ins"
    fi
    if grep -q "../RulebookShared/Format_Sheets.lyx" "$1"; then
        layout_file="build/LyxLayoutSheets.ins"
    fi

    # Rewrite the Lyx file with the new layout
    echo "Updating '$1' with layout '$layout_file'..."
    sed '/\\begin_local_layout/q' "$1" > build/RewriteFile.tmp || exit 1
    cat "$layout_file" >> build/RewriteFile.tmp || exit 1
    echo "\end_local_layout" >> build/RewriteFile.tmp || exit 1
    sed '1,/\\end_local_layout/d' "$1" >> build/RewriteFile.tmp || exit 1

    # Refactor renamed Lyx insets
    sed -i -e 's/^\\begin_inset Flex IgnoreThis$/\\begin_inset Note Note/' build/RewriteFile.tmp || exit 1
    sed -i -e 's/^\\begin_inset Flex TwoColumnBox$/\\begin_inset Flex TwoColumns/' build/RewriteFile.tmp || exit 1
    sed -i -e 's/^\\begin_inset Flex TwoColumnBoxFill$/\\begin_inset Flex TwoColumnsFill/' build/RewriteFile.tmp || exit 1
    sed -i -e 's/^\\begin_inset Flex LumPartQuote$/\\begin_inset Flex CofDPartQuote/' build/RewriteFile.tmp || exit 1
    sed -i -e 's/^\\begin_inset Flex LumChapQuote$/\\begin_inset Flex CofDChapterQuote/' build/RewriteFile.tmp || exit 1
    sed -i -e 's/^\\begin_inset Flex Foldable$/\\begin_inset Flex CollapsableRegion/' build/RewriteFile.tmp || exit 1
    sed -i -e 's/^\\begin_inset Flex LumIncomplete$/\\begin_inset Flex IncompleteChapter/' build/RewriteFile.tmp || exit 1
    sed -i -e 's/^\\begin_inset Flex LumIncompleteSection$/\\begin_inset Flex IncompleteSection/' build/RewriteFile.tmp || exit 1
    sed -i -e 's/^\\begin_inset Flex ContentWarning$/\\begin_inset Flex SidebarContentWarning/' build/RewriteFile.tmp || exit 1

    # Rewrite the original file if it was changed
    if ! diff -q "$1" build/RewriteFile.tmp &>/dev/null; then
        echo "- Overriding original file..."
        cp build/RewriteFile.tmp "$1" || exit 1
    fi
}

update_layouts_script() {
    mkdir -vp build || exit 1

    # Create layout for normal documents
    cat RulebookShared/layouts/LyxLayout.ins > build/LyxLayout.ins
    cat RulebookShared/layouts/LyxLayout.ins RulebookShared/layouts/LyxLayoutSheets.ins > build/LyxLayoutSheets.ins
    cat RulebookShared/layouts/LyxLayout.ins > build/LyxLayoutSystem.ins
    cat RulebookShared/layouts/LyxLayout.ins RulebookShared/layouts/LyxLayoutSheets.ins > build/LyxLayoutSheetsSystem.ins

    # Add local layout
    if [ -f LyxLayoutLocal.ins ]; then
        cat LyxLayoutLocal.ins > build/LyxLayout.ins
        cat LyxLayoutLocal.ins > build/LyxLayoutSheets.ins
    fi

    # Update all lyx files
    for i in contents/*.lyx RulebookShared/*.lyx; do
        update_layout "$i" || exit 1
    done

    # Cleanup
    rm -rfv build || exit 1
}

cd "$(realpath "$(dirname "$0")")/../.." || exit 1
update_layouts_script || exit 1
rm -rfv scripts || exit 1
cp -rfv RulebookShared/scripts/repo_scripts scripts || exit 1
chmod -v +x scripts/* || exit 1
cp -v RulebookShared/scripts/gitignore .gitignore || exit 1