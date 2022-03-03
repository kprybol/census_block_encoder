.PHONY: build test shell clean

build:
	docker build -t census_block_encoder .

test:
	docker run --rm -v "${PWD}/test":/tmp census_block_encoder my_address_file_geocoded.csv 2010

shell:
	docker run --rm -it --entrypoint=/bin/bash -v "${PWD}/test":/tmp census_block_encoder

clean:
	docker system prune -f
