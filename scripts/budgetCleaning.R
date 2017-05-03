#combing the old Los Angeles City budget with the new ones

library(dplyr) #moving and shaping the data
library(tidyr) #allows for melt and cast
library(magrittr) #pipeforwarding package %>% 
library(readxl) #reading the excel file
library(stringr) #working with strings eaiser

#reading in data from downloaded files
budget_existing <- read.csv("data/General_Fund_Revenue.csv", stringsAsFactors = FALSE)
budget_new <- read_excel("data/General_Fund_Revenue_1718Proposed (1).xlsx", 1) %>% data.frame()
budget_new <- budget_new %>% select(Dept.Code, Dept.Name, Prog.Code, Prog.Name, Fund.Code, Fund.Name, Account.Code, Account.Name, X2016.17.Estimates, X2017.18.Proposed)

#creating a unique key to for each budget line item to make it easier to melt
budget_existing$new_key <- paste0(budget_existing$Dept.Code, budget_existing$Program.Code, budget_existing$Fund.Code, budget_existing$Account.Code)
budget_new$new_key <- paste0(budget_new$Dept.Code, budget_new$Prog.Code, budget_new$Fund.Code, budget_new$Account.Code)

#melting the data to long form
budget_exi_melt <- gather(budget_existing, new_key, budgets, 9:13)
budget_new_melt <- gather(budget_new, key = new_key, value = budget, 9:10)

#setting the coloum names to be the same to allowing for the datasets to be combined
new_col_names <- c("dept_code", "dept_name", "prog_code", "prog_name", "fund_code", "fund_name", "account_code", "account_name", "new_key", "budget_year", "budget_value")
colnames(budget_exi_melt) <- new_col_names
colnames(budget_new_melt) <- new_col_names

#creating unique key for each line item in the budget
lookup_key <- rbind(budget_exi_melt, budget_new_melt) %>% 
  select(dept_code, dept_name, prog_code, prog_name, fund_code, fund_name, account_code, account_name, new_key) 
lookup_key$account_name <- lookup_key$account_name %>% toupper() %>% trimws() 
lookup_key <- lookup_key %>% distinct(new_key, .keep_all = TRUE)

#combing both datset together and casting the data to wide format
combined_budget <- rbind(budget_exi_melt, budget_new_melt) %>% select(new_key, budget_year, budget_value)
conbined_budget_spread <- spread(combined_budget, budget_year, budget_value)

#joining the the unique line item keys with values
combined_budget_join <- left_join(conbined_budget_spread, lookup_key, by = c("new_key", "new_key"))
combined_budget_join$account_name <- str_to_title(combined_budget_join$account_name)

#makiing the colnames easier to read and normalized
colnames(combined_budget_join) <- colnames(combined_budget_join) %>% tolower() %>% gsub("x", "", .) %>% gsub("\\.", "_", .)

#rearranging dataframe to match online data
combined_budget_join<-  combined_budget_join %>% select(dept_code, dept_name, prog_code,
                                                        prog_name, fund_code, fund_name, 
                                                        account_code, account_name, new_key, 
                                                        everything())

#writing combined budget data into CSV
write.csv(combined_budget_join, "data/final_budget_la_2014_2018.csv", row.names = FALSE)

