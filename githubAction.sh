#!/bin/bash

# Create the .github/workflows directory if it doesn't exist

mkdir -p .github/workflows

# Generate a basic workflow file for running tests and linting
cat <<EOL > .github/workflows/cicd.yml
name: Continue intergration and continues deployment pipeline
on:
  workflow_dispatch:
  # push:
  #   branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  integration:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [22]

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: \${{ matrix.node-version }}

      - name: Install dependencies for Frontend
        run: |
          cd ui
          npm install
        #   cd ..

      - name: Install dependencies for Backend
        run: |
          cd api
          npm install
        #   cd ..

      - name: Run lint for Frontend
        run: |
          cd ui
          # npm run lint
        #   cd ..

      - name: Run lint for Backend
        run: |
          cd api
          npm run lint
        #   cd ..

      - name: Run tests for Frontend
        run: |
          cd ui
          npm run test:coverage
      - name: Run tests for Backend
        run: |
          cd api
          npm run test
      - name: Analyze with SonarCloud
        uses: SonarSource/sonarcloud-github-action@v2.2.0
        env:
            SONAR_TOKEN: \${{ secrets.SONAR_TOKEN }}   # Generate a token on Sonarcloud.io, add it to the secrets of this repo with the name SONAR_TOKEN (Settings > Secrets > Actions > add new repository secret)
        with:
          # Additional arguments for the SonarScanner CLI
          args:
            # Unique keys of your project and organization. You can find them in SonarCloud > Information (bottom-left menu)
            # mandatory
            -Dsonar.projectKey=bvkakadiya_react-fastify-auth0
            -Dsonar.organization=bvkakadiya
            # Comma-separated paths to directories containing main source files.
            #-Dsonar.sources= # optional, default is project base directory
            # Comma-separated paths to directories containing test source files.
            #-Dsonar.tests= # optional. For more info about Code Coverage, please refer to https://docs.sonarcloud.io/enriching/test-coverage/overview/
            # Adds more detail to both client and server-side analysis logs, activating DEBUG mode for the scanner, and adding client-side environment variables and system properties to the server-side log of analysis report processing.
            #-Dsonar.verbose= # optional, default is false
          # When you need the analysis to take place in a directory other than the one from which it was launched, default is .
          projectBaseDir: .
      - run: echo "- Lint the code and run unit tests completed successfully!" >> \$GITHUB_STEP_SUMMARY
  build:
    needs: [integration]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "- Build the artifact"
  test-artifact:
    needs: [build]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: echo "- Simulate and test the artifact" >> \$GITHUB_STEP_SUMMARY

  development:
    environment: Development
    needs: [build]
    runs-on: ubuntu-latest
    steps:
      - run: echo "- Auto-deploy the artifact to the development environment" >> \$GITHUB_STEP_SUMMARY

  staging:
    environment: Staging
    needs: [development, test-artifact]
    runs-on: ubuntu-latest
    steps:
      - run: |
          echo "After development envirionment is deployed..."
          echo "and after the artifact tests have passed..."
          echo "- Auto-deploy the artifact to the staging environment" >> \$GITHUB_STEP_SUMMARY

  test-staging:
    needs: staging
    runs-on: ubuntu-latest
    steps:
      - run: echo "- Test the staging environment" >> \$GITHUB_STEP_SUMMARY

  production:
    environment: Production
    needs: [test-staging]
    runs-on: ubuntu-latest
    steps:
      - run: |
          echo "After staging envirionment is deployed..."
          echo "and after the staging tests have passed..."
          echo "require a review before deploying to the production envirionment, then..."
          echo "- Deploy the artifact to the production environment" >> \$GITHUB_STEP_SUMMARY

  test-production:
    needs: [production]
    runs-on: ubuntu-latest
    steps:
      - run: echo "- Test the artifact in the production environment"
      - run: echo "# Everything completed successfully!" >> \$GITHUB_STEP_SUMMARY

EOL

cat <<EOL > .github/workflows/build.yml
name: Vercel Build
env:
  VERCEL_ORG_ID: \${{ secrets.VERCEL_ORG_ID }}
  VERCEL_PROJECT_ID: \${{ secrets.VERCEL_PROJECT_ID }}
on:
    workflow_call:
    workflow_dispatch:
jobs:
  Build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Vercel CLI
        run: npm install --global vercel@latest
      - name: Pull Vercel Environment Information
        run: vercel pull --yes --environment=preview --token=\${{ secrets.VERCEL_TOKEN }}
      - name: Build Project Artifacts
        run: vercel build --token=\${{ secrets.VERCEL_TOKEN }}
EOL

cat <<EOL > .github/workflows/deploy_qa.yml
name: Vercel Non Prod Deployment
env:
  VERCEL_ORG_ID: \${{ secrets.VERCEL_ORG_ID }}
  VERCEL_PROJECT_ID: \${{ secrets.VERCEL_PROJECT_ID }}
on: 
  workflow_call:
  workflow_dispatch:
#   push:
#     branches-ignore:
#       - main
jobs:
  Deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Vercel CLI
        run: npm install --global vercel@latest
      - name: Pull Vercel Environment Information
        run: vercel pull --yes --environment=preview --token=\${{ secrets.VERCEL_TOKEN }}
      - name: Build Project Artifacts
        run: vercel build --token=\${{ secrets.VERCEL_TOKEN }}
      - name: Deploy Project Artifacts to Vercel
        run: vercel deploy --prebuilt --token=\${{ secrets.VERCEL_TOKEN }}
EOL

cat <<EOL > .github/workflows/deploy_prod.yml
name: Vercel Production Deployment
env:
  VERCEL_ORG_ID: \${{ secrets.VERCEL_ORG_ID }}
  VERCEL_PROJECT_ID: \${{ secrets.VERCEL_PROJECT_ID }}
on:
#   push:
#     branches:
#       - main
  workflow_call:
  workflow_dispatch:
jobs:
  Deploy-Production:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Vercel CLI
        run: npm install --global vercel@latest
      - name: Pull Vercel Environment Information
        run: vercel pull --yes --environment=production --token=\${{ secrets.VERCEL_TOKEN }}
      - name: Build Project Artifacts
        run: vercel build --prod --token=\${{ secrets.VERCEL_TOKEN }}
      - name: Deploy Project Artifacts to Vercel
        run: vercel deploy --prebuilt --prod --token=\${{ secrets.VERCEL_TOKEN }}
EOL

cat <<EOL > .github/workflows/e2e_test.yml
name: Vercel Non Prod Deployment With test
env:
  VERCEL_ORG_ID: \${{ secrets.VERCEL_ORG_ID }}
  VERCEL_PROJECT_ID: \${{ secrets.VERCEL_PROJECT_ID }}
on: 
  workflow_call:
  workflow_dispatch:
#   push:
#     branches-ignore:
#       - main
jobs:
  Deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Vercel CLI
        run: npm install --global vercel@latest
      - name: Pull Vercel Environment Information
        run: vercel pull --yes --environment=preview --token=\${{ secrets.VERCEL_TOKEN }}
      - name: Build Project Artifacts
        run: vercel build --token=\${{ secrets.VERCEL_TOKEN }}
      - name: Deploy Project Artifacts to Vercel
        id: deploy
        run: vercel deploy --prebuilt --token=\${{ secrets.VERCEL_TOKEN }} --prod
      - name: Get Preview URL
        id: get-url
        run: echo "PREVIEW_URL=\$(vercel inspect --token=\${{ secrets.VERCEL_TOKEN }} --output=json | jq -r '.url')" >> \$GITHUB_ENV
      - name: Install Dependencies
        run: npm install
      - name: Run Playwright E2E Tests
        run: |
          echo \$PREVIEW_URL
          npx playwright test --project=chromium --base-url=\${{ env.PREVIEW_URL }}

EOL

echo "GitHub Actions workflow file created at .github/workflows/ci.yml"