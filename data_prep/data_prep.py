## Mark Davis Career Vizualization Project

#load pandas package
import pandas as pd

#read in raw data
wos_export = pd.read_csv("./savedrecs.txt", sep='\t', header=0, index_col=False, usecols=['DT', 'AU', 'TI', 'SO', 'PY', 'CR', 'NR'])

#make nodes df for author-wise network
authors = []
for ix in wos_export.index:
    au_list = wos_export.loc[ix, 'AU'].split("; ")
    for au in au_list:
        authors.append(au.upper())

authors = list(set(authors))
authors.sort()

author_nodes = pd.DataFrame(columns=['au_id', 'au_name'])

for au in range(len(authors)):
    au_id = 'au' + str(au+1)
    author_nodes = author_nodes.append({'au_id':au_id, 'au_name':authors[au]}, ignore_index=True)

author_nodes.to_csv("./data_prep/author_network_nodes.tsv", sep='\t', index=False)

