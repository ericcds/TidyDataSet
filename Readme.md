---
title: "Readme"
author: "Eric C"
date: "October 26, 2014"
output: html_document
---

run_analysis.R
(requires reshape2)

Loads acceleration data, subject data, and activity data and clips them together to create a tidy data set.

Outputs to /AccelerationData/TidyDataSet1.rds (all measurements for each subject and activity) and /AccelerationData/TidyDataSet2.rds (mean of all measurements by subject and activity)