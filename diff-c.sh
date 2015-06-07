#!/bin/sh

if [ "$1" = "-i" ]; then
	opt_ignore_comment=1
	old=$2
	new=$3
else
	opt_ignore_comment=0
	old=$1
	new=$2
fi

if [ "$old" = "" ]; then
	echo "0 0 0 0 0"
	exit;
fi
if [ "$new" = "" ]; then
	echo "0 0 0 0 0"
	exit;
fi

if [ ! -f $old ]; then
	echo "0 0 0 0 0"
	exit
fi
if [ ! -f $new ]; then
	echo "0 0 0 0 0"
	exit
fi

if [ $opt_ignore_comment -eq 1 ]; then
	./rm_comment.pl $old > .old~
	./rm_comment.pl $new > .new~
	old=.old~
	new=.new~
fi

diff -u $old $new > .tmp~

cat .tmp~ | grep -v '^\++' | grep '^\+' > .add~
cat .tmp~ | grep -v '^\--' | grep '^\-' > .del~
add=`grep '' .add~ | wc -l`
del=`grep '' .del~ | wc -l`

rm -f .old~
rm -f .new~
rm -f .tmp~
rm -f .add~
rm -f .del~

# X = (+の行数) - (-の行数)
# if X>0  then 追加=X; 修正=(-の行数);
# if X<0  then 削除=|X|; 修正=(+の行数);
# if X==0 then 修正=(-の行数 or +の行数);
if [ $add -gt $del ]; then
	total_add=$(($add-$del))
	total_del=0
	total_mod=$(($del-0))
elif [ $add -lt $del ]; then
	total_add=0
	total_del=$(($del-$add))
	total_mod=$(($add-0))
else
	total_add=0
	total_del=0
	total_mod=$(($add-0))
fi

echo "+$(($add-0)) -$(($del-0)) $total_add $total_del $total_mod"
