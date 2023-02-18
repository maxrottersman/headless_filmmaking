#Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
Add-Type -AssemblyName System.Drawing
#
$argImageCount = 7
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
# Use Imagemagick to scale images to a height of 1920 and 1080
#
# file name format: Abstract_image_262 (1 to 2,781)
# Very large
# D:\ContentResources\backgrounds\Abstract_gallery_vlarge
$artwork_ai_path = "D:\ContentResources\backgrounds\Abstract1920h_min\"
$artwork_ai_prefix = "Abstract_image_"

$artwork_ai_1080 = $scriptPath + "\artwork_ai_1080\" 
$artwork_ai_1920 = $scriptPath + "\artwork_ai_1920\" 
#Write-Host $artwork_ai_1080 ;break

	for ($x=1; $x -le $argImageCount; $x=$x+1)
	{
				
		$artwork_ai_num = Get-Random -Minimum 1 -Maximum 2781
				
		$file = $artwork_ai_path + $artwork_ai_prefix + $artwork_ai_num + ".jpg"
		#$img = [System.Drawing.Image]::FromFile("$file") 
		#$dimensions = "$($img.Width) x $($img.Height)"
		#Write-Host $dimensions
		
		$cmd = "magick $( $file) -resize x1920  $artwork_ai_1920$($x).jpg"
		Write-Host $cmd
		Invoke-Expression $cmd
		
		$cmd = "magick $( $file) -resize x1080  $artwork_ai_1080$($x).jpg"
		Invoke-Expression $cmd
		#break
	}

