# "fun-Initialize-GitHubRepo.ps1"
function Initialize-GitHubRepo {
    param (
        [Parameter(Mandatory)]
        [string]$RepoName,

        [Parameter(Mandatory)]
        [string]$GitHubUsername,

        [string]$CommitMessage = "Initial commit",
        [string]$BranchName = "main",
        [switch]$UseSSH
    )

    try {
        # Create local repo
        git init
        Write-Host "✅ Initialized Git repository"

        # Stage all files
        git add .
        Write-Host "📦 Staged all files"

        # Commit
        git commit -m $CommitMessage
        Write-Host "📝 Committed with message: '$CommitMessage'"

        # Remote URL
        $remoteUrl = if ($UseSSH) {
            "git@github.com:$GitHubUsername/$RepoName.git"
        } else {
            "https://github.com/$GitHubUsername/$RepoName.git"
        }

        # Add remote
        git remote add origin $remoteUrl
        Write-Host "🔗 Remote 'origin' set to $remoteUrl"

        # Push to GitHub
        git push -u origin $BranchName
        Write-Host "🚀 Pushed to GitHub branch '$BranchName'"
    }
    catch {
        Write-Error "❌ Error during GitHub repo initialization: $_"
    }
}
Initialize-GitHubRepo -RepoName "my-powershell-tools" -GitHubUsername "bernard-dev" -CommitMessage "Bootstrap repo" -UseSSH
