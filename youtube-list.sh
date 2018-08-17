#!/bin/bash
#
# e.g.
# for https://www.youtube.com/playlist?list=PLL7JeXQtCv0MslQgUCV3DvKmaagaB9Nms use:
# youtube-list.sh PLL7JeXQtCv0MslQgUCV3DvKmaagaB9Nms
# youtube.list you want to download list-id 
# This is programe is update in 20170729.Del:short filename ahead 20 str and add current time.And change youtube-dl file name.
cd `dirname $0`
rm -rf list*.txt
for list in $(cat youtube.list | awk '{print $2}')
do
	title=`cat youtube.list | grep "$list" | awk '{print $1}'`
	rm -rf list$list.txt
	for i in `curl -s "https://www.youtube.com/playlist?list=$list" | grep -Po "/watch.*?$list" | sed -r "s#&.*##" | uniq`;
		do
			echo -e "$title""\t""https://www.youtube.com$i" >> list$list.txt
		done
# want to download newest 6 video of every list-id
	sed -i '7,$d' list$list.txt
	cat list$list.txt >> list.txt 
done
echo "list complate!"
# clear downloaded video's id
# $downkey is downloaded video's 
for downkey in $(cat list.txt | awk '{print substr($2,33)}')
do
	for okkey in $(cat down)
	do
		if [ "$downkey" = "$okkey" ]
		then
			sed -i '/'$downkey'/d' list.txt
		fi
	done
done
echo "drop downloaded key OK!"
for downurl in $(cat list.txt | awk '{print $2}')
do
        filename=`date +%y-%m-%d-%T`"-"`youtube-dl -e $downurl | sed 's/ //g' | sed 's/[/]/-/g' | awk '{print substr($0,1,30)}'`"-"`echo $downurl |awk '{print substr($0,33)}'`".mp4"
        echo $filename
        youtube-dl -f 22 $downurl -o $filename
done
# copy downloaded key to file:down and file:down-tmp
ls *.mp4 | sed 's/ //g' | awk '{print substr($0,length($0)-14)}' | awk '{print substr($0,1,11)}' | uniq >> ./down-tmp
cat ./down-tmp | sort |uniq > ./down
rm -rf ./down-tmp
cp ./down ./down-tmp
# then copy the file to the nas
for cpfilename in $(cat list.txt | awk '{print substr($2,33)}')
do
#	for cpfiledir in $(cat youtube.list | awk '{print $1}') 
#	do
		cpfiledir=`cat list.txt | grep "$cpfilename" | awk '{print $1}'`
		cptitle=`cat youtube.list | grep "$cpfiledir" | awk '{print $2}'`
		homedir=/mnt/dakula-wd/movie/youtube/
		chkdir="$homedir""$cpfiledir"
		if [ ! -d "$chkdir" ]
		then
			mkdir $chkdir
		fi
#	for cpfilename in $(cat list$cptitle.txt | awk '{print substr($2,33)}')
#	do
		cp -n ./*$cpfilename.mp4 $chkdir
#	done
done
# find download video file,del the file that is download 30 days ago
rm -rf *.part
find ./ -name "*.mp4" -mtime +2 -exec rm -rf {} \;
find /mnt/dakula-wd/movie/youtube -name "*.mp4" -mtime +60 -exec rm -rf {} \;
#rm -rf *.mp4
