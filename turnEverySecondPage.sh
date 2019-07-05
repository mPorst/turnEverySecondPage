#!/bin/bash

# Script created by Moritz Porst

#some programs to reference
awk=/usr/bin/awk
pdfinfo=/usr/bin/pdfinfo
pdftk=/usr/bin/pdftk

# input format is "script <filename> <parity>
filename=$1
parity=$2

# Array for pushing back the split file names in order to eventually merge them
declare -a split_pdfs

#Check if a file was given
if [ -z "$filename" ]
then
	echo "Please give a pdf file name"
	echo "input format is script <filename> <parity>"
	exit 1
fi

# check if a parity was chosen
if [ -z "$2" ] 
then
	echo "turn all >odd< or >even< pages ?"
	echo "input format is script <filename> <parity>"
	exit 1
fi

pdfSize=$($pdfinfo $1 | /usr/bin/grep Pages | $awk '{print $2}')
if [ -z $pdfSize ]
then
	echo "The file you supplied to this humble script seems to be no pdf. Please check again if $filename is the right file"
	exit 1
fi

# judging from the parity, calculate which sites are to be turned around
if [ "$parity" == "odd" ]
then
	turnPageMod=1
else
	turnPageMod=0
fi

echo "Splitting a pdf with $pdfSize pages using $parity parity"
# Split pdf in single files, turn every second
# note the additional space in the split_pdfs array. This is required for dereference in the end of the script
echo "Splitting the pdf... this may take a while"
for i in $(seq $pdfSize)
do
	if [ $(( $i % 2 )) -eq $turnPageMod ]
	then
		echo "page $i"
		$pdftk $filename cat $i$parity"south" output $filename"_corrected"$i".pdf"
		split_pdfs+=$filename"_corrected"$i".pdf "
	else
		echo "page $i"
		$pdftk $filename cat $i output $filename"_corrected"$i".pdf"
		split_pdfs+=$filename"_corrected"$i".pdf "
	fi
done

echo "Reassembly of your delicate pdf is in progress..."
$pdftk ${split_pdfs[*]} output $filename"_corrected.pdf"

# finally, delete all the split pdf single pages. noone needs them
echo "Cleaning up..."
/usr/bin/rm ${split_pdfs[*]}

# put a kind notice there that everything is done...
echo "Done. You may find the humble result being called by the name $filename"_corrected.pdf""  
