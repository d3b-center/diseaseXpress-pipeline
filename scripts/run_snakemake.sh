source activate rnaseq-env

for i in "$@"
do
case $i in
	-f=*|--freeze=*)
	FREEZE="${i#*=}"
	;;
	-s=*|--sourcedir=*)
	SOURCEDIR="${i#*=}"
	;;
	-p=*|--paired=*)
	PAIRED="${i#*=}"
	;;
esac
done
echo FREEZE = ${FREEZE}
echo SOURCEDIR = ${SOURCEDIR}
echo PAIRED = ${PAIRED}

if [ "$PAIRED" = "TRUE" ]; then
	echo "Paired ended analysis.."
	snakemake -j 30 -s Snakefile_paired --config freeze=$FREEZE sourcedir=$SOURCEDIR
else
	echo "Single ended analysis"
	snakemake -j 30 -s Snakefile_single --config freeze=$FREEZE sourcedir=$SOURCEDIR
fi
