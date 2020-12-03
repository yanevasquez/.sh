#!/bin/bash

# -------------------------------------------------------------------------------------------
#  Name: transfer.sh
#
#  Description: The script to perform the transfer of files from a module to a destination
#               directory. Files and directories that will be copied to the new project
#               [x] Routes/admin
#               [x] Breadcrumbs
#
#  Author: Yane <yanelisset4@gmail.com>
#
#  Last change: 02/12/2020
# -------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------
#  User settings:
# -------------------------------------------------------------------------------------------
ORIGIN_PROJECT="ORIGIN_PATTERN"
TARGET_PROJECT="TARGET_DIR"
PATHORIGIN="$HOME/.."

# -------------------------------------------------------------------------------------------
#  Paths settings of origin and destination directories
# -------------------------------------------------------------------------------------------
MODULE=""

TARGET_ADMIN_route_base="${PATHORIGIN}/${TARGET_PROJECT}/routes"
TARGET_ADMIN_route="${PATHORIGIN}/${TARGET_PROJECT}/routes/admin.php"
TARGETBreadcrumbs="${PATHORIGIN}/${TARGET_PROJECT}/app/Breadcrumbs/admin.php"
ORIGIN_Breadcrumbs="${PATHORIGIN}/${ORIGIN_PROJECT}/app/Breadcrumbs/admin.php"

TPUT_RESET="$(tput sgr 0)"
TPUTBOLD="$(tput bold)"
TPUPRED="$(tput setab 1)"
TPUT_BLUE="$(tput setab 4)"
TPUT_YELLOW="$(tput setaf 3)"
TPUT_BGRED="$(tput setab 1)"
TPUT_CYAN="$(tput setab 6)"

main() {
    _routesAdmin
    _breadcrumbsFilter
}

# -------------------------------------------------------------------------------------------
#    Message notification functions
# -------------------------------------------------------------------------------------------
informativeMessage() {
    TPUTBGGREEN="$(tput setab 2)"
    TPUT_WHITE="$(tput setaf 7)"
    printf >&2 "Files '${MODULE}' already exists! ${TPUT_RESET}${TPUTBGGREEN}${TPUTBOLD}[ok]${TPUT_RESET}\n"
}

failMessage() {
    TPUT_WHITE="$(tput setaf 7)"
    printf >&2 "${TPUT_BGRED}${TPUT_WHITE}${TPUT_BOLD}[ FAILED ]${TPUT_RESET}\n"
}

sucessMessage() {
    TPUTBGGREEN="$(tput setab 2)"
    TPUT_YELLOW="$(tput setaf 3)"
    TPUT_BGRED="$(tput setab 1)"
    printf >&2 "transfer successful! ${TPUTBGGREEN}${TPUTBOLD}[ok]${TPUT_RESET}\n"
}

# -------------------------------------------------------------------------------------------
#              Filters to perform copying or file transfer
# -------------------------------------------------------------------------------------------

_breadcrumbsFilter() {
    breadcrumbsAdmin=$(grep -w "admin.posts.index" $TARGETBreadcrumbs)
    if [ -z "${breadcrumbsAdmin}" ]; then
        printf "// Posts 
        Breadcrumbs::for('admin.posts.index', function (\$trail) {
            \$trail->parent('admin.dashboard.index');
            \$trail->push('Posts', route('admin.posts.index'));
        });
        Breadcrumbs::for('admin.posts.create', function (\$trail) {
            \$trail->parent('admin.posts.index');
            \$trail->push('Adicionar', route('admin.posts.create'));
        });
        Breadcrumbs::for('admin.posts.edit', function (\$trail, $id) {
            \$trail->parent('admin.posts.index');
            \$trail->push('Editar', route('admin.posts.edit', ['id' => \$id]));
        }); \n" >>$TARGETBreadcrumbs && printf "\t\t\t${TPUTBOLD}${TPUT_YELLOW}[ BreadCrumbs/Admin ] ${TPUT_RESET}" && sucessMessage
    else
        printf "\t\t\t${TPUTBOLD}${TPUT_YELLOW}[ BreadCrumbs/Admin ] ${TPUT_RESET}" && informativeMessage
    fi
}

_routesAdmin() {
    aspS="'"
    verificaRoute=$(grep -w "Route::prefix('posts')" ${TARGET_ADMIN_route})
    if [ -z "${verificaRoute}" ]; then
        searchFuncAuth=$(grep -nw "Route::middleware(\['first\.access'" ${TARGET_ADMIN_route} | cut -d":" -f 1)
        addLine=$(expr $searchFuncAuth + 5)
        cat $TARGET_ADMIN_route | sed ''${addLine}' a\\t\t\/** Posts **\/ \n \t    Route::prefix\('"${aspS}"posts"${aspS}"'\)->group(function \(\) { \n \t\t Route::name\('"${aspS}"posts\.index"${aspS}"'\)->get\('"${aspS}"/"${aspS}"', '"${aspS}"Admin'\\'Posts'\\'PostController@index"${aspS}"'\); \n \t\t Route::name\('"${aspS}"posts\.create"${aspS}"'\)->get('"${aspS}"'\/'adicionar"${aspS}"', '"${aspS}"Admin'\\'Posts'\\'PostController@create"${aspS}"'\);\n \t\t Route::name\('"${aspS}"posts\.store"${aspS}"'\)->post('"${aspS}"'\/'adicionar"${aspS}"', '"${aspS}"Admin'\\'Posts'\\'PostController@store"${aspS}"'\); \n \t\t Route::name\('"${aspS}"posts\.edit"${aspS}"'\)->get('"${aspS}"'\/'editar'\/'{uuid}"${aspS}"', '"${aspS}"Admin'\\'Posts'\\'PostController@edit"${aspS}"'\); \n  \t\t Route::name\('"${aspS}"posts\.update"${aspS}"'\)->put('"${aspS}"'\/'editar'\/'{uuid}"${aspS}"', '"${aspS}"Admin'\\'Posts'\\'PostController@update"${aspS}"'\); \n  \t\t Route::name\('"${aspS}"posts\.destroy"${aspS}"'\)->delete('"${aspS}"'\/'excluir'\/'{uuid}"${aspS}"', '"${aspS}"Admin'\\'Posts'\\'PostController@destroy"${aspS}"'\);\n\t\t}\); \n' $TARGET_ADMIN_route >$TARGET_ADMIN_route_base/temp.php
        mv $TARGET_ADMIN_route_base/temp.php $TARGET_ADMIN_route && printf "\t\t\t${TPUTBOLD}${TPUT_YELLOW}[ Routes/admin ]${TPUT_RESET}" && sucessMessage
    else
        printf "\t\t\t${TPUTBOLD}${TPUT_YELLOW}[ Routes/admin.php ] ${TPUT_RESET} " && informativeMessage
    fi
}

main
