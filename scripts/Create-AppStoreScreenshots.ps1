Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root "fastlane\screenshots\en-US"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$W = 1290
$H = 2796

function ColorFromHex([string]$hex) {
    $h = $hex.TrimStart("#")
    return [System.Drawing.Color]::FromArgb(
        255,
        [Convert]::ToInt32($h.Substring(0, 2), 16),
        [Convert]::ToInt32($h.Substring(2, 2), 16),
        [Convert]::ToInt32($h.Substring(4, 2), 16)
    )
}

$Colors = @{
    Primary = ColorFromHex "#216B40"
    PrimaryDark = ColorFromHex "#103F28"
    Accent = ColorFromHex "#D9AA4A"
    Background = ColorFromHex "#F3F7F0"
    Card = ColorFromHex "#FFFFFF"
    Text = ColorFromHex "#1A211B"
    Muted = ColorFromHex "#5B6B5C"
    Border = ColorFromHex "#DDE5DA"
    Orange = ColorFromHex "#D9822B"
    Blue = ColorFromHex "#2B6ED9"
}

function New-Font([float]$size, [System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Regular) {
    return New-Object System.Drawing.Font("Segoe UI", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

function New-Brush($color) {
    return New-Object System.Drawing.SolidBrush($color)
}

function New-Pen($color, [float]$width = 1) {
    return New-Object System.Drawing.Pen($color, $width)
}

function RoundPath([System.Drawing.RectangleF]$rect, [float]$radius) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $radius * 2
    $path.AddArc($rect.X, $rect.Y, $d, $d, 180, 90)
    $path.AddArc($rect.Right - $d, $rect.Y, $d, $d, 270, 90)
    $path.AddArc($rect.Right - $d, $rect.Bottom - $d, $d, $d, 0, 90)
    $path.AddArc($rect.X, $rect.Bottom - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function FillRound($g, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r, $color) {
    $path = RoundPath ([System.Drawing.RectangleF]::new($x, $y, $w, $h)) $r
    $brush = New-Brush $color
    $g.FillPath($brush, $path)
    $brush.Dispose()
    $path.Dispose()
}

function StrokeRound($g, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r, $color, [float]$line = 2) {
    $path = RoundPath ([System.Drawing.RectangleF]::new($x, $y, $w, $h)) $r
    $pen = New-Pen $color $line
    $g.DrawPath($pen, $path)
    $pen.Dispose()
    $path.Dispose()
}

function DrawText($g, [string]$text, [float]$x, [float]$y, [float]$w, [float]$h, $font, $color, [string]$align = "Near") {
    $brush = New-Brush $color
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::$align
    $format.LineAlignment = [System.Drawing.StringAlignment]::Near
    $format.Trimming = [System.Drawing.StringTrimming]::EllipsisWord
    $g.DrawString($text, $font, $brush, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $format)
    $format.Dispose()
    $brush.Dispose()
}

function DrawCenteredText($g, [string]$text, [float]$x, [float]$y, [float]$w, [float]$h, $font, $color) {
    $brush = New-Brush $color
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    $format.Trimming = [System.Drawing.StringTrimming]::EllipsisWord
    $g.DrawString($text, $font, $brush, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $format)
    $format.Dispose()
    $brush.Dispose()
}

function DrawPill($g, [string]$text, [float]$x, [float]$y, [float]$w, [float]$h, $bg, $fg) {
    FillRound $g $x $y $w $h ($h / 2) $bg
    DrawCenteredText $g $text $x ($y + 1) $w $h (New-Font 28 ([System.Drawing.FontStyle]::Bold)) $fg
}

function DrawHeader($g, [string]$headline, [string]$subhead) {
    DrawText $g $headline 94 88 1102 170 (New-Font 72 ([System.Drawing.FontStyle]::Bold)) $Colors.PrimaryDark
    DrawText $g $subhead 96 260 1040 96 (New-Font 34) $Colors.Muted
}

function DrawPhoneShell($g) {
    $x = 94
    $y = 450
    $w = 1102
    $h = 2190
    FillRound $g $x $y $w $h 76 (ColorFromHex "#111713")
    FillRound $g ($x + 18) ($y + 18) ($w - 36) ($h - 36) 58 $Colors.Background
    FillRound $g ($x + 410) ($y + 34) 280 28 14 (ColorFromHex "#111713")
    return @{
        X = $x + 42
        Y = $y + 72
        W = $w - 84
        H = $h - 118
    }
}

function DrawNav($g, $screen, [string]$title, [string]$right = "") {
    DrawText $g "9:41" ($screen.X + 18) $screen.Y 160 44 (New-Font 30 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    DrawText $g "LandscapeQuote AI" ($screen.X + 18) ($screen.Y + 86) 640 54 (New-Font 42 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    if ($title -ne "LandscapeQuote AI") {
        DrawText $g $title ($screen.X + 18) ($screen.Y + 142) 640 44 (New-Font 28) $Colors.Muted
    }
    if ($right.Length -gt 0) {
        DrawPill $g $right ($screen.X + $screen.W - 226) ($screen.Y + 100) 190 56 $Colors.Primary $Colors.Card
    }
}

function DrawCard($g, [float]$x, [float]$y, [float]$w, [float]$h) {
    FillRound $g $x $y $w $h 22 $Colors.Card
    StrokeRound $g $x $y $w $h 22 $Colors.Border 2
}

function DrawMetric($g, [string]$label, [string]$value, [float]$x, [float]$y, [float]$w, $tint) {
    DrawCard $g $x $y $w 210
    FillRound $g ($x + 28) ($y + 28) 72 72 18 ([System.Drawing.Color]::FromArgb(35, $tint.R, $tint.G, $tint.B))
    DrawCenteredText $g "+" ($x + 28) ($y + 19) 72 72 (New-Font 40 ([System.Drawing.FontStyle]::Bold)) $tint
    DrawText $g $value ($x + 30) ($y + 118) ($w - 60) 48 (New-Font 42 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    DrawText $g $label ($x + 30) ($y + 166) ($w - 60) 34 (New-Font 24) $Colors.Muted
}

function DrawListRow($g, [string]$title, [string]$subtitle, [string]$amount, [float]$x, [float]$y, [float]$w) {
    DrawCard $g $x $y $w 128
    FillRound $g ($x + 24) ($y + 26) 76 76 18 ([System.Drawing.Color]::FromArgb(34, $Colors.Primary.R, $Colors.Primary.G, $Colors.Primary.B))
    DrawCenteredText $g "LQ" ($x + 24) ($y + 27) 76 76 (New-Font 24 ([System.Drawing.FontStyle]::Bold)) $Colors.Primary
    DrawText $g $title ($x + 122) ($y + 22) 420 36 (New-Font 31 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    DrawText $g $subtitle ($x + 122) ($y + 65) 420 34 (New-Font 24) $Colors.Muted
    DrawText $g $amount ($x + $w - 260) ($y + 30) 220 42 (New-Font 30 ([System.Drawing.FontStyle]::Bold)) $Colors.Text "Far"
    DrawPill $g "Draft" ($x + $w - 150) ($y + 78) 110 36 ([System.Drawing.Color]::FromArgb(35, $Colors.Primary.R, $Colors.Primary.G, $Colors.Primary.B)) $Colors.Primary
}

function DrawDashboard($g, $screen) {
    DrawNav $g $screen "LandscapeQuote AI" "Pro"
    $x = $screen.X + 18
    $y = $screen.Y + 190
    $w = $screen.W - 36
    DrawCard $g $x $y $w 190
    DrawText $g "Turn garden photos and rough measurements into a professional quote in minutes." ($x + 28) ($y + 28) ($w - 56) 86 (New-Font 31 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    DrawPill $g "3 free quotes left" ($x + 28) ($y + 126) 260 46 ([System.Drawing.Color]::FromArgb(35, $Colors.Primary.R, $Colors.Primary.G, $Colors.Primary.B)) $Colors.Primary
    DrawPill $g "Unlimited with Pro" ($x + $w - 298) ($y + 126) 270 46 ([System.Drawing.Color]::FromArgb(35, $Colors.Accent.R, $Colors.Accent.G, $Colors.Accent.B)) $Colors.PrimaryDark

    $y += 230
    DrawMetric $g "Total quotes" "24" $x $y (($w - 24) / 2) $Colors.Primary
    DrawMetric $g "Draft quotes" "6" ($x + (($w - 24) / 2) + 24) $y (($w - 24) / 2) $Colors.Orange
    $y += 236
    DrawMetric $g "Approved" "11" $x $y (($w - 24) / 2) (ColorFromHex "#2FA05B")
    DrawMetric $g "Monthly revenue" '$18.4k' ($x + (($w - 24) / 2) + 24) $y (($w - 24) / 2) $Colors.Accent

    $y += 258
    DrawCard $g $x $y $w 270
    DrawText $g "Ready for the next job?" ($x + 30) ($y + 28) ($w - 60) 54 (New-Font 36 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    DrawText $g "Capture details, generate a first estimate, then tune line items before saving." ($x + 30) ($y + 88) ($w - 60) 72 (New-Font 26) $Colors.Muted
    FillRound $g ($x + 30) ($y + 178) ($w - 60) 76 18 $Colors.Primary
    DrawCenteredText $g "Create New Estimate" ($x + 30) ($y + 178) ($w - 60) 76 (New-Font 30 ([System.Drawing.FontStyle]::Bold)) $Colors.Card

    $y += 316
    DrawText $g "Recent quotes" $x $y $w 42 (New-Font 34 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    $y += 58
    DrawListRow $g "Amelia Carter" "Artificial grass" '$1,962' $x $y $w
    DrawListRow $g "Oakfield Nursery" "Garden clearance" '$740' $x ($y + 148) $w
    DrawListRow $g "James Patel" "Patio paving" '$3,418' $x ($y + 296) $w
}

function DrawEstimateForm($g, $screen) {
    DrawNav $g $screen "New Estimate"
    $x = $screen.X + 18
    $y = $screen.Y + 200
    $w = $screen.W - 36
    DrawCard $g $x $y $w 350
    DrawText $g "Client details" ($x + 28) ($y + 24) 440 48 (New-Font 34 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    DrawField $g "Client name" "Amelia Carter" ($x + 28) ($y + 90) ($w - 56)
    DrawField $g "Phone or email" "amelia@example.com" ($x + 28) ($y + 178) ($w - 56)
    DrawField $g "Site address" "42 Willow Lane, Bristol" ($x + 28) ($y + 266) ($w - 56)

    $y += 386
    DrawCard $g $x $y $w 360
    DrawText $g "Project type" ($x + 28) ($y + 24) 440 48 (New-Font 34 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    $types = @("Lawn mowing", "Artificial grass", "Patio paving", "Garden clearance", "Fencing", "Decking")
    $cx = $x + 28
    $cy = $y + 92
    for ($i = 0; $i -lt $types.Length; $i++) {
        $col = $i % 2
        $row = [Math]::Floor($i / 2)
        $selected = $types[$i] -eq "Artificial grass"
        $bg = if ($selected) { $Colors.Primary } else { $Colors.Background }
        $fg = if ($selected) { $Colors.Card } else { $Colors.Text }
        FillRound $g ($cx + ($col * 464)) ($cy + ($row * 78)) 438 58 16 $bg
        DrawCenteredText $g $types[$i] ($cx + ($col * 464)) ($cy + ($row * 78)) 438 58 (New-Font 25 ([System.Drawing.FontStyle]::Bold)) $fg
    }

    $y += 396
    DrawCard $g $x $y $w 410
    DrawText $g "Measurements" ($x + 28) ($y + 24) 440 48 (New-Font 34 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    DrawSmallField $g "Length" "8 m" ($x + 28) ($y + 92) 438
    DrawSmallField $g "Width" "5 m" ($x + 494) ($y + 92) 438
    DrawField $g "Area override" "40 sq m" ($x + 28) ($y + 190) ($w - 56)
    DrawField $g "Manual notes" "Rear garden with side access" ($x + 28) ($y + 278) ($w - 56)

    $y += 446
    DrawCard $g $x $y $w 210
    DrawText $g "Site photos" ($x + 28) ($y + 24) 440 48 (New-Font 34 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    FillRound $g ($x + 28) ($y + 92) 438 76 18 $Colors.Background
    DrawCenteredText $g "Photo Library" ($x + 28) ($y + 92) 438 76 (New-Font 27 ([System.Drawing.FontStyle]::Bold)) $Colors.Primary
    FillRound $g ($x + 494) ($y + 92) 438 76 18 $Colors.Background
    DrawCenteredText $g "Camera" ($x + 494) ($y + 92) 438 76 (New-Font 27 ([System.Drawing.FontStyle]::Bold)) $Colors.Primary
}

function DrawField($g, [string]$label, [string]$value, [float]$x, [float]$y, [float]$w) {
    DrawText $g $label $x $y $w 28 (New-Font 21) $Colors.Muted
    FillRound $g $x ($y + 32) $w 48 12 $Colors.Background
    DrawText $g $value ($x + 16) ($y + 40) ($w - 32) 32 (New-Font 24) $Colors.Text
}

function DrawSmallField($g, [string]$label, [string]$value, [float]$x, [float]$y, [float]$w) {
    DrawField $g $label $value $x $y $w
}

function DrawAI($g, $screen) {
    DrawNav $g $screen "AI Estimate"
    $x = $screen.X + 18
    $y = $screen.Y + 204
    $w = $screen.W - 36
    DrawCard $g $x $y $w 260
    DrawText $g "AI estimate generator" ($x + 28) ($y + 26) 560 48 (New-Font 35 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    DrawText $g "Local mock estimator generates a first pass you can edit before sending." ($x + 28) ($y + 86) ($w - 56) 78 (New-Font 26) $Colors.Muted
    FillRound $g ($x + 28) ($y + 178) ($w - 56) 66 18 $Colors.Primary
    DrawCenteredText $g "Generate Estimate" ($x + 28) ($y + 178) ($w - 56) 66 (New-Font 30 ([System.Drawing.FontStyle]::Bold)) $Colors.Card

    $y += 306
    DrawCard $g $x $y $w 300
    DrawText $g "Suggested client price" ($x + 28) ($y + 28) 520 44 (New-Font 31 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    DrawText $g '$1,962.48' ($x + 28) ($y + 82) 520 76 (New-Font 64 ([System.Drawing.FontStyle]::Bold)) $Colors.PrimaryDark
    DrawPill $g "18 labour hours" ($x + 30) ($y + 182) 250 48 ([System.Drawing.Color]::FromArgb(35, $Colors.Primary.R, $Colors.Primary.G, $Colors.Primary.B)) $Colors.Primary
    DrawPill $g "12% waste" ($x + 300) ($y + 182) 180 48 ([System.Drawing.Color]::FromArgb(35, $Colors.Accent.R, $Colors.Accent.G, $Colors.Accent.B)) $Colors.PrimaryDark
    DrawPill $g "1-3 days" ($x + 500) ($y + 182) 180 48 ([System.Drawing.Color]::FromArgb(35, $Colors.Blue.R, $Colors.Blue.G, $Colors.Blue.B)) $Colors.Blue

    $y += 344
    DrawText $g "Generated line items" $x $y $w 46 (New-Font 34 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    $y += 66
    DrawQuoteRow $g "Remove existing turf" '40 sq m x $3.25 + labour' '$320' $x $y $w
    DrawQuoteRow $g "Sand base" '40 sq m x $9.50 + labour' '$602' $x ($y + 120) $w
    DrawQuoteRow $g "Weed membrane" '40 sq m x $2.10 + labour' '$158' $x ($y + 240) $w
    DrawQuoteRow $g "Supply and install grass" '40 sq m x $24.00 + labour' '$1,229' $x ($y + 360) $w

    $y += 520
    DrawCard $g $x $y $w 250
    DrawText $g "AI upsells" ($x + 28) ($y + 26) 500 42 (New-Font 32 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    DrawText $g "Garden edging" ($x + 44) ($y + 92) 380 36 (New-Font 27) $Colors.Text
    DrawText $g "Weed membrane upgrade" ($x + 44) ($y + 138) 480 36 (New-Font 27) $Colors.Text
    DrawText $g "Annual artificial grass clean" ($x + 44) ($y + 184) 520 36 (New-Font 27) $Colors.Text
}

function DrawQuoteRow($g, [string]$name, [string]$detail, [string]$amount, [float]$x, [float]$y, [float]$w) {
    DrawCard $g $x $y $w 100
    DrawText $g $name ($x + 24) ($y + 18) 520 34 (New-Font 27 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    DrawText $g $detail ($x + 24) ($y + 54) 520 30 (New-Font 22) $Colors.Muted
    DrawText $g $amount ($x + $w - 190) ($y + 30) 150 40 (New-Font 29 ([System.Drawing.FontStyle]::Bold)) $Colors.Text "Far"
}

function DrawBuilder($g, $screen) {
    DrawNav $g $screen "Quote Builder"
    $x = $screen.X + 18
    $y = $screen.Y + 204
    $w = $screen.W - 36
    DrawCard $g $x $y $w 1000
    DrawText $g "Quote builder" ($x + 28) ($y + 26) 500 48 (New-Font 36 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    DrawPill $g "Add" ($x + $w - 142) ($y + 26) 108 48 $Colors.Primary $Colors.Card
    $rowY = $y + 94
    DrawEditableItem $g "Remove existing turf" '$320.00' $x $rowY $w $false
    DrawEditableItem $g "Sand base" '$602.40' $x ($rowY + 122) $w $false
    DrawEditableItem $g "Supply and install artificial grass" '$1,228.80' $x ($rowY + 244) $w $true
    DrawExpandedFields $g $x ($rowY + 350) $w
    $totalY = $y + 740
    FillRound $g ($x + 28) $totalY ($w - 56) 230 20 $Colors.Background
    DrawTotalLine $g "Subtotal" '$2,309.20' ($x + 56) ($totalY + 28) ($w - 112) $false
    DrawTotalLine $g "VAT/tax" '$461.84' ($x + 56) ($totalY + 80) ($w - 112) $false
    DrawTotalLine $g "Discount" '-$230.92' ($x + 56) ($totalY + 132) ($w - 112) $false
    DrawTotalLine $g "Final price" '$2,540.12' ($x + 56) ($totalY + 180) ($w - 112) $true

    $y += 1044
    DrawCard $g $x $y $w 260
    DrawText $g "Status and notes" ($x + 28) ($y + 26) 500 46 (New-Font 34 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    DrawPill $g "Draft" ($x + 28) ($y + 88) 130 48 ([System.Drawing.Color]::FromArgb(35, $Colors.Primary.R, $Colors.Primary.G, $Colors.Primary.B)) $Colors.Primary
    DrawPill $g "Sent" ($x + 180) ($y + 88) 120 48 $Colors.Background $Colors.Muted
    DrawPill $g "Approved" ($x + 322) ($y + 88) 170 48 $Colors.Background $Colors.Muted
    DrawText $g "Confirm drainage and access during site visit." ($x + 28) ($y + 164) ($w - 56) 54 (New-Font 26) $Colors.Muted
}

function DrawEditableItem($g, [string]$name, [string]$amount, [float]$x, [float]$y, [float]$w, [bool]$selected) {
    $bg = if ($selected) { [System.Drawing.Color]::FromArgb(24, $Colors.Primary.R, $Colors.Primary.G, $Colors.Primary.B) } else { $Colors.Background }
    FillRound $g ($x + 28) $y ($w - 56) 96 18 $bg
    DrawText $g $name ($x + 54) ($y + 24) 610 36 (New-Font 27 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    DrawText $g $amount ($x + $w - 260) ($y + 24) 190 36 (New-Font 27 ([System.Drawing.FontStyle]::Bold)) $Colors.Text "Far"
}

function DrawExpandedFields($g, [float]$x, [float]$y, [float]$w) {
    DrawSmallBox $g "Qty" "40" ($x + 54) $y 200
    DrawSmallBox $g "Unit" '$24' ($x + 280) $y 200
    DrawSmallBox $g "Labour" '$360' ($x + 506) $y 200
    DrawSmallBox $g "Markup %" "28" ($x + 732) $y 200
    DrawPill $g "Taxable" ($x + 54) ($y + 116) 170 48 ([System.Drawing.Color]::FromArgb(35, $Colors.Primary.R, $Colors.Primary.G, $Colors.Primary.B)) $Colors.Primary
}

function DrawSmallBox($g, [string]$label, [string]$value, [float]$x, [float]$y, [float]$w) {
    DrawText $g $label $x $y $w 26 (New-Font 21) $Colors.Muted
    FillRound $g $x ($y + 32) $w 58 12 $Colors.Card
    StrokeRound $g $x ($y + 32) $w 58 12 $Colors.Border 2
    DrawCenteredText $g $value $x ($y + 32) $w 58 (New-Font 25 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
}

function DrawTotalLine($g, [string]$label, [string]$amount, [float]$x, [float]$y, [float]$w, [bool]$big) {
    $font = if ($big) { New-Font 34 ([System.Drawing.FontStyle]::Bold) } else { New-Font 26 }
    $color = if ($big) { $Colors.PrimaryDark } else { $Colors.Text }
    DrawText $g $label $x $y 420 42 $font $color
    DrawText $g $amount ($x + $w - 300) $y 300 42 $font $color "Far"
}

function DrawPDF($g, $screen) {
    DrawNav $g $screen "PDF Export"
    $x = $screen.X + 18
    $y = $screen.Y + 204
    $w = $screen.W - 36
    DrawCard $g $x $y $w 1010
    DrawText $g "Landscape Quote" ($x + 54) ($y + 46) 600 66 (New-Font 48 ([System.Drawing.FontStyle]::Bold)) $Colors.Primary
    DrawText $g "Greenline Landscapes" ($x + 56) ($y + 116) 520 40 (New-Font 28 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    DrawText $g "Client" ($x + 56) ($y + 210) 300 40 (New-Font 28 ([System.Drawing.FontStyle]::Bold)) $Colors.PrimaryDark
    DrawText $g "Amelia Carter`namelia@example.com`n42 Willow Lane, Bristol" ($x + 56) ($y + 258) 500 108 (New-Font 23) $Colors.Text
    DrawText $g "Project" ($x + 56) ($y + 398) 300 40 (New-Font 28 ([System.Drawing.FontStyle]::Bold)) $Colors.PrimaryDark
    DrawText $g "Artificial grass - 40 sq m`nEstimated timeline: 1-3 working days" ($x + 56) ($y + 446) 700 80 (New-Font 23) $Colors.Text

    $tableY = $y + 570
    DrawText $g "Line items" ($x + 56) ($tableY - 52) 300 40 (New-Font 28 ([System.Drawing.FontStyle]::Bold)) $Colors.PrimaryDark
    DrawPDFLine $g "Remove existing turf" '$320.00' ($x + 56) $tableY 850
    DrawPDFLine $g "Sand base" '$602.40' ($x + 56) ($tableY + 64) 850
    DrawPDFLine $g "Weed membrane" '$158.00' ($x + 56) ($tableY + 128) 850
    DrawPDFLine $g "Supply and install artificial grass" '$1,228.80' ($x + 56) ($tableY + 192) 850
    DrawTotalLine $g "Total" '$2,540.12' ($x + 56) ($tableY + 300) 850 $true
    DrawText $g "Valid for 14 days" ($x + 56) ($tableY + 390) 400 36 (New-Font 24 ([System.Drawing.FontStyle]::Bold)) $Colors.Primary
    DrawText $g "Signature: __________________________" ($x + 56) ($tableY + 450) 720 40 (New-Font 23) $Colors.Text

    $y += 1056
    DrawCard $g $x $y $w 300
    DrawText $g "Pro plan included" ($x + 28) ($y + 28) 500 50 (New-Font 36 ([System.Drawing.FontStyle]::Bold)) $Colors.Text
    DrawText $g "Unlimited quotes, PDF export, photo uploads, and AI upsell suggestions." ($x + 28) ($y + 88) ($w - 56) 72 (New-Font 27) $Colors.Muted
    FillRound $g ($x + 28) ($y + 190) ($w - 56) 76 18 $Colors.Primary
    DrawCenteredText $g "Export PDF Quote" ($x + 28) ($y + 190) ($w - 56) 76 (New-Font 30 ([System.Drawing.FontStyle]::Bold)) $Colors.Card
}

function DrawPDFLine($g, [string]$name, [string]$amount, [float]$x, [float]$y, [float]$w) {
    DrawText $g $name $x $y 600 38 (New-Font 24) $Colors.Text
    DrawText $g $amount ($x + $w - 250) $y 250 38 (New-Font 24 ([System.Drawing.FontStyle]::Bold)) $Colors.Text "Far"
    $pen = New-Pen $Colors.Border 2
    $g.DrawLine($pen, $x, $y + 48, $x + $w, $y + 48)
    $pen.Dispose()
}

function New-Screenshot([string]$fileName, [string]$headline, [string]$subhead, [scriptblock]$drawContent) {
    $bmp = New-Object System.Drawing.Bitmap $W, $H
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.Clear($Colors.Background)

    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        [System.Drawing.Rectangle]::new(0, 0, $W, $H),
        (ColorFromHex "#F7FAF3"),
        (ColorFromHex "#E8F0E4"),
        90
    )
    $g.FillRectangle($brush, 0, 0, $W, $H)
    $brush.Dispose()

    DrawHeader $g $headline $subhead
    $screen = DrawPhoneShell $g
    & $drawContent $g $screen

    $path = Join-Path $outDir $fileName
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Output $path
}

New-Screenshot "01-dashboard.png" "Track every quote at a glance" "Monitor drafts, approvals, and estimated revenue from one contractor-friendly dashboard." { param($g, $screen) DrawDashboard $g $screen }
New-Screenshot "02-new-estimate.png" "Create a quote in minutes" "Capture the client, site address, project type, measurements, notes, and photos." { param($g, $screen) DrawEstimateForm $g $screen }
New-Screenshot "03-ai-estimate.png" "Generate smart estimates" "Get material line items, labour, waste allowance, timeline, and upsell ideas." { param($g, $screen) DrawAI $g $screen }
New-Screenshot "04-quote-builder.png" "Edit every price detail" "Adjust quantities, labour, markup, VAT, discounts, status, and final quote totals." { param($g, $screen) DrawBuilder $g $screen }
New-Screenshot "05-pdf-export.png" "Send client-ready PDFs" "Export a professional quote with terms, totals, timeline, and signature line." { param($g, $screen) DrawPDF $g $screen }
