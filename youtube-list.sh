#!/bin/bash
#
# e.g.
# for https://www.youtube.com/playlist?list=PLL7JeXQtCv0MslQgUCV3DvKmaagaB9Nms use:
# youtube-list.sh PLL7JeXQtCv0MslQgUCV3DvKmaagaB9Nms
# youtube.list you want to download list-id 

cd `dirname $0`
rm -rf list*.txt
for list in $(cat youtube.list | awk '{print $2}')
do
	echo $list
	rm -rf list$list.txt
	for i in `curl -s "https://www.youtube.com/playlist?list=$list" | grep -Po "/watch.*?$list" | sed -r "s#&.*##" | uniq`;
		do
			echo "https://www.youtube.com$i" >> list$list.txt
		done
# want to download newest 6 video of every list-id
	sed -i '7,$d' list$list.txt
	cat list$list.txt >> list.txt 
done
# sleep 30
# clear downloaded video's id
# $downkey is downloaded video's 
for downkey in $(cat list.txt | awk '{print substr($0,33)}')
do
# old:	for okkey in $(ls *.mp4 | sed 's/ //g' | awk '{print substr($0,length($0)-14)}' | awk '{print substr($0,1,11)}')
	for okkey in $(cat down)
	do
		if [ "$downkey" = "$okkey" ]
		then
			sed -i '/'$downkey'/d' list.txt
		fi
	done
done
# for downloadkey in $(cat list.txt)
# do
#	titlekey=`youtube-dl -e "$downloadkey" | awk '{print ($1,$2)}'`
#	youtube-dl -f 22 "$downloadkey" -o '%(title)s.%(id)s.%(ext)s
# done
# youtube-dl download video
youtube-dl -f 22 -i -a list.txt 
# then copy the file to the nas
cp -n ./*.mp4 /mnt/dakula-wd/movie/youtube
ls *.mp4 | sed 's/ //g' | awk '{print substr($0,length($0)-14)}' | awk '{print substr($0,1,11)}' | uniq >> ./down-tmp
cat ./down-tmp | sort |uniq > ./down
rm -rf ./down-tmp
cp ./down ./down-tmp
# find download video file,del the file that is download 30 days ago
find ./ -name "*.mp4" -mtime +2 -exec rm -rf {} \;
find /mnt/dakula-wd/movie/youtube -name "*.mp4" -mtime +60 -exec rm -rf {} \;
