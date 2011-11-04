GENERATEPMPACKAGE = generate-pm-package

all: dist

dist: always
	mkdir -p dist
	$(GENERATEPMPACKAGE) config/class-registry.pi dist/
	$(GENERATEPMPACKAGE) config/operation-response.pi dist/

test:
	prove t/*.t

always:
