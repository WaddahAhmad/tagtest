.PHONY: bump_tag

bump_tag:
    old_tag=$$(git describe --tags --always $$(git rev-list --tags --max-count=1)) | sed 's/v//' ; \
    case "${upgrade_level}" in \
        "patch") \
            incremented_version=$$(echo $$version | awk -F. '{$$NF = $$NF + 1;} 1' | sed 's/ /./g') ; \
            ;; \
        "minor") \
            incremented_version=$$(echo $$version | awk -F. '{$$(NF-1) = $$(NF-1) + 1; $$NF = 0 } 1' | sed 's/ /./g') ; \
            ;; \
        "major") \
            incremented_version=$$(echo $$version | awk -F. '{$$(NF-2) = $$(NF-2) + 1; $$NF = 0; $$(NF-1) = 0 } 1' | sed 's/ /./g') ; \
            ;; \
        *) \
            echo "Invalid upgrade level specified." ; \
            exit 1 ; \
            ;; \
    esac ; \
    incremented_tag="v$${incremented_version}" ; \
    echo "tag=$${incremented_tag}" >> "$$GITHUB_OUTPUT"