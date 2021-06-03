---
name: 'New Genome request '
about: Describe this issue template's purpose here.
title: Please include the following genome
labels: ''
assignees: ''

---

Thank you for suggesting a new genome to be included our database. This project is not just to mirror the genomes but to set it up in an a consistent way (with indices etc).  We shall include those but I need some more details. I understand this will be too much work, but try to provide as much information you can if not all (you may ask your colleagues to contribute to this issue as well). 

**If you do not have access to SAGA** then visit here: https://ewels.github.io/AWS-iGenomes/ and see what will be setup (source, build etcc) and if you do not see your genome there please include where to get that information for you genome in this issue. 

 **If you have access** to saga can you please go to the following location (where we have started including references): 
/cluster/shared/databases/references/
Then check if the genome you suggest is present. If yes, please check we have setup what you need.

 If not, please check the example for Human:

```/cluster/shared/databases/references/Homo_sapiens```

For example 
```/cluster/shared/databases/references/Homo_sapiens/Ensembl```
is what we have from Ensemble for human. 

Then check the format and suggest what to include. 
For example "Chicken Gallus gallus" find out how the genome is versioned and where the data can be downloaded and give the info here.
