load data 
infile 'nation.tbl'
append
into table NATION
fields terminated by '|' optionally enclosed by '"' TRAILING NULLCOLS
(
		N_NATIONKEY,
		N_NAME,
		N_REGIONKEY,  
		N_COMMENT

 )
