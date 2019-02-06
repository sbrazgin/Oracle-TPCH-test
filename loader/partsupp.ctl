load data 
infile 'partsupp.tbl'
append
into table PARTSUPP
fields terminated by '|' optionally enclosed by '"' TRAILING NULLCOLS
(
		PS_PARTKEY,
		PS_SUPPKEY, 
		PS_AVAILQTY,
		PS_SUPPLYCOST,
		PS_COMMENT

 )
