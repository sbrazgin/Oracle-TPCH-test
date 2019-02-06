#!/bin/sh

########################################################################
#  Sergey Brazgin     05.2018    IAC.DZM
#  mail:   sbrazgin@gmail.com
#  use:
#    ./run_tpch.sh DIRNAME USERNAME IS_FLUSH  
#  example:
#    ./run_tpch.sh RESULT4 TMP_TPCH NO
######################################################################## 

GEN_ERR=1  # something went wrong in the script

# check arguments
if [ $# -eq 0 ] || [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
	echo "No arguments supplied!"
	echo "use: run_tpch.sh DIRNAME USERNAME IS_FLUSH"
	exit
fi 

RESULTS=$1
USER=$2
FLUSHDB=$3


# delay between stats collections (iostat, vmstat, ...)
DELAY=15

# DSS queries timeout (5 minutes or something like that)
DSS_TIMEOUT=300 # 5 minutes in seconds

# log
LOGFILE=bench.log

# -------------------------------------------------------------------
function benchmark_run() {
	mkdir -p $RESULTS
	
	SPOOL_FILE=$RESULTS/settings.log
	report1=`sqlplus / as sysdba <<sql_end
	set linesize 200
    set pagesize 200
    SET AUTOPRINT OFF
    SET TERMOUT OFF
    SET SERVEROUTPUT ON
    column p_name format a30
    column p_value format a100

    SPOOL  ${SPOOL_FILE} 
	
    select name p_name,  value p_value from V\\$SYSTEM_PARAMETER where isdefault='FALSE' order by 1;
sql_end
`
	echo "FLUSHDB = $FLUSHDB"
    if [ $FLUSHDB = "YES" ]; then
		#print_log "FLUSH SHARED_POOL and BUFFER_CACHE !!!"
		print_log "FLUSH BUFFER_CACHE !!!"
		exec1=`sqlplus / as sysdba <<sql_end
		alter system flush  BUFFER_CACHE;
sql_end
`
        echo "exec1 = $exec1"
	else
		print_log "NO FLUSH"
	fi
	
	print_log "running TPC-H benchmark"

	benchmark_dss $RESULTS

	print_log "finished TPC-H benchmark"
}


# -------------------------------------------------------------------
function benchmark_dss() {

	mkdir -p $RESULTS

	mkdir $RESULTS/vmstat-s $RESULTS/vmstat-d $RESULTS/explain $RESULTS/results $RESULTS/errors

	vmstat -s > $RESULTS/vmstat-s-before.log 2>&1
	vmstat -d > $RESULTS/vmstat-d-before.log 2>&1

	print_log "running queries defined in TPC-H benchmark"
    
	SECONDS=0
	echo "Time taken to start sqlplus (sec). Not for run select!" > $RESULTS/results.log
    #	for n in `seq 1 2`
	for n in `seq 1 22`
	do
		q="run$n.sql"

		if [ -f "$q" ]; then

			print_log "  running query $n"

			echo "======= query $n =======" >> $RESULTS/data.log 2>&1;

			vmstat -s > $RESULTS/vmstat-s/before-$n.log 2>&1
			vmstat -d > $RESULTS/vmstat-d/before-$n.log 2>&1

			# run the query on background
			/usr/bin/time -a -f "$n = %e" -o $RESULTS/results.log echo exit | sqlplus $USER/$USER @$q  > $RESULTS/results/$n 2> $RESULTS/errors/$n &

			# wait up to the given number of seconds, then terminate the query if still running (don't wait for too long)
			for i in `seq 0 $DSS_TIMEOUT`
			do

				# the query is still running - check the time
				if [ -d "/proc/$!" ]; then

					# the time is over, kill it with fire!
					if [ $i -eq $DSS_TIMEOUT ]; then
						print_log "    killing query $n (timeout)"					
						kill -9 $!
					else
						# the query is still running and we have time left, sleep another second
						sleep 1;
					fi;

				else
					# the query finished in time, do not wait anymore
					print_log "    query $n finished OK ($i seconds)"
					break;
				fi;
			done;

			vmstat -s > $RESULTS/vmstat-s/after-$n.log 2>&1
			vmstat -d > $RESULTS/vmstat-d/after-$n.log 2>&1

		fi;

	done;
    
	duration=$SECONDS
	print_log  "========================================="
    print_log  "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
	print_log  "========================================="
	
	vmstat -s > $RESULTS/vmstat-s-after.log 2>&1
	vmstat -d > $RESULTS/vmstat-d-after.log 2>&1
}

# -------------------------------------------------------------------
function stat_collection_start()
{
	local RESULTS=$1

	# run some basic monitoring tools (iotop, iostat, vmstat)
	for dev in $DEVICES
	do
		iostat -t -x /dev/$dev $DELAY >> $RESULTS/iostat.$dev.log &
	done;

	vmstat $DELAY >> $RESULTS/vmstat.log &
}

# -------------------------------------------------------------------
function stat_collection_stop()
{
	# wait to get a complete log from iostat etc. and then kill them
	sleep $DELAY

	for p in `jobs -p`; do
		kill $p;
	done;
}

# -------------------------------------------------------------------
function print_log() {
	local message=$1
	echo `date +"%Y-%m-%d %H:%M:%S"` "["`date +%s`"] : $message" >> $RESULTS/$LOGFILE;
}


# -------------------------------------------------------------------
mkdir $RESULTS;

# start statistics collection
stat_collection_start $RESULTS

# run the benchmark
benchmark_run $RESULTS $DBNAME $USER

# stop statistics collection
stat_collection_stop

