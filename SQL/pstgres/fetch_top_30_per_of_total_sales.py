import psycopg2 as connection
import pandas as pd
con = connection.connect(host='localhost',
						user='postgres',
						password='mohamed2018',
						database='testingdb')
'''
The CUME_DIST() function gets the cumulated distribution based on
row number. But whta if we want to get the top 30% for instance
based on 30% of total spendings not just the top 30% of rows.
'''
cume_dist_query = '''
	SELECT *,
	CUME_DIST() OVER(ORDER BY total DESC)
	FROM total_spendings;
'''
cume_dist_df = pd.read_sql(cume_dist_query,con)
# The cume_dist() treats all rows as equal weights
# print(cume_dist_df)
# Now lets use some programming in here.
no_cume_dist_query = '''
	SELECT * FROM total_spendings
	ORDER BY total DESC;
'''
no_cume_dist_df = pd.read_sql(no_cume_dist_query, con)
# print(no_cume_dist_df)
''' TO distribute based on total we need to:
		1- get the total spendings. Easily done with sql
		2- divide each total by the sum(total). easily done with sql
		3- get the cumulative sum of the proportions. hard with sql
'''
total_spendings_sum = no_cume_dist_df.total.sum()
print(total_spendings_sum)
''' We have two options : 1 - work with cumulative totals then calculate percentages.
	2- work directly with percentages the cum_sum them.
	I will take the first approach.
'''
data_totals = list(no_cume_dist_df.total)
# Cum_Sum
def cum_sum(list_):
	cum_result = [list_[0]]
	appendable = 0.0
	for i in range(len(list_)):
		if i > 0:
			appendable = cum_result[i-1]+list_[i]
			cum_result.append(appendable)
	return cum_result
cume_totals = cum_sum(data_totals)

# Now since we get the cume_totals let's divide by the sum_total
cume_dist_totals = [round((x/total_spendings_sum)*100,2) for x in cume_totals]

# Since we have the cume_dist_totals let's add it to data frame
no_cume_dist_df['cume_dist_total'] = pd.Series(cume_dist_totals)

#  Now fetch all customers who represent 30% of total sales
top_30 = no_cume_dist_df.query('cume_dist_total <= 30')
print(top_30)

import matplotlib.pyplot as plt
top_30_count = top_30.groupby('city').count()
top_30_count['customerid'].plot(kind='bar')
plt.show()

con.close()