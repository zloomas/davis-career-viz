## Mark Davis Career Vizualization Project

#load pandas package
import pandas as pd

#read in raw data
wos_export = pd.read_csv("./data/savedrecs.txt", sep='\t', header=0, index_col=False, dtype={'PY':str}, usecols=['DT', 'AU', 'TI', 'SO', 'PY', 'CR', 'NR'])

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

#author_nodes.to_csv("./data/author_network_nodes.tsv", sep='\t', index=False)

#make edges df for author-wise network

nodes_dict = author_nodes.set_index('au_name').to_dict()['au_id']

author_edges = pd.DataFrame()

for entry in wos_export.index:

    au_list = wos_export.loc[entry, 'AU'].split("; ")
    new_entry ={'title': wos_export.loc[entry, 'TI'],
                'pub_year': wos_export.loc[entry, 'PY'],
                'journ': wos_export.loc[entry, 'SO'],
                'doc_type': wos_export.loc[entry, 'DT']}

    if len(au_list) > 1:
        ix = 0
        while ix < len(au_list):
            new_entry['from'] = nodes_dict[au_list[ix].upper()]
            for au in range(len(au_list)):
                if au > ix:
                    new_entry['to'] = nodes_dict[au_list[au].upper()]
                    author_edges = author_edges.append(new_entry, ignore_index=True)
            ix += 1

author_edges = author_edges[['from','to','title','journ','pub_year','doc_type']]
author_edges.to_csv("./data/author_network_edges.tsv", sep='\t', index=False)


