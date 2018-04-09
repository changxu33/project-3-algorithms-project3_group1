## Project 3: Algorithm Implementation and Evaluation
### Summary

+ Term: Spring 2018
+ Project title: Implementation and Evaluation of Collaborative Filtering Algorithms
+ Team Number: Group 1
+ Team Members: Mingkai Deng, Mao Guan, Ayano Kase, Juho Ma, Cindy Xu

+ Project summary: In this project, we implemented and evaluated different collaborative filtering algorithms of two types: memory-based and model-based. For memory-based model, we also considered possible variations in implementation, with varying methods of weighting (significance and variance weighting) and correlation/similarity measures (Pearson, Spearman, Vector Similarity, Entropy, Mean Squared Difference, and SimRank).

### Task 1. Model-based vs. Memory-based Algorithms

### Result

### Task 2. Correlation/Similarity Measures

### Result
	Movie                         (MAE)	               MS (Rank Score)
Pearson (Baseline)	             1.09	                26.89
Pearson (Significance weighting)		
Pearson (Variance weighting)	      1	                  26.3
Spearman	                        1.09	               26.89
Vector Similarity		                                   27.03
Entropy	
Mean-Square Difference	          1.1	                 27.14
SimRank	                          1.08	               27.08



### Task 3. Significance and Variance Weighting

### Result

### Contribution Statement

[default](doc/a_note_on_contributions.md) All team members contributed equally in all stages of this project. All team members approve our work presented in this GitHub repository including this contributions statement.

+ Mingkai Deng

+ Mao Guan
  
+ Ayano Kase

+ Juho Ma

+ Cindy Xu

+ All

### References

+ Breese, J. S., Heckerman, D., & Kadie, C. (1998, July). Empirical analysis of predictive algorithms for collaborative filtering. In Proceedings of the Fourteenth conference on Uncertainty in artificial intelligence (pp. 43-52). Morgan Kaufmann Publishers Inc..

+ Herlocker, J. L., Konstan, J. A., Borchers, A., & Riedl, J. (1999, August). An algorithmic framework for performing collaborative filtering. In Proceedings of the 22nd annual international ACM SIGIR conference on Research and development in information retrieval (pp. 230-237). ACM.

+ Su, X., & Khoshgoftaar, T. M. (2009). A survey of collaborative filtering techniques. Advances in artificial intelligence, 2009, 4.

+ Jeh, G., & Widom, J. (2002, July). SimRank: a measure of structural-context similarity. In Proceedings of the eighth ACM SIGKDD international conference on Knowledge discovery and data mining (pp. 538-543). ACM.

Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.
