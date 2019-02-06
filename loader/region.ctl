load data 
infile 'region.tbl'
append
into table REGION
fields terminated by '|' optionally enclosed by '"' TRAILING NULLCOLS
(
 R_REGIONKEY,
 R_NAME,
 R_COMMENT
 )
