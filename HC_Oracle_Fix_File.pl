#!/usr/bin/perl
    my $now = localtime;
    @date= split (/ /,$now);
    $now=join("_", @date);
  
    $LOG="/tmp/oracle_" . $ENV{ORACLE_SID} . "_HC_PROFILES_" . $now . ".log";
    
    $FAILED_LOGIN_ATTEMPTS=5;
    $PASSWORD_GRACE_TIME=5;
    
    ########################## SUBRUTINES #################################
 
    sub print_msg {
  
      open (FILE, ">> $LOG" ) || die("Cannot Open File");
      print FILE "$_[0]\n";     #Sends message to the Log File
      print      "$_[0]\n";     #Sends message to Screen
      close FILE;
  
   }
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
   
   sub separate {
       $message="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" . "@_" . "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n";
       print_msg ($message);
   }
    
   sub sql_exec_np {
  
     @results=`sqlplus -silent  "/ as sysdba" << eof
      set sqlprompt ""
      set pagesize 0
      set linesize 500
      set trimspool on
      set echo off
      set feedback off
      @_
      exit
    eof`;
  
     return @results;
  }
  
  sub sql_exec {

    @results=`sqlplus -silent  "/ as sysdba" << eof
    set sqlprompt ""
    set pagesize 0
    set linesize 500
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

     ############################## SCRIPT ###########################################
  
     #take the names of the profiles.
     separate (" PASSWORD_GRACE_TIME ");
     @profiles_arr = sql_exec_np "select DISTINCT profile from dba_profiles;";
     
     sql_exec "select Profile,LIMIT from dba_profiles where RESOURCE_NAME='PASSWORD_GRACE_TIME';";
     foreach (@profiles_arr){
      $pr_gr=$_;
      chomp($pr_gr);
      print "Do you want to set PASSWORD_GRACE_TIME to $PASSWORD_GRACE_TIME for profile $pr_gr [Y/n]";
      $res=<STDIN>;
      chomp($res);
      if ( $res eq "Y" ){ 
        sql_exec_np "alter profile $pr_gr limit PASSWORD_GRACE_TIME $PASSWORD_GRACE_TIME;";
        print_msg " => PASSWORD_GRACE_TIME set to $PASSWORD_GRACE_TIME for PROFILE $pr_gr.\n";
      }    
     }
     sql_exec "select Profile,LIMIT from dba_profiles where RESOURCE_NAME='PASSWORD_GRACE_TIME';";
     
     ############
     
     separate (" FAILED_LOGIN_ATTEMPTS ");
     sql_exec "select Profile,LIMIT from dba_profiles where RESOURCE_NAME='FAILED_LOGIN_ATTEMPTS';";
     foreach (@profiles_arr){
      $pr_gr=$_;
      chomp($pr_gr);
      #Fix FAILED_LOGIN_ATTEMPTS
      sql_exec_np "alter profile $pr_gr limit FAILED_LOGIN_ATTEMPTS $FAILED_LOGIN_ATTEMPTS;";
      print_msg " => FAILED_LOGIN_ATTEMPTS set to $FAILED_LOGIN_ATTEMPTS for PROFILE $pr_gr";
     }
     print_msg "\n";
     sql_exec "select Profile,LIMIT from dba_profiles where RESOURCE_NAME='FAILED_LOGIN_ATTEMPTS';";
     
     ############
   
    
   separate (" Default users with DEFAULT Password ");
   
   @def_ora_user_def_pass_locked = sql_exec_np "SELECT  username  FROM dba_users WHERE
  ( username='ADAMS' AND password='72CDEF4A3483F60D' AND ACCOUNT_STATUS != 'OPEN') OR
  ( username='DMSYS' AND password='BFBA5A553FD9E28A' AND ACCOUNT_STATUS != 'OPEN') OR
  ( username='MDDATA' AND password='DF02A496267DEE66' AND ACCOUNT_STATUS != 'OPEN') OR
  ( username='EXFSYS' AND password='66F4EF5650C20355' AND ACCOUNT_STATUS != 'OPEN') OR
  ( username='ADLDEMO' AND password='147215F51929A6E8' AND ACCOUNT_STATUS != 'OPEN') OR
  ( username='ADMIN' AND password='CAC22318F162D597'  AND ACCOUNT_STATUS != 'OPEN' )  OR
  ( username='ADMIN' AND password='B8B15AC9A946886A'  AND ACCOUNT_STATUS != 'OPEN' )  OR
  ( username='ADMINISTRATOR' AND password='1848F0A31D1C5C62'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='ADMINISTRATOR' AND password='F9ED601D936158BD'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='ANDY' AND password='B8527562E504BC3F'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='AP' AND password='EED09A552944B6AD'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='APPLSYS' AND password='0F886772980B8C79'  AND ACCOUNT_STATUS != 'OPEN' ) OR 
  ( username='APPLYSYSPUB' AND password='A5E09E84EC486FC9' AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='APPS' AND password='D728438E8A5925E0' AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='APPUSER' AND password='7E2C3C2D4BF4071B' AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='AQ' AND password='2B0C31040A1CFB48' AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='AQDEMO' AND password='5140E342712061DD'  AND ACCOUNT_STATUS != 'OPEN' ) OR 
  ( username='AQJAVA' AND password='8765D2543274B42E'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='AQUSER' AND password='4CF13BDAC1D7511C' AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='AUDIOUSER' AND password='CB4F2CEC5A352488'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='AURORA\$JIS\$UTILITY\$' AND password='E1BAE6D95AA95F1E'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='AURORA\$ORB\$UNAUTHENTICATED' AND password='80C099F0EADF877E'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='BC4J' AND password='EAA333E83BF2810D'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='BLAKE' AND password='9435F2E60569158E' AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='BRIO_ADMIN' AND password='EB50644BE27DF70B'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='CATALOG' AND password='397129246919E8DA'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='CDEMO82' AND password='67B891F114BE3AEB'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='CDEMO82' AND password='7299A5E2A5A05820'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='CDEMOCOR' AND password='3A34F0B26B951F3F'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='CDEMORID' AND password='E39CEFE64B73B308'  AND ACCOUNT_STATUS != 'OPEN' ) OR 
  ( username='CDEMOUCB' AND password='CEAE780F25D556F8'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='CENTRA' AND password='63BF5FFE5E3EA16D'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='CIDS' AND password='AA71234EF06CE6B3'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='CIS' AND password='AA2602921607EE84' AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='CISINFO' AND password='BEA52A368C31B86F'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='CLARK' AND password='7AAFE7D01511D73F'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='COMPANY' AND password='402B659C15EAF6CB'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='COMPIERE' AND password='E3D0DCF4B4DBE626'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='CQSCHEMAUSER' AND password='04071E7EDEB2F5CC'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='CSMIG' AND password='09B4BB013FBD0D65'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='CTXDEMO' AND password='CB6B5E9D9672FE89'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='CTXSYS' AND password='24ABAB8B06281B4C'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='CTXSYS' AND password='71E687F036AD56E5'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='DBI' AND password='D8FF6ECEF4C50809'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='DBSNMP' AND password='E066D214D5421CCC'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='DEMO' AND password='4646116A123897CF'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='DEMO8' AND password='0E7260738FDFD678'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='DEMO9' AND password='EE02531A80D998CA'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='DES' AND password='ABFEC5AC2274E54D'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='DEV2000_DEMOS' AND password='18A0C8BD6B13BEE2'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='DISCOVERER_ADMIN' AND password='5C1AED4D1AADAA4C'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='DIP' AND password='CE4A36B8E06CA59C'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='DSGATEWAY' AND password='6869F3CFD027983A'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='DSSYS' AND password='E3B6E6006B3A99E0'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='EMP' AND password='B40C23C6E2B4EA3D'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='ESTOREUSER' AND password='51063C47AC2628D4'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='EVENT' AND password='7CA0A42DA768F96D'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='FINANCE' AND password='6CBBF17292A1B9AA'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='FND' AND password='0C0832F8B6897321'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='FROSTY' AND password='2ED539F71B4AA697'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='GL' AND password='CD6E99DACE4EA3A6'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='GPFD' AND password='BA787E988F8BC424'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='GPLD' AND password='9D561E4D6585824B'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='HCPARK' AND password='3DE1EBA32154C56B'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='HLW' AND password='855296220C095810'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='HR' AND password='4C6D73C3E8B0F0DA'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='HR' AND password='6399F3B38EDF3288'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='IMAGEUSER' AND password='E079BF5E433F0B89'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='IMEDIA' AND password='8FB1DC9A6F8CE827'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='JMUSER' AND password='063BA85BF749DF8E'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='JONES' AND password='B9E99443032F059D'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='JWARD' AND password='CF9CB787BD98DA7F'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='L2LDEMO' AND password='0A6B2DF907484CEE'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='LBACSYS' AND password='AC9700FD3F1410EB'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='LIBRARIAN' AND password='11E0654A7068559C'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='MASTER' AND password='9C4F452058285A74'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='MDDEMO' AND password='46DFFB4D08C33739'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='MDDEMO_CLERK' AND password='564F871D61369A39'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='MDDEMO_MGR' AND password='B41BCD9D3737F5C4'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='MDSYS' AND password='72979A94BAD2AF80'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='MFG' AND password='FC1B0DD35E790847'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='MGWUSER' AND password='EA514DD74D7DE14C'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='MIGRATE' AND password='5A88CE52084E9700'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='MILLER' AND password='D0EFCD03C95DF106'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='MMO2' AND password='AE128772645F6709'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='MMO2' AND password='A0E2085176E05C85'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='MODTEST' AND password='BBFF58334CDEF86D'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='MOREAU' AND password='CF5A081E7585936B'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='MTS_USER' AND password='E462DB4671A51CD4'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='MTSSYS' AND password='6465913FF5FF1831'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='MXAGENT' AND password='C5F0512A64EB0E7F'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='NAMES' AND password='9B95D28A979CC5C4'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OAS_PUBLIC' AND password='A8116DB6E84FA95D'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OCITEST' AND password='C09011CB0205B347'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='ODS' AND password='89804494ADFC71BC'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='ODSCOMMON' AND password='59BBED977430C1A8'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='ODM' AND password='C252E8FA117AF049'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='ODM_MTR' AND password='A7A32CD03D3CE8D5'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OE' AND password='D1A2DFC623FDA40A'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OE' AND password='9C30855E7E0CB02D'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OEMADM' AND password='9DCE98CCF541AAE6'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OEMREP' AND password='7BB2F629772BF2E5'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OLAPDBA' AND password='1AF71599EDACFB00'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OLAPSVR' AND password='AF52CFD036E8F425'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OLAPSYS' AND password='3FB8EF9DB538647C'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OMWB_EMULATION' AND password='54A85D2A0AB8D865'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OO' AND password='2AB9032E4483FAFC'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OPENSPIRIT' AND password='D664AAB21CE86FD2'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='ORACACHE' AND password='5A4EEC421DE68DDD'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='ORAREGSYS' AND password='28D778112C63CB15'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='ORDPLUGINS' AND password='88A2B2C183431F00'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='ORDSYS' AND password='7EFA02EC7EA6B86F'  AND ACCOUNT_STATUS != 'OPEN' ) OR 
  ( username='ORACLE' AND password='38E38619A12E0257'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='ORASSO' AND password='F3701A008AA578CF'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OSE$HTTP$ADMIN' AND password='05327CD9F6114E21'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OSP22' AND password='C04057049DF974C2'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OUTLN' AND password='4A3BA55E08595C81'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OWA' AND password='CA5D67CD878AFC49'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OWA_PUBLIC' AND password='0D9EC1D1F2A37657'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='OWNER' AND password='5C3546B4F9165300'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PANAMA' AND password='3E7B4116043BEAFF'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PATROL' AND password='0478B8F047DECC65'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PERFSTAT' AND password='AC98877DE1297365'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PLEX' AND password='99355BF0E53FF635'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PLSQL' AND password='C4522E109BCF69D0'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PM' AND password='C7A235E6D2AF6018'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PM' AND password='72E382A52E89575A'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PO' AND password='355CBEC355C10FEF'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PO7' AND password='6B870AF28F711204'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PO8' AND password='7E15FBACA7CDEBEC'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PORTAL30' AND password='D373ABE86992BE68'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PORTAL30' AND password='969F9C3839672C6D'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PORTAL30_DEMO' AND password='CFD1302A7F832068'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PORTAL30_PUBLIC' AND password='42068201613CA6E2'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PORTAL30_SSO' AND password='882B80B587FCDBC8'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PORTAL30_SSO_PS' AND password='F2C3DC8003BC90F8'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PORTAL30_SSO_PUBLIC' AND password='98741BDA2AC7FFB2'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='POWERCARTUSER' AND password='2C5ECE3BEC35CE69'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PRIMARY' AND password='70C3248DFFB90152'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PUBSUB' AND password='80294AE45A46E77B'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='PUBSUB1' AND password='D6DF5BBC8B64933E'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QDBA' AND password='AE62CB8167819595'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QS' AND password='4603BCD2744BDE4F'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QS' AND password='8B09C6075BDF2DC4'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QS_ADM' AND password='3990FB418162F2A0'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QS_ADM' AND password='991CDDAD5C5C32CA'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QS_CB' AND password='870C36D8E6CD7CF5'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QS_CB' AND password='991CDDAD5C5C32CA'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QS_CBADM' AND password='20E788F9D4F1D92C'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QS_CBADM' AND password='7C632AFB71F8D305'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QS_CS' AND password='2CA6D0FC25128CF3'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QS_CS' AND password='91A00922D8C0F146'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QS_ES' AND password='9A5F2D9F5D1A9EF4'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QS_ES' AND password='E6A6FA4BB042E3C2'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QS_OS' AND password='0EF5997DC2638A61'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QS_OS' AND password='FF09F3EB14AE5C26'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QS_WS' AND password='0447F2F756B4F460'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='QS_WS' AND password='24ACF617DD7D8F2F'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='RE' AND password='933B9A9475E882A6'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='REP_MANAGER' AND password='2D4B13A8416073A1'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='REP_OWNER' AND password='88D8F06915B1FE30'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='REP_OWNER' AND password='BD99EC2DD84E3B5C'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='REPADMIN' AND password='915C93F34954F5F8'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='REPORTS_USER' AND password='635074B4416CD3AC'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='RMAIL' AND password='DA4435BBF8CAE54C'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='RMAN' AND password='E7B5D92911C831E1'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SAMPLE' AND password='E74B15A3F7A19CA8'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SAP' AND password='BEAA1036A464F9F0'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SCOTT' AND password='F894844C34402B67'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SDOS_ICSAP' AND password='C789210ACC24DA16'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SECDEMO' AND password='009BBE8142502E10'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SERVICECONSUMER1' AND password='183AC2094A6BD59F'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SH' AND password='54B253CBBAAA8C48'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SH' AND password='9793B3777CD3BD1A'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SITEMINDER' AND password='061354246A45BBAB'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SLIDE' AND password='FDFE8B904875643D'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='STARTER' AND password='6658C384B8D63B0A'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='STRAT_USER' AND password='AEBEDBB4EFB5225B'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SWPRO' AND password='4CB05AA42D8E3A47'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SWUSER' AND password='783E58C29D2FC7E1'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SYMPA' AND password='E7683741B91AF226'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SYS' AND password='D4C5016086B2DC6A'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SYS' AND password='43BE121A2A135FF3'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SYSADM' AND password='BA3E855E93B5B9B0'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SYSMAN' AND password='639C32A115D2CA57'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SYSTEM' AND password='D4DF7931AB130E37'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='SYSTEM' AND password='4438308EE0CAFB7F'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='TAHITI' AND password='F339612C73D27861'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='TDOS_ICSAP' AND password='7C0900F751723768'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='TESTPILOT' AND password='DE5B73C964C7B67D'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='TRACESVR' AND password='F9DA8977092B7B81'  AND ACCOUNT_STATUS != 'OPEN' ) OR 
  ( username='TRAVEL' AND password='97FD0AE6DFF0F5FE'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='TSDEV' AND password='29268859446F5A8C'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='TSUSER' AND password='90C4F894E2972F08'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='TURBINE' AND password='76F373437F33F347'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='ULTIMATE' AND password='4C3F880EFA364016'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='USER' AND password='74085BE8A9CF16B4'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='USER0' AND password='8A0760E2710AB0B4'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='USER1' AND password='BBE7786A584F9103'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='USER2' AND password='1718E5DBB8F89784'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='USER3' AND password='94152F9F5B35B103'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='USER4' AND password='2907B1BFA9DA5091'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='USER5' AND password='6E97FCEA92BAA4CB'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='USER6' AND password='F73E1A76B1E57F3D'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='USER7' AND password='3E9C94488C1A3908'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='USER8' AND password='D148049C2780B869'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='USER9' AND password='0487AFEE55ECEE66'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='UTLBSTATU' AND password='C42D1FA3231AB025'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='VIDEOUSER' AND password='29ECA1F239B0F7DF'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='VIF_DEVELOPER' AND password='9A7DCB0C1D84C488'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='VIRUSER' AND password='404B03707BF5CEA3'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='VRR1' AND password='811C49394C921D66'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='VRR1' AND password='3D703795F61E3A9A'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='WEBCAL01' AND password='C69573E9DEC14D50'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='WEBDB' AND password='D4C4DCDD41B05A5D'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='WEBREAD' AND password='F8841A7B16302DE6'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='WKPROXY' AND password='B97545C4DD2ABE54'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='WKSYS' AND password='545E13456B7DDEA0'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='WKSYS' AND password='69ED49EE1851900D'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='WMSYS' AND password='7C9BA362F8314299'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='WWW' AND password='6DE993A60BC8DBBF'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='WWWUSER' AND password='F239A50072154BAC'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='XDB' AND password='88D8364765FCE6AF'  AND ACCOUNT_STATUS != 'OPEN' ) OR
  ( username='XPRT' AND password='0D5C9EFC2DFE52BA'  AND ACCOUNT_STATUS != 'OPEN' );";
     
     if ( $#def_ora_user_def_pass_locked < 0 ){
      print_msg " => There are NO DEFAULT users with default passwords that are Expired or Locked";
     }
     else{
       print_msg " => The following list of DEFAULT USERS have DEFAULT PASSWORDS and are NOT OPEN.\n";
       print_arr (\@def_ora_user_def_pass_locked);
       print " => Do you want to set password 'abc01abc' to all the USERS from the list [Y/n] :";
       $res=<STDIN>;
       chomp($res);
       if ( $res eq "Y" ){
         foreach(@def_ora_user_def_pass_locked){
           $def_user=$_;
           chomp($def_user);
           sql_exec_np "alter user $def_user identified by abc01abc#;";
           print_msg " => The password for user $def_user was set to abc01abc#";
         }
       }
       else{
        print_msg " => No passwords have been changed.\n";
       } 
     }
     
     
       ############
   

       separate (" LOCKED OR EXPIRED DEFAULT USERS ROLES ");
       
       @def_user_locked = sql_exec_np ("select username
                  from dba_users
                  where ACCOUNT_STATUS!='OPEN'
                  AND 
                 USERNAME in ('DMSYS','MDDATA','EXFSYS','ADAMS','ADLDEMO','ADMIN',
                 'MINISTRATOR','ADMINISTRATOR',
                 'ANDY','AP','APPLYSYSPUB','APPS','APPUSER','AQ', 'AQDEMO',
                 'AQJAVA','AQUSER','AUDIOUSER','AURORA\$JIS\$UTILITY\$',
                 'AURORA\$ORB\$UNAUTHENTICATED','BC4J', 'BLAKE','BRIO_ADMIN', 'CATALOG',
                 'CDEMO82','CDEMO82','CDEMOCOR','CDEMORID','CDEMOUCB','CENTRA',
                 'CIDS','CIS','CISINFO','CLARK','COMPANY','COMPIERE',
                 'CQSCHEMAUSER','CSMIG','CTXDEMO','CTXSYS','DBI','DBSNMP',
                 'DEMO','DEMO8','DEMO9','DES','DEV2000_DEMOS','DISCOVERER_ADMIN',
                 'DIP','DSGATEWAY','DSSYS','EMP','ESTOREUSER','EVENT',
                 'FINANCE','FND','FROSTY','GL','GPFD','GPLD',
                 'HCPARK','HLW','HR','IMAGEUSER','IMEDIA','JMUSER',
                 'JONES','JWARD','L2LDEMO','LBACSYS','LIBRARIAN',
                 'MASTER','MDDEMO','MDDEMO_CLERK','MDDEMO_MGR','MDSYS',
                 'MFG','MGWUSER','MIGRATE','MILLER','MMO2','MODTEST',
                 'MOREAU','MTS_USER','MTSSYS','MXAGENT','NAMES','OAS_PUBLIC',
                 'OCITEST','ODS','ODSCOMMON','ODM','ODM_MTR','OE',
                 'OE','OEMADM','OEMREP','OLAPDBA','OLAPSVR','OLAPSYS',
                 'OMWB_EMULATION','OO','OPENSPIRIT','ORACACHE','ORAREGSYS',
                 'ORDPLUGINS','ORDSYS','ORACLE','ORASSO','OSE\$HTTP\$ADMIN',
                 'OSP22','OUTLN','OWA','OWA_PUBLIC','OWNER',
                 'PANAMA','PATROL','PERFSTAT','PLEX','PLSQL',
                 'PM','PO','PO7','PO8','PORTAL30','PORTAL30',
                 'PORTAL30_DEMO','PORTAL30_PUBLIC','PORTAL30_SSO',
                 'PORTAL30_SSO_PS','PORTAL30_SSO_PUBLIC','POWERCARTUSER','PRIMARY',
                 'PUBSUB','PUBSUB1','QDBA','QS','QS',
                 'QS_ADM','QS_ADM','QS_CB','QS_CB',
                 'QS_CBADM','QS_CBADM','QS_CS','QS_ES',
                 'QS_OS','QS_WS','RE','REP_MANAGER',
                 'REP_OWNER','REP_OWNER','REPADMIN','REPORTS_USER',
                 'RMAIL','RMAN','SAMPLE','SAP','SCOTT',
                 'SDOS_ICSAP','SECDEMO','SERVICECONSUMER1','SH',
                 'SITEMINDER','SLIDE','STARTER','STRAT_USER','SWPRO',
                 'SWUSER','SYMPA','SYS','SYSADM','SYSMAN',
                 'SYSTEM','TAHITI','TDOS_ICSAP','TESTPILOT',
                 'TRACESVR','TRAVEL','TSDEV','TSUSER',
                 'TURBINE','ULTIMATE','USER','USER0','USER1',
                 'USER2','USER3','USER4','USER5','USER6',
                 'USER7','USER8','USER9','UTLBSTATU','VIDEOUSER',
                 'VIF_DEVELOPER','VIRUSER','VRR1','VRR1','WEBCAL01',
                 'WEBDB','WEBREAD','WKPROXY','WMSYS',
                 'WWW','WWWUSER','XDB','XPRT');");
                 
      if ( $#def_user_locked < 0 ){
        print_msg " => There are NO DEFAULT USERS that are NOT OPEN";
      }
      else{
        foreach(@def_user_locked){
           $user_role=$_;
           chomp($user_role);
           print_msg "############################ $user_role ############################\n";
           @roles_arr = sql_exec_np ("select GRANTED_ROLE from dba_role_privs where grantee='$user_role';");
           if ($#roles_arr < 0){
             print_msg " => User $user_role has no ROLES GRANTED.";
           }
           else {
             print_msg " => User $user_role has the following ROLES GRANTED.";
             print_arr (\@roles_arr);
             print " => Do you want to REVOKE them ? [Y/n]:";
             $res=<STDIN>;
             chomp($res);
             if ( $res eq "Y"){
                foreach(@roles_arr){
                  $role_rev = $_;
                  chomp($role_rev);
                  sql_exec_np "revoke $role_rev from $user_role;";
                  print_msg " => Role $role_rev was REVOKED from user $user_role";
                }
             }
             else{
               print_msg " => No Roles were REVOKED for this user\n\n";
             }
           } 
        }
      }
    
    
    ########################
    
     
     separate (" AUDIT ");
     
  print " Do you want to fix THE AUDIT SETTINGS [Y/n]:";
  $res=<STDIN>;
  chomp($res);
  if ( $res eq Y ){
   
    sql_exec "select USER,AUDIT_OPTION, SUCCESS, FAILURE from dba_stmt_audit_opts;";
     
    sql_exec_np "audit profile;";   
    print_msg " => Deviation  ' Audit option  PROFILE, is not correct' was fixed.";
    
    sql_exec_np "audit role;";
    print_msg " => Deviation  'Audit option No ROLE audit option for all users' was fixed.";
   
    sql_exec_np "audit user;";
    print_msg " => Deviation  'Audit option USER  is not correct' was fixed.";
    
    sql_exec_np "audit system grant by access;";
    print_msg " => Deviation  'Audit option SYSTEM GRANT must be BY ACCESS for all users' was fixed.";
    
    sql_exec_np  "audit database link by access;"; 
    print_msg " => Deviation  'Audit option Database Link must be BY ACCESS for all users' was fixed.";
    
    sql_exec_np  "audit create session by access;";
    print_msg " => Deviation  'Audit option Create Session must be BY ACCESS for all users' was fixed.";
    
    sql_exec_np  "audit ALTER SYSTEM by access;";
    print_msg " => Deviation  'Audit option ALTER SYSTEM must be BY ACCESS for all users' was fixed.";
    
    sql_exec_np  "audit ALTER USER  by access;";
    print_msg " => Deviation  'Audit option ALTER USER  must be BY ACCESS for all users' was fixed.";
    
    sql_exec_np  "audit PUBLIC SYNONYM  by access;";
    print_msg " => Deviation  'Audit option PUBLIC SYNONYM  must be BY ACCESS for all users' was fixed.";
    
    sql_exec_np  "audit PUBLIC DATABASE LINK  by access;";
    print_msg " => Deviation  'Audit option PUBLIC DATABASE LINK  must be BY ACCESS for all users' was fixed.";
    
    sql_exec_np  "audit ALTER DATABASE  by access;";
    print_msg " => Deviation  'Audit option ALTER DATABASE  must be BY ACCESS for all users' was fixed.";
    
    sql_exec_np  "audit SYSTEM AUDIT by access;";
    print_msg " => Deviation  'Audit option SYSTEM AUDIT must be BY ACCESS for all users' was fixed.";
    
    print_msg " =>  SYSTEM AUDIT access configuration was completed.";
    
    sql_exec "select USER,AUDIT_OPTION, SUCCESS, FAILURE from dba_stmt_audit_opts;";
    
   
    
       
    separate (" SPFILE/PFILE  ");
    
     @file_type = sql_exec_np  "SELECT DECODE(value, NULL, 'PFILE', 'SPFILE') \"Init File Type\" FROM sys.v_\\\$parameter WHERE name = 'spfile';";
     chomp($file_type[0]); 
      
     if ( $file_type[0] eq 'SPFILE' ){
     
          print_msg "\n => SPFILE is in use!\n";
          
          sql_exec "show parameter audit_trail;";  
          sql_exec_np "alter system set AUDIT_TRAIL=DB scope=spfile;";
          print_msg "FIXED => AUDIT_TRAIL parameter is TRUE. It must be set to OS or DB to enable system wide auditing.";
          sql_exec "show parameter audit_trail;";
          
          print_msg " ------ \n";
          
          sql_exec "show parameter audit_sys_operations;";
          sql_exec_np "alter system set audit_sys_operations=true scope=spfile;";
          print_msg "FIXED - SPFILE - audit_sys_operations is set to FALSE. It must be set to TRUE";
          sql_exec "show parameter audit_sys_operations;";
          
          print_msg " ------ \n";
          
          sql_exec "show parameter O7_DICTIONARY_ACCESSIBILITY;";
          sql_exec_np "ALTER SYSTEM SET O7_DICTIONARY_ACCESSIBILITY = false SCOPE=spfile;";
          print_msg "FIXED - Parameter 07_DICTIONARY_ACCESSIBILITY is set to TRUE. It must be set to FALSE."; 
          sql_exec "show parameter O7_DICTIONARY_ACCESSIBILITY;";      
     } 
     else{
       
       print_msg "PFILE in use - TODO - Proceed manualy.";
       print_msg "No changes made in PFILE";
       
       #if [[ `grep -c "^audit_sys_operations=TRUE$" $ORACLE_HOME/dbs/init${ORACLE_SID}.ora` -eq 0 ]]; 
       #then
       #  echo 'audit_sys_operations=TRUE' >> $ORACLE_HOME/dbs/init${ORACLE_SID}.ora
       #  log_msg "Fix - PFILE - audit_sys_operations is set to FALSE. It must be set to TRUE."
       #fi
       #perl -i.bak -pe 's/^audit_sys_operations\s*=\s*(FALSE)\s*$/audit_sys_operations=TRUE\n/' $config_file;
       #perl -i.bak -pe 's/^07_DICTIONARY_ACCESSIBILITY\s*=\s*(TRUE)\s*$/07_DICTIONARY_ACCESSIBILITY=FALSE\n/' $config_file;
       
       #perl -i.bak -pe 's/^AUDIT_TRAIL\s*=\s*(TRUE)\s*$/AUDIT_TRAIL=DB\n/' $config_file;
       #  to false   
           
     }
  } 
  else{
   print_msg " => No changes made.";
  } 
  
  
     print "\n###########################################\n";
     print " => All changes are logged in  $LOG !!!\n";
     print "###########################################\n";
