Stockpile Locator
========
Introduction

If one has distances between several locations and wants to established stockpile centers based on distance. That is, you want to reach all of the locations by minimizing the number of stockpiles, such that all locations can be serviced by a stockpile located with X kms.

For example, if you want to reach each and every places within 5 hours, how many stockpiles need to established and where? Stockpiles must be from those places.

Results

As you may infer there will be two types of stockpiles, firstly those that will be used for the location itself and also for the neighbouring villages and secondly, those that are only going to be serving themselves (either because they are too far or because the villages surrounding this stockpile are already served by other stockpiles).

Below are the results for kilometers, but you can re-run it also for drivetimes, if you want. Note that this is based on a sample input provided with distance between different locations. The output is a set of location names and which stockpile will be servicing this location. 

At 50km distance you need 59 warehouses - 26 will be serving others as well but 33 only themselves
At 100km distance you need 27 warehouses - 13 will be serving others as well but 14 only themselves
At 200km distance you need 8 warehouses - 5 will be serving others as well but 3 only themselves
At 300km distance you need 6 warehouses - 6 will be serving others as well but 0 only themselves
At 400km distance you need 4 warehouses - 3 will be serving others as well but 1 only themselves

Attached to the repository is a sample input of the tool. This was developed using Postgres/POSTGis but can easily be transferrable to SQL Server, Oracle or other database application.
