# Oracle-TPCH-test
========================

Этот репозиторий содержит простой вариант теста TPC-H для базы данных Oracle.
Создан на основе официального репозитория http://tpc.org/tpch
Пошаговая инструкция для выполнения теста:

- Cоздайте каталог test
  mkdir test
  
- Скопируйте каталог dbgen с исходными текстами генератора данных 

- Скомпилируйте утилиту dbgen
  
  cd /home/oracle/test/dbgen 
  cp makefile.suite Makefile  
  vi Makefile

  измените: 
  --
	CC=gcc
	DATABASE=ORACLE
	MACHINE=LINUX
	WORKLOAD=TPCH
  --
  
  make  

- Сгенерируйте данные
  Для создания данных необходимо указывать параметр -s , который определяет предполагаемый
  размер тестовой базы, каждая единица примерно равна 1 Гб. 
  Например для генерации 10 Гб данных запустите: 
  
  ./dbgen -s 10

  Утилита создаст набор из 8 tbl-файлов в формате oracle csv
  
  ls *.tbl

- Создайте базу данных
  schema_create.sql
  
- Создайте таблицы
  sqlplus TMP_TPCH/TMP_TPCH @tables-create.sql  

- Заполните таблицы данными из tbl-файлов
  Скопируйте ctl-файлы из каталога loader и запустите загрузку данных:
  
  sqlldr TMP_TPCH/TMP_TPCH control=part.ctl  
  sqlldr TMP_TPCH/TMP_TPCH control=region.ctl
  sqlldr TMP_TPCH/TMP_TPCH control=nation.ctl
  sqlldr TMP_TPCH/TMP_TPCH control=supplier.ctl
  sqlldr TMP_TPCH/TMP_TPCH control=customer.ctl
  sqlldr TMP_TPCH/TMP_TPCH control=partsupp.ctl
  sqlldr TMP_TPCH/TMP_TPCH control=orders.ctl
  
- Обновите таблицы   
  tables-update.sql
  
- Сгенерируйте запросы, скопируйте шаблоны, затем:  
   for q in `seq 1 22`
    do
        ./qgen $q >> run$q.sql
    done

- Исправьте фразу LIMIT	

   for i in run*sql; do sed -i 's/LIMIT 100;/;/g' "$i"; done  

   for i in run*sql; do sed -i 's/LIMIT 10;/;/g' "$i"; done  

   for i in run*sql; do sed -i 's/LIMIT 1;/;/g' "$i"; done  
   
   for i in run*sql; do sed -i 's/LIMIT 20;/;/g' "$i"; done  
   
- Запуск теста:
    ./run_tpch.sh DIRNAME USERNAME IS_FLUSH  
  
    Описание параметров:
    - DIRNAME  Каталог с результатами
    - USERNAME Имя пользователя
    - IS_FLUSH YES или NO Очищать или нет буферный кэш
    Например:
    ./run_tpch.sh RESULT4 TMP_TPCH NO
