#!/usr/bin/perl
# Author: Dimitar Yordanov
#
# Create date: Feb 20 2010
# Last update: 27 Mart 2010
# Oracle Manual HC : The main objective of the script is to automate the Manual Oracle HC procedure.
#                    The script collects all necessary information and print it to the console and write it to a log file.
# Usage :   see down.
use Switch;
sub usage {
  print ' 1. ps -ef | grep pmon';
  print ' 2. su - oracle_user';
  print ' 3. export  $ORACLE_SID';
  print ' 4. export $ORACLE_HOME' ;
  print ' 5. ./name_of_the_script';
}

if ( $_[0] eq '--help' ){
  usage;
  exit;
}

# Set up a Log file
my $now = localtime;
@date= split (/ /,$now);
$now=join("_", @date);

$LOG="/tmp/oracle_" . $ENV{ORACLE_SID} . "_HC_" . $now . ".log";


sub print_msg {

open (FILE, ">> $LOG" ) || die("Cannot Open File");
 print FILE "$_[0]\n";     #Sends message to the Log File
 print      "$_[0]\n";     #Sends message to Screen
close FILE;

}

$PREFIX='===>';
sub separate {
  print_msg "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
}

sub separate_sharp {
  print_msg "#############################################";
}

sub uid_to_name {
my @res;
open (FILE,"</etc/passwd")  or die $!;
  while (<FILE>){
     if ( grep (/:@_:/, $_) ){
       @res = split (/:/);
      last;
     }
  }
 close(FILE);
 return $res[0];
}

# Check if the user that is running the script is a oracle user.
my $user=uid_to_name($<); # $< is current id.
chomp ($user);
my $temp="false";
open(PS_F, "ps -ef|");

 while (<PS_F>) {

  if ( grep (/_pmon_/,$_) ){
  ($uid) = split;
   push(@ora_user,$uid);
  }
 }
close(PS_F);

# SET THE ORACLE SIDs
#if ( grep {$_ eq $user} @ora_user ) {
if ( grep( /$user/,@ora_user ) ){
  $temp='great';
}
if ( $temp ne 'great' ){
  print "You are not Oracle user. Plaease switch to Oracle user.\n";
  exit;
}

#Check if $ORACLE_HOME is exported.
if ( $ENV{ORACLE_HOME} eq '') {
   print "Error: ORACLE_HOME is not exported.\n";
   exit;
}
else{
  print_msg "ORACLE_HOME=$ENV{ORACLE_HOME}";
}

#Check if $ORACLE_SID is exported.
if ( ( $ENV{ORACLE_SID} eq '') || ( $ENV{ORACLE_SID} eq 'noid' ) ) {
    print "Error: ORACLE_SID is not exported.\n";
    exit;
}
else{
   print_msg  "ORACLE_SID=$ENV{ORACLE_SID}";
}

my $oracle_home = $ENV{ORACLE_HOME};
my $oracle_sid = $ENV{ORACLE_SID};

sub print_arr(@$)
{
   my(@localArray) = @{(shift)};
   my($element);
   foreach $element (@localArray)
    {
      chomp($element); # because in print_msg is \n
      print_msg "$element";
    }
}

# Execute a standart query
sub sql_exec_np {

   @results=`sqlplus -silent  '/ as sysdba' << eof
    set sqlprompt ""
    set pagesize 0
    set trimspool on
    set echo off
    set feedback off
    @_
    exit
  eof`;

   return @results;
}

sub sql_exec {

    @results=`sqlplus -silent  '/ as sysdba' << eof
    set sqlprompt ""
    set pagesize 0
    set trimspool on
    set echo off
    set feedback off
    @_
    exit
    eof`;
    # This is because sqlplus -silent does not return  "no row selected"
    if ( $#results < 0 ){
     $results[0]="no row selected";
    }
    print_msg "@results";
}


################################################################################

print_msg "Oracle Version";

separate;

sql_exec 'select banner from v\$version;';

print  "Please enter the Oracle Version (11 or 10 or 9 or 8):\n";

while (1){
$version=<STDIN>;
chomp ($version);
        switch ($version) {
           case [8..11]   {$flag=1;}
           else		{print_msg '!!! Incorrect input: Please provided 11 or 10 or 9 or 8 as input !!!'}
        }
   if ($flag){last;}
}
################################################################################

#*******************************************************************************
#   HEALTH CHECK
#*******************************************************************************

#*******************************************************************************
separate_sharp
#1.1 Initial System Setup"
print_msg "1.1 Initial System Setup";
print_msg "  1.1.1 System Settings";

     separate;

     print_msg "$PREFIX O7_DICTIONARY_ACCESSIBILITY";
     print_msg "Should be False, otherwise KO";
     sql_exec 'select VALUE from v\$parameter where NAME=\'O7_DICTIONARY_ACCESSIBILITY\';';

     separate

     print_msg "$PREFIX DELETE_CATALOG_ROLE";
     print_msg "If no role selected then OK";
     sql_exec  "select GRANTEE from dba_role_privs where GRANTED_ROLE='DELETE_CATALOG_ROLE' and grantee not in ('DBA','SYS','SYSTEM','DBSNMP','RMAN') and grantee not in (select grantee from dba_role_privs where GRANTED_ROLE='DBA');";

separate_sharp;
# 1.1.2 Network Settings - Empty, Nothing to be done

print_msg "1.2 System Controls";
print_msg "1.2.1 Logging";

     separate;

     print_msg "$PREFIX AUDIT_TRAIL";
     print_msg "if audit_trail string NONE then KO (should be db or os)";
     sql_exec 'show parameter audit_trail';

     separate

     print_msg "$PREFIX audit definitions";
     print_msg "if no rows selected then KO (should be at least one row)";
     sql_exec  'select * from dba_stmt_audit_opts;';

     separate;

     print_msg "$PREFIX Retain logs";
     print_msg "The diffrence between the oldest and the newest log in days is:";
     @files = `ls $ENV{ORACLE_HOME}/rdbms/audit/`;
     #@files = grep (/aud$/,$files); #/TODO Fix this grep
     foreach $file (@files) {
        chomp ($file);
        $mod_date= -M "$ENV{ORACLE_HOME}/rdbms/audit/$file";
        push (@mod_dates,$mod_date);
     }
#    sort the numeric array
     @mod_dates = sort {$a <=> $b} @mod_dates;
     $date_diff = $mod_dates[$#mod_dates] - $mod_dates[0];
     @date_diff_split = split(/\./,$date_diff);
     print_msg "$date_diff_split[0]\n";
     print_msg "If bigger than in the standart then OK";

   separate_sharp;

#******************************************************************************************************

  print_msg "1.2.2 Identify and Authenticate Users";
###############################################################
  print_msg "$PREFIX Admin Accounts:  sys, system";
  @sys_account = sql_exec_np  "SELECT  username, account_status FROM dba_users WHERE
    ( username='SYS' AND password='D4C5016086B2DC6A' ) OR
    ( username='SYS' AND password='43BE121A2A135FF3' );";

  @system_account = sql_exec_np "SELECT  username, account_status FROM dba_users WHERE
    ( username='SYSTEM' AND password='D4DF7931AB130E37' ) OR
    ( username='SYSTEM' AND password='4438308EE0CAFB7F' );";

  if ( $#sys_account <  0 ){
      print_msg "OK - Account SYS has passwords different from the default one.";
  }
  else{
      print_msg "KO, Y/CUS - Account SYS has default password.";
  }

  if ( $#system_account  < 0 ){
      print_msg "OK - Account SYSTEM has passwords different from the default one.";
  }
  else{
      print_msg "KO, Y/CUS - Account SYSTEM has default password.";
  }

  separate;

################################################################
print_msg "$PREFIX Oracle product (service) Accounts";

 @product_accounts_open = sql_exec_np "SELECT  username FROM dba_users WHERE username
IN ('CTXSYS','DBSNMP','LBACSYS','MDSYS','MTSSYS','ODM','ODM_MTR','OLAPSYS','ORDPLUGINS','ORDSYS','OUTLN','PERFSTAT','TRACESVR','XDB','WMSYS',
'RDSYS','REPADMIN','SYSMAN','DIP') AND account_status='OPEN';";
 #| sqlplus '/ as sysdba' | egrep 'OPEN' | awk '{print $1}'`
   if ( $#product_accounts_open  < 0 ){
     print_msg "OK - No accounts from the list are OPEN";
   }
   else{
     print_msg "\nKO, Y/CUS - Those account should not be OPEN";
     print_arr (\@product_accounts_open);
   }

@product_accounts_def_pass = sql_exec_np "SELECT  username FROM dba_users WHERE
( username='CTXSYS' AND password='24ABAB8B06281B4C')OR
( username='DBSNMP' AND password='E066D214D5421CCC' ) OR
( username='LBACSYS' AND password='AC9700FD3F1410EB' ) OR
( username='MDSYS' AND password='72979A94BAD2AF80' ) OR
( username='MTSSYS' AND password='6465913FF5FF1831' ) OR
(username='ODM' AND password='C252E8FA117AF049' ) OR
( username='ODM_MTR' AND password='A7A32CD03D3CE8D5' ) OR
( username='OLAPSYS' AND password='3FB8EF9DB538647C' ) OR
( username='ORDPLUGINS' AND password='88A2B2C183431F00' ) OR
( username='ORDSYS' AND password='7EFA02EC7EA6B86F' ) OR
( username='OUTLN' AND password='4A3BA55E08595C81' ) OR
( username='PERFSTAT' AND password='AC98877DE1297365' ) OR
( username='TRACESVR' AND password='F9DA8977092B7B81' ) OR
( username='XDB' AND password='88D8364765FCE6AF' ) OR
( username='WMSYS' AND password='7C9BA362F8314299' ) OR
( username='RDSYS' AND password='7EFA02EC7EA6B86FShockedRDSYS' ) OR
( username='REPADMIN' AND password='915C93F34954F5F8' ) OR
( username='SYSMAN' AND password='639C32A115D2CA57' ) OR
( username='DIP' AND password='CE4A36B8E06CA59C' );";
#( username='AURORA$JIS$UTILITY$' AND password='E1BAE6D95AA95F1E' ) OR
#( username='AURORA$ORB$UNAUTHENTICATED' AND password='80C099F0EADF877E' ) OR
#( username='OSE$HTTP$ADMIN' AND password='05327CD9F6114E21' ) OR
 if ( $#product_accounts_def_pass  < 0 ){
     print_msg "OK - No accounts from the list have default password";
 }
 else{
     print_msg "KO, - The following list of accounts have default password.";
     print_arr (\@product_accounts_def_pass);
 }
 
 print_msg "The following list of accounts have default password and are NOT OPEN, so can be fixed.";

     if ( $#product_accounts_open >  -1 ){
      #Convert to hash   product_accounts_open
       %is_open = ();
       for (@product_accounts_open) { $is_open{$_} = 1 }
       foreach (@product_accounts_def_pass){
         if ( ! $is_open{$_} ){
           chomp($_);  # because there is a new line in print_msg
           print_msg "$_";
         }
       }
     }
     else { # there is no open accounts.
       print_arr (\@product_accounts_def_pass);
     }
separate
################################################################
print_msg "$PREFIX All demo user Accounts:";
@demo_accounts_open = sql_exec_np "SELECT  username, account_status FROM dba_users WHERE
USERNAME IN ('SCOTT', 'ADAMS', 'JONES', 'CLARK', 'BLAKE', 'HR', 'OE', 'SH') AND account_status='OPEN';";

 if ( $#demo_accounts_open < 0 ){
     print_msg "OK - No Demo accounts are OPEN";
 }
 else{
     print_msg "KO,Y/CUS, Exeption required - The following list of accounts Demo accounts are OPEN";
     print_arr(\@demo_accounts_open);
 }
separate
################################################################
print_msg "$PREFIX  User Accounts:";

#@user_accounts_def_pass = sql_exec_np "SELECT  username, account_status FROM dba_users WHERE
@user_accounts_def_pass_open = sql_exec_np "SELECT  username, account_status FROM dba_users WHERE
( username='TRACESVR' AND password='F9DA8977092B7B81' AND account_status='OPEN') OR
( username='MDSYS' AND password='72979A94BAD2AF80' AND account_status='OPEN') OR
( username='ORDSYS' AND password='7EFA02EC7EA6B86F' AND account_status='OPEN') OR
( username='ORDPLUGINS' AND password='88A2B2C183431F00' AND account_status='OPEN') OR
( username='CTXSYS' AND password='24ABAB8B06281B4C' AND account_status='OPEN') OR
( username='REPADMIN' AND password='915C93F34954F5F8' AND account_status='OPEN');";

#@user_accounts_def_pass = sql_exec_np "SELECT  username, account_status FROM dba_users WHERE
@user_accounts_def_pass_NOT_open = sql_exec_np "SELECT  username, account_status FROM dba_users WHERE
( username='TRACESVR' AND password='F9DA8977092B7B81' AND account_status!='OPEN' ) OR
( username='MDSYS' AND password='72979A94BAD2AF80' AND account_status!='OPEN') OR
( username='ORDSYS' AND password='7EFA02EC7EA6B86F' AND account_status!='OPEN') OR
( username='ORDPLUGINS' AND password='88A2B2C183431F00' AND account_status!='OPEN') OR
( username='CTXSYS' AND password='24ABAB8B06281B4C' AND account_status!='OPEN') OR
( username='REPADMIN' AND password='915C93F34954F5F8'AND account_status!='OPEN');";


if ( $#user_accounts_def_pass_open > -1){
    print_msg "=>List of the User accounts that OPEN - can not be fixed.";
    print_arr (\@user_accounts_def_pass_open);
}
else{
    print_msg "No default users with default passwords that are OPEN";
}

if ( $#user_accounts_def_pass_NOT_open > -1 ){
    print_msg "=>List of the Default user that are Expired or Locked or Both - Can be fixed.";
    print_arr (\@user_accounts_def_pass_NOT_open);
}
else{
    print_msg "No default users with default passwords that are Expired or Locked";
}

##########################################################################
separate;

     print_msg "$PREFIX User Account  dbsnmp, demo, po8 (Version 7 and higher)";

      @tree_accounts = sql_exec_np "select USERNAME, ACCOUNT_STATUS
                     from dba_users
                     where username in ('DBSNMP','demo','po8') AND ACCOUNT_STATUS='OPEN';";
    if ( $#tree_accounts < 0 ){
          print_msg "OK - DBSNMP,demo, po8  are Locked or Expired or do not exists";
    }
    else{
          print_msg "KO, Y/APP, Exeption required - The accounts in the list are OPEN";
          print_arr (\@tree_accounts);
    }
separate_sharp;
##########################################################################
  print_msg "$PREFIX Any privileges and roles containing the word ANY";
  print_msg " If no row selected - OK,  otherwise KO";
  sql_exec "select * from dba_sys_privs where PRIVILEGE like '%ANY%' and  grantee not in ('DBA','SYS','SYSTEM');";
  
  separate
     #TODO - separate the default users
print_msg "$PREFIX CONNECT, RESOURCE, ALTER SESSION, and UNLIMITED TABLESPACE";
@user_wrong_priv = sql_exec_np "select username,account_status  from dba_users where username not in ('SYS','SYSTEM','OUTLN','DBSNMP')
	and username in ( select grantee from dba_sys_privs where privilege  in ('ALTER SESSION','UNLIMITED_TABLESPACE')
		union
			select grantee from dba_role_privs where granted_role  in ('CONNECT','RESOURCE') );";

	if ( $#user_wrong_priv < 0 ){
          print_msg "OK - No users with wrong priv/rolls";
  }
  else{
          print_msg "KO, - The following list of user have wrong priv.";
          print_msg "For the default users that are locked or expired deviation can be fixed.";
          print_msg "For all OPEN Account Y/APP";
          print_arr (\@user_wrong_priv);
  }

   separate;

     print_msg "$PREFIX Oracle userid";
     print_msg "The user under witch the Oracle run should not be a common user.";
     $user_ora_id=uid_to_name($<); # $< is current id.
     print "$user_ora_id\n";

    separate;

     print_msg "$PREFIX Oracle software owner.";
     print_msg "The user that owns  the Oracle software should not be a common user.";
     my $uid = (stat("$ENV{ORACLE_HOME}/bin/oracle"))[4];
     $uid=uid_to_name($uid);

    open (FILE,"</etc/group")  or die $!;
    while (<FILE>){
       if ( grep (/^dba/, $_) ){
          if ( grep(/$uid/,$_) ){
            print_msg "OK - The owner of the Oracle ($uid) software belongs to DBA system group.";
          }
          else{
            print_msg "KO - The owner of the Oracle software DOES NOT belongs to DBA system group.";
          }
          last;
       }
    }
    close(FILE);
##########################################################################################################

   separate_sharp;

     print_msg "DBA, SYSDBA and SYSOPER Roles (or privileges reserved uniquely for these roles)";
      # TODO - I think it is printig only the first elemenf ot the array
      @user_wrong_privil = sql_exec_np  "select username,account_status from dba_users where
          username not in ('SYS','SYSTEM','OUTLN','DBSNMP')
          and username in (select grantee from dba_role_privs where GRANTED_ROLE in ('DBA', 'SYSDBA', 'SYSOPER'));";

	if ( $#user_wrong_privil < 0 ){
          print_msg "OK - No users with wrong rolls";
  }
  else{
          print_msg "KO, - The following list of user have wrong rolls.";
          print_msg "For the default users that are locked or expired deviation can be fixed.";
          print_msg "For all OPEN Account Y/APP";
          print_arr (\@user_wrong_privil);
  }

  separate

    print_msg "$PREFIX DROP privileges";
    print_msg "If user different than SYS or SYSTEM - then KO.";
    sql_exec "select distinct grantee from dba_sys_privs where privilege like 'DROP%' and grantee not in (select role from dba_roles);";
    #echo "select username,account_status from dba_users where username='WMSYS';" |sqlplus '/ as sysdba'
    
    separate;

    if ( $version < 8 ){
       print_msg "$PREFIX Password management policy is applicable for Oracle8 and higher";
       print_msg "$PREFIX Current Oracle version is $version";
    }
    else{
      print_msg "$PREFIX Password management policy (Oracle8 and higher)";
      print_msg "Must be enabled (including application userids)-";
      print_msg "Password limits should be set in the profile.";
      sql_exec "select distinct profile from dba_profiles;";
      sql_exec "select * from dba_profiles;";
    }
    
    separate;
    
    print_msg "$PREFIX Profile limits";
     print_msg "PASSWORD_LIFE_TIME";
     sql_exec "select profile,limit from dba_profiles where resource_name = 'PASSWORD_LIFE_TIME';";
     separate;
     print_msg "PASSWORD_GRACE_TIME";
     sql_exec "select profile,limit from dba_profiles where resource_name = 'PASSWORD_GRACE_TIME';";
     separate;
     print_msg "PASSWORD_REUSE_TIME";
     sql_exec "select profile,limit from dba_profiles where resource_name = 'PASSWORD_REUSE_TIME';";
     separate;
     print_msg "PASSWORD_REUSE_MAX";
     sql_exec "select profile,limit from dba_profiles where resource_name = 'PASSWORD_REUSE_MAX';";
     separate;
     print_msg "FAILED_LOGIN_ATTEMPTS";
     sql_exec "select profile,limit from dba_profiles where resource_name = 'FAILED_LOGIN_ATTEMPTS';";
     separate;
     print_msg "PASSWORD_LOCK_TIME";
     sql_exec "select profile,limit from dba_profiles where resource_name = 'PASSWORD_LOCK_TIME';";
    

     separate;

     print_msg "$PREFIX IBM_PASSWORD_VERIFY_FUNC";
     print_msg "Must be created to enforce password syntax - if no Function name provided then KO (Ex. null,default,unlimited = KO)";
     sql_exec "select PROFILE,LIMIT from dba_profiles where resource_name = 'PASSWORD_VERIFY_FUNCTION';";
     
     
     separate;

     print_msg "$PREFIX Expire parameter";
     @user_exp= sql_exec_np "select USERNAME,account_status
       from dba_users
       where EXPIRY_DATE is null and account_status='OPEN';";

     	if ( $#user_exp < 0 ){
          print_msg "OK - No Open users with Expire parameter = NULL";
      }
      else{
          print_msg "KO,Y/APP - The following list of user have Expire parameter = NULL and are OPEN.";
          print_arr (\@user_exp);
      }

  separate;

     print_msg "$PREFIX Listener password - Oracle 8i and 9i only";
     if ( ($version == 8) || ($version == 9) ){
      print_msg "Must have passwords but are not required to be changed every 60 days";
      print_msg "Making grep -i passwd of $ENV{ORACLE_HOME}/network/admin/listener.ora";
      print_msg "If not result - KO";
      open (FILE,"<$ENV{ORACLE_HOME}/network/admin/listener.ora")  or die $!;
       while (<FILE>){
        if( grep (/passw/i, $_) ){
          chomp($_);
          print_msg $_;
        }
       }
       close(FILE);
     }#if
     else{
        print_msg "# Not applicable for Oracle  version $version.";
     }

     separate;
       
     print_msg "$PREFIX Listener port - Oracle 8i and 9i only";
     if ( ($version == 8) || ($version == 9) ){
      open (FILE,"<$ENV{ORACLE_HOME}/network/admin/listener.ora")  or die $!;
       while (<FILE>){
        if( grep (/port/i, $_) ){
          chomp($_);
          print_msg $_;
        }
       }
       close(FILE);
     }#if
     else{
        print_msg "# Not applicable for Oracle  version $version.";
     }
     
     separate;
     
   #    echo "Sec_return_server_release_banner (version 11g)"
   #    print_msg ""
   #    sql_exec "show parameter sec_return_server_release_banner;"
   #    separate

#************************************************************************************
#     Protecting Resources -OSRs
#************************************************************************************

separate_sharp;
     print_msg "$PREFIX Tablespaces/UNDO Tablespaces";
     print_msg "";
     sql_exec "select tablespace_name, contents from dba_tablespaces where contents = 'UNDO';";
     print_msg "$PREFIX Rollback segments (RBS)";
     #sql_exec "select distinct a.file_name,a.tablespace_name,b.tablespace_name from dba_data_files a,dba_rollback_segs b where a.tablespace_name=b.tablespace_name and b.tablespace_name not in 'SYSTEM';"
     @files = sql_exec_np "select distinct a.file_name from dba_data_files a,dba_rollback_segs b where a.tablespace_name=b.tablespace_name and b.tablespace_name not in 'SYSTEM';";
      foreach (@files){
        if ( grep (/dbf$/,$_) ){
         system("ls -l $_");
        }
      }
     
separate;

     print_msg "$PREFIX Temporary Tablespaces";
     @temp_files = sql_exec_np  'select name from v\$tempfile;';
     foreach (@temp_files){
        if ( grep (/dbf$/,$_) ){
         system("ls -l $_");
        }
      }

separate;

     print_msg "$PREFIX Control files";
     @ctl_files = sql_exec_np 'select name from v\$controlfile;';
      foreach (@ctl_files){
        if ( grep (/ctl$/,$_) ){
         system("ls -l $_");
        }
      }

separate;

     print_msg "$PREFIX Redo log files";
     print_msg "This functionality is in testing mode. Please provide feedback of your experience.";
     print_msg " DB_CREATE_FILE_DEST : Default location for Oracle-managed datafiles and default for Oracle-managed control files and online redo logs if DB_CREATE_ONLINE_LOG_DEST_n is not specified.";
     sql_exec "show parameter DB_CREATE_FILE_DEST;";
     print_msg "DB_CREATE_ONLINE_LOG_DEST_n :Default for Oracle-managed control files and online redo logs";
     sql_exec "show parameter DB_CREATE_ONLINE_LOG_DEST_n;";
     sql_exec "show parameter DB_CREATE_ONLINE_LOG_DEST;";
     @log_files = sql_exec_np 'select member from v\$logfile;';
      foreach (@log_files){
        if ( grep (/log$|dbf$/,$_) ){
         system("ls -l $_");
        }
      }
      
separate;

     print_msg "$PREFIX Archive log files";
     print_msg "If disable, OK otherwise check the folder.";
     sql_exec "archive log list";


separate;

     print_msg "$PREFIX Alert logs - List the result folder and check only  the alert_ZUDB.log (ls -l folder_name | grep -i alert)";
     @temp = sql_exec_np "show parameter background_dump_dest";
     @alert_log = split (/\s+/,$temp[0]);
     print_msg "$alert_log[0]   $alert_log[1]   $alert_log[2]";
     @log_files = `ls -l $alert_log[2]`;
     foreach (@log_files){
       if ( grep (/alert/,$_) ){
        print_msg ($_);
       }
     }

separate;

     print_msg "$PREFIX Initialization File ";

     $init_SID_ora =  $ENV{ORACLE_HOME} . "/dbs/init" . $ENV{ORACLE_SID} . ".ora";
     if ( -e $init_SID_ora ){
            if (  -l $init_SID_ora ){
              $_ = `ls -l $init_SID_ora`;
              @link = split (/->/);
              $_ = `ls -l $link[1]`;
              print_msg ($_);
            }
            else{
             $_ = `ls -l $init_SID_ora`;
             print_msg ($_);
            }
     }
     else{
          print_msg ("Initialization File does not exist!");
     }
     

separate;

     print_msg "$PREFIX CONFIG.ORA File";
     @res_find = `find $ENV{ORACLE_HOME} -name "config.ora"`;
      foreach (@res_find){
        if ( grep (/config\.ora/,$_) ){
         pring_msg ($_);
        }
      }

separate;

    print_msg "$PREFIX Data files";
    @data_files = sql_exec_np  'select name from v\$datafile;';
     foreach (@data_files){
       if ( grep (/dbf$/,$_)){
         $file=`ls -l $_`;
         chomp ($file);
         print_msg ($file);
       }
     }

separate;

    print_msg "$PREFIX  Dump Files";
    @dump_files = `find $ENV{ORACLE_HOME} -name  *.dmp`;
     foreach (@dump_files){
       if ( grep (/dmp$/,$_) ){
         $file=`ls -l $_`;
         chomp ($file);
         print_msg ($file);
       }
     }

separate;


    print_msg "$PREFIX SPFILE";
    print_msg "";
    $SPfile = $ENV{ORACLE_HOME} . "/dbs/spfile" . $ENV{ORACLE_SID} . ".ora";
         if ( -e $SPfile ){
           if (  -l $SPfile ){
              $_ = `ls -l $SPfile`;
              @link = split (/->/);
              $_ = `ls -l $link[1]`;
              print_msg ($_);
           }
           else{
             $_ = `ls -l $SPfile`;
             print_msg ($_);
           }
         }
         else{
          print_msg ("SPFile does not exist!");
         }

separate;

    print_msg "$PREFIX Oracle program - must have 6751";
     $oracle_prog =  $ENV{ORACLE_HOME} . "/bin/oracle";
     if ( -e $oracle_prog ){
        $_ = `ls -l $oracle_prog`;
        @ora_temp = split (/ /);
        print $ora_temp[0];
        if ($ora_temp[0] eq '-rwsr-s--x'){
          print_msg "Permissions are OK : Current permissions are $ora_temp[0]";
        }
        else{
          print_msg "Permissions are NOT OK - KO : Current permissions are $ora_temp[0]";
        }
     }
     else{
       print_msg ("$oracle_prog does not exist!");
     }

separate;

    print_msg "UTLPWDMG.SQL";
    print_msg "";
    $sql_file =  $ENV{ORACLE_HOME} . "/rdbms/admin/utlpwdmg.sql";
     if ( -e $sql_file){
       $temp_sql = `ls -l $sql_file`;
       print_msg ($temp_sql);
     }
     else{
       print_msg ("$sql_file does not exist!");
     }
     
separate;

     print_msg "$PREFIX Oracle IMP and EXP privileges";
     print_msg "If any ueser in the list - KO";
     @priv_ora = sql_exec_np "select grantee, granted_role from DBA_ROLE_PRIVS
           where granted_role in ('IMP_FULL_DATABASE', 'EXP_FULL_DATABASE')
           and grantee not in ('SYS','SYSTEM','DBA');";

     if ( $#priv_ora < 0 ){
       print_msg ("no row selected");
     }
     else{
        print_arr (\@priv_ora);
     }
     
separate;

     print_msg "$PREFIX ops$ account";
     print_msg "If not user in the list - OK";
     sql_exec "select username from dba_users where username like 'OPS%';";
     
separate;
     print_msg "$PREFIX oratab, oraInst.loc, tnsnames.ora, listener.ora";
     print_msg "Must be owned by the  oracle software owner and oracle group (usually dba)";
     # /etc/oratab
      if ( -e '/etc/oratab' ){
        $ora_temp = `ls -l /etc/oratab`;
        print_msg ($ora_temp);
      }
      else{
        print_msg ("/etc/oratab does not exist!");
      }
     # /etc/oraInst.loc
      if ( -e '/etc/oraInst.loc' ){
        $ora_temp = `ls -l /etc/oraInst.loc`;
        print_msg ($ora_temp);
      }
      else{
        print_msg ("/etc/oraInst.loc does not exist!");
      }
     #tnsnames.ora
      $tns_file =  $ENV{ORACLE_HOME} . '/network/admin/tnsnames.ora';
       if ( -e $tns_file ){
        $ora_temp = `ls -l $tns_file`;
        print_msg ($ora_temp);
      }
      else{
        print_msg ("$tns_file does not exist!");
      }
     # listener.ora
       $lis_file =  $ENV{ORACLE_HOME} . '/network/admin/tnsnames.ora';
       if ( -e $lis_file ){
        $ora_temp = `ls -l $lis_file`;
        print_msg ($ora_temp);
      }
      else{
        print_msg ("$lis_file does not exist!");
      }

separate_sharp;

     print_msg "$PREFIX umask";
      $temp_umask =`umask`;
       if ( $temp_umask eq '027' ){
          print_msg ("OK - umask is 027");
       }
       else{
          print_msg ("KO - umask is $temp_umask");
       }

separate;

     print_msg "$PREFIX Directories containing the database files.";
     print_msg "Check the prermissions";
     @dir_db = sql_exec_np 'select name from v\$datafile;';
     foreach (@dir_db){
       if ( grep (/dbf$/,$_) ){
         $file=`ls -l $_`;
         chomp ($file);
         print_msg ($file);
       }
     }
     
separate_sharp;

  print_msg "dblink parameter only in 8i oracle db.(Current version: $version)";
     if ( $version == 8 ){
       sql_exec "show parameter dblink;";
     }
     else{
       print_msg " Not applicable for this version of Oracle.";
     }

print "=========================================================\n";
print "All collected data will be loged in $LOG\n";
print "=========================================================\n";
#END


