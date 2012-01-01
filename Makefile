GENERATEPMPACKAGE = generate-pm-package

all: dist

dist: always
	mkdir -p dist
	$(GENERATEPMPACKAGE) config/dist/class-registry.pi dist/
	$(GENERATEPMPACKAGE) config/dist/operation-response.pi dist/

test:
	prove t/*.t t/list-ish/*.t

always:
