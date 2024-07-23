
# Statistical Methods Library - AWS Glue test harness

This repository facilitates local testing of the ONS statistical methods library across different glue versions and the pure apache spark equivalents.

## Usage

Use the makefile to run the tests using docker containers with builds of glue v2, glue v34 and the pure spark equivalent of glue 4.

Makefile test targets will build relevant docker image and download the SML as required
### Examples

Run tests using Glue v3
`make test-glue3`

Run tests using Glue v4
`make test-glue4`

Run tests using pure spark v4
`make test-glue4-spark-equiv`

By default all tests are run, alternatively you can make the exit after the first test failure by defining a FAILFAST variable when calling make

e.g to run the glue v4 tests, exiting after the first failing test

`FAILFAST=1 make test-glue4`

For other targets, running `make` on it's own willl display help text.


