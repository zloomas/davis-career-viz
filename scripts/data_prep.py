## Mark Davis Career Vizualization Project

#load packages
import pandas as pd
import glob

#read in raw data
wos_export = pd.read_csv("./data/savedrecs.txt", sep='\t', header=0, index_col=False, dtype={'PY': str}, usecols=['DT', 'AU', 'TI', 'SO', 'PY', 'CR', 'NR', 'UT'])

#make nodes df for author-wise network
authors = []
for ix in wos_export.index:
    au_list = wos_export.loc[ix, 'AU'].split("; ")
    for au in au_list:
        authors.append(au.upper())

authors = list(set(authors))
authors.sort()

mark_ix = authors.index("DAVIS, MH")

author_nodes = pd.DataFrame(columns=['au_id', 'au_name'])

for au in range(len(authors)):
    if au < mark_ix:
        au_id = 'au' + str(au+1)
    elif au > mark_ix:
        au_id = 'au' + str(au)
    else:
       continue
    author_nodes = author_nodes.append({'au_id': au_id, 'au_name': authors[au]}, ignore_index=True)

#author_nodes.to_csv("./data/coauthors/author_network_nodes.tsv", sep='\t', index=False)

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


author_edges = author_edges[['from', 'to', 'title', 'journ', 'pub_year', 'doc_type']]
#author_edges.to_csv("./data/coauthors/author_network_edges.tsv", sep='\t', index=False)

#ok - now instead, time to try to make an actual (tiny) citation network
#start with list of his own papers to get some ids - use inherent WOS IDs
paper_cols = ['paper_id', 'title', 'journ', 'pub_year', 'au_name']

seed_paper_nodes = pd.DataFrame(columns=paper_cols)

for entry in wos_export.index:
    paper_id = wos_export.loc[entry, 'UT'].split(':')[-1]
    title = wos_export.loc[entry, 'TI'].upper()
    journ = wos_export.loc[entry, 'SO']
    pub_year = wos_export.loc[entry, 'PY']
    au_name = wos_export.loc[entry, 'AU'].upper()

    new_entry = {'paper_id': paper_id,
                 'title': title,
                 'journ': journ,
                 'pub_year': pub_year,
                 'au_name': au_name}

    seed_paper_nodes = seed_paper_nodes.append(new_entry, ignore_index=True)

#seed_paper_nodes.to_csv("./data/papers/seed_paper_network_nodes.tsv", sep='\t', index=False)

#cobble together a superset of all the papers in TC and CR exports
path = './data/papers/citations'
files = glob.glob(path + '/*.txt')

df_list = []
for file in files:
    file_name = file.split('/')[-1]
    paper_id = file_name.split('_')[0]
    df = pd.read_csv(file, sep='\t', header=0, index_col=False, usecols=['AU', 'TI', 'SO', 'PY', 'UT'], dtype={'PY': str})

    if 'tc' in file_name:
        df['to'] = paper_id
        df['from'] = df['UT']
        df = df.rename(columns={'UT': 'paper_id'})
    else:
        df['from'] = paper_id
        df['to'] = df['UT']
        df = df.rename(columns={'UT': 'paper_id'})

    df = df.rename(columns={'AU': 'au_name', 'TI': 'title', 'SO': 'journ', 'PY': 'pub_year'})

    df_list.append(df)

full_citations = pd.concat(df_list, axis=0, ignore_index=True, sort=False)

for entry in full_citations.index:
    full_citations.loc[entry, 'to'] = full_citations.loc[entry, 'to'].split(':')[-1]
    full_citations.loc[entry, 'from'] = full_citations.loc[entry, 'from'].split(':')[-1]
    full_citations.loc[entry, 'paper_id'] = full_citations.loc[entry, 'paper_id'].split(':')[-1]
    full_citations.loc[entry, 'title'] = full_citations.loc[entry, 'title'].upper()
    au_name = full_citations.loc[entry, 'au_name']
    if pd.notna(au_name):
        full_citations.loc[entry, 'au_name'] = au_name.upper()

paper_nodes = seed_paper_nodes.append(full_citations[paper_cols])
paper_nodes = paper_nodes.drop_duplicates(subset='paper_id', ignore_index=True)

#paper_nodes.to_csv('./data/papers/paper_network_nodes.tsv', sep='\t', index=False)

paper_edges = full_citations[['from', 'to']]
#paper_edges.to_csv('./data/papers/paper_network_edges.tsv', sep='\t', index=False)
