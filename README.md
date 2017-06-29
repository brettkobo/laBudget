Every year on April 20th, the mayor releases a proposed budget. After typically a few modifications, the budget is then adopted by City Council in June. While this has been the process in Los Angeles for some time, we only recently started putting the proposed and adopted budgets and related datasets onto the Open Data Portal each year as part of Mayor Garcetti’s open data initiative. 

Again, the data needs to be updated twice a year - when the proposed budget is released and when the adopted budget is released - so it was fine in the past to do this pretty manually using the excel exports we get from the City Administrative Office. But for the sustainability of the open data program, and to get the data to Angelenos quickly, it was time to get more programmatic about it. 

For this project, we started by picking one dataset - General Fund Revenue. Our task was to write a script that merged the new export of data into the current dataset (easier said than done without a unique identifier), and that we could rerun with minimal changes for future budget releases. 

We collaborated using R to complete the project and learned from each other along the way to make a programmatic update method for more datasets like Budget Expenses, Incremental Changes, and Performance Measures as well. 
