#!/usr/bin/env python

import subprocess as p
import datetime
import os
import os.path
import sys, getopt

try:
	import pyferret
except ImportError:
	print "You must module load pyferret"
	exit(1)   

def mymain(argv):    

	now = datetime.datetime.now()
	today = ''
	
	#the following establishes the three options for the script

	try:
		opts, args = getopt.getopt(argv,"thd:",["input="])

	except getopt.GetoptError:
   		print "ERROR Invalid Syntax. See 'SSTanom.py -h'"
		sys.exit(2)

	for opt, arg in opts:
 		if opt == '-h': #help option
        		print '\nThis script automatically generates plots of global SST anomalies for ######## \n'
			print 'Options are as follows:'
			print "'-h' launches this help text"
			print "'-t' generates today's most recent plots"
			print "'-d mmyyy' generates plots for ############## particular date i.e. '-d 072016' \n"
			print 'This script relies on the standard naming convention of SST NetCDF files in this directory:'
			print '######################## \n'
			print 'This script also relies on the historical data located in this archived file:'
			print '######################## \n'
			print 'Written by Miguel M. Moravec. For questions please email miguel.moravec@vanderbilt.edu \n'
        		sys.exit()

		elif opt == '-t':
			#option automatically generates most recent plots
			today = now.strftime('%m%Y')

		elif opt in ('-d', '--input'):
         		#option generates plots for specific date mmyyyy
			today = arg			
	
	#reminds user to select an option

	if today == '':
		print 'ERROR must select an option'
		print "'-t' generates plots for months preceding today's date"
		print "'-d mmyyy' generates plots for ################# preceding a particular date i.e. '-d 072016'"
		exit(1)

	try:
		date = datetime.datetime.strptime('25' + today, '%d%m%Y')

	except ValueError:
		print "ERROR Invalid Syntax. Arguments following '-d' should be formatted: mmyyyy"
		exit(1)

	#sets time variables, used in generation of NetCDFs, plots, and file names	

	date = datetime.datetime.strptime('25' + today, '%d%m%Y')	
	date_abrev = date.strftime('%Y%m')
	date_abrev_opp = date.strftime('%m%Y')
	year = date.strftime('%Y')
	year_abrev = date.strftime('%y')
	date_fut = date + datetime.timedelta(days=(335))    #advances date 11 months
	date_fut_abrev = date_fut.strftime('%Y%m')
	print date_abrev
	print date_fut_abrev

	file_rt = str('/archive/rgg/CM2.5/CM2.5_FLOR_B01_p1_ECDA_2.1Rv3.1_01' + date_abrev_opp + '/pp_ensemble/ocean_month/ts/monthly/1yr/ocean_month.' + date_abrev + '-' + date_fut_abrev + '.temp.nc')
	print file_rt

	d = '.'
	child = p.Popen(["dmget", file_rt],cwd=d)
      	child.communicate()

	#does pyferret things

	if ( not pyferret.start(quiet=True, journal=False, unmapped=True) ):
		print "ERROR. Pyferret start failed. Exiting . . ."
		exit(1)

	header ()

	ano = str('ano' + year)
	
	cmd1 = 'use ' + file_rt
	cmd0 = 'show data'
	cmd2 = 'let sst_clm = TEMP[d=1, J=1]'
	cmd3 = 'let sst_rt = TEMP[d=2, J=1]'
	cmd4 = 'let ' + ano + ' = sst_rt - sst_clm'

	(errval, errmsg) = pyferret.run(cmd1)
	(errval, errmsg) = pyferret.run(cmd0)
	(errval, errmsg) = pyferret.run(cmd2)

def header():
	
	#the following clears data from previously running pyferrets, establishes base parameters, and loads ensemble data

	file_clm = '/archive/rgg/CM2.5/CM2.5_FLOR_B01_p1_ECDA_2.1Rv3.1_0107/maproom/ocean_month_ens_01-12.198207-201206.temp.climo.nc'

	d = '.'
	child = p.Popen(["dmget", file_clm],cwd=d)
      	child.communicate()

	com1 = 'cancel data/all'
	com2 = 'def sym print_opt $1"0"'
	com3 = 'set mem/size=240'
	com4 = 'use ' + file_clm

	(errval, errmsg) = pyferret.run(com1)
	(errval, errmsg) = pyferret.run(com2)
	(errval, errmsg) = pyferret.run(com3)
	(errval, errmsg) = pyferret.run(com4)



if __name__=="__main__":
    mymain(sys.argv[1:])
