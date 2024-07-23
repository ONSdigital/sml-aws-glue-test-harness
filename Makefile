.PHONY: build-image-glue4 build-image-glue3 build-image-glue4 build-image-glue4-spark-equiv get-sml-releasei test-glue3 test-glue4 help

define help_text
Usage: make <target> [FAILFAST=1]

Parameters:

target - the operation to run e.g

clean                   - remove all build artifacts, docker images, downloaded sml, test logs.
get-sml-release         - download and unpack SML release ready for testing
test-glue3              - run SML tests in a glue v3 docker container
test-glue4              - run SML tests in a glue v4 docker container
test-glue4-spark-equiv  - run SML tests in a plain spark container with versions matching glue4

Options:
FAILFAST=1  - exit on first failure, default is to run all the tests
endef

help:
	@$(info $(help_text)):

build-image-glue4:
	@echo building glue4 image
	@docker buildx build \
	-f conf/dockerfile-glue \
	--build-arg=GLUE_IMAGE_TAG="glue_libs_4.0.0_image_01-amd64" \
	-t sml-testing:glue4 ./conf

build-image-glue3:
	@echo building glue3 image
	@docker buildx build \
	-f conf/dockerfile-glue \
	--build-arg=GLUE_IMAGE_TAG="glue_libs_3.0.0_image_01-amd64" \
	-t sml-testing:glue3 ./conf
    
build-image-glue4-spark-equiv:
	@echo building spark-glue4-equiv image
	@docker buildx build \
	-f conf/dockerfile-glue4-spark-equiv \
	-t sml-testing:glue4-spark-equiv ./conf

get-sml-release:
ifneq ($(wildcard ./statistical-methods-library-13.3.9/.*),) 
	@echo getting SML-13.3.0
	@curl -s -L --max-redirs 2 \
	-O "https://github.com/ONSdigital/statistical-methods-library/archive/refs/tags/13.3.0.tar.gz"
	@tar zxf 13.3.0.tar.gz
	@cp ./statistical-methods-library-13.3.0/pyproject.toml ./statistical-methods-library-13.3.0/pyproject.toml.exitfirstfailure
	@sed -e '/--exitfirst/d' -I '' ./statistical-methods-library-13.3.0/pyproject.toml > ./statistical-methods-library-13.3.0/pyproject.toml.alltests
else
	@echo Found SML directory, skipping download and unpack
endif

test-glue3:  build-image-glue3 get-sml-release
	@docker run --rm -it -v .:/home/smltest \
	--entrypoint '' \
	sml-testing:glue3 \
	bash -c "cd /home/smltest/statistical-methods-library-13.3.0; python3 -m pytest | tee ../glue3-tests.log"

test-glue4: build-image-glue4 get-sml-release
	@echo running glue 4 tests
	@docker run --rm -it -v .:/home/smltest \
	--entrypoint '' \
	sml-testing:glue4 \
	bash -l -c "cd /home/smltest/statistical-methods-library-13.3.0; python3 -m pytest | tee ../glue4-tests.log"

test-glue4-spark-equiv: build-image-glue4-spark-equiv get-sml-release
	@docker run --rm -it -v .:/home/smltest \
	sml-testing:glue4-spark-equiv \
	bash -c "cd /home/smltest/statistical-methods-library-13.3.0; python -m pytest | tee ../glue4-spark-equiv-tests.log"

clean:
	@echo cleaning up build artifacts
	@-docker rmi sml-testing:glue3
	@-docker rmi sml-testing:glue4
	@-docker rmi sml-testing:glue4-spark-equiv
	@-rm -rf ./statistical-methods-library-13.3.0

