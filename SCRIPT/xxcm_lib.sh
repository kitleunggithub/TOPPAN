#!/bin/bash
#
# Program:	xxcm_lib
# Purpose:	collect common functions used in shell scripts
#
# Functions included:
#   get_parameters                            # Standard function for returning parameters from concurrent manager
#   get_db                                    # Returns database instance
#   is_prod_db                                # Check if production database (returns Y/N)
#   get_ftpserver                             # Get ftp server name
#       set variable ftpserver
#   get_ftp_dirs migrationSetName             # Get local/remote/file mask from XXCM_FTP_FILES
#       set variables $localdir, $remotedir, $filename
#   ftp_get remote_dir remote_file local_dir  # Get file from ftp server
#   ftp_put local_dir local_file remote_dir   # Put file on ftp server
#   ftp_del remote_dir remote_file            # Delete file from ftp server
#   get_db_constant constant                  # Gets database specific constant value from db (XXCM_DB_CONSTANTS)
#   get_flex_value value_set_name value field # Accesses get_flex_value function (XXCM_COMMON.GET_FLEX_VALUE)
#   get_constant constant                     # Gets constant value from db (XXCM_CONSTANTS)
#   get_applcust                              # Get value used by DB server for $APPL_CUST
#   get_utl_path name                         # Get path associated with utl file directory name
#   get_user_email user_id                    # Get email address for specified user
#   get_email prod_email_constant             # Get email address.  If test, gets for specified user.
#                                             # If prod, uses parameter to pull from XXCM_CONSTANTS
#   archive_file   file_name   archive_dir    # Increments file name if already exists in archive
#   exec_sql  "sql script"                    # Get results from sql query.  Quotes are required to keep query in single parameter
#   check_concsub $? "result of CONCSUB"
#   wait_for_request request_id               # Returns name of output file
#
# ============================================================================
# HISTORY:
# 06/07/15  akaplan  Created
# 12/10/15  akaplan  Add get_email function
# 01/08/15  akaplan   Add auditing to track get_parameters setup issues
#                     exec_sql for quick query results
#                     get_applcust for accessing APPLCUST path db server uses
# 09/11/20  kit   	 TM Split Instance
# ============================================================================
#

#==============================================================================
# Function:	get_parameters
# Purpose:	Get the parameters passed by the caller.  This program can be
#		called by the concurrent manager or be called from UNIX command
#		line.
# Parameters:	1 - Number of parameters to parse
#		2..N - Parameters passed to this script
#==============================================================================
export curr_host=`hostname`

# TM Split Instance
#BOLD=$(tput bold)
#RESET=$(tput sgr0)
#UNDERLINE=$(tput smul)

function get_time {
   echo "`date +%T`"
}

get_parameters()
{
   # Get the number of parameters to parse.  Test to see it is a number.
   param_cnt=`expr $1 + 0 2>/dev/null`
   if [ "$param_cnt" = "" ] || [ "$param_cnt" -lt 0 ]
   then
      echo "***** Error: get_parameters:"
      echo "      The first parameter must be a positive number"
      exit 1
   fi
   total_cnt=1

   #
   # Test the first word in the first parameter.  If it is the same as the
   # program name, this is invoked by the concurrent manager.  Otherwise it
   # is invoked by UNIX shell.
   #
   first_word=`echo "$2" |cut -d" " -f1 |sed 's/"//g'`
   echo "first word = $first_word"
   if [ "$first_word" = "$this_script_name" ]
   then
      #
      # Concurrent Manager: All values are in the first parameters.  Each group
      # of value is separated by space.  The first eight are system parameters.
      # Program parameters start as the ninth group.  Each parameter might be
      # enclosed by double quote.
      #
      prog_param=`echo "$2" |cut -d' ' -f9-`
      while [ "$total_cnt" -le "$param_cnt" ]
      do
         param[$total_cnt]=`echo $prog_param |cut -d'"' -f2`
         let total_cnt=$total_cnt+1
         prog_param=`echo $prog_param |cut -d '"' -f3-`
      done

      # Get system parameters.
      req_id=`echo "$2" |cut -d' ' -f2 |cut -d'=' -f2 |sed 's/"//g'`
      login_str=`echo "$2" |cut -d' ' -f3 |cut -d'=' -f2 |sed 's/"//g'`
      user_id=`echo "$2" |cut -d' ' -f4 |cut -d'=' -f2 |sed 's/"//g'`
      user_name=`echo "$2" |cut -d' ' -f5 |cut -d'=' -f2 |sed 's/"//g'`

      echo "req_id=$req_id"
      echo "login_str=XXXXXX"
      echo "user_id=$user_id"
      echo "user_name=$user_name"

   else
      #
      # UNIX: The values for the parameters are listed in sequence in
      # $2, $3, ...  We first shift out $1 which is the parameter count.
      # We loop until we get all the values.
      #
      echo "Variable this_script_name[$this_script_name] does not match incoming program name [$first_word]"
      echo "This is expected if running from UNIX"
      echo

      shift
      while [ "$total_cnt" -le "$param_cnt" ]
      do
         param[$total_cnt]=$1
         let total_cnt=$total_cnt+1
         shift
      done

      # UNIX call must provide system parameters at the end.
      login_str=$1
      user_name=$2

   fi

}

get_user_email() {

  p_user_id=$1

  email=`sqlplus -s $login_str <<END_OF_SQL
  SET PAGESIZE 0
  set lines 80
  WHENEVER SQLERROR EXIT FAILURE
  select email_address
  from fnd_user
  where user_id=$p_user_id;
  EXIT
END_OF_SQL`

  echo "$email"
}

get_email() {
   prod_email_constant=$1
   # If TEST use user_id.  If not found for some reason, use default for database
   # If PROD, use email address setup in XXCM_CONSTANTS
   if [ "`is_prod_db`" = 'N' ]; then
      email1=`get_user_email $user_id`
      if [ "$email1" = "" ]; then
         email1=`get_db_constant DEFAULT_EMAIL`
      fi
   else
      email1=`get_constant $prod_email_constant`
   fi

   echo "$email1"
}

get_db() {

  p_db=`sqlplus -s $login_str <<END_OF_SQL
  SET PAGESIZE 0
  set lines 80
  WHENEVER SQLERROR EXIT FAILURE
  select xxcm_common.get_db
  from dual;
  EXIT
END_OF_SQL`

  echo "$p_db"
}

get_db_constant() {

  p_constant=$1

  p_value=`sqlplus -s $login_str <<END_OF_SQL
  SET PAGESIZE 0
  set lines 80
  WHENEVER SQLERROR EXIT FAILURE
  select xxcm_common.get_db_constant('$p_constant')
  from dual;
  EXIT
END_OF_SQL`

  echo "$p_value"
}

get_applcust() {

  p_value=`sqlplus -s $login_str <<END_OF_SQL
  SET PAGESIZE 0
  set lines 80
  WHENEVER SQLERROR EXIT FAILURE
  select xxcm_common.get_flex_value_field('XXCM_INSTANCES',xxcm_common.get_db,'APPL_CUST')
  from dual;
  EXIT
END_OF_SQL`

  echo "$p_value"
}

get_ftpserver() {
   ftpserver=`get_db_constant "FTP_SERVER"`;

   echo $ftpserver
}

get_ftp_dirs() {
   migrationSet=$1

   # Reset variables
   localdir=
   filename=
   remotedir=

   ftp_rec=`sqlplus -s $login_str << EOSql
set head off
set feed off
set lines 2000
   select 'FTP'
    ||'='||dfv.ftp_type
    ||'~'||dfv.local_directory
    ||'~'||dfv.filename
    ||'~'||dfv.remote_directory
   from fnd_flex_value_sets fvs
      join fnd_flex_values_vl vl on ( vl.flex_value_set_id = fvs.flex_value_set_id )
      join fnd_flex_values_dfv dfv on ( dfv.row_id = vl.row_id )
   where fvs.flex_value_set_name = 'XXCM_FTP_FILES'
     and vl.flex_value='$migrationSet'
/
EOSql`

   localdir=`echo $ftp_rec | cut -d~ -f2`
   filename=`echo $ftp_rec | cut -d~ -f3`
   remotedir=`echo $ftp_rec | cut -d~ -f4`

}

ftp_put()
{
  local_dir=$1
  local_file=$2
  remote_dir=$3
#  if [ -d "$local_dir" ]; then
#     echo "Local directory [$local_dir] does not exist!"
#     return 1
#  fi
  if [ "$remote_dir" ]; then
     bat_file=/usr/tmp/ftp_$$.bat
     echo "cd $remote_dir" > $bat_file
     echo "put $local_file" >> $bat_file
     cd $local_dir
     sftp -b $bat_file oraapps@$ftpserver
     retcode=$?
     rm -f $bat_file
     if [ $retcode -eq 0 ]; then
        echo "  File [$local_file] successfully copied to $remote_dir."
     else
        echo "  File [$local_file] failed attempting to copy to $remote_dir."
     fi
  else
     echo "  No FTP directory setup.  Skipping step"
  fi
  return $retcode
}

ftp_get()
{
  remote_dir=$1
  remote_file=$2
  local_dir=$3

#  if [ -d "$local_dir" ]; then
#     echo "Local directory [$local_dir] does not exist!"
#     return 1
#  fi
  if [ "$remote_dir" ]; then
     bat_file=/usr/tmp/ftp_$$.bat
     echo "cd $remote_dir" > $bat_file
     echo "mget $remote_file" >> $bat_file
     cd $local_dir
     sftp -b $bat_file oraapps@$ftpserver
     retcode=$?
     rm -f $bat_file
     if [ $retcode -eq 0 ]; then
         echo "  File [$remote_file] successfully retrieved."
     else
         echo "  File [$remote_file] retrieval failed."
     fi
  else
     echo "  No FTP directory setup.  Skipping step"
  fi
  return $retcode
}

ftp_del()
{
  remote_dir=$1
  remote_file=$2
  if [ "$remote_dir" ]; then
     bat_file=/usr/tmp/ftp_$$.bat
     echo "cd $remote_dir" > $bat_file
     echo "rm $remote_file" >> $bat_file
     sftp -b $bat_file oraapps@$ftpserver
     retcode=$?
     rm -f $bat_file
     if [ $retcode -eq 0 ]; then
        echo "  File [$remote_file] successfully removed."
     else
        echo "  File [$remote_file] failed attempt to remove file."
     fi
  else
     echo "  No FTP directory setup.  Skipping step"
  fi
  return $retcode
}

get_constant()
{
  p_constant=$1

  p_value=`sqlplus -s $login_str <<END_OF_SQL
  SET PAGESIZE 0
  set lines 80
  WHENEVER SQLERROR EXIT FAILURE
  select xxcm_common.get_constant_value('$p_constant')
  from dual;
  EXIT
END_OF_SQL`

  echo $p_value
}

get_flex_value() {

  p_set_name=$1
  p_value=$2

  if [ "$3" = "" ]; then
     p_field="DESCRIPTION"
  else
     p_field=$3
  fi

  p_value=`sqlplus -s $login_str <<END_OF_SQL
  SET PAGESIZE 0
  set lines 240 
  WHENEVER SQLERROR EXIT FAILURE
  select xxcm_common.get_flex_value_field('$p_set_name','$p_value','$p_field','Y')
  from dual;
  EXIT
END_OF_SQL`

  echo "$p_value"
}

get_utl_path()
{
  p_directory=$1

  p_value=`sqlplus -s $login_str <<END_OF_SQL
  SET PAGESIZE 0
  set lines 80
  WHENEVER SQLERROR EXIT FAILURE
  select xxcm_common.get_utl_path('$p_directory')
  from dual;
  EXIT
END_OF_SQL`

  echo $p_value
}

is_prod_db ()
{
  p_is_prod=`sqlplus -s $login_str <<END_OF_SQL
  SET PAGESIZE 0
  set lines 80
  WHENEVER SQLERROR EXIT FAILURE
  select xxcm_common.is_prod_db
  from dual;
  EXIT
END_OF_SQL`

  echo $p_is_prod
}

#==============================================================================
# Function:     check_concsub
# Purpose:      Check the result of the CONCSUB command
# Parameters:   1 - Return code from CONCSUB
#               2 - CONCSUB result string
#
# Example:
#      cs_result=`CONCSUB $login_str $resp_app_short_name "$resp_name" $user_name WAIT =Y CONCURRENT $resp_app_short_name APXVVCF4 "$PROGRAM_ID" "$IN_FILE"`
#      check_concsub $? "$cs_result"
#==============================================================================
check_concsub()
{
   if [ $1 -ne 0 ]
   then
      echo "ERROR: CONCSUB failed"
      echo "$2"
      exit $1
   fi

   request_id=`echo "$2" |grep 'Submitted request' |cut -d' ' -f3`
   log_file=$APPLCSF/$APPLLOG/"*"$request_id"*"
   output_file=$APPLCSF/$APPLOUT/"*"$request_id"*"
   if [ -z "$request_id" ]
   then
      echo "ERROR: Cannot find the request id after CONCSUB"
      echo "$2"
      exit 1
   fi
  # Find the execution status of the request by querying the database
   result=`sqlplus -s $login_str <<END_OF_SQL
           SET PAGESIZE 0
           SET SERVEROUTPUT ON
           WHENEVER SQLERROR EXIT FAILURE
           DECLARE
              l_request_id NUMBER := $request_id;
              l_phase VARCHAR2(80);
              l_status VARCHAR2(80);
              l_dev_phase VARCHAR2(80);
              l_dev_status VARCHAR2(80);
              l_text VARCHAR2(255);
              found BOOLEAN;
           BEGIN
              found := fnd_concurrent.get_request_status (
                             l_request_id, NULL, NULL,
                             l_phase, l_status,
                             l_dev_phase, l_dev_status,
                             l_text);
              IF NOT found THEN
                 DBMS_OUTPUT.PUT_LINE ('no rows selected');
              ELSE
                 DBMS_OUTPUT.PUT_LINE ('status=' || l_status);
                 DBMS_OUTPUT.PUT_LINE ('phase=' || l_phase);
              END IF;
           END;
/
           EXIT
END_OF_SQL`

   if [ $? != 0 ]
   then
      echo "***** ERROR: SQL statment failed trying to get status for"
      echo "             request $request_id @`get_time`"
      echo "SQL Result:"
      echo "$result"
      exit 1
   fi
   if [ -n "`echo $result | grep 'no rows selected'`" ]
   then
      echo "***** ERROR: No status found for request $request_id @`get_time`"
      exit 1
   fi

   echo "*****"$result"****"
   # Get the status and phase.  It must be completed with either a Normal or
   # a Warning status
   status=`echo "$result" |grep "status=" |cut -d'=' -f2`
   phase=`echo "$result" |grep "phase=" |cut -d'=' -f2`
   if [ "$phase" = "Completed" ] && [ "$status" = "Normal" ]
   then
      echo "Request $request_id completed @`get_time`"
   elif [ "$phase" = "Completed" ] && [ $status = 'Warning' ]
   then
      echo "Request $request_id completed with WARNING @`get_time`"
      retval=2
   else
      echo "***** ERROR: Request $request_id completed with phase ($phase)"
      echo "             and status ($status) @`get_time`"
      return 1
   fi
   echo ""              # Print a blank line
}

archive_file() {
   p_file=$1
   p_archive_dir=$2
   base_file=`basename $p_file`
   archive_file="$p_archive_dir/$base_file"
   incr=0

   now=`date +%m%d%Y.%H%M%S`
   if [ -d $p_archive_dir ]; then
      archive_file="$archive_file.$now"
      echo "Archiving $base_file to $archive_file"
      mv $p_file $archive_file
   else
      echo "Archive dir [$p_archive_dir] does not exist.  Cannot archive file."
   fi
}

exec_sql() {
  p_sql="$1"

  sql_result=`sqlplus -s $login_str <<END_OF_SQL
  SET PAGESIZE 0
  set lines 132
  WHENEVER SQLERROR EXIT FAILURE
  $p_sql;
  EXIT
END_OF_SQL`

  if [ $? -gt 0 ]; then
     echo "Problem executing sql statement"
     return 1
  else
     echo "$sql_result"
  fi

}

wait_for_request() {
   p_request=$1

   v_reqInfo=`sqlplus -s $login_str << EOSql
WHENEVER SQLERROR exit SQL.SQLCODE
REM WHENEVER OSERROR exit FAILURE
set serveroutput on size 999999
set scan off
var outFile VARCHAR2(1000);
set pages 0
set lines 9999
declare
   p_request       NUMBER := ${p_request};
   v_reqInfo       VARCHAR2(1000);
   oErrMsg         VARCHAR2(2000);

   -- Wait for request parameters
   intvl            NUMBER := 20;
   waitTime         NUMBER := 300;
   oPhase           VARCHAR2(2000);
   oStatus          VARCHAR2(2000);
   oDevPhase        VARCHAR2(2000);
   oDevStatus       VARCHAR2(2000);
   oRetStat         BOOLEAN;

   -- If no output file found, use standard output file name
   CURSOR conc_req_output_cur (pReqID NUMBER) IS
      SELECT 'RequestName='||nvl(cr.user_concurrent_program_name, cr.description)
           ||chr(10)||'ProgramName='||cr.program_short_name
           ||chr(10)||'OutputFile='||substr(cro.file_name, instr(cro.file_name, '/', -1) + 1)
           ||chr(10)||'ParamList='||argument_text info
      FROM fnd_conc_req_summary_v cr
        LEFT JOIN fnd_conc_req_outputs cro ON ( cro.concurrent_request_id = cr.request_id )
      WHERE cr.request_id = pReqID;

begin

      WHILE TRUE LOOP
         oRetStat := fnd_concurrent.wait_for_request(request_id => p_request
                                                    ,interval => intvl
                                                    ,max_wait => waitTime
                                                    ,phase => oPhase
                                                    ,status => oStatus
                                                    ,dev_phase => oDevPhase
                                                    ,dev_status => oDevStatus
                                                    ,message => oErrMsg );

         EXIT WHEN NOT oRetStat /* returned unsuccessfully */
                    OR upper(oDevPhase) = 'COMPLETE';
         -- During post-processing, sometimes concludes before post-processing is complete.
         --   If not marked COMPLETE, go wait 60 seconds and check again
         dbms_lock.sleep(60);
      END LOOP;

      IF oRetStat then
         IF upper(trim(oStatus)) IN ('NORMAL') THEN
            OPEN conc_req_output_cur(p_request);
            FETCH conc_req_output_cur INTO v_reqInfo;
            CLOSE conc_req_output_cur;

            dbms_output.put_line(v_reqInfo);
--            dbms_output.put_line('Request '||p_request||' successfully completed');
        ELSE
            raise_application_error(-20020, 'Report ended with status ['||oStatus||']');
         END IF;
      ELSE
         raise_application_error(-20010, 'Request ID not found');
      END IF;
end;
/

EOSql`

if [ $? -ne 0 ]; then
   print "Program did not complete successfully.\n$v_reqInfo"
   exit 1
fi

echo "$v_reqInfo"
}
