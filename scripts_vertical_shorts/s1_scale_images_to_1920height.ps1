#Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
#
# Use Imagemagick to scale images to a height of 1920
#
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

$files = Get-ChildItem ".\*.jpg"
$filenumber = 1
	
	ForEach ($file in $files){
	
	Write-host $file  $file.Name.Length
	#convert -resize x1080 {from_path} {to_path}
	# with path: FullName.Length
	
		if ($file.Name.Length -gt 5) # we don't want to operate on our short number files
		{
		$cmd = "magick $( $file) -resize x1920  $($scriptPath)\$( $filenumber).jpg"
		
		Write-host  $cmd
		$filenumber += 1
		Invoke-Expression $cmd
		#break
		}
		
	}