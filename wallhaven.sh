#!/bin/bash
#
# This script gets the beautiful wallpapers from http://wallhaven.cc
# This script is brought to you by MacEarl and is based on the
# script for wallbase.cc (https://github.com/sevensins/Wallbase-Downloader)
#
#
# This Script is written for GNU Linux, it should work under Mac OS
#
#
# Revision 0.1.5
# 1. fixed issue if all wallpapers on a page where already downloaded
#
# Revision 0.1.4
# 1. fixed parallel mode
#
# Revision 0.1.3
# 1. added check if downloaded.txt file exists
# 2. added "--gnu" option to parallel 
# (for some older Distributions which set the default mode to tollef)
# For some older Versions of parallel remove the "--no-notice" option if you get an error like this:
# "parallel: Error: Command (--no-notice) starts with '-'. Is this a wrong option?"
# 3. fixed issue where wget would not automatically add a "http://" prefix 
#
# Revision 0.1.2
# 1. fixed urls to work with latest wallhaven update
# 2. added some comments
# 3. fixed login issue when downloading favorites
# 4. merged normal and parallel version
# 
# Revision 0.1.1
# 1. updated and tested parts of the script to work with 
#    newest wallhaven site (not all features tested)
#
# Revision 0.1
# 1. first Version of script, most features from the wallbase 
#    script are implemented
#
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

####################################
###     Configuration Options    ###
####################################
# Where should the Wallpapers be stored?
LOCATION=/location/to/your/wallpaper/folder
# How many Wallpapers should be downloaded, should be multiples of 24 (right now they only use a fixed number of thumbs per page)
WPNUMBER=48
# Type standard (newest, oldest, random, hits, mostfav), search, favorites (for now only the default collection), useruploads (if selected, only purity variable will change the outcome)
TYPE=standard
# From which Categories should Wallpapers be downloaded, first number is for General, second for Anime, third for People, 1 to enable category, 0 to disable it
CATEGORIES=111
# Which Purity Wallpapers should be downloaded, first number is for sfw content, second for sketchy content, third for nsfw, 1 to enable, 0 to disable
PURITY=110
# Which Resolution should be downloaded, leave empty for all (most common resolutions possible, for details see wallhaven site)
RESOLUTION=
# Which aspectratio should be downloaded, leave empty for all (possible values: 4x3, 5x4, 16x9, 16x10, 32x9, 48x9)
RATIO=
# Which Type should be displayed (relevance, random, date_added, views, favorites)
SORTING=random
# How should the Wallpapers be ordered (desc, asc)
ORDER=desc
# Searchterm, only used if TYPE = search
QUERY="nature"
# User from which Wallpapers should be downloaded (only used for TYPE=useruploads)
USR=AksumkA
# use gnu parallel to speed up the download (0, 1), if set to 1 make sure you have gnuparallel installed, see normal.vs.parallel.txt for speed improvements
PARALLEL=0
####################################
###   End Configuration Options  ###
####################################

# creates Location folder if it does not exist
if [ ! -d $LOCATION ]; then
    mkdir -p $LOCATION
fi

cd $LOCATION

# creates downloaded.txt if it does not exist
if [ ! -f ./downloaded.txt ]; then
    touch downloaded.txt
fi

#
# logs in to the wallhaven website to give the user more functionality
# requires 2 arguments:
# arg1: username
# arg2: password
#
function login {
    # checking parameters -> if not ok print error and exit script
    if [ $# -lt 2 ] || [ $1 == '' ] || [ $2 == '' ]; then
        printf "Please check the needed Options for NSFW Content (username and password)\n\n"
        printf "For further Information see Section 13\n\n"
        printf "Press any key to exit\n"
        read
        exit
    fi
    
    # everythings ok --> login
    wget -q --keep-session-cookies --save-cookies=cookies.txt --referer=http://alpha.wallhaven.cc http://alpha.wallhaven.cc/auth/login
    token="$(cat login | grep 'name="_token"' | sed  's .\{180\}  ' | sed 's/.\{16\}$//')"
    wget -q --load-cookies=cookies.txt --keep-session-cookies --save-cookies=cookies.txt --referer=http://alpha.wallhaven.cc/auth/login --post-data="_token=$token&username=$USER&password=$PASS" http://alpha.wallhaven.cc/auth/login
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
        read
        exit
    fi

    # parameters ok --> get page
    wget -q --keep-session-cookies --load-cookies=cookies.txt --referer=alpha.wallhaven.cc -O tmp "http://alpha.wallhaven.cc/$1"
} # /getPage

#
# downloads all the wallpapers from a wallpaperfile
# arg1: the file containing the wallpapers
#
function downloadWallpapers {
    URLSFORIMAGES="$(cat tmp | grep -o '<a class="preview" href="http://alpha.wallhaven.cc/wallpaper/[0-9]*"' | sed  's .\{25\}  ')"
    for imgURL in $URLSFORIMAGES
        do
        img="$(echo $imgURL | sed 's/.\{1\}$//')"
        number="$(echo $img | sed  's .\{36\}  ')"
        if cat downloaded.txt | grep -w "$number" >/dev/null
            then
                printf "\n    Wallpaper $number already downloaded!"
        elif [ $PARALLEL == 1 ]
            then
                echo $number >> downloaded.txt
                echo $number >> download.txt
        else
                echo $number >> downloaded.txt
                wget -q --keep-session-cookies --load-cookies=cookies.txt --referer=alpha.wallhaven.cc $img
                cat $number | egrep -o 'wallpapers.*(png|jpg|gif)' | echo "http://$(cat -)" | wget -q --keep-session-cookies --load-cookies=cookies.txt --referer=http://alpha.wallhaven.cc/wallpaper/$number -i -
                rm $number
            fi
        done

    if [ $PARALLEL == 1 -a -f ./download.txt ]
        then
            cat download.txt | parallel --gnu --no-notice wget -q --keep-session-cookies --load-cookies=cookies.txt --referer=alpha.wallhaven.cc http://alpha.wallhaven.cc/wallpaper/{}
            cat download.txt | parallel --gnu --no-notice 'cat {} | echo "http://$(egrep -o "wallpapers.*(png|jpg|gif)")" | wget -q --keep-session-cookies --load-cookies=cookies.txt --referer=http://alpha.wallhaven.cc/wallpaper/{} -i -'
            rm tmp $(cat download.txt) download.txt
        else
            rm tmp
        fi
} #/downloadWallpapers

# login only when it is required ( for example to download favourites or nsfw content... )
if [ $PURITY == 001 ] || [ $PURITY == 011 ] || [ $PURITY == 111 ] || [ $TYPE == favorites ] ; then
   login $USER $PASS
fi

if [ $TYPE == standard ]; then
    for (( count=0, page=1; count< "$WPNUMBER"; count=count+24, page=page+1 ));
    do
        printf "Download Page $page"
        getPage "search?page=$page&categories=$CATEGORIES&purity=$PURITY&resolutions=$RESOLUTION&ratios=$RATIO&sorting=$SORTING&order=$ORDER"
        printf "\n    - done!\n"
        printf "Download Wallpapers from Page $page"
        downloadWallpapers
        printf "\n    - done!\n"
    done

elif [ $TYPE == search ] ; then
    # SEARCH
    for (( count=0, page=1; count< "$WPNUMBER"; count=count+24, page=page+1 ));
    do
        printf "Download Page $page"
        getPage "search?page=$page&categories=$CATEGORIES&purity=$PURITY&resolutions=$RESOLUTION&ratios=$RATIO&sorting=relevance&order=desc&q=$QUERY"
        printf "\n    - done!\n"
        printf "Download Wallpapers from Page $page"
        downloadWallpapers
        printf "\n    - done!\n"
    done
    
elif [ $TYPE == favorites ] ; then
    # FAVORITES
    # currently using sum of all collections
    favnumber="$(wget -q --keep-session-cookies --load-cookies=cookies.txt --referer=alpha.wallhaven.cc http://alpha.wallhaven.cc/favorites -O - | grep -A 1 "<span>Favorites</span>" | grep -B 1 "<small>" | sed -n '2{p;q}' | sed 's/<[^>]\+>/ /g')"
    for (( count=0, page=1; count< "$WPNUMBER" && count< "$favnumber"; count=count+64, page=page+1 ));
    do
        printf "Download Page $page"
        getPage "favorites?page=$page"
        printf "\n    - done!\n"
        printf "Download Wallpapers from Page $page"
        downloadWallpapers
        printf "\n    - done!\n"
    done

elif [ $TYPE == useruploads ] ; then
    # UPLOADS FROM SPECIFIC USER
    for (( count=0, page=1; count< "$WPNUMBER"; count=count+24, page=page+1 ));
    do
        printf "Download Page $page"
        getPage "user/$USR/uploads?page=$page&purity=$PURITY"
        printf "\n    - done!\n"
        printf "Download Wallpapers from Page $page"
        downloadWallpapers
        printf "\n    - done!\n"
    done

else
    printf "error in TYPE please check Variable\n"
fi

rm -f cookies.txt login login.1