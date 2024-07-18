.PHONY: build-image-glue4 build-image-glue3 build-image-glue4 build-image-glue4-spark-equiv get-sml-release

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
	@echo getting SML-13.3.0
	@curl -s -L --max-redirs 2 \
	-O "https://github.com/ONSdigital/statistical-methods-library/archive/refs/tags/13.3.0.tar.gz"
	@tar zxf 13.3.0.tar.gz
	@sed -e '/--exitfirst/d' -I '' ./statistical-methods-library-13.3.0/pyproject.toml

test-glue3:
	@docker run --rm -it -v .:/home/smltest \
	sml-testing:glue3 \
	bash -c "cd /home/sml/statistical-methods-library-13.3.0; python -m pytest | tee ../glue3-tests.log"

test-glue4:
	@docker run --rm -it -v .:/home/smltest \
	sml-testing:glue4 \
	bash -l -c "cd /home/smltest/statistical-methods-library-13.3.0; ls; python -m pytest "

test-glue4-spark-equiv:
	@docker run --rm -it -v .:/home/smltest \
	sml-testing:glue4-spark-equiv \
	bash -c "cd /home/smltest/statistical-methods-library-13.3.0; python -m pytest | tee ../glue4-spark-equiv-tests.log"

