### Verify SF Binaries ###
This script attempts to download the signature file `SHA256SUMS.asc` from https://github.com/adeptio-project/adeptio/releases/download/v2.0.0.0/sha256sums.asc

It first checks if the signature passes, and then downloads the files specified in the file, and checks if the hashes of these files match those that are specified in the signature file.

The script returns 0 if everything passes the checks. It returns 1 if either the signature check or the hash check doesn't pass. If an error occurs the return value is 2.
