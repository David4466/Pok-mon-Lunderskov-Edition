#==============================================================================#
#                  Pokétch for Pokémon Essentials v16.X | v17.X                #
#                                     v1.0                                     #
#                                                                              #
#                                   by Marin                                   #
#==============================================================================#
#                               Dual-screen usage                              #
#                                                                              #
#               Double DEFAULTSCREENHEIGHT (usually 384; 384 * 2 = 768)        #
#                            Set DUAL_SCREEN to true                           #
#                              Set POKETCH_Y to 384                            #
#                    Make sure NO_POKETCH_BACKGROUND has a value               #
#                                                                              #
#      This Dual-screen script has most likely messed up your battle scene     #
#      You will have to do some repositioning in PokeBattle_SceneConstants     #
#                                                                              #
#      To give or take the Pokétch, use pbObtainPoketch and pbTakePoketch      #
#==============================================================================#
#                              Single-screen usage                             #
#                                                                              #
#            Set DEFAULTSCREENHEIGHT to 384 or whatever height you want        #
#                             Set DUAL_SCREEN to false                         #
#                                Set POKETCH_Y to 0                            #
#                                                                              #
#                       To call the Pokétch, use pbPoketch                     #
#              You can use this method to call it from other menus             #
#==============================================================================#
#                                     Apps                                     #
#                                                                              #
#     To enable or disable an app, use pbEnableApp(id) or pbDisableApp(id)     #
#        To enable or disable all apps, use pbEnableAll or pbDisableAll        #
#        To determine if an app is enabled or not, use pbAppEnabled?(id)       #
#                                                                              #
#    To get the ID of an app, you could do, say, "PoketchApps::PoketchRotom"   #
#           This will get you the ID of an app called "PoketchRotom"           #
#                                                                              #
#                                    Alternative:                              #
#                    Scroll to the bottom of Pokétch_Apps.                     #
#           You'll see a module with the number before the app.                #
#                                                                              #
#      If you want to change the Pokétch to a specific app, you can use        #
#                             pbChangeApp(app_id)                              #
#                This method bypasses usability and availability.              #
#==============================================================================#
#                              Making your own apps                            #
#                                                                              #
# The top of Pokétch_Apps contains a small tutorial as to how to make your own #
#                                     apps.                                    #
#                                                                              #
#    Did you successfully make your own app? Feel free to share it in the      #
#            PokéCommunity or RelicCastle thread for others to use!            #
#==============================================================================#



# Set this to false if you don't want two screens. You'll also have to set
# DEFAULTSCREENHEIGHT to 384.
DUAL_SCREEN = false

# If you want this Pokétch to be on a single screen or elsewhere on the screen,
# You'll likely want to set this value to 0. If not, set it to 384.
POKETCH_Y = 0

# If you don't have the Pokétch, this is the image that will be displayed instead
# (because it's not ideal to have just a black screen) (DUAL_SCREEN ONLY)
NO_POKETCH_BACKGROUND = "Graphics/Pictures/Poketch/background"



$Poketch = nil if $Poketch # F12 soft reset fix
$no_poketch_bg = nil if $no_poketch_bg # F12 soft reset fix

def pbPoketch # (NON-DUAL_SCREEN ONLY)
  return if $Poketch
  $Poketch = Poketch.new
  $Poketch.show
  if $Poketch.app
    $Poketch.run_app
    $Poketch.hideOverlay
  end
  loop do
    Graphics.update
    Input.update
    $Poketch.update
    break if Input.trigger?(Input::B)
  end
  if $Poketch.app
    $Poketch.showOverlay(proc { $Poketch.app.dispose } )
    24.times { Graphics.update; Input.update; $Poketch.update }
  end
  $Poketch.hide
  $Poketch.dispose
end

def pbChangeApp(id)
  return if $Poketch
  $Poketch.changeApp(id)
end

# Give the Pokétch (DUAL_SCREEN ONLY)
def pbObtainPoketch(animate = true)
  return if $Poketch
  $Trainer.poketch = true
  pbEnableApp(PoketchApps::PoketchClock)
  pbEnableApp(PoketchApps::PoketchClicker)
  pbEnableApp(PoketchApps::PoketchCalculator)
  pbEnableApp(PoketchApps::PoketchAnalogWatch)
  $Poketch = Poketch.new
  $Poketch.show(animate)
  if $Poketch.app
    $Poketch.run_app
    $Poketch.hideOverlay
  end
  $no_poketch_bg.dispose if $no_poketch_bg
end

# Take away the Pokétch (DUAL_SCREEN ONLY)
def pbTakePoketch(animate = true)
  return if !$Poketch
  if $Poketch.app
    $Poketch.showOverlay(proc { $Poketch.app.dispose } )
    24.times { Graphics.update; Input.update; $Poketch.update }
  end
  make_background
  $Poketch.hide(animate)
  $Poketch.dispose
  $Poketch = nil
  $Trainer.poketch = false
end

def pbEnableAll
  for const in PoketchApps.constants
    key = appID(const)
    $Trainer.poketch_app_access << key if !$Trainer.poketch_app_access.include?(key)
  end
  $Poketch.refresh if $Poketch
end

def pbDisableAll
  $Trainer.poketch_app_access.clear
  $Poketch.refresh if $Poketch
end

def pbEnableApp(id)
  $Trainer.poketch_app_access << id if !$Trainer.poketch_app_access.include?(id)
  $Poketch.refresh if $Poketch
end

def pbDisableApp(id)
  $Trainer.poketch_app_access.delete(id)
  $Poketch.refresh if $Poketch
end

def pbAppEnabled?(id)
  return $Trainer.poketch_app_access.include?(id)
end

class Poketch
  attr_accessor :app
  attr_accessor :apps
  attr_accessor :updated_frame
  
  def initialize
    @viewport = Viewport.new(0,POKETCH_Y,Graphics.width,Graphics.height)
    @viewport.z = 99998
    @viewport2 = Viewport.new(0,POKETCH_Y,Graphics.width,Graphics.height)
    @viewport2.z = 100000
    @overlay = Sprite.new(@viewport2)
    @overlay.x = 32
    @overlay.y = 32
    @poketch = Sprite.new(@viewport)
    @poketch.bmp("Graphics/Pictures/Poketch/poketch#{["Male","Female"][$Trainer.gender]}")
    @btnUp = Sprite.new(@viewport)
    @btnUp.bmp("Graphics/Pictures/Poketch/btnUp")
    @btnUp.x = 448
    @btnUp.y = 66
    @btnDown = Sprite.new(@viewport)
    @btnDown.bmp("Graphics/Pictures/Poketch/btnDown")
    @btnDown.x = 448
    @btnDown.y = 191
    @transUp = Sprite.new(@viewport2)
    @transUp.bmp("Graphics/Pictures/Poketch/transition")
    @transUp.x = 32
    @transUp.y = 32
    @transUp.zoom_y = 160
    @transUp.opacity = 0
    @transUp.z = 1
    @transDown = Sprite.new(@viewport2)
    @transDown.bmp("Graphics/Pictures/Poketch/transition")
    @transDown.x = 32
    @transDown.y = 352
    @transDown.zoom_y = 160
    @transDown.oy = @transDown.bitmap.height
    @transDown.opacity = 0
    @transDown.z = 1
    @i = 0
    @proc = nil
    @showOverlay = false
    @hideOverlay = false
    hide(false)
    @transUp.zoom_y = 170
    @transDown.zoom_y = 170
    @sel = 0
    sort_apps
    if $Trainer.poketch_last_app
      if @apps[$Trainer.poketch_last_app]
        @sel = $Trainer.poketch_last_app
      end
    end
    @app = @apps[@sel] if @apps[@sel]
    if !$Trainer.poketch_color || $Trainer.poketch_color == 0
      no_color
    else
      set_color("Graphics/Pictures/Poketch/Color Changer/overlay#{$Trainer.poketch_color}")
    end
  end
  
  def show(animate = true)
    unless @poketch.opacity >= 255
      for i in 0...25
        if animate
          Graphics.update
          Input.update
        end
        @poketch.opacity += 256 / 24.0
        @btnUp.opacity += 256 / 24.0
        @btnDown.opacity += 256 / 24.0
        @transUp.opacity += 256 / 23.0
        @transDown.opacity += 256 / 23.0
      end
      @transDown.zoom_y = 160
      @transUp.zoom_y = 160
      showOverlay
    end
  end
  
  def hide(animate = true)
    unless @poketch.opacity == 0
      for i in 0...25
        if animate
          Graphics.update
          Input.update
        end
        @poketch.opacity -= 256 / 24.0
        @btnUp.opacity -= 256 / 24.0
        @btnDown.opacity -= 256 / 24.0
        @transUp.opacity -= 256 / 24.0
        @transDown.opacity -= 256 / 24.0
      end
    end
  end
  
  def showOverlay(proc = nil)
    @showOverlay = true
    @proc = proc
  end
  
  def hideOverlay(proc = nil)
    @hideOverlay = true
    @proc = proc
  end
  
  def sort_apps
    @apps = {}
    for const in PoketchApps.constants
      key = appID(const)
      cls = eval(const.to_s)
      @apps[key] = cls if pbAppEnabled?(key) && cls.usable?
    end
  end
  
  def refresh
    sort_apps
    @app.refresh if @app.respond_to?("refresh")
    if @apps.size == 0
      showOverlay
      @proc = proc { @app.dispose if @app && @app.respond_to?("dispose") }
    else
      if !@app
        for const in PoketchApps.constants
          key = appID(const)
          if @apps[key]
            @sel = key
            break
          end
        end
        run_app
        hideOverlay
      else
        if !@apps.map { |app| app[1] }.include?(@app.class)
          showOverlay
          @proc = proc do
            @app.dispose if @app.respond_to?("dispose")
            move_up
            run_app
            hideOverlay
          end
        end
      end
    end
  end
  
  def run_app
    @app = @apps[@sel].new if @apps[@sel]
  end
  
  def update
    if @showOverlay
      if @transUp.zoom_y != 160
        @transUp.zoom_y += 10
        @transDown.zoom_y += 10
      end
      @i += 1
      if @i == 6
        @btnDown.bmp("Graphics/Pictures/Poketch/btnDown")
        @btnUp.bmp("Graphics/Pictures/Poketch/btnUp")
      end
      if @i == 24
        @showOverlay = false
        @proc.call if @proc
        @proc = nil
        @i = 0
      end
      return
    end
    if @hideOverlay
      if @transUp.zoom_y != 0
        @transUp.zoom_y -= 10
        @transDown.zoom_y -= 10
      end
      @i += 1
      if @i == 6
        @btnDown.bmp("Graphics/Pictures/Poketch/btnDown")
        @btnUp.bmp("Graphics/Pictures/Poketch/btnUp")
      end
      if @i == 16
        @hideOverlay = false
        @proc.call if @proc
        @proc = nil
        @i = 0
      end
      return
    end
    @app.update if @app.respond_to?("update")
    return if @apps.size == 0
    if $mouse && $mouse.click?(@btnUp)
      click_up
    end
    if $mouse && $mouse.click?(@btnDown)
      click_down
    end
  end
  
  # Change the app to something else. Bypasses usability/availability.
  def changeApp(id)
    @sel = id
    refresh
    showOverlay
    @proc = proc do
      @app.dispose if @app && @app.respond_to?("dispose")
      run_app
      $Trainer.poketch_last_app = @sel
      hideOverlay
    end
  end
  
  # For the Itemfinder/Notepad to be able to read these buttons.
  attr_reader :btnUp
  attr_reader :btnDown
  
  def click_up(animate = true)
    @btnUp.bmp("Graphics/Pictures/Poketch/btnUpClick") if animate
    refresh
    showOverlay
    @proc = proc do
      @app.dispose if @app && @app.respond_to?("dispose")
      move_up
      run_app
      $Trainer.poketch_last_app = @sel
      hideOverlay
    end
  end
  
  def click_down(animate = true)
    @btnDown.bmp("Graphics/Pictures/Poketch/btnDownClick") if animate
    refresh
    showOverlay
    @proc = proc do
      @app.dispose if @app && @app.respond_to?("dispose")
      move_down
      run_app
      $Trainer.poketch_last_app = @sel
      hideOverlay
    end
  end
  
  def move_up
    s = false
    i = @sel
    if @apps.size > 1
      while !s
        i += 1
        if @apps[i]
          s = true
          @sel = i
        end
        if i >= PoketchApps.constants.size
          i = -1
        end
      end
    end
  end
  
  def move_down
    s = false
    i = @sel
    if @apps.size > 1
      while !s
        i -= 1
        if @apps[i]
          s = true
          @sel = i
        end
        if i < 0
          i = PoketchApps.constants.size
        end
      end
    end
  end
  
  def set_color(path)
    @overlay.bmp(path)
  end
  
  def no_color
    @overlay.bitmap = nil
  end
  
  def dispose
    showOverlay
    @proc = proc do
      @app.dispose if @app && @app.respond_to?("dispose")
    end
    @poketch.dispose
    @btnUp.dispose
    @btnDown.dispose
    @transUp.dispose
    @transDown.dispose
    $Poketch = nil
  end
end
# Do not change.
ERRORTEXT += "[Pokétch v1.0]\r\n" if defined?(ERRORTEXT)