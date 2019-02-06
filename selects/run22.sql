-- using 1526481501 as a seed to the RNG


select
	cntrycode,
	count(*) as numcust,
	sum(c_acctbal) as totacctbal
from
	(
		select
			substr(c_phone,1,2) as cntrycode,
			c_acctbal
		from
			customer
		where
			substr(c_phone,1,2) in
				('41', '22', '24', '30', '34', '27', '38')
			and c_acctbal > (
				select
					avg(c_acctbal)
				from
					customer
				where
					c_acctbal > 0.00
					and substr(c_phone,1,2) in
						('41', '22', '24', '30', '34', '27', '38')
			)
			and not exists (
				select
					*
				from
					orders
				where
					o_custkey = c_custkey
			)
	)  custsale
group by
	cntrycode
order by
	cntrycode
;