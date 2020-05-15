include boot.mk

.tmp:
	@mkdir .tmp

clean: boot~clean
	rm -fr .tmp

system/helmfile.yaml apps/helmfile-augmented.yaml: jx-apps.yaml jx-requirements.yaml apps/helmfile-augment.yaml | .tmp
	jx step create helmfile
	awk '(FNR==1) { print "---" }1' apps/helmfile.yaml apps/helmfile-augment.yaml | \
          yq r -d'*' -j -P - | jq --slurp add - | yq r -P - > apps/helmfile-augmented.yaml

helmfile.yaml: system/helmfile.yaml apps/helmfile-augmented.yaml; @touch helmfile.yaml

export JX_SECRETS_YAML ?= $(realpath .tmp/boot-secrets.yaml)

%~template:
	helmfile --selector name=$(*) template

%~diff:
	helmfile --selector name=$(*) diff

%~sync:
	helmfile --selector name=$(*) sync

%~destroy:
	helmfile --selector name=$(*) destroy
