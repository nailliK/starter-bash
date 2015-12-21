#!/bin/bash

logo="
████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████
██████████████████████                                  ████████████████████████
█████████████████                                     ██████████████████████████
██████████████                                      ████████████████████████████
████████████                                      ██████████████████████████████
███████████                                     ████████████████████████████████
██████████                                    ██████████████████████████████████
██████████                                  ███████         ████████████████████
██████████                                ███████               ████████████████
██████████                              ███████                   ██████████████
███████████                           ███████                       ████████████
████████████                        ███████                          ███████████
█████████████                     ███████                             ██████████
███████████████                 ███████                               ██████████
██████████████████            ███████                                 ██████████
███████████████████████████████████                                   ██████████
█████████████████████████████████                                    ███████████
███████████████████████████████                                     ████████████
█████████████████████████████                                      █████████████
███████████████████████████                                      ███████████████
██████████████████████████                                   ███████████████████
████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████ SPIRE DIGITAL - PROJECT STARTER


"

function typewriter
{
    text="$1"
    delay="$2"

    for ((i = 0; i < ${#text}; i++)) ; do
        echo -n "${text:$i:1}"
        sleep ${delay}
    done
}

typewriter "${logo}" .000001

git_bb_clone () {
	local protocol=$1
	local repo=$2
	local target=$3

	if [[ $protocol -eq 1 ]]; then
		echo "git clone https://bitbucket.org/spiremedia/$repo $target"
		git clone https://bitbucket.org/spiremedia/$repo $target
	elif [[ $protocol -eq 2 ]]; then
		echo "git clone git@bitbucket.org:spiremedia/$repo $target"
		git clone git@bitbucket.org:spiremedia/$repo $target
	fi
}

PWD="`pwd`"

# set target directory name
echo "Please provide a directory name for your web root"
read -p 'Directory name: ' installTarget
mkdir $installTarget

# choose installation type
echo ""
echo "Please choose one of the following options:"
echo "  [1] Front-End Project Starter Only"
echo "  [2] Laravel 5 + Front-End Project Starter"
echo "  [3] Node + Front-End Project Starter"
echo "  [4] Wordpress + Theme Project Starter"
read -p 'Choice [1, 2, 3, 4]: ' installOption

# choose git clone protocol
echo ""
echo "Bitbucket Git clone protocol"
echo "  [1] https"
echo "  [2] ssh"
read -p 'Choice [1, 2]: ' cloneOption

if [[ $installOption -eq 1 ]]; then
	# clone repository
	git_bb_clone $cloneOption starter-front-end.git $installTarget
fi

if [[ $installOption -eq 2 ]]; then
	# clone repositories
	git_bb_clone  $cloneOption starter-front-end.git $installTarget/frontend
	git_bb_clone  $cloneOption starter-laravel.git $installTarget/laravel
	
	# remove git files
	rm -r -f $installTarget/frontend/.git
	rm -r -f $installTarget/laravel/.git
	
	# move necessary files to project root
	mv -f $installTarget/frontend/package.json $installTarget/laravel
	mv -f $installTarget/frontend/.editorconfig $installTarget/laravel
	mv -f $installTarget/frontend/.eslintrc $installTarget/laravel
	mv -f $installTarget/frontend/index.html $installTarget/laravel/resources/views/welcome.blade.php
	
	# move front-end files to resources/assets folder
	cp -a $installTarget/frontend/src/. $installTarget/laravel/resources/assets/
	
	# set build path
	sed -i.bak 's~"build"~"public"~g' $installTarget/laravel/package.json
	rm  $installTarget/laravel/package.json.bak
	
	# set source path
	sed -i.bak 's~"src"~"resources/assets"~g' $installTarget/laravel/package.json
	rm  $installTarget/laravel/package.json.bak
	
	# change css and javascript directory in welcome script
	sed -i.bak "s/build//g" $installTarget/laravel/resources/views/welcome.blade.php
	rm  $installTarget/laravel/resources/views/welcome.blade.php.bak
	
	# move laravel contents to root
	cp -a $installTarget/laravel/. $installTarget/
	
	# remove temp install folders
	rm -r -f $installTarget/laravel
	rm -r -f $installTarget/frontend
	
	# make public folder and add index.php and .htaccess files
	mkdir $installTarget/public
	mv -f $installTarget/_index.php $installTarget/public/index.php
	mv -f $installTarget/_htaccess $installTarget/public/.htaccess
	
	# update packages
	npm install --prefix $installTarget
	composer install --working-dir $installTarget
fi

if [[ $installOption -eq 3 ]]; then
	# clone repositories
	git_bb_clone $cloneOption starter-front-end.git $installTarget/frontend
	git_bb_clone $cloneOption starter-express.git $installTarget/node
	git clone https://github.com/jaredsohn/mergejson.git $installTarget/mergejson
	
	# remove git files
	rm -r -f $installTarget/node/.git
	rm -r -f $installTarget/frontend/.git

	# move necessary files to project root
	mv -f $installTarget/frontend/.editorconfig $installTarget/node
	mv -f $installTarget/frontend/.eslintrc $installTarget/node
	
	# install mergeJSON library + dependencies
	sudo easy_install SimpleJson
	sudo chmod +x $installTarget/mergejson/mergejson.py
	
	# make new package.json and merge
	touch $installTarget/package.json
	python $installTarget/mergejson/mergejson.py $installTarget/frontend/package.json $installTarget/node/package.json $installTarget/package.json
	
	# remove old package.json files
	rm $installTarget/frontend/package.json
	rm $installTarget/node/package.json
	
	# remove mergeJSON
	rm -r -f $installTarget/mergejson
	rm  -f $installtarget/mergejson.py
	
 	# move front-end files to node src folder
 	cp -a $installTarget/frontend/src/. $installTarget/node/src/
	mkdir $installTarget/node/public
	touch $installTarget/node/public/favicon.ico
	
	# set build path
	sed -i.bak 's~"build"~"public"~g' $installTarget/package.json
	rm  $installTarget/package.json.bak
	
	# move laravel contents to root
	cp -a $installTarget/node/. $installTarget/
	
	# remove temp install folders
	rm -r -f $installTarget/node
	rm -r -f $installTarget/frontend
	
	# update packages
	npm install --prefix $installTarget
fi

if [[ $installOption -eq 4 ]]; then
	# clone repositories
	git clone https://github.com/WordPress/WordPress $installTarget/wordpress
	git_bb_clone $cloneOption starter-front-end.git $installTarget/frontend
	git_bb_clone $cloneOption starter-wordpress.git $installTarget/Spire
	
	# remove git files
	rm -r -f $installTarget/wordpress/.git
	rm -r -f $installTarget/frontend/.git
	rm -r -f $installTarget/Spire/.git
	
	# don't require jQuery
	sed -i.bak "s~ = require('jquery');~;~g" $installTarget/frontend/src/js/main.js
	rm  $installTarget/frontend/src/js/main.js.bak
	
	# move front-end code into the theme folder
	cp -a $installTarget/frontend/. $installTarget/Spire
	
	# Extract plugins from theme Extras folder
	for zip in $installTarget/Spire/Extras/*.zip
	do
		unzip $zip -d $installTarget/wordpress/wp-content/plugins
	done
	
	# move modified wp-config.php file
	mv $installTarget/Spire/Extras/wp-config.php $installTarget/wordpress
	
	#remove sample wp-config file
	rm -f $installTarget/wordpress/wp-config-sample.php
			
	#move front-end files into theme folder
	mkdir $installTarget/Spire/src
	mv -f $installTarget/frontend/.editorconfig $installTarget/Spire
	mv -f $installTarget/frontend/.eslintrc $installTarget/Spire
	mv -f $installTarget/frontend/.gitignore $installTarget/Spire
	mv -f $installTarget/frontend/package.json $installTarget/Spire
	cp -a $installTarget/frontend/src/. $installTarget/Spire/src
	
	# remove unnecessary directories
	rm -r -f $installTarget/Spire/Extras
	rm -r -f $installTarget/frontend

	# remove old index.html file
	rm -f $installTarget/Spire/index.html

	# update packages
	npm install --prefix $installTarget/Spire
	
	# move theme to wordpress/themes directory
	mv $installTarget/Spire $installTarget/wordpress/wp-content/themes
	
	#move wordpress contents to the project root
	cp -a $installTarget/wordpress/. $installTarget/
	rm -r -f $installTarget/wordpress
	rm -r -f $installTarget/.git
fi

echo "all done!"