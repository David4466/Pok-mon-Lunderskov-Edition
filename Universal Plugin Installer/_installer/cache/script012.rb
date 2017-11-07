#==============================================================================#
#                           Automatic Backup System                            #
#                                  by Marin                                    #
#                                 Version 1.1                                  #
#==============================================================================#
# You can manually make a backup by calling this method.
# In an event this would be :
# Script: backup
def backup(forced = true)
  BackupHandler.new(forced) { |txt| Win32API.SetWindowText(_INTL(txt)) }
end

class BackupHandler
  # This is the folder the backup will be made in. This can be relative
  # (in the folder itself), or a full path (C:\Users\....\Desktop)
  # If the LAST FOLDER does not exist, it will be created. The rest has to be
  # existent and valid.
  # Examples:
  # BACKUP_TO = "C:/Users/MyUser/Desktop/MyBackupFolder"
  # BACKUP_TO = "Game Backups"
  BACKUP_TO = "Backups"
  
  # Whatever is in this array will determine what will be backed up whenever a
  # backup is being made.
  # Possible values:
  # :MAPS
  # :SCRIPTS
  # :PBS
  # :GRAPHICS_PICTURES
  # :GRAPHICS_AUTOTILES
  # :GRAPHICS_TILESETS
  
  # The following can be used too, but they may cause a bit of delay.
  # :AUDIO_BGM
  # :AUDIO_BGS
  # :AUDIO_ME
  
  # The following can be used too, but they will likely cause a lot of lag and
  # have the potential to crash the game (this does not/should not have any
  # consequences; it will just mean the backup failed (Script is hanging))
  # If it does hang, it has likely still properly copied all Icon/AudioSE files.
  # These two are done last, meaning that all other backups will have been
  # successfully made.
  # :AUDIO_SE
  # :ICONS
  
  SHOULD_BACKUP = [
    :MAPS,
    :SCRIPTS,
    :PBS,
    :AUDIO_BGM,
    :AUDIO_BGS,
    :AUDIO_ME,
    :AUDIO_SE,
    :GRAPHICS_PICTURES,
    :GRAPHICS_AUTOTILES,
    :GRAPHICS_TILESETS,
    :ICONS
  ]
  
  def initialize(forced)
    return if !$DEBUG
    @path = BACKUP_TO
    @make_backup = shouldBackup
    @make_backup = true if forced
    if @make_backup
      yield _INTL("Clearing old backup folders...")
      empty("Data")
      empty("PBS")
      empty("Audio")
      empty("Graphics")
      if SHOULD_BACKUP.include?(:SCRIPTS)
        yield _INTL("Creating backups of Data/Scripts.rxdata...")
        backupScripts
      end
      if SHOULD_BACKUP.include?(:MAPS)
        yield _INTL("Creating backups of Data/MapXXX.rxdata...")
        backupMaps
      end
      if SHOULD_BACKUP.include?(:PBS)
        yield _INTL("Creating backups of PBS...")
        backupPBS
      end
      if SHOULD_BACKUP.include?(:AUDIO_BGM)
        yield _INTL("Creating backups of Audio/BGM...")
        backupRec("Audio", "BGM")
      end
      if SHOULD_BACKUP.include?(:AUDIO_BGS)
        yield _INTL("Creating backups of Audio/BGS...")
        backupRec("Audio", "BGS")
      end
      if SHOULD_BACKUP.include?(:AUDIO_ME)
        yield _INTL("Creating backups of Audio/ME...")
        backupRec("Audio", "ME")
      end
      if SHOULD_BACKUP.include?(:AUDIO_SE)
        yield _INTL("Creating backups of Audio/SE...")
        backupRec("Audio", "SE")
      end
      if SHOULD_BACKUP.include?(:GRAPHICS_PICTURES)
        yield _INTL("Creating backups of Graphics/Pictures...")
        backupRec("Graphics", "Pictures")
      end
      if SHOULD_BACKUP.include?(:GRAPHICS_AUTOTILES)
        yield _INTL("Creating backups of Graphics/Autotiles...")
        backupRec("Graphics", "Autotiles")
      end
      if SHOULD_BACKUP.include?(:GRAPHICS_TILESETS)
        yield _INTL("Creating backups of Graphics/Tilesets...")
        backupRec("Graphics", "Tilesets")
      end
      if SHOULD_BACKUP.include?(:ICONS)
        yield _INTL("Creating backups of Graphics/Icons...")
        backupRec("Graphics", "Icons")
      end
    end
  end  
  
  def backupScripts
    copy("Data/Scripts.rxdata", @path+"/Data/Scripts.rxdata")
  end
  
  def backupMaps
    Dir.foreach("Data") do |f|
      next if f == '.' || f == '..'
      if f[0..2] == 'Map' # Including MapInfos.rxdata as well
        copy("Data/#{f}", @path+"/Data/#{f}")
      end
    end
  end
  
  def backupPBS
    Dir.foreach("PBS") do |f|
      next if f == '.' || f == '..'
      copy("PBS/#{f}", @path+"/PBS/#{f}")
    end
  end
  
  # Recursive and dynamic
  def backupRec(one, two)
    return false if !File.directory?(one)
    if !File.directory?(@path+"/"+one)
      Dir.mkdir(@path+"/"+one)
    end
    empty(one+"/"+two)
    Dir.glob("#{one}/#{two}/**/*") do |f|
      next if !File.directory?(f)
      if !File.directory?("#{@path}/#{f}")
        Dir.mkdir("#{@path}/#{f}")
      end
    end
    Dir.glob("#{one}/#{two}/**/*") do |f|
      next if File.directory?(f)
      copy(f, "#{@path}/#{f}")
    end
  end
  
  # Determines if it should update again
  def shouldBackup
    ret = false
    ensureExists
    if !File.file?(@path+"/last.txt")
      f = File.open(@path+"/last.txt", "w")
      f.write(getTime)
      f.close
      ret = true
    else
      f = File.open(@path+"/last.txt")
      d = f.read
      f.close
      old = d.split('-').map { |e| e.to_i }
      old.map
      if old.size != 3
        ret = false
      else
        new = getTime.split('-').map { |e| e.to_i }
        ret = (new[2] > old[2] || new[1] > old[1] || new[0] > old[0])
      end
      if ret
        File.truncate(@path+"/last.txt", 0)
        file = File.open(@path+"/last.txt", "w")
        file.write(getTime)
        file.close
      end
    end
    return ret
  end
  
  def getTime
    t = Time.now
    return "#{t.day}-#{t.month}-#{t.year.to_s[2..3]}"
  end
  
  def ensureExists
    if !File.directory?(@path)
      Dir.mkdir(@path)
    end
  end
  
  def copy(src, dest)
    File.open(src, 'rb') do |r|
      File.open(dest, 'wb') do |w|
        while s = r.read(4096)
          w.write(s)
        end
      end
    end
  end
  
  def empty(path)
    return if !File.directory?(path)
    ensureExists
    if !File.directory?("#{@path}/#{path}")
      Dir.mkdir("#{@path}/#{path}")
    else
      recursiveDelete(@path+"/"+path) # Clear all files first
      recursiveDelete(@path+"/"+path, true) # Then all empty directories
    end
  end
  
  def recursiveDelete(file, delete_dirs = false)
    Dir.glob("#{file}/**/*") do |f|
      if File.directory?(f)
        if delete_dirs
          if Dir.entries(f).size > 2
            recursiveDelete(f, true)
            Dir.delete(f) rescue nil
          else
            Dir.delete(f)
          end
        else
          recursiveDelete(f, delete_dirs)
        end
      else
        File.delete(f)
      end
    end
  end
end

backup(false) # Call the method; determines if it actually SHOULD backup inside the call