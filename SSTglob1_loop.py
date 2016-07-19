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
	month = date.strftime('%m')
	month_abrev = date.strftime('%b')
	month_abrev_low = month_abrev.lower()
	year = date.strftime('%Y')
	year_abrev = date.strftime('%y')

	date_fut = date + datetime.timedelta(days=(335))    #advances date 11 months
	date_fut_abrev = date_fut.strftime('%Y%m')
	month_fut = date_fut.strftime('%m')
	month_abrev_fut = date_fut.strftime('%b')
	month_abrev_fut_lower = month_abrev_fut.lower()
	year_fut = date_fut.strftime('%Y')

	print date_abrev
	print date_fut_abrev

	file_clm = str('/archive/rgg/CM2.5/CM2.5_FLOR_B01_p1_ECDA_2.1Rv3.1_01' + month + '/maproom/ocean_month_ens_01-12.1982' + month + '-2012' + month_fut + '.temp.climo.nc')
	file_clm_alt = str('/archive/rgg/CM2.5/CM2.5_FLOR_B01_p1_ECDA_2.1Rv3.1_01' + month + '/maproom/ocean_month_ens01-12.1982' + month + '-2012' + month_fut + '.temp.climo.nc')
	file_rt = str('/archive/rgg/CM2.5/CM2.5_FLOR_B01_p1_ECDA_2.1Rv3.1_01' + date_abrev_opp + '/pp_ensemble/ocean_month/ts/monthly/1yr/ocean_month.' + date_abrev + '-' + date_fut_abrev + '.temp.nc')
	file_rt_alt = str('/archive/rgg/CM2.5/CM2.5_FLOR_B01_p1_ECDA_2.1Rv3.1_01072016/ocean_month.' + date_abrev + '-' + date_fut_abrev + '.temp.nc')

	d = '.'	

	if os.path.isfile(file_clm):
		
		print 'dmgetting archived data files (1/2). Please wait, this may take a while . . .'
		child = p.Popen(["dmget", file_clm],cwd=d)
      		child.communicate()
		cmd = 'use ' + file_clm

	elif os.path.isfile(file_clm_alt):
		
		print 'dmgetting archived data files (1/2). Please wait, this may take a while . . .'
		child = p.Popen(["dmget", file_clm_alt],cwd=d)
      		child.communicate()
		cmd = 'use ' + file_clm_alt

	else:
		print 'dmgetting archived data files (1/2). Please wait, this may take a while . . .'
		print "ERROR. Unable to locate historical data. Please ensure data files are located in their proper directories. See '-h'"
		exit(1)

	if os.path.isfile(file_rt):

		print 'dmgetting archived data files (2/2). Please wait, this may take a while . . .'
		child = p.Popen(["dmget", file_rt],cwd=d)
	      	child.communicate()
		cmd1 = 'use ' + file_rt

	elif os.path.isfile(file_rt_alt):
		
		print 'dmgetting archived data files (2/2). Please wait, this may take a while . . .'
		child = p.Popen(["dmget", file_rt_alt],cwd=d)
      		child.communicate()
		cmd1 = 'use ' + file_rt_alt

	else:
		print 'dmgetting archived data files (2/2). Please wait, this may take a while . . .'
		print "ERROR. Unable to locate contemporary data. Please ensure data files are located in their proper directories. See '-h'"
		exit(1)

	#does pyferret things

	if ( not pyferret.start(quiet=True, journal=False) ): #####change last to true ', unmapped=True'
		print "ERROR. Pyferret start failed. Exiting . . ."
		exit(1)

	header ()


	(errval, errmsg) = pyferret.run(cmd)
	(errval, errmsg) = pyferret.run(cmd1)

	count = 0
	month = 1

	while (count < 6): 
	
		count = count + 1
		
		cmd6 = 'set viewport V' + str(count)
		cmd7 = 'SHA//NOLABEL/lev=(-inf)(-10,-5,1)(-5,5,0.5)(5,10,1)(inf)/PALETTE=blue_darkred (temp[d=2,L=' + str(month) + ':' + str(month+1) + '@AVE,K=1]-temp[d=1,L=' + str(month) + ':' + str(month+1) + '@AVE,K=1])'
		cmd8 = 'go land'
		cmd9 = 'FRAME/FILE=testloopaxis_' + date_abrev + '.png'

		(errval, errmsg) = pyferret.run(cmd6)
		(errval, errmsg) = pyferret.run(cmd7)
		(errval, errmsg) = pyferret.run(cmd8)
		(errval, errmsg) = pyferret.run(cmd9)

		month = month + 2


def header():
	#the following clears data from previously running pyferrets, establishes base parameters, and loads ensemble data


	
	com1 = 'cancel data/all'
	com3 = 'set mem/size=240'
	com4 = 'set WINDOW/SIZE=10'
	com5 = 'define VIEWPORT/xlim=0.,0.4/ylim=0.5,1.0 V1'
	com6 = 'define VIEWPORT/xlim=0.,0.4/ylim=0.,0.5 V2'
	com7 = 'define VIEWPORT/xlim=0.3,0.7/ylim=0.5,1.0 V3'
	com8 = 'define VIEWPORT/xlim=0.3,0.7/ylim=0.,0.5 V4'
	com9 = 'define VIEWPORT/xlim=0.6,1/ylim=0.5,1.0 V5'
	com10 = 'define VIEWPORT/xlim=0.6,1/ylim=0.,0.5 V6'


	(errval, errmsg) = pyferret.run(com1)
	(errval, errmsg) = pyferret.run(com3)
	(errval, errmsg) = pyferret.run(com4)
	(errval, errmsg) = pyferret.run(com5)
	(errval, errmsg) = pyferret.run(com6)
	(errval, errmsg) = pyferret.run(com7)
	(errval, errmsg) = pyferret.run(com8)
	(errval, errmsg) = pyferret.run(com9)
	(errval, errmsg) = pyferret.run(com10)

if __name__=="__main__":
    mymain(sys.argv[1:])
