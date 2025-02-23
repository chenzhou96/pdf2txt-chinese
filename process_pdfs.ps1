# 带参数校验的param区块
param (
    [Parameter(Mandatory=$true)]
    [ValidateScript({ 
        # 这里需要显式闭合验证脚本块
        Test-Path $_ -PathType Container 
    })]  # <-- 注意这个闭合括号
    [string]$folderPath
)

# 动态获取脚本所在路径
$scriptDir = $PSScriptRoot
$mainGpuPyPath = Join-Path $scriptDir "main-gpu.py"

# 检查主程序是否存在
if (-Not (Test-Path $mainGpuPyPath)) {
    Write-Error "main-gpu.py not found at path: $mainGpuPyPath"
    exit 1
}

# 指定Python解释器路径（注意路径斜杠方向）
$pythonPath = "D:/Program/anaconda3/envs/pdf2txt/python.exe"

# 检查Python解释器是否存在
if (-Not (Test-Path $pythonPath)) {
    Write-Error "Python interpreter not found at path: $pythonPath"
    exit 1
}

# 获取目标文件夹的PDF文件
$pdfFiles = Get-ChildItem -Path $folderPath -Filter *.pdf

# 文件存在性检查
if ($pdfFiles.Count -eq 0) {
    Write-Output "No PDF files found in folder: $folderPath"
    exit 0
}

# 创建日志文件路径
$desktopPath = [System.Environment]::GetFolderPath("Desktop")
$logFilePath = Join-Path $desktopPath "pdf_processing_errors.log"

# 初始化日志文件
if (Test-Path $logFilePath) {
    Remove-Item $logFilePath
}

# 在循环中添加错误处理
$total = $pdfFiles.Count
$current = 0
foreach ($pdfFile in $pdfFiles) {
    $current++
    Write-Progress -Activity "Processing PDFs" -Status "$current/$total" -PercentComplete ($current/$total*100)
    try {
        # 打印完整的命令行字符串
        $command = "& $pythonPath $mainGpuPyPath --encoding utf-8 $($pdfFile.FullName)"
        Write-Output "Running command: $command"
        
        # 捕获退出码
        $exitCode = & $pythonPath $mainGpuPyPath --encoding utf-8 $pdfFile.FullName
        if ($LASTEXITCODE -ne 0) {
            throw "Python script failed with exit code $LASTEXITCODE"
        }
        Write-Output "[SUCCESS] Processed $($pdfFile.Name)"
    }
    catch {
        Write-Warning "[FAILED] Error processing $($pdfFile.Name): $_"
        # 将出错的PDF文件名写入日志文件
        Add-Content -Path $logFilePath -Value "$($pdfFile.Name): $_"
    }
}