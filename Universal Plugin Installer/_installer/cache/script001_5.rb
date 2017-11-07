#===============================================================================
#  Elite Battle system
#    by Luka S.J.
# ----------------
#  Sprites Script
# ----------------  
#  system is based off the original Essentials battle system, made by
#  Poccil & Maruno
#  No additional features added to AI, mechanics 
#  or functionality of the battle system.
#  This update is purely cosmetic, and includes a B/W like dynamic scene with a 
#  custom interface.
#
#  Enjoy the script, and make sure to give credit!
#  (DO NOT ALTER THE NAMES OF THE INDIVIDUAL SCRIPT SECTIONS OR YOU WILL BREAK
#   YOUR SYSTEM!)
#-------------------------------------------------------------------------------
#  New methods for creating in-battle Pokemon sprites.
#  * creates fixed shadows in the sprite itself
#  * calculates correct positions according to metric data in here
#  * sprites have a different focal point for more precise base placement
#===============================================================================
class DynamicPokemonSprite
  attr_accessor :shadow
  attr_accessor :sprite
  attr_accessor :showshadow
  attr_accessor :status
  attr_accessor :hidden
  attr_accessor :fainted
  attr_accessor :anim
  attr_accessor :charged
  attr_accessor :isShadow
  attr_reader :loaded
  attr_reader :selected
  attr_reader :isSub
  attr_reader :viewport
  attr_reader :pulse

  def initialize(doublebattle,index,viewport=nil)
    @viewport=viewport
    @metrics=load_data("Data/metrics.dat")
    @selected=0
    @frame=0
    @frame2=0
    @frame3=0
    
    @status=0
    @loaded=false
    @charged=false
    @index=index
    @doublebattle=doublebattle
    @showshadow=true
    @altitude=0
    @yposition=0
    @shadow=Sprite.new(@viewport)
    @sprite=Sprite.new(@viewport)
      back=(@index%2==0)
    @substitute=AnimatedBitmapWrapper.new("Graphics/Battlers/"+(back ? "substitute_back" : "substitute"),POKEMONSPRITESCALE)
    @overlay=Sprite.new(@viewport)
    @isSub=false
    @lock=false
    @pokemon=nil
    @still=false
    @hidden=false
    @fainted=false
    @anim=false
    @isShadow=false
    
    @fp = {}
    for i in 0...16
      @fp["#{i}"] = Sprite.new(@viewport)
      @fp["#{i}"].bitmap = pbBitmap("Graphics/Animations/ebShadow")
      @fp["#{i}"].ox = @fp["#{i}"].bitmap.width/4
      @fp["#{i}"].oy = @fp["#{i}"].bitmap.height/2
      @fp["#{i}"].src_rect.set(0,0,@fp["#{i}"].bitmap.width/2,@fp["#{i}"].bitmap.height)
      @fp["#{i}"].opacity = 0
    end
    
    for i in 0...16
      @fp["c#{i}"] = Sprite.new(@viewport)
      @fp["c#{i}"].bitmap = pbBitmap("Graphics/Animations/ebCharged")
      @fp["c#{i}"].ox = @fp["c#{i}"].bitmap.width/8
      @fp["c#{i}"].oy = @fp["c#{i}"].bitmap.height
      @fp["c#{i}"].src_rect.set(0,0,@fp["c#{i}"].bitmap.width/4,@fp["c#{i}"].bitmap.height)
      @fp["c#{i}"].opacity = 0
    end
    
    for j in 0...4
      @fp["r#{j}"] = Sprite.new(viewport)
      @fp["r#{j}"].bitmap = pbBitmap("Graphics/Animations/ebRipple")
      @fp["r#{j}"].ox = @fp["r#{j}"].bitmap.width/2
      @fp["r#{j}"].oy = @fp["r#{j}"].bitmap.height/2
      @fp["r#{j}"].zoom_x = 0
      @fp["r#{j}"].zoom_y = 0
      @fp["r#{j}"].param = 0
    end
    
    @pulse = 8
    @k = 1
  end
  
  def battleIndex; return @index; end
  def x; @sprite.x; end
  def y; @sprite.y; end
  def z; @sprite.z; end
  def ox; @sprite.ox; end
  def oy; @sprite.oy; end
  def zoom_x; @sprite.zoom_x; end
  def zoom_y; @sprite.zoom_y; end
  def visible; @sprite.visible; end
  def opacity; @sprite.opacity; end
  def width; @bitmap.width; end
  def height; @bitmap.height; end
  def tone; @sprite.tone; end
  def bitmap; @bitmap.bitmap; end
  def actualBitmap; @bitmap; end
  def disposed?; @sprite.disposed?; end
  def color; @sprite.color; end
  def src_rect; @sprite.src_rect; end
  def blend_type; @sprite.blend_type; end
  def angle; @sprite.angle; end
  def mirror; @sprite.mirror; end
  def src_rect; return @sprite.src_rect; end
  def src_rect=(val)
    @sprite.src_rect=val
  end
  def lock
    @lock=true
  end
  def bitmap=(val)
    @bitmap.bitmap=val
  end
  def x=(val)
    @sprite.x=val
    @shadow.x=val
  end
  def ox=(val)
    @sprite.ox=val
    self.formatShadow
  end
  def addOx(val)
    @sprite.ox+=val
    self.formatShadow
  end
  def oy=(val)
    @sprite.oy=val
    self.formatShadow
  end
  def addOy(val)
    @sprite.oy+=val
    self.formatShadow
  end
  def y=(val)
    @sprite.y=val
    @shadow.y=val
  end
  def z=(val)
    @shadow.z=(val==32) ? 31 : 10
    @sprite.z=val
  end
  def zoom_x=(val)
    @sprite.zoom_x=val
    self.formatShadow
  end
  def zoom_y=(val)
    @sprite.zoom_y=val
    self.formatShadow
  end
  def visible=(val)
    return if @hidden
    @sprite.visible=val
    if @fp
      val = false if @hidden || @fainted
      for key in @fp.keys
        if key.include?("c") || key.include?("r")
          val = false if !@charged
        else
          val = false if !@isShadow
        end
        @fp[key].visible=val
      end
    end
    self.formatShadow
  end
  def opacity=(val)
    @sprite.opacity=val
    self.formatShadow
  end
  def tone=(val)
    @sprite.tone=val
  end
  def color=(val)
    @sprite.color=val
    if @fp
      for key in @fp.keys
        @fp[key].color=val
      end
    end
  end
  def blend_type=(val)
    @sprite.blend_type=val
    self.formatShadow
  end
  def angle=(val)
    @sprite.angle=(val)
    self.formatShadow
  end
  def mirror=(val)
    @sprite.mirror=(val)
    self.formatShadow
  end
  def dispose
    @sprite.dispose
    @shadow.dispose
    pbDisposeSpriteHash(@fp)
  end
  def selected=(val)
    @selected=val
    @sprite.visible=true if !@hidden
  end
  def toneAll(val)
    @sprite.tone.red+=val
    @sprite.tone.green+=val
    @sprite.tone.blue+=val
  end
  
  def setBitmap(file,shadow=false)
    self.resetParticles
    @showshadow = shadow
    @bitmap = AnimatedBitmapWrapper.new(file)
    @sprite.bitmap = @bitmap.bitmap.clone
    @shadow.bitmap = @bitmap.bitmap.clone    
    @loaded = true
    self.formatShadow
  end
  
  def setPokemonBitmap(pokemon,back=false,species=nil)
    self.resetParticles
    return if !pokemon || pokemon.nil?
    @pokemon = pokemon
    @isShadow = true if @pokemon.isShadow?
    @altitude = @metrics[2][pokemon.species]
    if back
      @yposition = @metrics[0][pokemon.species]
      @altitude *= 0.5
    else
      @yposition = @metrics[1][pokemon.species]
    end
    scale = back ? BACKSPRITESCALE : POKEMONSPRITESCALE
    if !species.nil?
      @bitmap = pbLoadPokemonBitmapSpecies(pokemon,species,back,scale)
    else
      @bitmap = pbLoadPokemonBitmap(pokemon,back,scale)
    end
    @sprite.bitmap = @bitmap.bitmap.clone
    @shadow.bitmap = @bitmap.bitmap.clone
    @sprite.ox = @bitmap.width/2
    @sprite.oy = @bitmap.height
    @sprite.oy += @altitude
    @sprite.oy -= @yposition
    @sprite.oy -= pokemon.formOffsetY if pokemon.respond_to?(:formOffsetY)
    
    @fainted = false
    @loaded = true
    @hidden = false
    self.visible = true
    @pulse = 8
    @k = 1
    self.formatShadow
  end
  
  def resetParticles
    if @fp
      for key in @fp.keys
        @fp[key].visible = false
      end
    end
    @isShadow = false
    @charged = false
  end
  
  def refreshMetrics(metrics)
    @metrics = metrics
    @altitude = @metrics[2][@pokemon.species]
    if (@index%2==0)
      @yposition = @metrics[0][@pokemon.species]
      @altitude *= 0.5
    else
      @yposition = @metrics[1][@pokemon.species]
    end
    
    @sprite.ox = @bitmap.width/2
    @sprite.oy = @bitmap.height
    @sprite.oy += @altitude
    @sprite.oy -= @yposition
    @sprite.oy -= @pokemon.formOffsetY if @pokemon.respond_to?(:formOffsetY)
  end
  
  def setSubstitute
    @isSub = true
    @sprite.bitmap = @substitute.bitmap.clone
    @shadow.bitmap = @substitute.bitmap.clone
    @sprite.ox = @substitute.width/2
    @sprite.oy = @substitute.height
    self.formatShadow
  end
  
  def removeSubstitute
    @isSub = false
    @sprite.bitmap = @bitmap.bitmap.clone
    @shadow.bitmap = @bitmap.bitmap.clone
    @sprite.ox = @bitmap.width/2
    @sprite.oy = @bitmap.height
    @sprite.oy += @altitude
    @sprite.oy -= @yposition
    @sprite.oy -= @pokemon.formOffsetY if @pokemon && @pokemon.respond_to?(:formOffsetY)
    self.formatShadow
  end
  
  def still
    @still = true
  end
  
  def clear
    @sprite.bitmap.clear
    @bitmap.dispose
  end
  
  def formatShadow
    @shadow.zoom_x = @sprite.zoom_x*0.90
    @shadow.zoom_y = @sprite.zoom_y*0.30
    @shadow.ox = @sprite.ox - 6
    @shadow.oy = @sprite.oy - 6
    @shadow.opacity = @sprite.opacity*0.3
    @shadow.tone = Tone.new(-255,-255,-255,255)
    @shadow.visible = @sprite.visible
    @shadow.mirror = @sprite.mirror
    @shadow.angle = @sprite.angle
    
    @shadow.visible = false if !@showshadow
  end
  
  def update(angle=74)
    if @still
      @still = false
      return
    end
    return if @lock
    return if !@bitmap || @bitmap.disposed?
    if @isSub
      @substitute.update
      @sprite.bitmap=@substitute.bitmap.clone
      @shadow.bitmap=@substitute.bitmap.clone
    else
      @bitmap.update
      @sprite.bitmap=@bitmap.bitmap.clone
      @shadow.bitmap=@bitmap.bitmap.clone
    end
    @shadow.skew(angle)
    if !@anim && !@pulse.nil?
      @pulse += @k
      @k *= -1 if @pulse == 128 || @pulse == 8
      case @status
      when 0
        @sprite.color = Color.new(0,0,0,0)
      when 1 #PSN
        @sprite.color = Color.new(109,55,130,@pulse)
      when 2 #PAR
        @sprite.color = Color.new(204,152,44,@pulse)
      when 3 #FRZ
        @sprite.color = Color.new(56,160,193,@pulse)
      when 4 #BRN
        @sprite.color = Color.new(206,73,43,@pulse)
      end
    end
    @anim = false
    # Pokémon sprite blinking when targeted or damaged
    @frame += 1
    @frame = 0 if @frame > 256
    if @selected==2 # When targeted or damaged
      @sprite.visible = (@frame%10<7) && !@hidden
    end
    self.formatShadow
  end  
  
  def shadowUpdate
    return if !@loaded
    return if self.disposed? || @bitmap.disposed?
    for i in 0...16
      next if i > @frame2/4
      @fp["#{i}"].visible = @showshadow
      @fp["#{i}"].visible = false if @hidden
      @fp["#{i}"].visible = false if !@isShadow
      next if !@isShadow
      if @fp["#{i}"].opacity <= 0
        @fp["#{i}"].toggle = 2
        z = [0.5,0.6,0.7,0.8,0.9,1.0][rand(6)]
        @fp["#{i}"].param = z
        @fp["#{i}"].x = self.x - self.bitmap.width*self.zoom_x/2 + rand(self.bitmap.width)*self.zoom_x
        @fp["#{i}"].y = self.y - 64*self.zoom_y + rand(64)*self.zoom_y
        @fp["#{i}"].z = (rand(2)==0) ? self.z - 1 : self.z + 1
        @fp["#{i}"].speed = (rand(2)==0) ? +1 : -1
        @fp["#{i}"].src_rect.x = rand(2)*@fp["#{i}"].bitmap.width/2
      end
      @fp["#{i}"].zoom_x = @fp["#{i}"].param*self.zoom_x
      @fp["#{i}"].zoom_y = @fp["#{i}"].param*self.zoom_y
      @fp["#{i}"].param -= 0.01
      @fp["#{i}"].y -= 1
      @fp["#{i}"].opacity += 8*@fp["#{i}"].toggle
      @fp["#{i}"].toggle = -1 if @fp["#{i}"].opacity >= 255
    end
    @frame2 += 1 if @frame2 < 128
  end
  
  def chargedUpdate
    return if !@loaded
    return if self.disposed? || @bitmap.disposed?
    for i in 0...16
      next if i > @frame3/16
      @fp["c#{i}"].visible = @showshadow
      @fp["c#{i}"].visible = false if @hidden
      @fp["c#{i}"].visible = false if !@charged
      next if !@charged
      if @fp["c#{i}"].opacity <= 0
        x = @sprite.x - @sprite.ox + rand(@sprite.bitmap.width)
        y = @sprite.y - @sprite.oy*0.7 + rand(@sprite.bitmap.height*0.8)
        @fp["c#{i}"].x = x
        @fp["c#{i}"].y = y
        @fp["c#{i}"].z = (rand(2)==0) ? self.z - 1 : self.z + 1
        @fp["c#{i}"].src_rect.x = rand(4)*@fp["c#{i}"].bitmap.width/4
        @fp["c#{i}"].zoom_y = 0.6
        @fp["c#{i}"].opacity = 166 + rand(90)
        @fp["c#{i}"].mirror = (x < @sprite.x) ? false : true
      end
      @fp["c#{i}"].zoom_y += 0.1
      @fp["c#{i}"].opacity -= 16
    end
    for j in 0...4
      next if j > @frame3/32
      @fp["r#{j}"].visible = @showshadow
      @fp["r#{j}"].visible = false if @hidden
      @fp["r#{j}"].visible = false if !@charged
      if @fp["r#{j}"].opacity <= 0
        @fp["r#{j}"].opacity = 255
        @fp["r#{j}"].zoom_x = 0
        @fp["r#{j}"].zoom_y = 0
        @fp["r#{j}"].param = 0
      end
      @fp["r#{j}"].param += 0.01
      @fp["r#{j}"].zoom_x = @fp["r#{j}"].param*self.zoom_x
      @fp["r#{j}"].zoom_y = @fp["r#{j}"].param*self.zoom_x
      @fp["r#{j}"].x = self.x
      @fp["r#{j}"].y = self.y
      @fp["r#{j}"].opacity -= 2
    end
    @frame3 += 1 if @frame3 < 256
  end
end
#-------------------------------------------------------------------------------
#  Animated trainer sprites
#-------------------------------------------------------------------------------
class DynamicTrainerSprite  <  DynamicPokemonSprite
  
  def initialize(doublebattle,index,viewport=nil,trarray=false)
    @viewport=viewport
    @trarray=trarray
    @selected=0
    @frame=0
    @frame2=0
    
    @status=0
    @loaded=false
    @index=index
    @doublebattle=doublebattle
    @showshadow=true
    @altitude=0
    @yposition=0
    @shadow=Sprite.new(@viewport)
    @sprite=Sprite.new(@viewport)
    @overlay=Sprite.new(@viewport)
    @lock=false
  end
  
  def totalFrames; @bitmap.animationFrames; end
  def toLastFrame 
    @bitmap.toFrame(@bitmap.totalFrames-1)
    self.update
  end
  def selected; end
    
  def setTrainerBitmap(file)
    @bitmap=AnimatedBitmapWrapper.new(file,TRAINERSPRITESCALE)
    @sprite.bitmap=@bitmap.bitmap.clone
    @shadow.bitmap=@bitmap.bitmap.clone
    @sprite.ox=@bitmap.width/2
    if @doublebattle && @trarray
      if @index==-2
        @sprite.ox-=50
      elsif @index==-1
        @sprite.ox+=50
      end
    end
    @sprite.oy=@bitmap.height-16
    
    self.formatShadow
    @shadow.skew(74)
  end

end
#-------------------------------------------------------------------------------
#  New class used to configure and animate battle backgrounds
#-------------------------------------------------------------------------------
class AnimatedBattleBackground < Sprite
  
  def setBitmap(backdrop,scene)
    blur = 4; blur = BLURBATTLEBACKGROUND if BLURBATTLEBACKGROUND.is_a?(Numeric)
    @eff = {}
    @scene = scene
    if $INEDITOR
      @defaultvector = VECTOR1
    else
      @defaultvector = (@scene.battle.doublebattle ? VECTOR2 : VECTOR1)
    end
    @canAnimate = !pbResolveBitmap("Graphics/BattleBacks/Animation/eff1"+backdrop).nil?
    bg = pbBitmap("Graphics/BattleBacks/battlebg/"+backdrop)
    @bmp = Bitmap.new(bg.width*BACKGROUNDSCALAR,bg.width*BACKGROUNDSCALAR)
    @bmp.stretch_blt(Rect.new(0,0,@bmp.width,@bmp.height),bg,Rect.new(0,0,bg.width,bg.height))
    self.bitmap = @bmp.clone
    self.blur_sprite(blur) if BLURBATTLEBACKGROUND
    sx, sy = @scene.vector.spoof(@defaultvector)
    self.ox = 256 + sx
    self.oy = 192 + sy
    for i in 1..3
      next if !@canAnimate
      @eff["#{i}"] = Sprite.new(self.viewport)
      bmp = pbBitmap("Graphics/BattleBacks/Animation/eff#{i}"+backdrop)
      @eff["#{i}"].bitmap = Bitmap.new(@bmp.width*2,@bmp.height)
      @eff["#{i}"].bitmap.stretch_blt(Rect.new(0,0,@bmp.width*2,@bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      @eff["#{i}"].src_rect.set([0,128,0,-128][i]*BACKGROUNDSCALAR,0,bmp.width*BACKGROUNDSCALAR/2,bmp.height*BACKGROUNDSCALAR)
      @eff["#{i}"].ox = self.ox
      @eff["#{i}"].oy = self.oy
      @eff["#{i}"].blur_sprite(blur) if BLURBATTLEBACKGROUND
    end
    self.update
  end
  
  def update
    if @canAnimate
      @eff["1"].src_rect.x -= 1
      @eff["1"].src_rect.x = 512*BACKGROUNDSCALAR if @eff["1"].src_rect.x <= -256*BACKGROUNDSCALAR
      @eff["2"].src_rect.x += 1
      @eff["2"].src_rect.x = -256*BACKGROUNDSCALAR if @eff["2"].src_rect.x >= 512*BACKGROUNDSCALAR
      @eff["3"].src_rect.x -= 2
      @eff["3"].src_rect.x = 512*BACKGROUNDSCALAR if @eff["3"].src_rect.x <= -256*BACKGROUNDSCALAR
    end    
    # coordinates
    self.x = @scene.vector.x2
    self.y = @scene.vector.y2
    self.angle = ((@scene.vector.angle - @defaultvector[2])*0.5).to_i if $PokemonSystem.screensize < 2 && @scene.sendingOut
    sx, sy = @scene.vector.spoof(@defaultvector)
    self.zoom_x = ((@scene.vector.x2 - @scene.vector.x)*1.0/(sx - @defaultvector[0])*1.0)**0.6
    self.zoom_y = ((@scene.vector.y2 - @scene.vector.y)*1.0/(sy - @defaultvector[1])*1.0)**0.6
    for i in 1..3
      next if !@canAnimate
      @eff["#{i}"].x = self.x
      @eff["#{i}"].y = self.y
      @eff["#{i}"].zoom_x = self.zoom_x
      @eff["#{i}"].zoom_y = self.zoom_y
      @eff["#{i}"].visible = true
      @eff["#{i}"].tone = self.tone
      if self.angle!=0
        @eff["#{i}"].opacity -= 51
      else
        @eff["#{i}"].opacity += 51
      end
    end
  end
  
  alias dispose_bg_ebs dispose unless self.method_defined?(:dispose_bg_ebs)
  def dispose
    pbDisposeSpriteHash(@eff)
    dispose_bg_ebs
  end
  
  alias :color_bg= :color= unless self.method_defined?(:color_bg=)
  def color=(val)
    for i in 1..3
      next if !@canAnimate
      @eff["#{i}"].color = val
    end
    self.color_bg = val
  end
end
#-------------------------------------------------------------------------------
#  New class used to render the Mother Beast Lusamine styled VS background
#-------------------------------------------------------------------------------
class CrazyRainbowBackground
  
  def initialize(viewport)
    @viewport = viewport
    @sprites = {}
    
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].drawRect(@viewport.rect.width,@viewport.rect.height,Color.new(0,0,0))
    @sprites["bg"].z = 200
    for j in 0...3
      @sprites["b#{j}"] = RainbowSprite.new(@viewport)
      @sprites["b#{j}"].setBitmap("Graphics/Transitions/smC#{j}",8)
      @sprites["b#{j}"].ox = @sprites["b#{j}"].bitmap.width/2
      @sprites["b#{j}"].oy = @sprites["b#{j}"].bitmap.height/2
      @sprites["b#{j}"].x = @viewport.rect.width/2
      @sprites["b#{j}"].y = @viewport.rect.height/2
      @sprites["b#{j}"].zoom_x = 0.6 + 0.6*j
      @sprites["b#{j}"].zoom_y = 0.6 + 0.6*j
      @sprites["b#{j}"].opacity = 64 + 64*(1+j)
      @sprites["b#{j}"].z = 250
    end
    for j in 0...64
      @sprites["p#{j}"] = Sprite.new(@viewport)
      @sprites["p#{j}"].z = 300
      width = 16 + rand(48)
      height = 16 + rand(16)
      @sprites["p#{j}"].bitmap = Bitmap.new(width,height)
      bmp = pbBitmap("Graphics/Transitions/smCParticle")
      @sprites["p#{j}"].bitmap.stretch_blt(Rect.new(0,0,width,height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      @sprites["p#{j}"].bitmap.hue_change(rand(360))
      @sprites["p#{j}"].ox = width/2
      @sprites["p#{j}"].oy = height + 192 + rand(32)
      @sprites["p#{j}"].angle = rand(360)
      @sprites["p#{j}"].speed = 1 + rand(4)
      @sprites["p#{j}"].x = @viewport.rect.width/2
      @sprites["p#{j}"].y = @viewport.rect.height/2
      @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/192.0)*1.5
      @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/192.0)*1.5
    end
    @frame = 0
  end
  
  def update
    for j in 0...3
      @sprites["b#{j}"].zoom_x -= 0.025
      @sprites["b#{j}"].zoom_y -= 0.025
      @sprites["b#{j}"].opacity -= 4
      if @sprites["b#{j}"].zoom_x <= 0 || @sprites["b#{j}"].opacity <= 0
        @sprites["b#{j}"].zoom_x = 2.25
        @sprites["b#{j}"].zoom_y = 2.25
        @sprites["b#{j}"].opacity = 255
      end
      @sprites["b#{j}"].update if @frame%8==0
    end
    for j in 0...64
      @sprites["p#{j}"].angle -= @sprites["p#{j}"].speed
      @sprites["p#{j}"].opacity -= @sprites["p#{j}"].speed
      @sprites["p#{j}"].oy -= @sprites["p#{j}"].speed/2 if @sprites["p#{j}"].oy > @sprites["p#{j}"].bitmap.height
      @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/192.0)*1.5
      @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/192.0)*1.5
      if @sprites["p#{j}"].zoom_x <= 0 || @sprites["p#{j}"].oy <= 0 || @sprites["p#{j}"].opacity <= 0
        @sprites["p#{j}"].angle = rand(360)
        @sprites["p#{j}"].oy = @sprites["p#{j}"].bitmap.height + 192 + rand(32)
        @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/192.0)*1.5
        @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/192.0)*1.5
        @sprites["p#{j}"].opacity = 255
        @sprites["p#{j}"].speed = 1 + rand(4)
      end
    end
    @frame += 1
    @frame = 0 if @frame > 128
  end
  
  def dispose
    pbDisposeSpriteHash(@sprites)
  end
  
end
#===============================================================================
#  New functions for the Sprite class
#  adds new bitmap transformations
#===============================================================================
def setPictureSpriteEB(sprite,picture)
  sprite.visible = picture.visible
  # Set sprite coordinates
  sprite.y = picture.y
  sprite.z = picture.number
  # Set zoom rate, opacity level, and blend method
  sprite.zoom_x = picture.zoom_x / 100.0
  sprite.zoom_y = picture.zoom_y / 100.0
  sprite.opacity = picture.opacity
  sprite.blend_type = picture.blend_type
  # Set rotation angle and color tone
  angle = picture.angle
  sprite.tone = picture.tone
  sprite.color = picture.color
  while angle < 0
    angle += 360
  end
  angle %= 360
  sprite.angle=angle
end
#-------------------------------------------------------------------------------
#  Utilities used for move animations
#-------------------------------------------------------------------------------
class PokeBattle_Scene  
  def getCenter(sprite,zoom=false)
    zoom = zoom ? sprite.zoom_y : 1
    x = sprite.x
    y = sprite.y + (sprite.bitmap.height-sprite.oy)*zoom - sprite.bitmap.height*zoom/2
    return x, y
  end
  
  def alignSprites(sprite,target)
    sprite.ox = sprite.src_rect.width/2
    sprite.oy = sprite.src_rect.height/2
    sprite.x, sprite.y = getCenter(target)
    sprite.zoom_x, sprite.zoom_y = target.zoom_x/2, target.zoom_y/2
  end
  
  def getRealVector(targetindex,player)
    vector = (player ? PLAYERVECTOR : ENEMYVECTOR).clone
    if @battle.doublebattle && !USEBATTLEBASES
      case targetindex
      when 0
        vector[0] = vector[0] + 80
      when 1
        vector[0] = vector[0] + 192
      when 2
        vector[0] = vector[0] - 64
      when 3
        vector[0] = vector[0] - 36
      end
    end
    return vector
  end
  
  def applySpriteProperties(sprite1,sprite2)
    sprite2.x = sprite1.x
    sprite2.y = sprite1.y
    sprite2.z = sprite1.z
    sprite2.zoom_x = sprite1.zoom_x
    sprite2.zoom_y = sprite1.zoom_y
    sprite2.opacity = sprite1.opacity
    sprite2.angle = sprite1.angle
    sprite2.tone = sprite1.tone
    sprite2.color = sprite1.color
    sprite2.visible = sprite1.visible
  end
end
#===============================================================================
#  Misc. scripting tools
#===============================================================================
def checkEBFolderPath
  if !pbResolveBitmap("Graphics/Pictures/EBS/pokeballs").nil?
    return "Graphics/Pictures/EBS"
  else
    return "Graphics/Pictures"
  end
end

def checkEBFolderPathDS
  if !pbResolveBitmap("Graphics/Pictures/EBS/DS/background").nil?
    return "Graphics/Pictures/EBS/DS"
  else
    return "Graphics/Pictures"
  end
end