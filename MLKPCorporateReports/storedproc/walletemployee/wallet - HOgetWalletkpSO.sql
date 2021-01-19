DELIMITER $$

USE `kpmobile`$$

DROP PROCEDURE IF EXISTS `HOgetWalletKpSO`$$

CREATE DEFINER=`root`@`%` PROCEDURE `HOgetWalletKpSO`(IN accountCode VARCHAR(30),IN _datefrom VARCHAR(15),IN _dateto VARCHAR(15),IN prefix VARCHAR(5))
BEGIN
DECLARE _monthdate VARCHAR(4);
DECLARE _year VARCHAR(4);
DROP  TEMPORARY  TABLE IF EXISTS `kpmobile`.tmpwallettxn;
CREATE  TEMPORARY TABLE `kpmobile`.tmpwallettxn(flag VARCHAR(100),transdate VARCHAR(100),kptn VARCHAR(100),receivername VARCHAR(100),sendername VARCHAR(100),sobranch VARCHAR(100),
pobranch VARCHAR(100),partnername VARCHAR(100),principal VARCHAR(100),charge VARCHAR(100),commission VARCHAR(100),accountid VARCHAR(100),username VARCHAR(100),
fullname VARCHAR(100),operator VARCHAR(100),cancelreason VARCHAR(100),cancelleddate VARCHAR(100),oldkptn VARCHAR(100),cancelledbyoperator VARCHAR(100),
custid VARCHAR(100),controlno VARCHAR(100),branchcode VARCHAR(100),zonecode VARCHAR(100),senderwalletno VARCHAR(100),receiverwalletno VARCHAR(100));
#WHILE DATE(_datefrom) <= DATE(_dateto) DO
SET _monthdate = DATE_FORMAT(_datefrom,'%m%d');
SET _year = DATE_FORMAT(_datefrom,'%Y');
	
SET @n_query= CONCAT(/*'insert into `kpmobile`.tmpwallettxn(flag ,transdate ,kptn ,receivername ,sendername ,sobranch ,
pobranch ,partnername ,principal ,charge ,commission ,accountid ,username ,
fullname ,operator ,cancelreason ,cancelleddate ,oldkptn ,cancelledbyoperator ,
custid ,controlno ,branchcode ,zonecode,senderwalletno,receiverwalletno )'*/
'SELECT 
IF(s.cancelreason IS NOT NULL,IF(s.cancelreason=''Request for Change'',''***'',
IF(s.cancelreason=''CANCEL'' or s.cancelreason=''SO CANCEL'' or s.cancelreason=''CANCEL SENDOUT'',''**'',IF(s.cancelreason=''RETURN TO SENDER'',
IF(DATE(s.transdate)<>DATE(s.cancelleddate),'''',''*''),''''))),
'''') AS flag,transdate ,kptnno as kptn ,receivername ,sendername ,senderbranchid as sobranch ,
'''' AS  pobranch ,'''' AS partnername ,
CONVERT(AES_DECRYPT(principal,''mlinc1234''), DECIMAL(11,2)) as principal ,
CONVERT(AES_DECRYPT(charge,''mlinc1234''), DECIMAL(11,2)) as charge ,
0 AS commission ,custid AS accountid ,'''' AS username ,
'''' AS fullname ,operatorid AS operator ,cancelreason ,cancelleddate ,oldkptnno as oldkptn ,
cancelledbyoperatorid AS cancelledbyoperator ,
custid ,controlno ,branchcode ,zonecode ,
( select walletno from `kpmobile`.`mobileaccounts` k where  k.custid=s.custid limit 1  ) as senderwalletno, 
( select walletno from `kpmobile`.`mobileaccounts` k where  concat(k.firstname,'' '',k.middlename,'' '',k.lastname)=s.receivername limit 1  ) as receiverwalletno
FROM `kpmobiletransactions`.sendout',_monthdate,' s
WHERE controlno  not LIKE ''%op%'' AND kptnno LIKE ''',prefix,''' 
and if(receivername=sendername,0,
if((receivername<>sendername and charge=(select charge from `kpforms`.`wallettowalletFixCharge` limit 1) ),0,1)) 
#and (cancelledreason not in ('''',''Request for Change'',''Cancel Sendout'') or cancelledreason is null)
#AND IF((SELECT username from `kpmobile`.mobileaccounts WHERE username=operatorid LIMIT 1) IS NOT NULL,0,1)
AND YEAR(transdate)=',_year,' ORDER BY transdate ASC;
');						
#SET _datefrom = DATE_ADD(_datefrom, INTERVAL 1 DAY);                 
PREPARE StrSQL FROM @n_query;
EXECUTE StrSQL;
#END WHILE;
/*SET @sql3=CONCAT('select flag ,if(transdate is null,''0000-00-00 00:00:00'',transdate) as transdate ,kptn ,receivername ,sendername ,sobranch ,
pobranch ,partnername ,principal ,if(charge is null,0,charge) as charge ,commission ,accountid ,username ,
fullname ,operator ,cancelreason ,if(cancelleddate is null,''0000-00-00 00:00:00'',cancelleddate) as cancelleddate ,oldkptn ,cancelledbyoperator ,
custid ,controlno ,branchcode ,zonecode ,senderwalletno ,receiverwalletno from `kpmobile`.tmpwallettxn;  ');
PREPARE gtpo3 FROM @sql3;
EXECUTE gtpo3;*/
END$$

DELIMITER ;