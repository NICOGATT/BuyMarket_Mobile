Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot
$masterPath = Join-Path $projectRoot 'assets\images\app_icon_enlarged.png'

function Export-ResizedPng {
    param(
        [System.Drawing.Image]$Source,
        [string]$Destination,
        [int]$Width,
        [int]$Height,
        [System.Drawing.Rectangle]$SourceRectangle
    )

    $bitmap = New-Object System.Drawing.Bitmap($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $bitmap.SetResolution(72, 72)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

    try {
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $destinationRectangle = New-Object System.Drawing.Rectangle(0, 0, $Width, $Height)
        $graphics.DrawImage($Source, $destinationRectangle, $SourceRectangle, [System.Drawing.GraphicsUnit]::Pixel)
        $bitmap.Save($Destination, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

$master = [System.Drawing.Image]::FromFile($masterPath)
$fullMaster = New-Object System.Drawing.Rectangle(0, 0, 1024, 1024)

try {
    $androidSizes = @{
        'mipmap-mdpi\ic_launcher.png' = 48
        'mipmap-hdpi\ic_launcher.png' = 72
        'mipmap-xhdpi\ic_launcher.png' = 96
        'mipmap-xxhdpi\ic_launcher.png' = 144
        'mipmap-xxxhdpi\ic_launcher.png' = 192
    }

    foreach ($entry in $androidSizes.GetEnumerator()) {
        $destination = Join-Path $projectRoot ('android\app\src\main\res\' + $entry.Key)
        Export-ResizedPng -Source $master -Destination $destination -Width $entry.Value -Height $entry.Value -SourceRectangle $fullMaster
    }

    $iosDirectory = Join-Path $projectRoot 'ios\Runner\Assets.xcassets\AppIcon.appiconset'
    Get-ChildItem $iosDirectory -Filter '*.png' | ForEach-Object {
        $current = [System.Drawing.Image]::FromFile($_.FullName)
        try {
            $width = $current.Width
            $height = $current.Height
        }
        finally {
            $current.Dispose()
        }

        Export-ResizedPng -Source $master -Destination $_.FullName -Width $width -Height $height -SourceRectangle $fullMaster
    }
}
finally {
    $master.Dispose()
}
