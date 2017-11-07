# This is what actually makes the game dual-screen. DEFAULTSCREENHEIGHT still
# has to be doubled (384 * 2) = 768. Don't change this code below.
if DUAL_SCREEN
  module Graphics
    @@height = DEFAULTSCREENHEIGHT / 2
  end
end

class PokeBattle_Trainer
  attr_accessor :poketch
  attr_accessor :poketch_last_app
  attr_writer :poketch_app_access
  
  alias poketch_init initialize
  def initialize(name, trainertype)
    poketch_init(name, trainertype)
    @poketch = false
    @poketch_last_app = PoketchClock
    @poketch_app_access = []
  end
  
  def poketch_app_access
    @poketch_app_access = [] if !@poketch_app_access
    return @poketch_app_access
  end
end

# Converts integers to string with N digits. Examples:
#  -> pbFormat(19,4) => "0019"
#  -> pbFormat(7) => "007"
#  -> pbFormat(321,3) => "321"
def pbFormat(int, n = 3)
  strInt = int.to_s
  numLeading = n - strInt.length
  return strInt if numLeading <= 0
  leadingZeroes = "0" * numLeading
  return leadingZeroes + strInt
end

class Sprite
  def bmp(arg1 = nil, arg2 = nil)
    if arg1
      if arg1.is_a?(Bitmap)
        self.bitmap = arg1
      elsif arg2
        self.bitmap = Bitmap.new(arg1, arg2)
      else
        self.bitmap = BitmapCache.load_bitmap(arg1)
      end
    else
      return self.bitmap
    end
  end
end

if DUAL_SCREEN
  class Spriteset_Map
    alias poketch_init initialize
    def initialize(map = nil)
      poketch_init(map)
      if $Trainer && $Trainer.poketch && !$Poketch
        pbObtainPoketch(false)
      else
        return if $no_poketch_bg
        make_background
      end
    end
    
    alias poketch_update update
    def update
      poketch_update
      # Ensuring the Pokétch only updates once per frame (bug fix for map transfer)
      if $Poketch && $Poketch.updated_frame != Graphics.frame_count
        $Poketch.update
        $Poketch.updated_frame = Graphics.frame_count
      end
    end
  end
end

def make_background
  $no_poketch_bg.dispose if $no_poketch_bg
  $no_poketch_bg = Sprite.new((v=Viewport.new(0,POKETCH_Y,Graphics.width,Graphics.height);v.z=99997;v))
  $no_poketch_bg.bmp(NO_POKETCH_BACKGROUND)
end

class PoketchApp
  def self.usable?
    return true
  end
  
  def initialize
    @viewport = Viewport.new(32,POKETCH_Y+32,384,320)
    @viewport.z = 100001
    @cooldown = -1
    @tmp = []
    @bg = Sprite.new(@viewport)
  end

  def update
    @cooldown -= 1 if @cooldown > -1
    if @cooldown == 0 && @tmp[0]
      @tmp[0].bmp(@tmp[1]+"/"+@tmp[2])
    end
  end
  
  # "sprite": The sprite that is clicked on
  # "path": Used for "unclicked" and "clicked"
  # "unclicked": The path "sprite" will get when the cooldown ends (path is "path"/"unclicked")
  # "clicked": The path "sprite" will get when clicked on (path is "path"/"clicked")
  # "cooldown": How long other mouse input in this app will be disabled
  def click?(sprite, path, unclicked, clicked = unclicked + "Click", cooldown = 3)
    return false if !$mouse || !$mouse.click?(sprite) || @cooldown > -1
    @tmp = [sprite,path,unclicked]
    @tmp[0].bmp(@tmp[1]+"/"+clicked)
    @cooldown = cooldown
    return true
  end
  
  def refresh
  end
  
  def dispose
    @bg.dispose
    @viewport.dispose
    $Poketch.app = nil
  end
end

class Sprite
  def poketch_average
    bmp = self.bitmap.clone
    for x in 0...bmp.width
      for y in 0...bmp.height
        px = bmp.get_pixel(x, y)
        next if px.alpha == 0
        av = (px.red + px.green + px.blue) / 3
        if av < 96
          color = Color.new(57,82,49)
        elsif av < 128
          color = Color.new(76,120,74)
        elsif av < 170
          color = Color.new(82,132,82)
        else
          color = Color.new(115,181,115)
        end
        bmp.set_pixel(x, y, color)
      end
    end
    self.bitmap = bmp.clone
  end
end

# Drawing method
RNET = File.file?("Assemblies/RPG.Net.dll")
if RNET
  Win32API.new('Assemblies/RPG.Net.dll', 'Initialize', 'i', '').call(4)
  class Bitmap
    DrawLine = Win32API.new('RPG.Net.dll', 'BmDrawLine', 'iiiiiii', '')
    def draw_line(x1, y1, x2, y2, color, thickness = 4)
      c = color
      c = [c.red.to_i.chr, c.green.to_i.chr, c.blue.to_i.chr, c.alpha.to_i.chr].join.unpack('L').shift
      DrawLine.call(__id__, x1, y1, x2, y2, c, thickness)
    end
  end
end

def appID(const)
  return PoketchApps.const_get(const) rescue nil
end