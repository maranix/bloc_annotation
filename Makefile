.PHONY: dry_run_annotation dry_run_generator dry_run publish_annotation publish_generator publish fix_annotation fix_generator fix test_annotation test_generator test

# Reusable function for confirmation
define confirm
	@read -p "Are you sure you want to continue? [y/N] " ans; \
	if [ "$$ans" != "y" ] && [ "$$ans" != "Y" ]; then \
		echo "Aborted."; \
		exit 1; \
	fi
endef

# Dry-run targets
dry_run_annotation:
	dart pub -C packages/bloc_annotation publish --dry-run

dry_run_generator:
	dart pub -C packages/bloc_annotation_generator publish --dry-run

dry_run: dry_run_annotation dry_run_generator

# Actual publish targets
publish_annotation:
	dart test packages/bloc_annotation && dart pub -C packages/bloc_annotation publish

publish_generator:
	dart test packages/bloc_annotation_generator && dart pub -C packages/bloc_annotation_generator publish

publish:
	$(confirm)
	@$(MAKE) publish_annotation
	@$(MAKE) publish_generator


# Apply dart fix to targets
fix_annotation:
	dart fix packages/bloc_annotation --apply

fix_generator:
	dart fix packages/bloc_annotation_generator --apply

fix:
	$(confirm)
	@$(MAKE) fix_annotation
	@$(MAKE) fix_generator

# Run tests for targets
test_annotation:
	dart test packages/bloc_annotation

test_generator:
	dart test packages/bloc_annotation_generator

test:
	$(confirm)
	@$(MAKE) test_annotation
	@$(MAKE) test_generator
