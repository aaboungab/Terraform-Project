# Terraform Project 

## Overview

You are the lead DevOps Engineer for Netflix; and currently they are having issues maintaining consistency with all the infrastructure being deployed as they are being managed by different junior DevOps Engineers.

The lead architect has decided that it is time to use Terraform to maintain consistency in infrastructure.

However, the CTO is unsure whether he wants this application to be deployed in-case this has any negative impact on the current live infrastructure.

You are tasked to create a mock version of what's already been deployed.

This application is to make sure the CTO is given confidence that the terraform application works and can be deployed safely across all environments.

The use of all best practice should be implemented, this includes ensuring no security is breached and the code is reusable.

 
## Project Scope

The terraform application should deploy to multiple Scale Sets that are located within the following regions: Paris, London; Mumbai. Each of the regions should be either: Development, Staging and Production, any region is fine to be any of the environment. The Scale Set in Paris should scale out between 10am - 3pm, for London, 9am - 5pm and in Mumbai, 2:30am - 10:30 pm.

The maximum size should be 3 and during out of hours there should be no VM instances in the region, as this would incur cost. The lead architect has designed the overview for you to develop.

## Architect

<img src="/061cb21e939291b48a5a51f2c47e4eba.png" alt="" width="100%" height="100%"/>
