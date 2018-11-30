# About

Docker image that restores MySQL database from S3.

Here is what we do:
1) download the latest backup file from a given S3 prefix
2) drop the old database
3) create a fresh database
4) run the dump downloaded on step 1 against the fresh database
