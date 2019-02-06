load data 
infile 'orders.tbl'
append
into table ORDERS
fields terminated by '|' optionally enclosed by '"' TRAILING NULLCOLS
(
	O_ORDERKEY,
		O_CUSTKEY, 
		O_ORDERSTATUS,
		O_TOTALPRICE,
		O_ORDERDATE TIMESTAMP 'YYYY-MM-DD',  
		O_ORDERPRIORITY,
		O_CLERK,
		O_SHIPPRIORITY,
		O_COMMENT
 )
