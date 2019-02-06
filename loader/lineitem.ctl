load data 
infile 'lineitem.tbl'
append
into table LINEITEM
fields terminated by '|' optionally enclosed by '"' TRAILING NULLCOLS
(
		L_ORDERKEY, 
		L_PARTKEY, 
		L_SUPPKEY, 
		L_LINENUMBER,
		L_QUANTITY,
		L_EXTENDEDPRICE,
		L_DISCOUNT,
		L_TAX,
		L_RETURNFLAG,
		L_LINESTATUS,
		L_SHIPDATE TIMESTAMP 'YYYY-MM-DD',
		L_COMMITDATE TIMESTAMP 'YYYY-MM-DD',
		L_RECEIPTDATE TIMESTAMP 'YYYY-MM-DD',
		L_SHIPINSTRUCT,
		L_SHIPMODE,
		L_COMMENT

 )
