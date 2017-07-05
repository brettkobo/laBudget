#combing the old Los Angeles City budget with the new ones

library(dplyr) #moving and shaping the data
library(tidyr) #allows for melt and cast
library(magrittr) #pipeforwarding package %>% 
library(readxl) #reading the excel file
library(stringr) #working with strings eaiser
library(RSocrata)

#reading in data from data.lacity.org and downloaded files
#Pull existing data from Socrata
gf_existing <- read.socrata(url = 'https://data.lacity.org/A-Prosperous-City/General-Fund-Revenue/qrkr-kfbh')

#Pull new data from Excel extract
gf_new <- read_excel("FY17-18 Adopted Budget/General Fund Revenue_1718Adopted.xls", 1) %>% data.frame()
gf_new <- gf_new %>% select(Dept.Code, Dept.Name, Prog.Code, Prog.Name, Fund.Code, Fund.Name, Account.Code, Account.Name, X2017.18.Adopted.Budget)

#creating a unique key to for each budget line item to make it easier to melt
gf_existing$new_key <- paste0(gf_existing$Dept.Code, gf_existing$Program.Code, gf_existing$Fund.Code, gf_existing$Account.Code)
gf_new$new_key <- paste0(gf_new$Dept.Code, gf_new$Prog.Code, gf_new$Fund.Code, gf_new$Account.Code)

#melting the data to long form
#gf_exi_melt <- gather(gf_existing, new_key, budgets, 9:10)
gf_exi_melt <- gf_existing[c("Dept.Code", "Department.Name", "Program.Code", "Program.Name", "Fund.Code", "Fund.Name", "Account.Code", "Account.Name","new_key", "Fiscal.Year", "Revenue.Amount")]
gf_new_melt <- gather(gf_new, key = new_key, value = budget, 9)


#setting the coloum names to be the same to allowing for the datasets to be combined
new_col_names <- c("dept_code", "dept_name", "prog_code", "prog_name", "fund_code", "fund_name", "account_code", "account_name", "new_key", "budget_year", "budget_value")
colnames(gf_exi_melt) <- new_col_names
colnames(gf_new_melt) <- new_col_names

#creating unique key for each line item in the budget
lookup_key <- rbind(gf_exi_melt, gf_new_melt) %>% 
  select(dept_code, dept_name, prog_code, prog_name, fund_code, fund_name, account_code, account_name, new_key) 
lookup_key$account_name <- lookup_key$account_name %>% toupper() %>% trimws() 
lookup_key <- lookup_key %>% distinct(new_key, .keep_all = TRUE)

#combing both datset together and casting the data to wide format
combined_gf <- rbind(gf_exi_melt, gf_new_melt) %>% select(new_key, budget_year, budget_value)
combined_gf_spread <- spread(combined_gf, budget_year, budget_value)

#joining the the unique line item keys with values
combined_gf_join <- left_join(combined_gf_spread, lookup_key, by = c("new_key", "new_key"))
combined_gf_join$account_name <- str_to_title(combined_gf_join$account_name)

#makiing the colnames easier to read and normalized
colnames(combined_gf_join) <- colnames(combined_gf_join) %>% tolower() %>% 
  gsub("x", "", .) %>% 
  gsub("\\.", "_", .) %>% 
  gsub(" ", "_", .) %>%
  gsub("\\-", "_", .)
  

#rearranging dataframe to match online data
combined_gf_join <- combined_gf_join %>% select(dept_code, dept_name, prog_code,
                                                prog_name, fund_code, fund_name, 
                                                account_code, account_name, new_key, 
                                                everything())

#creating long format for upload
combined_gf_long <- gather(combined_gf_join, budget_year, revenue_amount, 10:17)

#writing combined budget data into CSV
write.csv(combined_gf_join, "data/final_actuals_budget_la_2014_2018_wide.csv", row.names = FALSE)
write.csv(combined_gf_long, "data/final_actuals_budget_la_2014_2018_long.csv", row.names = FALSE)



