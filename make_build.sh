version=$(node -p "require('./package.json').version") 
echo "current version is ${version}."

major=0
minor=0
build=0

# break down the version number into it's components
regex="([0-9]+).([0-9]+).([0-9]+)"
if [[ $version =~ $regex ]]; then
  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  build="${BASH_REMATCH[3]}"
  build=$(echo $build + 1 | bc)
fi

newVersion=${major}.${minor}.${build}

sed -i '' "s/${version}/${newVersion}/" ./package.json
sed -i '' "s/'${version}'/'${newVersion}'/" ./HowtankWidgetSwift.podspec
cat ./package.json

#remove old one
rm -rf ./iOS/HowtankWidgetSwift.xcframework

cd ./source
git pull

#run build framewok.
sh ./build_xcframework.sh

# updated podspec
cd ..
sh ./cocoapod.sh

