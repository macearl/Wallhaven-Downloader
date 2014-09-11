#!/bin/bash
#
##################################
###    Needed for NSFW/New     ###
##################################

# Enter your Username
USER=""
# Enter your password
PASS=""

#################################
###  End needed for NSFW      ###
#################################

#################################
###   Configuration Options   ###
#################################
# Where should the Wallpapers be stored?
LOCATION=/location/to/your/wallpaper/folder
# How many Wallpapers should be downloaded, should be multiples of 64 (right now they only use a fixed number of thumbs per page)
WPNUMBER=64
# Type standard (newest, oldest, random, hits, mostfav), search, favorites, useruploads
TYPE=standard
# From which Categories should Wallpapers be downloaded
CATEGORIES=111
# Which Purity Wallpapers should be downloaded
PURITY=111
# Which Resolution should be downloaded, leave empty for all
RESOLUTION=
# Which aspectratio should be downloaded, leave empty for all
RATIO=
# Which Type should be displayed (relevance, random, date_added, views, favorites)
SORTING=random
# How should the Wallpapers be ordered (desc, asc)
ORDER=desc
# Searchterm
QUERY="nature"
# User from which Wallpapers should be downloaded (only used for TYPE=useruploads)
USR=AksumkA
#################################
### End Configuration Options ###
#################################
 
if [ ! -d $LOCATION ]; then
    mkdir -p $LOCATION
fi

cd $LOCATION

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
	URLSFORIMAGES="$(cat tmp | grep -o '<a href="http://alpha.wallhaven.cc/wallpaper/[0-9]*"' | sed  's .\{9\}  ')"
	for imgURL in $URLSFORIMAGES
		do
		img="$(echo $imgURL | sed 's/.\{1\}$//')"
		number="$(echo $img | sed  's .\{36\}  ')"
		if cat downloaded.txt | grep -w "$number" >/dev/null
			then
				printf "File already downloaded!\n"
			else
				echo $number >> downloaded.txt
				wget -q --keep-session-cookies --load-cookies=cookies.txt --referer=alpha.wallhaven.cc $img
				cat $number | egrep -o "http://alpha.wallhaven.cc/wallpapers.*(png|jpg|gif)" | wget -q --keep-session-cookies --load-cookies=cookies.txt --referer=http://alpha.wallhaven.cc/wallpaper/$number -i -
				rm $number	
		fi
		done
        rm tmp
} #/downloadWallpapers
 
# login only when it is required ( for example to download favourites or nsfw content... )
if [ $PURITY == 001 ] || [ $PURITY == 011 ] || [ $PURITY == 111 ] ; then
   login $USER $PASS
fi

if [ $TYPE == standard ]; then
    for (( count= 0, page=1; count< "$WPNUMBER"; count=count+64, page=page+1 ));
    do
        printf "Download Page $page"
        getPage "wallpaper/search?page=$page&categories=$CATEGORIES&purity=$PURITY&resolutions=$RESOLUTION&ratios=$RATIO&sorting=$SORTING&order=$ORDER"
        printf "                    - done!\n"
        printf "Download Wallpapers from Page $page"
        downloadWallpapers
        printf "    - done!\n"
    done

elif [ $TYPE == search ] ; then
    # SEARCH
    for (( count= 0, page=1; count< "$WPNUMBER"; count=count+"64", page=page+1 ));
    do
        printf "Download Page $page"
        getPage "wallpaper/search?page=$page&categories=$CATEGORIES&purity=$PURITY&resolutions=$RESOLUTION&ratios=$RATIO&sorting=relevance&order=desc&q=$QUERY"
        printf "                    - done!\n"
        printf "Download Wallpapers from Page $page"
        downloadWallpapers
        printf "    - done!\n"
    done
    
elif [ $TYPE == favorites ] ; then
    # FAVORITES
    # currently using sum of all collections
    favnumber="$(wget -q --keep-session-cookies --load-cookies=cookies.txt --referer=alpha.wallhaven.cc http://alpha.wallhaven.cc/favorites -O - | grep -A 1 "<span>Favorites</span>" | grep -B 1 "<small>" | sed -n '2{p;q}' | sed 's/.\{9\}$//' | sed 's .\{23\}  ')"
    for (( count= 0, page=1; count< "$WPNUMBER" && count< "$favnumber"; count=count+"64", page=page+1 ));
    do
        printf "Download Page $page"
        getPage "favorites?page=$page"
        printf "                    - done!\n"
        printf "Download Wallpapers from Page $page"
        downloadWallpapers
        printf "    - done!\n"
    done

elif [ $TYPE == useruploads ] ; then
    # UPLOADS FROM SPECIFIC USER
    for (( count= 0, page=1; count< "$WPNUMBER"; count=count+"64", page=page+1 ));
    do
        printf "Download Page $page"
        getPage "user/$USR/uploads?page=$page"
        printf "                    - done!\n"
        printf "Download Wallpapers from Page $page"
        downloadWallpapers
        printf "    - done!\n"
    done

else
    printf "error in TYPE please check Variable\n"
fi

rm -f cookies.txt login login.1