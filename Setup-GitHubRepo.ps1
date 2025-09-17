# "Setup-GitHubRepo.ps1"
function Initialize-GitHubRepo {
    param (
        [Parameter(Mandatory)]
        [string]$RepoName,

        [Parameter(Mandatory)]
        [string]$GitHubUsername,

        [Parameter(Mandatory)]
        [string]$GitHubToken,

        [string]$CommitMessage = "Initial commit",
        [string]$BranchName = "main",
        [switch]$UseSSH
    )

    # Check for Git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "❌ Git is not installed or not in PATH."
        return
    }

    # Create .gitignore if missing
    $gitignorePath = ".gitignore"
    if (-not (Test-Path $gitignorePath)) {
        @"
# PowerShell artifacts
*.ps1~
*.psm1~
*.log
*.tmp
*.bak

# VS Code
.vscode/

# OS junk
Thumbs.db
.DS_Store
"@ | Out-File $gitignorePath -Encoding UTF8
        Write-Host "📄 Created .gitignore"
    }

    # Create GitHub repo via API
    $apiUrl = "https://api.github.com/user/repos"
    $headers = @{ Authorization = "token $GitHubToken" }
    $body = @{ name = $RepoName; auto_init = $false } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body
        Write-Host "🌐 Created GitHub repo '$RepoName'"
    }
    catch {
        Write-Warning "⚠️ Repo may already exist or token is invalid. Continuing..."
    }

    # Git operations
    git init
    Write-Host "✅ Initialized Git repository"

    git add .
    Write-Host "📦 Staged all files"

    git commit -m $CommitMessage
    Write-Host "📝 Committed with message: '$CommitMessage'"

    $remoteUrl = if ($UseSSH) {
        "git@github.com:$GitHubUsername/$RepoName.git"
    } else {
        "https://github.com/$GitHubUsername/$RepoName.git"
    }

    git remote add origin $remoteUrl
    Write-Host "🔗 Remote 'origin' set to $remoteUrl"

    git push -u origin $BranchName
    Write-Host "🚀 Pushed to GitHub branch '$BranchName'"
}

# 🧑‍💻 Prompt for input
$repoName = Read-Host "Enter the GitHub repository name"
$githubUsername = Read-Host "Enter your GitHub username"
$githubToken = Read-Host "Enter your GitHub personal access token"
$useSSH = Read-Host "Use SSH? (y/n)"
$switchSSH = if ($useSSH -eq 'y') { $true } else { $false }

# 🔄 Execute
Initialize-GitHubRepo -RepoName $repoName -GitHubUsername $githubUsername -GitHubToken $githubToken -UseSSH:$switchSSH