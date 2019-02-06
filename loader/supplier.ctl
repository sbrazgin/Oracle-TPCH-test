load data 
infile 'supplier.tbl'
append
into table SUPPLIER
fields terminated by '|' optionally enclosed by '"' TRAILING NULLCOLS
(
		S_SUPPKEY,
		S_NAME	,
		S_ADDRESS	,
		S_NATIONKEY	, 
		S_PHONE	,
		S_ACCTBAL,
		S_COMMENT
 )
