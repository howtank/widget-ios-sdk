sourceCodeVersion=$(node -p "require('.source/package.json').version") 
sdkVersion=$(node -p "require('./package.json').version") 

if [ "$sourceCodeVersion" == "$sdkVersion"  ]; then
  echo 'No new version detected.'
  exit 1
else
  echo '============ update version ================'
  sed -i '' "s/${sdkVersion}/${sourceCodeVersion}/" ./package.json
  sed -i '' "s/'${sdkVersion}'/'${sourceCodeVersion}'/" ./HowtankWidgetSwift.podspec
  sed -i '' "s/${sdkVersion}/${sourceCodeVersion}/" ./README.md

  echo '============ copy framework from source code repo ================'
  cp -Rv .source/build/HowtankWidgetSwift.xcframework ./
fi

