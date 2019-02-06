load data 
infile 'part.tbl'
append
into table PART
fields terminated by '|' optionally enclosed by '"' TRAILING NULLCOLS
(
		P_PARTKEY,
		P_NAME	,
		P_MFGR	,
		P_BRAND	,
		P_TYPE	,
		P_SIZE	,
		P_CONTAINER	,
		P_RETAILPRICE	,
		P_COMMENT
 )
