name: Disable All WebTests

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Azure CLI script file
        uses: azure/CLI@v1
        with:
          azcliversion: 2.45.0
          inlineScript: |
            az config set extension.use_dynamic_install=yes_without_prompt
            cd $GITHUB_WORKSPACE
            chmod +x $GITHUB_WORKSPACE/utils/disable_all_webtests.sh
            $GITHUB_WORKSPACE/utils/disable_all_webtests.sh
