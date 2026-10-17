Given a set of high-dimensional data, run\_umap.m produces a lower-dimensional representation of the data for purposes of data visualization and exploration. See the file run\_umap.m for documentation and many examples of how to use this code.

The UMAP algorithm is the invention of Leland McInnes, John Healy, and James Melville. See [their original paper](https://arxiv.org/pdf/1802.03426.pdf) for a long-form description. Also see [the documentation for the original Python implementation](https://umap-learn.readthedocs.io/en/latest/index.html).

Connor Meehan developed code in C++, Python, Java, and MATLAB to build this implementation of UMAP for the MATLAB community, with assistance from Jonathan Ebrahimian, Stephen Meehan, and Wayne Moore. Our visualization features require a MATLAB version no earlier than R2019a and no later than R2024b because R2025 removes the ability of Java to access MATLAB figures/windows. We appreciate all and any help in finding bugs.

Provided by the Herzenberg Lab at Stanford University.

This submission interoperates with FlowJo v10.x, a widely used analysis app for flow cytometry distributed by BD Life Sciences.

Our priority has been determining the suitability of our concepts for research publications in flow cytometry for the use of UMAP supervised templates and exhaustive projection pursuit.