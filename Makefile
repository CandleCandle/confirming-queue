#
# Examples:
#   make test tests='"something"'
#     build and run the pony tests, filtering for only those whos name
#     starts with "something"
#

.PHONY: clean build test all

test:
	stable env ponyc -o bin test && ./bin/test --only=$(tests)

build:
	stable env ponyc -o bin confirming-queue

clean:
	rm -f bin/*

all: clean test build
