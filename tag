rtname: Bump version
on:
  workflow_dispatch:
    inputs:
      upgrade_level:
        type: choice
        description: kind of update
        default: 'patch'
        options: 
        - patch
        - minor
        - major

jobs:

  extract_tag:4trw4twertewtretr
    runs-on: ubuntu-latest
    outputs:
      old_tag: ${{ steps.old_tag.outputs.old_tag }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-tags: 'true'
          fetch-depth: '0'
          
      - name: Get Old Tag
        id: old_tag
        run: |
          echo "old_tag=$(git describe --tags --always $(git rev-list --tags --max-count=1))" >> "$GITHUB_OUTPUT"
          
  bump_tag:
    runs-on: ubuntu-latest
    needs: extract_tag
    outputs:
      final_tag: ${{steps.bump_tag.outputs.tag}}
    steps:
    - name: bump_tag
      id: bump_tag
      run: |
        old_tag=${{ needs.extract_tag.outputs.old_tag }}
        echo $old_tag
        echo ${{ inputs.upgrade_level }} 
        version=$(echo $old_tag | sed 's/v//')
        case ${{ inputs.upgrade_level }} in
          "patch")
            incremented_version=$(echo $version | awk -F. '{$NF = $NF + 1;} 1' | sed 's/ /./g')
            ;;
          "minor")
            incremented_version=$(echo $version | awk -F. '{$(NF-1) = $(NF-1) + 1; $NF = 0 } 1' | sed 's/ /./g')
            ;;
          "major")
            incremented_version=$(echo $version | awk -F. '{$(NF-2) = $(NF-2) + 1; $NF = 0; $(NF-1) = 0 } 1' | sed 's/ /./g')
            ;;
          *)
            echo "Invalid upgrade level specified."
            exit 1
            ;;
        esac
        incremented_tag="v${incremented_version}"
        echo "tag=${incremented_tag}" >> "$GITHUB_OUTPUT"
        
  push_tag_name:
    runs-on: ubuntu-latest
    needs: bump_tag
    steps:
      - uses: actions/checkout@v3
        with:
          token: ${{ secrets.PAT }}
      - name: Create version
        run: git tag ${{needs.bump_tag.outputs.final_tag}}
      - name: Commit report
        run: |
          git config --global user.name 'waddah'
          git config --global user.email 'waddah.t.ahmad@gmail.com'
          git push origin ${{needs.bump_tag.outputs.final_tag}}
