# Dev Experience with Microsoft DevBox

Example templates and customization configurations for Dev Box and Azure Deployment Environments.

## Table of Contents

- [Solution Architecture](#solution-architecture)
  - [Azure Resources Deployed](#azure-resources-deployed)
- [Pre-requisites](#pre-requisites)
  - [Install Git](#install-git)
  - [Install Visual Studio Code](#install-visual-studio-code)
  - [Install Azure Developer CLI](#install-azure-developer-cli)
- [Deploy Solution](#deploy-solution)
  - [Clone this Repo](#clone-this-repo)
  - [Open VS Code](#open-vs-code)
  - [Open a new Terminal](#open-a-new-terminal)
  - [Login to Azure](#login-to-azure)
    - [Add the current user to the Dev Center Groups](#rbac---assign-the-current-user-to-the-dev-center-rbac-roles)
  - [Create your environment](#create-your-environment)
  - [Deploy solution to Azure](#deploy-solution-to-azure)
    - [Checking the deployment](#checking-deployment)
- [Create a DevBox](#comingsoon)
- [Create a Deployment Environment](#comingsoon)
- [Contributing](#contributing)
- [Trademarks](#trademarks)
- [License](#license)

## Solution Architecture

![Solution Architecture](./images/ContosoDevBox.png)

## Azure Resources Deployed

![Azure Resources Deployed](./images/azureResourcesDeployed.png)

## Pre-requisites

Before getting started, ensure you have the following tools installed on your Windows machine. You can use `winget` to install them quickly.

### Install Git

Git is required for cloning the repository.

```powershell
winget install --id Git.Git -e --source winget
```

### Install Visual Studio Code
VS Code is used for editing and running scripts.

```powershell
winget install --id Microsoft.VisualStudioCode -e --source winget
```

### Install Azure Developer CLI
Azure Developer CLI (azd) is required to interact with Azure services.

```powershell
winget install --id Microsoft.AzureCLI -e --source winget
```

## Deploy Solution

### Clone this Repo

```powershell
git clone https://github.com/Evilazaro/DevExp-DevBox.git
```

### Open VS Code
```powershell
cd DevExp-DevBox
```
```powershell
code .
```

You are going to see VS Code with all the content of this repo

![VS Code](./images/vscode.png)

### Open a new Terminal

Click on Terminal Menu >> New Terminal

![New Terminal](./images/terminalmenu.png)

Your Visual Studio Code must be like the image below

![VS Code Terminal](./images/vscodeterminal.png)

### Login to Azure

Type the command below into the Terminal Window and press enter
```
azd auth login
```
Provide your Azure Credentials.

After the login to Azure has been completed, you must see the following message below:

![Logint to Azure Completed](./images/azureloggedin.png)

### Create your environment
```powershell
azd env new dev
```
You are going to see a new *.azure* folder with the *dev environment* configuration that will be used by Azure Developer CLI.

![new dev environment](./images/newdevenv.png)

### RBAC - Assign the Current User to the Dev Center RBAC Roles

 This script will assign the current user to the DevCenter Project Admin, Dev Box User, Deployment Environments Reader, and Deployment Environments User RBAC roles. You can see more details on the [Azure role-based access control in Microsoft Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/concept-dev-box-role-based-access-control), and [Azure role-based access control in Azure Deployment Environments](https://learn.microsoft.com/en-us/azure/deployment-environments/concept-deployment-environments-role-based-access-control#built-in-roles).

```powershell
.\setup.ps1
```
You will see the following output in the Terminal Window.

![setup](./images/setup.png)


### Deploy solution to Azure
```powershell
azd provision -e dev
```
Select the Azure Subscription you want to deploy the workload to and press Enter.

![Azure Subscription](./images/azureSubscription.png)

Select the Azure Region you want to deploy the workload to and press Enter.

![Azure Region](./images/azureRegion.png)

Azure Develper CLI will start the deployment to your Azure Subscription. When the deployment is finished, you must see the following message:

![Azure Deployment Finished](./images/azuredeploymentfinished.png)

### Checking deployment

## Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit [https://cla.opensource.microsoft.com](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general). Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party's policies.

## License

This project is licensed under the [MIT License](LICENSE).