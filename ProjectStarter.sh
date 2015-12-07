#!/bin/bash

PWD="`pwd`"

echo ${PWD}

# set target directory name
echo "Please provide a directory name for your project"
read installTarget
mkdir $installTarget

# choose installation type
echo "Please choose the following options:"
echo "[1] Front-End Project Starter Only"
echo "[2] Laravel 5 + Front-End Project Starter"
echo "[3] Node + Front-End Project Starter"
read installOption

if [[ $installOption -eq 1 ]]; then
	git clone https://bitbucket.org/spiremedia/starter-front-end.git $installTarget
fi

if [[ $installOption -eq 2 ]]; then
	# clone repositories
	git clone https://bitbucket.org/spiremedia/starter-front-end.git $installTarget/frontend
	git clone https://bitbucket.org/spiremedia/starter-laravel.git $installTarget/laravel
	
	# move necessary files to project root
	mv -f $installTarget/frontend/gulpfile.js $installTarget/laravel
	mv -f $installTarget/frontend/package.json $installTarget/laravel
	mv -f $installTarget/frontend/editorconfig $installTarget/laravel
	mv -f $installTarget/frontend/.eslintrc $installTarget/laravel
	mv -f $installTarget/frontend/index.html $installTarget/laravel/resources/views/welcome.blade.php
	
	# move front-end files to resources/assets folder
	cp -a $installTarget/frontend/src/. $installTarget/laravel/resources/assets/
	
	# set build path
	sed -i.bak "s~'build/'~'public/'~g" $installTarget/laravel/gulpfile.js
	rm  $installTarget/laravel/gulpfile.js.bak
	
	# set source path
	sed -i.bak "s~'src/'~'resources/assets/'~g" $installTarget/laravel/gulpfile.js
	rm  $installTarget/laravel/gulpfile.js.bak
	
	# change css and javascript directory in welcome script
	sed -i.bak "s/build//g" $installTarget/laravel/resources/views/welcome.blade.php
	rm  $installTarget/laravel/resources/views/welcome.blade.php.bak
	
	# move laravel contents to root
	cp -a $installTarget/laravel/. $installTarget/
	
	# remove temp install folders
	rm -r -f $installTarget/laravel
	rm -r -f $installTarget/frontend
	
	# update packages
	npm install --prefix $installTarget
	composer install --working-dir $installTarget
	gulp build --gulpfile $installTarget/gulpfile.js
fi

if [[ $installOption -eq 3 ]]; then
	# clone repositories
	git clone https://bitbucket.org/spiremedia/starter-front-end.git $installTarget/frontend
	git clone https://bitbucket.org/spiremedia/starter-express.git $installTarget/node
	git clone https://github.com/jaredsohn/mergejson.git $installTarget/mergejson
	
	# move necessary files to project root
	mv -f $installTarget/frontend/gulpfile.js $installTarget/node
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
	sed -i.bak "s~'build/'~'public/'~g" $installTarget/node/gulpfile.js
	rm  $installTarget/node/gulpfile.js.bak
	
	# move laravel contents to root
	cp -a $installTarget/node/. $installTarget/
	
	# remove temp install folders
	rm -r -f $installTarget/node
	rm -r -f $installTarget/frontend
	
	# update packages
	npm install --prefix $installTarget
	gulp build --gulpfile $installTarget/gulpfile.js
fi

echo "all done!"