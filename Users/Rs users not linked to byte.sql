SELECT 

bch branch,
uname,
fullname

 FROM useraccount a
 
 WHERE a.status ='ACTIVE'
 
 AND not EXISTS(
 
 SELECT 1 FROM byte_user_mappings b
 
 WHERE b.username = a.uname
 
 )