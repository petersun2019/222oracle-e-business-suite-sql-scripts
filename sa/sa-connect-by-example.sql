/*
File Name: sa-connect-by-example.sql
Version: Oracle Release 12 / R12
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-e-business-suite-sql-scripts
*/

-- ##################################################################
-- CONNECT BY EXAMPLE
-- ##################################################################

create table xx_test_emp (
	empno numeric(4) not null,
	ename varchar(10),
	job varchar(9),
	mgr numeric(4),
	hiredate date,
	sal numeric(7, 2),
	comm numeric(7, 2),
	deptno numeric(2)
);

insert into xx_test_emp values (7369, 'SMITH', 'CLERK', 7902, '17-DEC-1980', 800, null, 20);
insert into xx_test_emp values (7499, 'ALLEN', 'SALESMAN', 7698, '20-FEB-1981', 1600, 300, 30);
insert into xx_test_emp values (7521, 'WARD', 'SALESMAN', 7698, '22-FEB-1981', 1250, 500, 30);
insert into xx_test_emp values (7566, 'JONES', 'MANAGER', 7839, '2-APR-1981', 2975, null, 20);
insert into xx_test_emp values (7654, 'MARTIN', 'SALESMAN', 7698, '28-SEP-1981', 1250, 1400, 30);
insert into xx_test_emp values (7698, 'BLAKE', 'MANAGER', 7839, '1-MAY-1981', 2850, null, 30);
insert into xx_test_emp values (7782, 'CLARK', 'MANAGER', 7839, '9-JUN-1981', 2450, null, 10);
insert into xx_test_emp values (7788, 'SCOTT', 'ANALYST', 7566, '09-DEC-1982', 3000, null, 20);
insert into xx_test_emp values (7839, 'KING', 'PRESIDENT', null, '17-NOV-1981', 5000, null, 10);
insert into xx_test_emp values (7844, 'TURNER', 'SALESMAN', 7698, '8-SEP-1981', 1500, 0, 30);
insert into xx_test_emp values (7876, 'ADAMS', 'CLERK', 7788, '12-JAN-1983', 1100, null, 20);
insert into xx_test_emp values (7900, 'JAMES', 'CLERK', 7698, '3-DEC-1981', 950, null, 30);
insert into xx_test_emp values (7902, 'FORD', 'ANALYST', 7566, '3-DEC-1981', 3000, null, 20);
insert into xx_test_emp values (7934, 'MILLER', 'CLERK', 7782, '23-JAN-1982', 1300, null, 10);

-- SHOW STAFF STRUCTURE
		select lpad(' ', (level - 1) * 10, ' ') || ename
			 , level
			 , ename
			 , job
			 , mgr
		  from xx_test_emp
	connect by prior empno = mgr
	start with empno = 7839; -- president, starting at the top of the chain

-- ANOTHER VERSION
		select e.empno
			 , e.ename
			 , e.job
			 , level
			 , sys_connect_by_path(e.ename, '/') path
		  from (select *
		  from xx_test_emp) e
	connect by empno = prior mgr
	start with empno = 7788; -- starting at the bottom of the chain
