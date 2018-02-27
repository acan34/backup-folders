function backupFiles(){
    # Set wether the backup as catch an error or if it has completed successfully
    $status = "completed"

    # Set the date to the format we want
    $date = "$(Get-Date -f yyyy-MM-dd@HH)h$(Get-Date -f mm)m$(Get-Date -f ss)s"

    <#
    Set the paths        
      The source path is pointing to the files/folders to be backed up
      The destination path is pointing to the destination of the backup with the archive name
      The date after the name of the backup archive is to insure there will never be duplicates as well as keep the backups organized
    #>
    $sourcePath = "C:\YOUR_SOURCE_PATH" # i.e. C:\Users\USERNAME\Desktop
    $destinationPath = "C:\YOUR_DESTINATION_PATH\THE_NAME_OF_YOUR_BACKUP_$date.zip" # i.e. C:\Users\USERNAME\Documents\desktop_backup_$date.zip
      
    # Create the archive (.zip) file from everything in the source directory and saves it into the destination folder
    try{
        Add-Type -assembly "system.io.compression.filesystem"
        [io.compression.zipfile]::CreateFromDirectory($sourcePath, $destinationPath)
    }
    # IOException is triggered if at least one of the files from the source path is currently in use
    # Show a message box that explains it
    catch [System.IO.IOException]{
        $status = "interrupted (IO)"

        $Message = "$($Error[0].Exception.Message)`n`nIOException`nEither one of the file in the source directory is in use or the specified path has changed.`n`nClose all the source directory files that are opened and try again. If it doesn't work, please verify the source directory value as well as the destination directory value."
        $Title = "An IO error occured"
        $Btn = 1 # OKCancel
        $Icon = 64 # IconInformation

        messageBox -Message $Message -Title $Title -Btn $Btn -Icon $Icon

        # Delete the partial file that has started to be stored since it's not complete
        Remove-Item $destinationPath
    }    
    catch{
        $status = "interrupted (Unhandled)"        

        $Message = "System.Exception on:- $(Get-Date -f yyyy-MM-dd@HH:mm:ss) `n$($Error[0].Exception.Message)"
        $Title = "An unhandled error occured"
        $Btn = 1 # OKCancel
        $Icon = 64 # IconInformation

        messageBox -Message $Message -Title $Title -Btn $Btn -Icon $Icon
    }
    finally
    {
        Write-Host "Backup was $status on : $(Get-Date -f yyyy-MM-dd@HH:mm:ss)"
        Pause
    }

}

function messageBox($Message,$Title,$Btn,$Icon){
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $Response = [System.Windows.Forms.MessageBox]::Show($Message, $Title , $Btn, $Icon)
}

#Launch backupFiles
backupFiles