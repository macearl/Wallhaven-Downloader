#!/bin/bash
#
# This script gets the beautiful wallpapers from http://wallhaven.cc
# This script is brought to you by MacEarl and is based on the
# script for wallbase.cc (https://github.com/sevensins/Wallbase-Downloader)
#
# This Script is written for GNU Linux, it should work under Mac OS

REVISION=0.1.6.9

#####################################
###   Needed for NSFW/Favorites   ###
#####################################
# Enter your Username
USER=""
# Enter your password
PASS=""
#####################################
### End needed for NSFW/Favorites ###
#####################################

#####################################
###     Configuration Options     ###
#####################################
# Where should the Wallpapers be stored?
LOCATION=/location/to/your/wallpaper/folder
# How many Wallpapers should be downloaded, should be multiples of 24 (right now they only use a fixed number of thumbs per page)
WPNUMBER=48
# What page to start downloading at, default and minimum of 1.
STARTPAGE=1
# Type standard (newest, oldest, random, hits, mostfav), search, favorites (for now only the default collection), useruploads (if selected, only FILTER variable will change the outcome)
TYPE=standard
# From which Categories should Wallpapers be downloaded, first number is for General, second for Anime, third for People, 1 to enable category, 0 to disable it
CATEGORIES=111
# filter wallpapers before downloading, first number is for sfw content, second for sketchy content, third for nsfw content, 1 to enable, 0 to disable
FILTER=110
# Which Resolutions should be downloaded, leave empty for all (most common resolutions possible, for details see wallhaven site), separate multiple resolutions with , eg. 1920x1080,1920x1200
RESOLUTION=
# Which aspectratios should be downloaded, leave empty for all (possible values: 4x3, 5x4, 16x9, 16x10, 32x9, 48x9), separate mutliple ratios with , eg. 4x3,16x9
ASPECTRATIO=
# Which Type should be displayed (relevance, random, date_added, views, favorites)
MODE=random
# How should the wallpapers be ordered (desc, asc)
ORDER=desc
# Searchterm, only used if TYPE = search
QUERY="nature"
# User from which wallpapers should be downloaded (only used for TYPE=useruploads)
USR=AksumkA
# use gnu parallel to speed up the download (0, 1), if set to 1 make sure you have gnuparallel installed, see normal.vs.parallel.txt for speed improvements
PARALLEL=0
#####################################
###   End Configuration Options   ###
#####################################

#
# logs in to the wallhaven website to give the user more functionality
# requires 2 arguments:
# arg1: username
# arg2: password
#
function login {
    # checking parameters -> if not ok print error and exit script
    if [ $# -lt 2 ] || [ "$1" == '' ] || [ "$2" == '' ]; then
        printf "Please check the needed Options for NSFW Content (username and password)\n\n"
        printf "For further Information see Section 13\n\n"
        printf "Press any key to exit\n"
        read -r
        exit
    fi

    # everythings ok --> login
    WGET --referer=https://alpha.wallhaven.cc https://alpha.wallhaven.cc/auth/login
    token="$(grep 'name="_token"' login | sed 's:.*value="::' | sed 's/.\{2\}$//')"
    WGET --referer=https://alpha.wallhaven.cc/auth/login --post-data="_token=$token&username=$USER&password=$PASS" https://alpha.wallhaven.cc/auth/login
} # /login

#
# downloads Page with Thumbnails
#
function getPage {
    # checking parameters -> if not ok print error and exit script
    if [ $# -lt 1 ]; then
        printf "getPage expects at least 1 argument\n"
        printf "arg1:    parameters for the wget -q command\n\n"
        printf "press any key to exit\n"
        read -r
        exit
    fi

    # parameters ok --> get page
    WGET --referer=https://alpha.wallhaven.cc -O tmp "https://alpha.wallhaven.cc/$1"
} # /getPage

#
# downloads all the wallpaper from a wallpaperfile
# arg1: the file containing the wallpapers
#
function downloadWallpapers {
    URLSFORIMAGES="$(grep -o '<a class="preview" href="https://alpha.wallhaven.cc/wallpaper/[0-9]*"' tmp)"

    OIFS="$IFS"
    IFS=$'\n'

    for imgURL in $URLSFORIMAGES
        do
        img="${imgURL: 25 : -1}"
        number="${img##*/}"

        if grep -w "$number" downloaded.txt >/dev/null
            then
                printf "\n    Wallpaper %s already downloaded!" "$number"
        elif [ $PARALLEL == 1 ]
            then
                echo "$number" >> downloaded.txt
                echo "$number" >> download.txt
        else
                echo "$number" >> downloaded.txt
                WGET --referer=https://alpha.wallhaven.cc "$img"
                echo "https:$(egrep -m 1 -o "src=\"//wallpapers.*(png|jpg|gif)" "$number" | cut -b 6-)" | WGET --referer=https://alpha.wallhaven.cc/wallpaper/"$number" -i -
                rm "$number"
        fi
        done

    IFS="$OIFS"

    if [ $PARALLEL == 1 ] && [ -f ./download.txt ]
        then
            # export wget wrapper to make it available for parallel
            export -f WGET
            SHELL=$(type -p bash) parallel --gnu --no-notice 'WGET --referer=https://alpha.wallhaven.cc https://alpha.wallhaven.cc/wallpaper/{}' < download.txt
            SHELL=$(type -p bash) parallel --gnu --no-notice 'cat {} | echo "https:$(egrep -m 1 -o "src=\"//wallpapers.*(png|jpg|gif)" | cut -b 6-)" | WGET --referer=https://alpha.wallhaven.cc/wallpaper/{} -i -' < download.txt
            rm tmp $(cat download.txt) download.txt
        else
            rm tmp
    fi
} #/downloadWallpapers

#
# wrapper for wget with some default arguments
# arg0: additional arguments for wget (optional)
# arg1: file to download
#
function WGET {
    # checking parameters -> if not ok print error and exit script
    if [ $# -lt 1 ]; then
        printf "WGET expects at least 1 argument\n"
        printf "arg0:    additional arguments for wget (optional)\n"
        printf "arg1:    file to download\n\n"
        printf "press any key to exit\n"
        read -r
        exit
    fi
    # default wget command
    wget -q -U "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.99 Safari/537.36" --keep-session-cookies --save-cookies=cookies.txt --load-cookies=cookies.txt "$@"
}

#
# displays help text (valid command line arguments)
#
function helpText {
    printf 'Usage: ./wallhaven.sh [OPTIONS]\n'
    printf 'Download wallpapers from wallhaven.cc\n\n'
    printf 'If no options are specified, default values from within the script will be used\n\n'
    printf '%s -l, --location\t\t location where the wallpapers will be stored\n'
    printf '%s -n, --number\t\t Number of Wallpapers to download\n'
    printf '%s -s, --startpage\t page to start downloading from\n'
    printf '%s -t, --type\t\t Type of download Operation: standard, search, \n\t\t\t favorites, useruploads\n'
    printf '%s -c, --categories\t categories to download from, eg. 111 for General,\n\t\t\t Anime and People, 1 to include, 0 to exclude\n'
    printf '%s -f, --filter\t\t filter out content based on purity rating, eg. 111 \n\t\t\t for SFW, sketchy and NSFW content, 1 to include, \n\t\t\t 0 to exclude\n'
    printf '%s -r, --resolution\t resolutions to download, separate mutliple \n\t\t\t resolutions by ,\n'
    printf '%s -a, --aspectratio\t only download wallpaper with given aspectratios, \n\t\t\t separate multiple aspectratios by ,\n'
    printf '%s -m, --mode\t\t sorting mode for wallpapers: relevance, random,\n\t\t\t date_added, views, favorites \n'
    printf '%s -o, --order\t\t order ascending (asc) oder descending (desc)\n'
    printf '%s -q, --query\t\t search query, eg. '\''mario'\'', single quotes needed,\n\t\t\t for searching exact phrases use double quotes \n\t\t\t inside single quotes, eg. '\''"super mario"'\'' \n'
    printf '%s -u, --user\t\t download wallpapers from given user\n'
    printf '%s -p, --parallel\t\t make use of gnu parallel (1 to enable, 0 to disable)\n'
    printf '%s -v, --version\t\t show current version\n'
    printf '%s -h, --help\t\t show this help text and exit\n\n'
    printf 'Examples:\n'
    printf './wallhaven.sh -l ~/wp/ -n 48 -s 1 -t standard -c 101 -f 111 -r 1920x1080 \n\t       -a 16x9 -m random -o desc -p 1\n\n'
    printf 'Download 48 random wallpapers with a resolution of 1920x1080 and \nan aspectratio of 16x9 to ~/wp/ starting with page 1 from the \ncategories general and people including SFW, sketchy and NSWF Content\nwhile utilizing gnu parallel\n\n'
    printf './wallhaven.sh -l ~/wp/ -n 48 -s 1 -t search -c 111 -f 111 -r 1920x1080 \n\t       -a 16x9 -m relevance -o desc -q '\''"super mario"'\'' -p 1\n\n'
    printf 'Download 48 wallpapers related to the search query "super mario" with\na resolution of 1920x1080 and an aspectratio of 16x9 to ~/wp/ starting\nwith page 1 from the categories general, anime and people including SFW,\nsketchy and NSWF Content while utilizing gnu parallel\n\n\n'
    printf 'latest version available at: <https://github.com/macearl/Wallhaven-Downloader>'
} # helptext

# Command line Arguments
while [[ $# -ge 1 ]]
    do
    key="$1"

    case $key in
        -l|--location)
            LOCATION="$2"
            shift;;
        -n|--number)
            WPNUMBER="$2"
            shift;;
        -s|--startpage)
            STARTPAGE="$2"
            shift;;
        -t|--type)
            TYPE="$2"
            shift;;
        -c|--categories)
            CATEGORIES="$2"
            shift;;
        -f|--filter)
            FILTER="$2"
            shift;;
        -r|--resolution)
            RESOLUTION="$2"
            shift;;
        -a|--aspectratio)
            ASPECTRATIO="$2"
            shift;;
        -m|--mode)
            MODE="$2"
            shift;;
        -o|--order)
            ORDER="$2"
            shift;;
        -q|--query)
            QUERY=${2//\'/}
            shift;;
        -u|--user)
            USR="$2"
            shift;;
        -p|--parallel)
            PARALLEL="$2"
            shift;;
        -h|--help)
            helpText
            exit
            ;;
        -v|--version)
            printf "Wallhaven Downloader %s" "$REVISION"
            exit
            ;;
        *)
            printf "unknown option: %s\n" "$1"
            helpText
            exit
            ;;
    esac
    shift # past argument or value
    done

# creates Location folder if it does not exist
if [ ! -d "$LOCATION" ]; then
    mkdir -p "$LOCATION"
fi

cd "$LOCATION" || exit

# creates downloaded.txt if it does not exist
if [ ! -f ./downloaded.txt ]; then
    touch downloaded.txt
fi

# login only when it is required ( for example to download favourites or nsfw content... )
if [ "$FILTER" == 001 ] || [ "$FILTER" == 011 ] || [ "$FILTER" == 111 ] || [ "$TYPE" == favorites ] ; then
   login "$USER" "$PASS"
fi

if [ "$TYPE" == standard ]; then
    for (( count=0, page="$STARTPAGE"; count< "$WPNUMBER"; count=count+24, page=page+1 ));
    do
        printf "Download Page %s" "$page"
        getPage "search?page=$page&categories=$CATEGORIES&purity=$FILTER&resolutions=$RESOLUTION&ratios=$ASPECTRATIO&sorting=$MODE&order=$ORDER"
        printf "\n    - done!\n"
        printf "Download Wallpapers from Page %s" "$page"
        downloadWallpapers
        printf "\n    - done!\n"
    done

elif [ "$TYPE" == search ] ; then
    # SEARCH
    for (( count=0, page="$STARTPAGE"; count< "$WPNUMBER"; count=count+24, page=page+1 ));
    do
        printf "Download Page %s" "$page"
        getPage "search?page=$page&categories=$CATEGORIES&purity=$FILTER&resolutions=$RESOLUTION&ratios=$ASPECTRATIO&sorting=$MODE&order=desc&q=$QUERY"
        printf "\n    - done!\n"
        printf "Download Wallpapers from Page %s" "$page"
        downloadWallpapers
        printf "\n    - done!\n"
    done

elif [ "$TYPE" == favorites ] ; then
    # FAVORITES
    # currently using sum of all collections
    favnumber="$(WGET --referer=https://alpha.wallhaven.cc https://alpha.wallhaven.cc/favorites -O - | grep -A 25 "<ul class=\"blocklist collections-list\" data-target=\"https://alpha.wallhaven.cc/favorites/move\">" | grep -B 1 "<small>" | sed -n '2{p;q}' | sed 's/<[^>]\+>/ /g' | sed  's .\{3\}  ' | sed 's/.\{1\}$//')"
    for (( count=0, page="$STARTPAGE"; count< "$WPNUMBER" && count< "$favnumber"; count=count+24, page=page+1 ));
    do
        printf "Download Page %s" "$page"
        getPage "favorites?page=$page"
        printf "\n    - done!\n"
        printf "Download Wallpapers from Page %s" "$page"
        downloadWallpapers
        printf "\n    - done!\n"
    done

elif [ "$TYPE" == useruploads ] ; then
    # UPLOADS FROM SPECIFIC USER
    for (( count=0, page="$STARTPAGE"; count< "$WPNUMBER"; count=count+24, page=page+1 ));
    do
        printf "Download Page %s" "$page"
        getPage "user/$USR/uploads?page=$page&purity=$FILTER"
        printf "\n    - done!\n"
        printf "Download Wallpapers from Page %s" "$page"
        downloadWallpapers
        printf "\n    - done!\n"
    done

else
    printf "error in TYPE please check Variable\n"
fi

rm -f cookies.txt login login.1