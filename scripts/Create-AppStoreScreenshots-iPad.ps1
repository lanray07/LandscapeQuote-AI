Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root "fastlane\screenshots\en-US-iPad-13-inch"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$W = 2048
$H = 2732

function C([string]$hex) {
    $h = $hex.TrimStart("#")
    return [System.Drawing.Color]::FromArgb(255, [Convert]::ToInt32($h.Substring(0,2),16), [Convert]::ToInt32($h.Substring(2,2),16), [Convert]::ToInt32($h.Substring(4,2),16))
}

$Primary = C "#216B40"
$Dark = C "#103F28"
$Accent = C "#D9AA4A"
$Bg = C "#F3F7F0"
$Card = C "#FFFFFF"
$Text = C "#1A211B"
$Muted = C "#5B6B5C"
$Border = C "#DDE5DA"
$Blue = C "#2B6ED9"
$Orange = C "#D9822B"

function Font([float]$size, [System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Regular) {
    return New-Object System.Drawing.Font("Segoe UI", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

function Brush($color) { New-Object System.Drawing.SolidBrush($color) }
function Pen($color, [float]$width = 1) { New-Object System.Drawing.Pen($color, $width) }

function RoundPath([System.Drawing.RectangleF]$rect, [float]$radius) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $radius * 2
    $p.AddArc($rect.X, $rect.Y, $d, $d, 180, 90)
    $p.AddArc($rect.Right - $d, $rect.Y, $d, $d, 270, 90)
    $p.AddArc($rect.Right - $d, $rect.Bottom - $d, $d, $d, 0, 90)
    $p.AddArc($rect.X, $rect.Bottom - $d, $d, $d, 90, 90)
    $p.CloseFigure()
    return $p
}

function FillRound($g, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r, $color) {
    $path = RoundPath ([System.Drawing.RectangleF]::new($x, $y, $w, $h)) $r
    $b = Brush $color
    $g.FillPath($b, $path)
    $b.Dispose()
    $path.Dispose()
}

function StrokeRound($g, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r, $color, [float]$line = 3) {
    $path = RoundPath ([System.Drawing.RectangleF]::new($x, $y, $w, $h)) $r
    $p = Pen $color $line
    $g.DrawPath($p, $path)
    $p.Dispose()
    $path.Dispose()
}

function DrawText($g, [string]$s, [float]$x, [float]$y, [float]$w, [float]$h, $font, $color, [string]$align = "Near") {
    $b = Brush $color
    $f = New-Object System.Drawing.StringFormat
    $f.Alignment = [System.Drawing.StringAlignment]::$align
    $f.LineAlignment = [System.Drawing.StringAlignment]::Near
    $f.Trimming = [System.Drawing.StringTrimming]::EllipsisWord
    $g.DrawString($s, $font, $b, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $f)
    $f.Dispose()
    $b.Dispose()
}

function DrawCenter($g, [string]$s, [float]$x, [float]$y, [float]$w, [float]$h, $font, $color) {
    $b = Brush $color
    $f = New-Object System.Drawing.StringFormat
    $f.Alignment = [System.Drawing.StringAlignment]::Center
    $f.LineAlignment = [System.Drawing.StringAlignment]::Center
    $f.Trimming = [System.Drawing.StringTrimming]::EllipsisWord
    $g.DrawString($s, $font, $b, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $f)
    $f.Dispose()
    $b.Dispose()
}

function Card($g, [float]$x, [float]$y, [float]$w, [float]$h) {
    FillRound $g $x $y $w $h 24 $Card
    StrokeRound $g $x $y $w $h 24 $Border 3
}

function Pill($g, [string]$s, [float]$x, [float]$y, [float]$w, [float]$h, $bg, $fg) {
    FillRound $g $x $y $w $h ($h / 2) $bg
    DrawCenter $g $s $x $y $w $h (Font 34 ([System.Drawing.FontStyle]::Bold)) $fg
}

function Header($g, [string]$title, [string]$subtitle) {
    DrawText $g $title 140 100 1760 130 (Font 92 ([System.Drawing.FontStyle]::Bold)) $Dark
    DrawText $g $subtitle 142 265 1680 150 (Font 46) $Muted
}

function Tablet($g) {
    $x = 140
    $y = 500
    $w = 1768
    $h = 2040
    FillRound $g $x $y $w $h 72 (C "#111713")
    FillRound $g ($x + 28) ($y + 28) ($w - 56) ($h - 56) 48 $Bg
    FillRound $g ($x + 794) ($y + 44) 180 20 10 (C "#111713")
    return @{ X = $x + 70; Y = $y + 96; W = $w - 140; H = $h - 150 }
}

function Nav($g, $s, [string]$sub = "") {
    DrawText $g "9:41" ($s.X + 18) $s.Y 140 42 (Font 32 ([System.Drawing.FontStyle]::Bold)) $Text
    DrawText $g "LandscapeQuote AI" ($s.X + 18) ($s.Y + 85) 720 70 (Font 52 ([System.Drawing.FontStyle]::Bold)) $Text
    if ($sub) { DrawText $g $sub ($s.X + 20) ($s.Y + 150) 520 44 (Font 32) $Muted }
}

function Metric($g, [string]$name, [string]$value, [float]$x, [float]$y, [float]$w, $tint) {
    Card $g $x $y $w 220
    FillRound $g ($x + 28) ($y + 28) 78 78 18 ([System.Drawing.Color]::FromArgb(35, $tint.R, $tint.G, $tint.B))
    DrawCenter $g "+" ($x + 28) ($y + 18) 78 78 (Font 48 ([System.Drawing.FontStyle]::Bold)) $tint
    DrawText $g $value ($x + 34) ($y + 122) ($w - 68) 52 (Font 48 ([System.Drawing.FontStyle]::Bold)) $Text
    DrawText $g $name ($x + 34) ($y + 174) ($w - 68) 36 (Font 28) $Muted
}

function Row($g, [string]$title, [string]$sub, [string]$right, [float]$x, [float]$y, [float]$w) {
    Card $g $x $y $w 118
    FillRound $g ($x + 24) ($y + 22) 74 74 18 ([System.Drawing.Color]::FromArgb(35, $Primary.R, $Primary.G, $Primary.B))
    DrawCenter $g "LQ" ($x + 24) ($y + 24) 74 74 (Font 26 ([System.Drawing.FontStyle]::Bold)) $Primary
    DrawText $g $title ($x + 120) ($y + 20) 620 38 (Font 32 ([System.Drawing.FontStyle]::Bold)) $Text
    DrawText $g $sub ($x + 120) ($y + 62) 620 34 (Font 26) $Muted
    DrawText $g $right ($x + $w - 280) ($y + 36) 230 42 (Font 34 ([System.Drawing.FontStyle]::Bold)) $Text "Far"
}

function Dashboard($g, $s) {
    Nav $g $s
    $x = $s.X + 20; $y = $s.Y + 205; $w = $s.W - 40
    Card $g $x $y $w 180
    DrawText $g "Turn garden photos and rough measurements into a professional quote in minutes." ($x + 34) ($y + 30) ($w - 68) 74 (Font 36 ([System.Drawing.FontStyle]::Bold)) $Text
    Pill $g "3 free quotes left" ($x + 34) ($y + 116) 300 48 ([System.Drawing.Color]::FromArgb(35, $Primary.R, $Primary.G, $Primary.B)) $Primary
    Pill $g "Unlimited with Pro" ($x + $w - 420) ($y + 116) 370 48 ([System.Drawing.Color]::FromArgb(35, $Accent.R, $Accent.G, $Accent.B)) $Dark
    $y += 225
    $mw = ($w - 54) / 4
    Metric $g "Total quotes" "24" $x $y $mw $Primary
    Metric $g "Draft quotes" "6" ($x + $mw + 18) $y $mw $Orange
    Metric $g "Approved" "11" ($x + ($mw + 18) * 2) $y $mw (C "#2FA05B")
    Metric $g "Revenue" '$18.4k' ($x + ($mw + 18) * 3) $y $mw $Accent
    $y += 275
    Card $g $x $y $w 320
    DrawText $g "Ready for the next job?" ($x + 36) ($y + 36) 700 58 (Font 44 ([System.Drawing.FontStyle]::Bold)) $Text
    DrawText $g "Capture details, generate a first estimate, then tune the line items before saving." ($x + 36) ($y + 105) 1250 86 (Font 32) $Muted
    FillRound $g ($x + 36) ($y + 210) ($w - 72) 82 18 $Primary
    DrawCenter $g "Create New Estimate" ($x + 36) ($y + 210) ($w - 72) 82 (Font 34 ([System.Drawing.FontStyle]::Bold)) $Card
    $y += 375
    DrawText $g "Recent quotes" $x $y 600 50 (Font 42 ([System.Drawing.FontStyle]::Bold)) $Text
    Row $g "Amelia Carter" "Artificial grass" '$1,962' $x ($y + 70) $w
    Row $g "Oakfield Nursery" "Garden clearance" '$740' $x ($y + 210) $w
    Row $g "James Patel" "Patio paving" '$3,418' $x ($y + 350) $w
}

function Field($g, [string]$label, [string]$value, [float]$x, [float]$y, [float]$w) {
    DrawText $g $label $x $y $w 30 (Font 24) $Muted
    FillRound $g $x ($y + 36) $w 60 14 $Bg
    DrawText $g $value ($x + 18) ($y + 48) ($w - 36) 38 (Font 28) $Text
}

function Estimate($g, $s) {
    Nav $g $s "New Estimate"
    $x = $s.X + 20; $y = $s.Y + 220; $w = $s.W - 40
    Card $g $x $y $w 315
    DrawText $g "Client details" ($x + 34) ($y + 28) 520 52 (Font 40 ([System.Drawing.FontStyle]::Bold)) $Text
    Field $g "Client name" "Amelia Carter" ($x + 34) ($y + 92) 470
    Field $g "Phone or email" "amelia@example.com" ($x + 540) ($y + 92) 470
    Field $g "Site address" "42 Willow Lane, Bristol" ($x + 1046) ($y + 92) 470
    Field $g "Manual notes" "Rear garden with side access" ($x + 34) ($y + 190) ($w - 68)
    $y += 360
    Card $g $x $y $w 360
    DrawText $g "Project type" ($x + 34) ($y + 28) 500 52 (Font 40 ([System.Drawing.FontStyle]::Bold)) $Text
    $types = @("Lawn mowing", "Artificial grass", "Patio paving", "Garden clearance", "Fencing", "Decking", "Hedge trimming", "Drainage", "Full garden makeover")
    for ($i=0; $i -lt $types.Length; $i++) {
        $col = $i % 3; $row = [Math]::Floor($i / 3)
        $bx = $x + 34 + ($col * 500); $by = $y + 100 + ($row * 72)
        $sel = $types[$i] -eq "Artificial grass"
        FillRound $g $bx $by 460 54 16 $(if($sel){$Primary}else{$Bg})
        DrawCenter $g $types[$i] $bx $by 460 54 (Font 28 ([System.Drawing.FontStyle]::Bold)) $(if($sel){$Card}else{$Text})
    }
    $y += 405
    Card $g $x $y $w 270
    DrawText $g "Measurements and photos" ($x + 34) ($y + 28) 720 52 (Font 40 ([System.Drawing.FontStyle]::Bold)) $Text
    Field $g "Length" "8 m" ($x + 34) ($y + 102) 330
    Field $g "Width" "5 m" ($x + 400) ($y + 102) 330
    Field $g "Area" "40 sq m" ($x + 766) ($y + 102) 330
    Pill $g "Photo Library" ($x + 1132) ($y + 138) 240 58 $Bg $Primary
    Pill $g "Camera" ($x + 1390) ($y + 138) 150 58 $Bg $Primary
}

function QuoteRow($g, [string]$title, [string]$sub, [string]$price, [float]$x, [float]$y, [float]$w) {
    Card $g $x $y $w 112
    DrawText $g $title ($x + 28) ($y + 20) 760 38 (Font 31 ([System.Drawing.FontStyle]::Bold)) $Text
    DrawText $g $sub ($x + 28) ($y + 62) 760 34 (Font 25) $Muted
    DrawText $g $price ($x + $w - 260) ($y + 34) 220 44 (Font 34 ([System.Drawing.FontStyle]::Bold)) $Text "Far"
}

function AI($g, $s) {
    Nav $g $s "AI Estimate"
    $x = $s.X + 20; $y = $s.Y + 220; $w = $s.W - 40
    Card $g $x $y 720 290
    DrawText $g "AI estimate generator" ($x + 34) ($y + 34) 620 52 (Font 40 ([System.Drawing.FontStyle]::Bold)) $Text
    DrawText $g "Generate a first pass you can edit before sending." ($x + 34) ($y + 98) 620 72 (Font 30) $Muted
    FillRound $g ($x + 34) ($y + 195) 620 70 18 $Primary
    DrawCenter $g "Generate Estimate" ($x + 34) ($y + 195) 620 70 (Font 32 ([System.Drawing.FontStyle]::Bold)) $Card
    Card $g ($x + 760) $y ($w - 760) 290
    DrawText $g "Suggested client price" ($x + 798) ($y + 34) 620 44 (Font 34 ([System.Drawing.FontStyle]::Bold)) $Text
    DrawText $g '$1,962.48' ($x + 798) ($y + 88) 620 86 (Font 72 ([System.Drawing.FontStyle]::Bold)) $Dark
    Pill $g "18 labour hours" ($x + 798) ($y + 198) 275 50 ([System.Drawing.Color]::FromArgb(35, $Primary.R, $Primary.G, $Primary.B)) $Primary
    Pill $g "12% waste" ($x + 1090) ($y + 198) 200 50 ([System.Drawing.Color]::FromArgb(35, $Accent.R, $Accent.G, $Accent.B)) $Dark
    Pill $g "1-3 days" ($x + 1310) ($y + 198) 180 50 ([System.Drawing.Color]::FromArgb(35, $Blue.R, $Blue.G, $Blue.B)) $Blue
    $y += 345
    DrawText $g "Generated line items" $x $y 700 50 (Font 42 ([System.Drawing.FontStyle]::Bold)) $Text
    QuoteRow $g "Remove existing turf" '40 sq m x $3.25 + labour' '$320' $x ($y + 70) $w
    QuoteRow $g "Sand base" '40 sq m x $9.50 + labour' '$602' $x ($y + 205) $w
    QuoteRow $g "Weed membrane" '40 sq m x $2.10 + labour' '$158' $x ($y + 340) $w
    QuoteRow $g "Supply and install artificial grass" '40 sq m x $24.00 + labour' '$1,229' $x ($y + 475) $w
    $y += 650
    Card $g $x $y $w 220
    DrawText $g "AI upsells" ($x + 34) ($y + 30) 500 48 (Font 40 ([System.Drawing.FontStyle]::Bold)) $Text
    DrawText $g "Garden edging     Weed membrane upgrade     Annual artificial grass clean" ($x + 34) ($y + 100) ($w - 68) 48 (Font 32) $Text
}

function Builder($g, $s) {
    Nav $g $s "Quote Builder"
    $x = $s.X + 20; $y = $s.Y + 220; $w = $s.W - 40
    Card $g $x $y $w 780
    DrawText $g "Quote builder" ($x + 34) ($y + 32) 520 54 (Font 42 ([System.Drawing.FontStyle]::Bold)) $Text
    Pill $g "Add" ($x + $w - 150) ($y + 34) 110 50 $Primary $Card
    QuoteRow $g "Remove existing turf" "Editable quantity, labour, unit cost, and markup" '$320.00' ($x + 34) ($y + 110) ($w - 68)
    QuoteRow $g "Sand base" "Editable quantity, labour, unit cost, and markup" '$602.40' ($x + 34) ($y + 245) ($w - 68)
    QuoteRow $g "Supply and install artificial grass" "Qty 40, unit $24, labour $360, markup 28%" '$1,228.80' ($x + 34) ($y + 380) ($w - 68)
    FillRound $g ($x + 34) ($y + 550) ($w - 68) 175 24 $Bg
    DrawText $g "Subtotal" ($x + 70) ($y + 580) 500 38 (Font 30) $Text
    DrawText $g '$2,309.20' ($x + $w - 360) ($y + 580) 290 38 (Font 30) $Text "Far"
    DrawText $g "VAT/tax" ($x + 70) ($y + 630) 500 38 (Font 30) $Text
    DrawText $g '$461.84' ($x + $w - 360) ($y + 630) 290 38 (Font 30) $Text "Far"
    DrawText $g "Final price" ($x + 70) ($y + 680) 500 46 (Font 38 ([System.Drawing.FontStyle]::Bold)) $Dark
    DrawText $g '$2,540.12' ($x + $w - 360) ($y + 680) 290 46 (Font 38 ([System.Drawing.FontStyle]::Bold)) $Dark "Far"
    $y += 835
    Card $g $x $y $w 230
    DrawText $g "Status and contractor notes" ($x + 34) ($y + 34) 760 52 (Font 40 ([System.Drawing.FontStyle]::Bold)) $Text
    Pill $g "Draft" ($x + 34) ($y + 105) 130 50 ([System.Drawing.Color]::FromArgb(35, $Primary.R, $Primary.G, $Primary.B)) $Primary
    Pill $g "Sent" ($x + 190) ($y + 105) 120 50 $Bg $Muted
    Pill $g "Approved" ($x + 335) ($y + 105) 190 50 $Bg $Muted
    DrawText $g "Confirm drainage and access during site visit." ($x + 34) ($y + 170) 880 40 (Font 30) $Muted
}

function PDF($g, $s) {
    Nav $g $s "PDF Export"
    $x = $s.X + 20; $y = $s.Y + 220; $w = $s.W - 40
    Card $g $x $y 980 960
    DrawText $g "Landscape Quote" ($x + 70) ($y + 60) 700 70 (Font 56 ([System.Drawing.FontStyle]::Bold)) $Primary
    DrawText $g "Greenline Landscapes" ($x + 72) ($y + 135) 540 42 (Font 34 ([System.Drawing.FontStyle]::Bold)) $Text
    DrawText $g "Client" ($x + 72) ($y + 250) 300 44 (Font 34 ([System.Drawing.FontStyle]::Bold)) $Dark
    DrawText $g "Amelia Carter`namelia@example.com`n42 Willow Lane, Bristol" ($x + 72) ($y + 304) 520 120 (Font 29) $Text
    DrawText $g "Project" ($x + 72) ($y + 465) 300 44 (Font 34 ([System.Drawing.FontStyle]::Bold)) $Dark
    DrawText $g "Artificial grass - 40 sq m`nEstimated timeline: 1-3 working days" ($x + 72) ($y + 520) 760 88 (Font 29) $Text
    DrawText $g "Line items" ($x + 72) ($y + 635) 300 44 (Font 34 ([System.Drawing.FontStyle]::Bold)) $Dark
    DrawText $g "Remove existing turf                                  $320.00`nSand base                                                 $602.40`nWeed membrane                                      $158.00`nSupply and install artificial grass          $1,228.80" ($x + 72) ($y + 695) 820 170 (Font 28) $Text
    DrawText $g "Total" ($x + 72) ($y + 880) 300 48 (Font 40 ([System.Drawing.FontStyle]::Bold)) $Dark
    DrawText $g '$2,540.12' ($x + 620) ($y + 880) 260 48 (Font 40 ([System.Drawing.FontStyle]::Bold)) $Dark "Far"
    Card $g ($x + 1030) $y ($w - 1030) 460
    DrawText $g "Pro plan included" ($x + 1070) ($y + 50) 560 56 (Font 46 ([System.Drawing.FontStyle]::Bold)) $Text
    DrawText $g "Unlimited quotes, PDF export, photo uploads, and AI upsell suggestions." ($x + 1070) ($y + 125) 560 110 (Font 32) $Muted
    FillRound $g ($x + 1070) ($y + 300) 560 82 18 $Primary
    DrawCenter $g "Export PDF Quote" ($x + 1070) ($y + 300) 560 82 (Font 34 ([System.Drawing.FontStyle]::Bold)) $Card
}

function New-Shot([string]$file, [string]$title, [string]$subtitle, [scriptblock]$draw) {
    $bmp = New-Object System.Drawing.Bitmap $W, $H
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.Clear($Bg)
    $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush([System.Drawing.Rectangle]::new(0,0,$W,$H), (C "#F7FAF3"), (C "#E7F0E4"), 90)
    $g.FillRectangle($grad, 0, 0, $W, $H)
    $grad.Dispose()
    Header $g $title $subtitle
    $s = Tablet $g
    & $draw $g $s
    $path = Join-Path $outDir $file
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Output $path
}

New-Shot "01-dashboard.png" "Track every quote at a glance" "Monitor drafts, approvals, and estimated revenue from one contractor-friendly dashboard." { param($g,$s) Dashboard $g $s }
New-Shot "02-new-estimate.png" "Create a quote in minutes" "Capture the client, site address, project type, measurements, notes, and photos." { param($g,$s) Estimate $g $s }
New-Shot "03-ai-estimate.png" "Generate smart estimates" "Get material line items, labour, waste allowance, timeline, and upsell ideas." { param($g,$s) AI $g $s }
New-Shot "04-quote-builder.png" "Edit every price detail" "Adjust quantities, labour, markup, VAT, discounts, status, and final quote totals." { param($g,$s) Builder $g $s }
New-Shot "05-pdf-export.png" "Send client-ready PDFs" "Export a professional quote with terms, totals, timeline, and signature line." { param($g,$s) PDF $g $s }
