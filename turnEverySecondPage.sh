#!/bin/bash

# Script created by Moritz Porst

#some programs to reference
awk=/usr/bin/awk
pdfinfo=/usr/bin/pdfinfo
pdftk=/usr/bin/pdftk

# input format is "script <filename> <parity>
filename=$1
parity=$2

#Check if a file was given
if [ -z "${filename}" ]
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

pdfSize=$(${pdfinfo} $1 | /usr/bin/grep Pages | $awk '{print $2}')
if [ -z ${pdfSize} ]
then
	echo "The file you supplied to this humble script seems to be no pdf. Please check again if ${filename} is the right file"
	exit 1
fi

echo "Good Sir, your $pdfSize pages large document is being processed now"
echo "Assembly of your delicate pdf is in progress..."

# judging from the parity, which sites are to be turned around (ty to Simon)
# shuffle is specifically for this use case...
if [ "${parity}" == "odd" ]
then
	$pdftk $filename shuffle 1-endodddown 1-endeven output "${filename}_corrected.pdf"
else
	$pdftk $filename shuffle 1-endodd 1-endevendown output "${filename}_corrected.pdf"
fi

# put a kind notice there that everything is done...
echo "Done. You may find the humble result being called by the name "${filename}_corrected.pdf""  
