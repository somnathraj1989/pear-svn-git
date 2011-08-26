#!/bin/sh
# move a PEAR package to github
if [ -z "$1" ]; then
    echo "Usage: ./package-to-git.sh package [username]"
    echo "	- package must be a valid PEAR package hosted in PEAR SVN"
    echo "	- username only needs to be specified to utilise the https:// style of github interaction"
    exit 1
fi
package=$1

if [ $2 ]
then
    username=$2
fi

firstrev=`svn log -q http://svn.php.net/repository/pear/packages/$package\
 |tail -n2\
 |head -n1\
 |awk '{split($0,a," "); print a[1]}'\
 |sed 's/r//'`
echo "First SVN revision: $firstrev"
git svn clone -s http://svn.php.net/repository/pear/packages/$package/\
 -r $firstrev\
 --authors-file=./authors.txt
cd $package
git svn rebase

if [ $username ]
then
    git remote add origin https://$username@github.com/pear/$package.git
else
    git remote add origin git@github.com:pear/$package.git
fi 

echo "Visit https://github.com/pear/$package now"
echo "or create it at"
echo " https://github.com/organizations/pear/repositories/new"
echo " + disable issues and wiki"
echo "then run"
echo " $ git push -u origin master"
echo ""
echo "When all went fine, remove it from svn:"
echo " svn rm https://svn.php.net/repository/pear/packages/$package -m '$package moved to https://github.com/pear/$package'"
#echo "Windows users may need to set SVN_EDITOR=notepad.exe"
echo " svn propedit svn:externals https://svn.php.net/repository/pear/packages-all -m '$package moved to https://github.com/pear/$package'"
