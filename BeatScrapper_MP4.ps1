#Installation de FFmpeg s'il ne l'est pas
winget install ffmpeg

#Chemin d'accès des maps BS
$BSPath = "C:\Program Files (x86)\Steam\steamapps\common\Beat Saber\Beat Saber_Data\CustomLevels"

#Fichier où les musiques seront transferées
$DestPath = "C:\Users\Maxime\Downloads\test"

#Listage des maps
Get-ChildItem -LiteralPath $BSPath -Directory | ForEach-Object{
    #Chemin de la map
    $LevelPath = Join-Path -Path $BSPath -ChildPath $_.Name

    #Réinitialisation des variables
    $SongName = $null
    $SongExtension = $null
    $ImageName = $null
    $ImageExtension = $null

    #Listage du contenu de la map
    Get-ChildItem -LiteralPath $LevelPath | ForEach-Object {
        #Récupération du nom et de l'extension de la musique (format egg)
        if ($_.Extension -ieq ".egg" || $_.Extension -ieq ".wav") {
            $SongName = $_.Name
            $SongExtension = $_.Extension
        }

        # Récupération du nom et de l'extension de l'image (formats jpg, png, jpeg, jfif)
        if ($_.Extension -match "^\.(jpg|png|jpeg|jfif)$") {
            $ImageName = $_.Name
            $ImageExtension = $_.Extension
        }
    }

    #Copie de la musique
    if ($SongName -eq $null) {
        #Chemin complet vers la musique
        $SongPath = Join-Path -Path $LevelPath -ChildPath $SongName

        Write-Output "Pas de musique pour : "$SongPath
    }
    else {
        if($ImageName -eq $null){
            #Nom de la musique (avec format)
            $DestSongName = $_.Name+$SongExtension

            #Chemin complet vers la musique
            $SongPath = Join-Path -Path $LevelPath -ChildPath $SongName

            #Chemin de destination complet vers la musique
            $SongDestPath = Join-Path -Path $DestPath -ChildPath $DestSongName

            #On la copie au format d'origine
            Copy-Item -Path $SongPath -Destination $SongDestPath -Force
        }
        else {
            #Nom de la musique (avec format)
            $DestSongName = $_.Name+".mp4"

            #Chemin complet vers la musique
            $SongPath = Join-Path -Path $LevelPath -ChildPath $SongName

            #Chemin de destination complet vers la musique
            $SongDestPath = Join-Path -Path $DestPath -ChildPath $DestSongName

            #Chemin de la cover
            $CoverPath = Join-Path -Path $LevelPath -ChildPath $ImageName

            #On la copie au format mp4 avec la cover
            # Commande FFmpeg pour créer un fichier MP4
            $FFmpegCommand = "ffmpeg -y -loop 1 -framerate 1 -i `"$CoverPath`" -i `"$SongPath`" -c:v libx264 -preset ultrafast -c:a aac -b:a 320k -shortest -movflags +faststart `"$SongDestPath`""

            try {
                Invoke-Expression $FFmpegCommand
            } catch {
                Write-Warning "Erreur lors de la création du fichier $SongName : $_"

                #Nom de la musique (avec format)
                $DestSongName = $_.Name+$SongExtension
    
                #Chemin complet vers la musique
                $SongPath = Join-Path -Path $LevelPath -ChildPath $SongName
    
                #Chemin de destination complet vers la musique
                $SongDestPath = Join-Path -Path $DestPath -ChildPath $DestSongName
    
                #On la copie au format d'origine
                Copy-Item -Path $SongPath -Destination $SongDestPath -Force
            }
        }
    }
}

Write-Host "En cas d'erreur de FFmpeg, merci de fermer et rouvrir powershell"
