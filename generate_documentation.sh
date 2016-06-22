cd atom-sdk/AtomSDK 
jazzy \
	--author IronSource.Atom \
	--author_url http://www.ironsrc.com/data-flow-management/ \

TARGET_BRANCH="gh-pages"
mkdir $TARGET_BRANCH
cd $TARGET_BRANCH
 
git clone -b $TARGET_BRANCH --single-branch https://github.com/ironSource/atom-ios.git

cd atom-ios
cp -r ../../docs/* .

git add .
git commit -m "Deploy to GitHub Pages"

# Now that we're all set up, we can push.
git push origin $TARGET_BRANCH

cd ../../
rm -r -f $TARGET_BRANCH
rm -r -f docs