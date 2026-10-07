"""Standard-library smoke tests. SQLite compatibility shims, NOT a MySQL integration test."""
from pathlib import Path
import sqlite3, datetime, calendar, json, csv
ROOT = Path(__file__).resolve().parents[1]
customers = [(1,'Ada Demo','Ada','Demo','2025-10-07'), (2,'','Bola','Demo','2025-10-07'),
             (3,'Chidi Demo','Chidi','Demo','2025-10-07'), (4,'Dara Demo','Dara','Demo','2025-10-07'),
             (5,'Efe Demo','Efe','Demo','2026-10-01'), (6,'Fola Demo','Fola','Demo','2025-10-07')]
plans = [(11,1,1,0),(12,1,0,1),(21,2,1,0),(22,2,0,1),(31,3,1,0),(41,4,1,0),(51,5,1,0),(61,6,1,0)]
transactions = []
def add(owner,plan,date,amount): transactions.append((len(transactions)+1,owner,plan,date,amount))
add(1,11,'2026-04-01',100000); add(1,12,'2026-06-01',200000)
for n in range(19): add(2,21,'2026-04-01' if n<10 else '2026-05-01',10000)
add(2,22,'2026-05-01',0)  # existing investment does not mean funded
for n in range(10): add(3,31,'2026-04-02',10000)
add(4,41,'2025-10-07',50000) # exactly 365 days: excluded
add(6,61,'2025-10-06',75000) # 366 days: included
add(5,51,'2026-10-02',0) # new never-funded plan: not stale
add(1,11,'2026-06-01',-10000) # non-inflow excluded
schema = '''CREATE TABLE users_customuser (id INTEGER PRIMARY KEY, name VARCHAR(100), first_name VARCHAR(100), last_name VARCHAR(100), date_joined DATE);
CREATE TABLE plans_plan (id INTEGER PRIMARY KEY, owner_id INTEGER, is_regular_savings INTEGER, is_a_fund INTEGER);
CREATE TABLE savings_savingsaccount (id INTEGER PRIMARY KEY, owner_id INTEGER, plan_id INTEGER, transaction_date DATE, confirmed_amount BIGINT);
'''
def quote(x): return str(x) if isinstance(x,int) else "'"+x.replace("'","''")+"'"
setup = '-- SYNTHETIC DATA ONLY. Run in a NEW empty demo database. No production data.\n'+schema
for table,rows in [('users_customuser',customers),('plans_plan',plans),('savings_savingsaccount',transactions)]:
    setup += 'INSERT INTO '+table+' VALUES\n'+',\n'.join('('+','.join(map(quote,row))+')' for row in rows)+';\n'
    cols = {'users_customuser':['id','name','first_name','last_name','date_joined'], 'plans_plan':['id','owner_id','is_regular_savings','is_a_fund'], 'savings_savingsaccount':['id','owner_id','plan_id','transaction_date','confirmed_amount']}[table]
    with (ROOT/'demo'/f'{table}.csv').open('w',newline='') as f:
        writer=csv.writer(f); writer.writerow(cols); writer.writerows(rows)
(ROOT/'demo'/'setup_mysql.sql').write_text(setup)
db=sqlite3.connect(':memory:'); db.executescript(setup)
def date(x): return datetime.date.fromisoformat(x)
def diff(unit,a,b):
    a,b=date(a),date(b)
    return (b.year-a.year)*12+b.month-a.month-(b.day<a.day)
def next_month(x):
    d=date(x); y=d.year+d.month//12; m=d.month%12+1
    return datetime.date(y,m,min(d.day,calendar.monthrange(y,m)[1])).isoformat()
db.create_function('CONCAT_WS',-1,lambda sep,*args:sep.join(str(x) for x in args if x is not None))
db.create_function('YEAR',1,lambda x:date(x).year)
db.create_function('MONTH',1,lambda x:date(x).month)
db.create_function('DATEDIFF',2,lambda a,b:(date(a)-date(b)).days)
db.create_function('TIMESTAMPDIFF',3,diff)
db.create_function('NEXT_MONTH',1,next_month)
def run(filename):
    sql=(ROOT/filename).read_text()
    for s in ['2026-10-07','2026-04-01','2026-09-01']: sql=sql.replace(f"CAST('{s}' AS DATE)",f"'{s}'")
    sql=sql.replace('TIMESTAMPDIFF(MONTH,',"TIMESTAMPDIFF('MONTH',")
    sql=sql.replace('DATE_ADD(month_start, INTERVAL 1 MONTH)','NEXT_MONTH(month_start)')
    sql=sql.replace('DATE_ADD(m.month_start, INTERVAL 1 MONTH)','NEXT_MONTH(m.month_start)')
    cur=db.execute(sql); cols=[x[0] for x in cur.description]; rows=cur.fetchall()
    with (ROOT/'demo'/filename.replace('.sql','_output.csv')).open('w',newline='') as f:
        w=csv.writer(f);w.writerow(cols);w.writerows(rows)
    return rows
q1=run('Assessment_Q1.sql'); assert len(q1)==1 and q1[0][0]==1 and q1[0][-1]==3000
q2=run('Assessment_Q2.sql'); assert q2==[('High Frequency',1,10.0),('Medium Frequency',1,9.5),('Low Frequency',3,0.89)],q2
q3=run('Assessment_Q3.sql'); assert len(q3)==1 and q3[0][0]==61 and q3[0][-1]==366,q3
q4=run('Assessment_Q4.sql'); values={row[0]:row[-1] for row in q4}; assert values[1]==3.0 and values[5] is None,values
q5=run('Monthly_Deposit_Trends.sql'); assert [row[1] for row in q5]==[3000,900,2000,0,0,0],q5
assert q5[2][-1]==122.22 and q5[3][-1]==-100 and q5[4][-1] is None,q5
report={'status':'PASS','engine':'SQLite with explicit MySQL compatibility shims; MySQL execution not verified', 'checks':['funded product qualification','duplicate join prevention','9.5 frequency boundary','365/366 day inactivity boundary','new never-funded exclusion','kobo-to-naira profit conversion','zero tenure returns NULL','missing calendar months','zero denominator MoM handling'], 'positive_inflows_ngn':7150,'april_to_september_inflows_ngn':5900,'synthetic':True}
(ROOT/'demo'/'validation_report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
