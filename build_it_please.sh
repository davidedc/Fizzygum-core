#!/bin/bash

# Ways to invoke:
#   ./build_it_please --homepage
#     leaves out all tests and removes experimental parts of the code
#   ./build_it_please.sh --homepage --keepTestsDirectoryAsIs
#     homepage build, but if there are any tests in the current build, it leaves them there,
#     so you can do a full-test build much quicker later
#   ./build_it_please --notests
#     removes tests, leaves in experimental parts of the code
#   ./build_it_please --keepTestsDirectoryAsIs
#     leaves in experimental parts of the code, leaves the whole "tests" directory AS IS, which saves a loooot of time
#   ./build_it_please
#     leaves in tests and experimental parts of the code

BUILD_PATH=../Fizzygum-builds/latest
SCRATCH_PATH=$BUILD_PATH/delete_me

# save the arguments because we are going to shift them to parse them here,
# but we need to pass them as-is to the python script
args=( "$@" )

# parse the arguments ###################################################################

# we'll put the switches in these variables:
homepage=false
keepTestsDirectoryAsIs=false
notests=false

# see https://stackoverflow.com/questions/7069682/how-to-get-arguments-with-flags-in-bash
while test $# -gt 0; do
  case "$1" in
    --homepage)
      homepage='true'
      shift
      ;;
    --keepTestsDirectoryAsIs)
      keepTestsDirectoryAsIs='true'
      shift
      ;;
    --notests)
      notests='true'
      shift
      ;;
    *)
      break
      ;;
  esac
done


if [ ! -d ../../Fizzygum-all ]; then
  echo
  echo ----------- error -------------
  echo You miss the overarching Fizzygum directory.
  echo ...the directory structure should be
  echo   Fizzygum-all
  echo      - Fizzygum
  echo      - Fizzygum-builds
  echo      - Fizzygum-tests
  echo      - Fizzygum-website
  echo
  exit
fi

if [ ! -d ../Fizzygum-builds ]; then
  echo
  echo ----------- warning! -------------
  echo You miss the destination Fizzygum-builds directory.
  echo I\'ll create one for you, but ideally you should have
  echo checked-out such directory from github
  echo
  mkdir ../Fizzygum-builds
fi

echo coffeescript version -------------
coffee --version

if [ ! -d $BUILD_PATH ]; then
  mkdir $BUILD_PATH
fi


if $keepTestsDirectoryAsIs || $keepTestsDirectoryAsIs ; then
  if [ ! -d $BUILD_PATH/js/tests ]; then
    echo
    echo ----------- error -------------
    echo You asked to keep the tests but there
    echo is no tests directory
    echo
    exit
  else
    find $BUILD_PATH/ -maxdepth 1 ! -path $BUILD_PATH/ -not -name "js" -exec rm -r {} \;
    find $BUILD_PATH/js/ -maxdepth 1 ! -path $BUILD_PATH/js/ -not -name "tests" -exec rm -r {} \;
    # read -p "Delete everything old, press any key to continue... " -n1 -s
  fi
else
  # cleanup the contents of the build directory
  rm -rf $BUILD_PATH/*
fi


if [ ! -d $BUILD_PATH/js ]; then
  mkdir $BUILD_PATH/js
fi

if [ ! -d $BUILD_PATH/icons ]; then
  mkdir $BUILD_PATH/icons
fi

if [ ! -d $BUILD_PATH/js/libs ]; then
  mkdir $BUILD_PATH/js/libs
fi

if [ ! -d $BUILD_PATH/js/sourceCode ]; then
  mkdir $BUILD_PATH/js/sourceCode
fi

if [ ! -d $SCRATCH_PATH ]; then
  mkdir $SCRATCH_PATH
fi

# make space for the test files
if [ ! -d $BUILD_PATH/js/tests ]; then
  mkdir $BUILD_PATH/js/tests
fi

# generate the Fizzygum coffee file in the delete_me directory
# note that this file won't contain much code.
# All the code of the morphs is put in other .coffee files
# which just contain the coffeescript source as the text!
# the first parameter "--homepage" specifies whether this
# is a build for the homepage, in which case a lot of
# legacy code and test-supporting code is left out.
python ./buildSystem/build.py "${args[@]}"

touch $SCRATCH_PATH/fizzygum-boot.coffee

if $notests || $homepage ; then
  printf "BUILDFLAG_LOAD_TESTS = false\n" >> $SCRATCH_PATH/fizzygum-boot.coffee
else
  printf "BUILDFLAG_LOAD_TESTS = true\n" >> $SCRATCH_PATH/fizzygum-boot.coffee
fi


# turn the coffeescript file into js in the js directory
echo "compiling boot file..."

cat $SCRATCH_PATH/numberOfSourceBatches.coffee >> $SCRATCH_PATH/fizzygum-boot.coffee

printf "\n" >> $SCRATCH_PATH/fizzygum-boot.coffee
cat src/boot/globalFunctions.coffee >> $SCRATCH_PATH/fizzygum-boot.coffee

# extensions -----------------------------------------------------

printf "\n" >> $SCRATCH_PATH/fizzygum-boot.coffee
cat src/boot/extensions/Array-extensions.coffee >> $SCRATCH_PATH/fizzygum-boot.coffee

printf "\n" >> $SCRATCH_PATH/fizzygum-boot.coffee
cat src/boot/extensions/Object-extensions.coffee >> $SCRATCH_PATH/fizzygum-boot.coffee

printf "\n" >> $SCRATCH_PATH/fizzygum-boot.coffee
cat src/boot/extensions/CanvasRenderingContext2D-extensions.coffee >> $SCRATCH_PATH/fizzygum-boot.coffee

printf "\n" >> $SCRATCH_PATH/fizzygum-boot.coffee
cat src/boot/extensions/CanvasGradient-extensions.coffee >> $SCRATCH_PATH/fizzygum-boot.coffee

printf "\n" >> $SCRATCH_PATH/fizzygum-boot.coffee
cat src/boot/extensions/String-extensions.coffee >> $SCRATCH_PATH/fizzygum-boot.coffee

printf "\n" >> $SCRATCH_PATH/fizzygum-boot.coffee
cat src/boot/extensions/HTMLCanvasElement-extensions.coffee >> $SCRATCH_PATH/fizzygum-boot.coffee

printf "\n" >> $SCRATCH_PATH/fizzygum-boot.coffee
cat src/boot/extensions/Date-extensions.coffee >> $SCRATCH_PATH/fizzygum-boot.coffee

# extensions -----------------------------------------------------

if ! $homepage ; then
  printf "\n" >> $SCRATCH_PATH/fizzygum-boot.coffee
  cat src/boot/numbertimes.coffee >> $SCRATCH_PATH/fizzygum-boot.coffee
fi

printf "\n" >> $SCRATCH_PATH/fizzygum-boot.coffee
cat src/boot/logging-div.coffee >> $SCRATCH_PATH/fizzygum-boot.coffee

printf "\n" >> $SCRATCH_PATH/fizzygum-boot.coffee
cat src/boot/dependencies-finding.coffee >> $SCRATCH_PATH/fizzygum-boot.coffee

printf "\nmorphicVersion = 'version of $(date)'" >> $SCRATCH_PATH/fizzygum-boot.coffee

coffee -b -c -o $BUILD_PATH/js/ $SCRATCH_PATH/fizzygum-boot.coffee 
echo "... done compiling boot file"

echo "minifying boot file..."
terser --compress --mangle --output $BUILD_PATH/js/fizzygum-boot-min.js -- $BUILD_PATH/js/fizzygum-boot.js
#cp $BUILD_PATH/js/fizzygum-boot.js $BUILD_PATH/js/fizzygum-boot-min.js
echo "... done minifying boot file"

if [ "$?" != "0" ]; then
  tput bel;
  echo "!!!!!!!!!!! error: coffeescript compilation failed!" 1>&2
  exit 1
fi

# copy the html files
cp src/index.html $BUILD_PATH/

# copy the interesting js files from the submodules
cp auxiliary\ files/FileSaver/FileSaver.min.js $BUILD_PATH/js/libs/
cp auxiliary\ files/JSZip/jszip.min.js $BUILD_PATH/js/libs/

cp auxiliary\ files/CoffeeScript/coffee-script_2.0.3.js $BUILD_PATH/js/libs/

if ! $notests && ! $homepage ; then
  coffee -b -c -o $BUILD_PATH/js/libs auxiliary\ files/Mousetrap/Mousetrap.coffee 
  echo "minifying..."
  terser --compress --mangle --output $BUILD_PATH/js/libs/Mousetrap.min.js -- $BUILD_PATH/js/libs/Mousetrap.js
  echo "... done minifying"
fi

echo "copying pre-compiled file"
cp auxiliary\ files/pre-compiled.js $BUILD_PATH/js/pre-compiled.js
echo "... done"

# copy aux icon files
echo "copying icon files..."
cp auxiliary\ files/additional-icons/*.png $BUILD_PATH/icons/
cp auxiliary\ files/additional-icons/spinner.svg $BUILD_PATH/icons/
echo "... done copying icon files"


if ! $notests && ! $homepage && ! $keepTestsDirectoryAsIs ; then

  # read -p "Got in the notests area. Press any key to continue... " -n1 -s

  # the tests files are copied from a directory
  # where they are organised in a clean structure
  # so we copy them with their structure first...
  mkdir $BUILD_PATH/js/tests/assets
  echo "copying all tests (this could take a minute)..."
  cp -r ../Fizzygum-tests/tests/* $BUILD_PATH/js/tests/assets &

  # ------  spinning wheel  -------
  pid=$! # Process Id of the previous running command
  spin='-\|/'
  i=0
  TOTAL_NUMBER_OF_FILES=$(ls -afq ../Fizzygum-tests/tests/ | wc -l)

  while kill -0 $pid 2>/dev/null
  do
    i=$(( (i+1) %4 ))
    CURRENT_NUMBER_OF_FILES=$(ls -afq $BUILD_PATH/js/tests/assets | wc -l)
    printf "\r${spin:$i:1} %s / %s" $CURRENT_NUMBER_OF_FILES $TOTAL_NUMBER_OF_FILES
    sleep 1
  done
  # ------  END OF spinning wheel  -------


  echo "... done copying all tests"

  # ...however, the system actually needs the "body"
  # of the test (the one file with the commands)
  # all into one directory.
  # So we go through what we just copied and pick the
  # test body files and move them all into one
  # directory
  echo "moving all tests body into the same directory..."
  # we don't seem to need the escaping in Windows Subsystem for Linux, while in OSX we needed \{\}
  find $BUILD_PATH/js/tests -iname '*[!0123456789][!0123456789][!0123456789][!0123456789][!0123456789][!0123456789].js' -exec mv {} $BUILD_PATH/js/tests \;
  echo "...done"

  # also all the assets are lumped-in into another directory
  # this is because the path would otherwise be too long to be
  # accessed by browsers (both Edge and Chrome in Nov 2018) in
  # Windows.
  echo "moving all tests assets into the same directory..."
  # we don't seem to need the escaping in Windows Subsystem for Linux, while in OSX we needed \{\}
  find $BUILD_PATH/js/tests/assets -iname 'SystemTest_*.js' -exec mv {} $BUILD_PATH/js/tests/assets \;
  echo "...done"
fi


echo "cleanup unneeded files"
rm -rdf $SCRATCH_PATH
echo "...done"

if $homepage ; then
  rm $BUILD_PATH/worldWithSystemTestHarness.html
  rm $BUILD_PATH/icons/doubleClickLeft.png
  rm $BUILD_PATH/icons/middleButtonPressed.png
  rm $BUILD_PATH/icons/scrollUp.png
  rm $BUILD_PATH/icons/doubleClickRight.png
  rm $BUILD_PATH/icons/rightButtonPressed.png
  rm $BUILD_PATH/icons/xPointerImage.png
  rm $BUILD_PATH/icons/leftButtonPressed.png
  rm $BUILD_PATH/icons/scrollDown.png
  rm $BUILD_PATH/js/fizzygum-boot.js
  
  ls -d -1 $BUILD_PATH/js/sourceCode/* | grep -v /sources_batch | grep -v /Mixin_coffeSource | grep -v /Class_coffeSource | xargs rm -f
  
  echo "generating the pre-compiled file via the browser. this might take a few seconds..."
  . ./buildSystem/generate-pre-compiled-file-via-browser.sh

  if ! $keepTestsDirectoryAsIs && ! $keepTestsDirectoryAsIs ; then
    rm -rdf $BUILD_PATH/js/tests
  fi

  rm $BUILD_PATH/js/libs/FileSaver.min.js
  rm $BUILD_PATH/js/libs/jszip.min.js


  # There are many "if Automator ..." and "if AutomatorRecorder ..." and "if AutomatorPlayer ..."
  # sections in the code. In the homepage version we don't use any of those three classes,
  # and the code in those sections is completely dead,
  # so we can search/replace those checks with "if (false", so that terser can just eliminate
  # both the checks and the dead-code sections.
  sed -i 's/if (Automator[a-zA-Z]*/if (false/g' $BUILD_PATH/js/pre-compiled.js

  terser --compress --mangle --output $BUILD_PATH/js/pre-compiled-min.js -- $BUILD_PATH/js/pre-compiled.js
  mv $BUILD_PATH/js/pre-compiled.js $BUILD_PATH/js/pre-compiled-max.js
  mv $BUILD_PATH/js/pre-compiled-min.js $BUILD_PATH/js/pre-compiled.js
fi

# for OSX: say build done
tput bel
echo done!!!!!!!!!!!!