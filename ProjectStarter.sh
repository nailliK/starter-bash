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
echo "  [5] Drupal 7 + Front-End Project Starter"
echo "  [6] Slim Framework + Front-End Project Starter"
read -p 'Choice [1, 2, 3, 4, 5, 6]: ' installOption

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
	
	sed -i.bak 's~build~public~g' $installTarget/laravel/src/config.rb
	rm  $installTarget/laravel/src/config.rb.bak
	
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
	
	# install node modules and compass libraries
	npm install --prefix $installTarget
	composer install -d $installTarget
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
	
	sed -i.bak 's~build~public~g' $installTarget/src/config.rb
	rm  $installTarget/src/config.rb.bak
	
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

if [[ $installOption -eq 5 ]]; then
	# Is Drush installed?
	if hash drush 2>/dev/null; then
		echo "Found Drush"
	else
		echo "Installing Drush"
		wget http://files.drush.org/drush.phar
		chmod +x drush.phar
		sudo mv drush.phar /usr/local/bin/drush
		drush init
	fi
	# Fetch the starter-drupal, which gives us both our theme and the drush make file.
	git_bb_clone $cloneOption starter-drupal $installTarget/starter-drupal
	drush make $installTarget/starter-drupal/spiredigital_drupal.make.yml $installTarget/drupal
	
	git_bb_clone  $cloneOption starter-front-end.git $installTarget/frontend

	# remove git files
	rm -r -f $installTarget/starter-drupal/.git
	rm -r -f $installTarget/frontend/.git

	# move theme to Drupal:
	mkdir $installTarget/drupal/sites/all/themes/contrib
	mkdir $installTarget/drupal/sites/all/themes/contrib/starter
	cp -a $installTarget/starter-drupal/theme/* $installTarget/drupal/sites/all/themes/contrib/starter

	# change compass target
	sed -i.bak 's~"build/css"~"public/css"~g' $installTarget/frontend/src/config.rb
	rm  $installTarget/frontend/src/config.rb.bak

	# move necessary files to theme
	mkdir $installTarget/drupal/sites/all/themes/contrib/starter/src
	mv -f $installTarget/frontend/.editorconfig $installTarget/drupal
	mv -f $installTarget/frontend/.eslintrc $installTarget/drupal
	# do we need to append this?
	mv -f $installTarget/frontend/.gitignore $installTarget/drupal/sites/all/themes/contrib/starter
	mv -f $installTarget/frontend/package.json $installTarget/drupal/sites/all/themes/contrib/starter
	cp -a $installTarget/frontend/src/. $installTarget/drupal/sites/all/themes/contrib/starter/src

	# remove frontend code
	rm -r -f $installTarget/frontend
	rm -r -f $installTarget/starter-drupal

	# update packages
	npm install --prefix $installTarget/drupal/sites/all/themes/contrib/starter

	#move drupal contents to the project root
	cp -a $installTarget/drupal/. $installTarget/
	rm -r -f $installTarget/drupal
fi

if [[ $installOption -eq 6 ]]; then
	# Clone Repositories
	git_bb_clone $cloneOption starter-front-end.git $installTarget/frontend
	git_bb_clone $cloneOption starter-slim.git $installTarget/slim
	
	# remove git files
	rm -r -f $installTarget/slim/.git
	rm -r -f $installTarget/frontend/.git

	# move necessary files to project root
	mv -f $installTarget/frontend/.editorconfig $installTarget/slim
	mv -f $installTarget/frontend/.gitignore $installTarget/slim
	mv -f $installTarget/frontend/.eslintrc $installTarget/slim
	mv -f $installTarget/frontend/package.json $installTarget/slim
	cp -a $installTarget/frontend/src/. $installTarget/slim/src
	
	# set build path
	sed -i.bak 's~"build"~"public"~g' $installTarget/slim/package.json
	rm  $installTarget/slim/package.json.bak
	
	sed -i.bak 's~build~public~g' $installTarget/slim/src/config.rb
	rm  $installTarget/slim/src/config.rb.bak
	
	# copy files to root
	cp -a $installTarget/slim/. $installTarget
	
	# remove unused directories
	rm -r -f $installTarget/frontend
	rm -r -f $installTarget/slim
	
	# install node modules and compass libraries
	npm install --prefix $installTarget
	composer install -d $installTarget
fi

echo "all done!"
