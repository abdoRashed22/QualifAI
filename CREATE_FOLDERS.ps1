# QualifAI — Create Folder Structure
# Run from: E:\Projects\qualif_ai
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\CREATE_FOLDERS.ps1

Write-Host 'Creating QualifAI folder structure...' -ForegroundColor Cyan

New-Item -ItemType Directory -Force -Path '.\android\app\src\main\res\xml' | Out-Null
New-Item -ItemType Directory -Force -Path '.\assets\icons' | Out-Null
New-Item -ItemType Directory -Force -Path '.\assets\images' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\core\api' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\core\cache' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\core\di' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\core\errors' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\core\localization' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\core\router' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\core\theme' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\accreditation\data\remote' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\accreditation\domain\repositories' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\accreditation\presentation\cubit' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\accreditation\presentation\screens' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\accreditation\repository' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\admin\data\remote' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\admin\domain\repositories' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\admin\presentation\cubit' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\admin\presentation\screens' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\admin\repository' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\auth\data\models' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\auth\data\remote' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\auth\domain\repositories' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\auth\presentation\cubit' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\auth\presentation\screens' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\auth\repository' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\chat\data\remote' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\chat\domain\repositories' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\chat\presentation\cubit' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\chat\presentation\screens' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\chat\repository' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\dashboard\data\remote' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\dashboard\domain\repositories' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\dashboard\presentation\cubit' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\dashboard\presentation\screens' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\dashboard\repository' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\deadlines\data\remote' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\deadlines\domain\repositories' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\deadlines\presentation\cubit' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\deadlines\presentation\screens' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\deadlines\repository' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\notifications\data\remote' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\notifications\domain\repositories' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\notifications\presentation\cubit' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\notifications\presentation\screens' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\notifications\repository' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\profile\data\remote' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\profile\domain\repositories' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\profile\presentation\cubit' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\profile\presentation\screens' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\profile\repository' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\reports\data\remote' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\reports\domain\repositories' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\reports\presentation\cubit' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\reports\presentation\screens' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\features\reports\repository' | Out-Null
New-Item -ItemType Directory -Force -Path '.\lib\shared\widgets' | Out-Null

Write-Host 'All folders created!' -ForegroundColor Green