-- 1  Поднимите нижнюю границу минимальной заработной платы в таблице JOB до 1000$.
UPDATE JOB SET MINSALARY = 1000 WHERE MINSALARY = (SELECT MIN(MINSALARY) FROM JOB)

-- 2  Поднимите минимальную зарплату в таблице JOB на 10% для всех специальностей, кроме финансового
--    директора.
UPDATE JOB SET MINSALARY = 1.1*MINSALARY WHERE JOBNAME != 'FINANCIAL DIRECTOR';

-- 3  Поднимите минимальную зарплату в таблице JOB на 10% для клерков и на 20% для финансового
--    директора (одним оператором).
UPDATE JOB SET MINSALARY = MINSALARY * (CASE WHEN JOBNAME = 'CLERK' THEN 1.1 ELSE 1.2 END)
    WHERE JOBNAME IN ('FINANCIAL DIRECTOR', 'CLERK')

-- 4  Установите минимальную зарплату финансового директора равной 90% от зарплаты исполнительного
--    директора.
UPDATE JOB SET MINSALARY = 0.9 * (SELECT MINSALARY FROM JOB WHERE JOBNAME = 'EXECUTIVE DIRECTOR')
    WHERE JOBNAME = 'FINANCIAL DIRECTOR'

-- 5  Приведите в таблице EMP имена служащих, начинающиеся на букву ‘J’, к нижнему регистру.
UPDATE EMP SET EMPNAME = LCASE(EMPNAME) WHERE EMPNAME LIKE 'J%'

-- 6  Измените в таблице EMP имена служащих, состоящие из двух слов, так, чтобы оба слова в имени
--    начинались с заглавной буквы, а продолжались прописными.
UPDATE EMP SET EMPNAME = INITCAP(EMPNAME) WHERE INSTR(EMPNAME, ' ') != 0

-- 7  Приведите в таблице EMP имена служащих к верхнему регистру.
UPDATE EMP SET EMPNAME = UCASE(EMPNAME)
-- 8  Исправьте даты рождения в таблице EMP, в которых год приходится на первый век нашей эры по
--    следующему правилу: даты до 03 года включительно относятся к 21-му веку, а с 04 по 99 год -
--    к 20-му веку.


-- 9  Перенесите отдел исследований (RESEARCH) в тот же город, в котором расположен отдел
--    продаж (SALES).
UPDATE DEPT SET DEPTADDR = (SELECT DEPTADDR FROM DEPT WHERE DEPTNAME = 'SALES')
    WHERE DEPTNAME = 'RESEARCH'

-- 10 Добавьте нового сотрудника в таблицу EMP. Его имя и фамилия должны совпадать с Вашими,
--    записанными латинскими буквами согласно паспорту, дата рождения также совпадает с Вашей.
INSERT INTO emp VALUES((SELECT MAX(EMPNO) FROM EMP) + 1, 'ILYA ARKHANHELSKY', to_date('06.07.1992', 'dd.mm.yyyy'));

-- 11 Определите нового сотрудника (см. предыдущее задание) на работу в бухгалтерию
--    (отдел ACCOUNTING) начиная с текущей даты.
INSERT INTO CAREER VALUES
     (1004, (SELECT EMPNO FROM EMP WHERE EMPNAME = 'ILYA ARKHANHELSKY'), 10, sysdate , NULL);

-- 12 Удалите все записи из таблицы TMP_EMP. Добавьте в нее информацию о сотрудниках, которые
--    работают клерками в настоящий момент.
DELETE FROM TMP_EMP;
INSERT INTO TMP_EMP VALUES
    SELECT E,EMPNO, E,EMPNAME, E,BIRTHDATE FROM EMP E
        JOIN CAREER C ON E.EMPNO = C.EMPNO
        JOIN JOBNO J ON C.JOBNO = J.JOBNO
           WHERE J.JOBNAME = 'CLERCK' AND C.ENDDATE IS NULL;

-- 13 Добавьте в таблицу TMP_EMP информацию о тех сотрудниках, которые уже не работают на
--    предприятии, а в период работы занимали только одну должность.
SELECT * FROM EMP
    WHERE EMPNO IN
        (SELECT EMPNO FROM CAREER WHERE EMPNO IN (SELECT EMPNO FROM (SELECT DISTINCT JOBNO, EMPNO FROM CAREER) T
            GROUP BY EMPNO
            HAVING COUNT(EMPNO) = 1)
            AND ENDDATE IS NOT NULL AND ENDDATE < CURRENT_DATE)

-- 14 Выполните тот же запрос для тех сотрудников, которые никогда не приступали к работе на
--    предприятии.
INSERT INTO TMP_EMP VALUES
    SELECT EMPNO, EMPNAME, BIRTHDATE FROM EMP E JOIN CAREER C ON E.EMPNO = C.EMPNO
        WHERE C.STARTDATE IS NULL;

-- 15 Удалите все записи из таблицы TMP_JOB и добавьте в нее информацию по тем специальностям,
--    которые не используются в настоящий момент на предприятии.
DELETE FROM TMP_JOB

INSERT INTO TMP_JOB VALUES
    (SELECT * FROM JOB WHERE JOBNO NOT IN (SELECT JOBNO FROM EMP))


-- 16 Начислите зарплату в размере 120% минимального должностного оклада всем сотрудникам,
--    работающим на предприятии. Зарплату начислять по должности, занимаемой сотрудником в настоящий
--    момент и отнести ее на прошлый месяц относительно текущей даты.
INSERT INTO SALARY VALUES
    SELECT EMPNO, EXTRACT(MONTH FROM ADD_MONTHS(sysdate, -1)),
        EXTRACT(YEAR FROM ADD_MONTHS(sysdate, -1)), 1.2 * MINSALARY FROM CAREER
        NATURAL JOIN EMP
        NATURAL JOIN JOB
            WHERE ENDDATE IS NULL;

-- 17 Удалите данные о зарплате за прошлый год.
DELETE FROM SALARY WHERE YEAR = 2012

-- 18 Удалите информацию о карьере сотрудников, которые в настоящий момент уже не работают на
--    предприятии, но когда-то работали.
DELETE FROM CAREER WHERE ENDDATE <= sysdate AND ENDDATE IS NOT NULL;

-- 19 Удалите информацию о начисленной зарплате сотрудников, которые в настоящий момент уже не
--    работают на предприятии (можно использовать результаты работы предыдущего запроса)
DELETE FROM SALARY WHERE EMPNO IN (SELECT EMPNO FROM TMP_EMP)

-- 20 Удалите записи из таблицы EMP для тех сотрудников, которые никогда не приступали к работе на
--    предприятии.
DELETE FROM EMP E1 WHERE E1.EMPNO = (SELECT EMPNO FROM CAREER WHERE CAREER.STARTDATE IS NULL);


