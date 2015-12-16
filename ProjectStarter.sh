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

	# echo "two $2"
	if [[ $protocol -eq 1 ]]; then
		# git clone https://bitbucket.org/spiremedia/starter-front-end.git $installTarget
		echo "git clone https://bitbucket.org/spiremedia/$repo $target"
		git clone https://bitbucket.org/spiremedia/$repo $target
	elif [[ $protocol -eq 2 ]]; then
		# git clone git@bitbucket.org:spiremedia/starter-front-end.git $installTarget
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
read -p 'Choice [1, 2, 3]: ' installOption

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
	
	# move necessary files to project root
	mv -f $installTarget/frontend/package.json $installTarget/laravel
	mv -f $installTarget/frontend/editorconfig $installTarget/laravel
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

	# move necessary files to project root
	mv -f $installTarget/frontend/editorconfig $installTarget/node
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

echo "all done!"