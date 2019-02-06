load data 
infile 'customer.tbl'
append
into table CUSTOMER
fields terminated by '|' optionally enclosed by '"' TRAILING NULLCOLS
(
		C_CUSTKEY,
		C_NAME	,
		C_ADDRESS,
		C_NATIONKEY, 
		C_PHONE	,
		C_ACCTBAL,
		C_MKTSEGMENT,
		C_COMMENT
 )
