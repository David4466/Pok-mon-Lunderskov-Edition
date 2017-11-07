# WARNING: RPG.Net is a bit buggy. You may get "RGSS Player stopped working"
# when using an app that uses RPG.Net. I can sadly not do anything about this.


# Process of creating your own application:
#  -> Create the class
#  -> Make sure it inherits from "PoketchApp"
#  -> "Register" the app in the PoketchApps module by adding a unique ID and
#     the classname.


# Why to inherit PoketchApp and call "super" in some methods:

# class "PoketchApp"'s intention is to make your code as small as possible.
# It will make you an @bg sprite and an @viewport if you call "super" in
# the constructor of your class (def initialize). Make sure to call this first.
# It will also handle "def click?", which is a method that handles normal
# button clicks. To use, make sure to call "super" in the update method of your
# class (def update).
# To make sure everything (including the actual $Poketch.app), @bg, and @viewport
# disposes correctly, call "super" LAST in your dispose method (def dispose).


# If you only want the app to be available under certain circumstances (ON TOP OF
# THE APP ENABLED STATE), you can overwrite "def self.usable?". Apps that need
# RPG.Net to function, for example, have "return RNET".



# Additional Utility: (more can be found in Pokétch_Utility)

# <Sprite>.poketch_average: Will average out your sprite's colors to be of the
# same 4 colors the Pokétch originally has. (used for party icons)

# pbFormat(integer, digits): Better to show some examples:
#                            -> pbFormat(27,3) # => "027"
#                            -> pbFormat(12,2) # => "12"

#==============================================================================#
# Pokétch Clock. Shows the computer's time.                                    #
#==============================================================================#
class PoketchClock < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Clock/background")
    @time = Time.now
    @numbers = []
    draw_time
  end
  
  def update
    if @time.hour != Time.now.hour || @time.min != Time.now.min
      draw_time
      @time = Time.now
    end
  end
  
  def draw_time
    n = pbFormat(@time.hour,2).split("")
    n.concat(pbFormat(@time.min,2).split(""))
    for i in 0...4
      @numbers[i].dispose if @numbers[i]
      @numbers[i] = nil
      @numbers[i] = Sprite.new(@viewport)
      @numbers[i].bmp("Graphics/Pictures/Poketch/Clock/numbers")
      @numbers[i].src_rect.width = 64
      @numbers[i].src_rect.x = n[i].to_i * 64
      @numbers[i].x = [15,97,208,290][i]
      @numbers[i].y = 82
    end
  end
  
  def dispose
    for n in @numbers
      n.dispose
    end
    super
  end
end


#==============================================================================#
# Pokétch Clicker. Click your heart away.                                      #
#==============================================================================#
class PokemonTemp
  attr_accessor :click_count
end

class PoketchClicker < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Clicker/background")
    @numbers = []
    @btn = Sprite.new(@viewport)
    @btn.bmp("Graphics/Pictures/Poketch/Clicker/btn")
    @btn.x = 128
    @btn.y = 166
    $PokemonTemp.click_count = 0 if !$PokemonTemp.click_count
    draw_count
  end
  
  def draw_count
    n = pbFormat($PokemonTemp.click_count, 4).split("")
    for i in 0...4
      @numbers[i].dispose if @numbers[i]
      @numbers[i] = nil
      @numbers[i] = Sprite.new(@viewport)
      @numbers[i].bmp("Graphics/Pictures/Poketch/Clicker/numbers")
      @numbers[i].src_rect.width = 24
      @numbers[i].src_rect.x = n[i].to_i * 24
      @numbers[i].x = 135 + 30 * i
      @numbers[i].y = 68
    end
  end
  
  def update
    super
    if click?(@btn, "Graphics/Pictures/Poketch/Clicker", "btn")
      $PokemonTemp.click_count += 1
      $PokemonTemp.click_count = 0 if $PokemonTemp.click_count > 9999
      draw_count
    end
  end
  
  def dispose
    $PokemonTemp.click_count = 0
    super
  end
end


#==============================================================================#
# Pokétch Calculator. You can do basic math with this.                         #
#==============================================================================#
class Float
  def round_to(x)
    return (self * 10 ** x).round.to_f / 10 ** x
  end
end

# This one's rather complex. Ignore this.
class PoketchCalculator < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Calculator/background")
    @buttons = []
    @buttons[0] = []
    @buttons[0][0] = 0
    @buttons[0][1] = Sprite.new(@viewport)
    @buttons[0][1].bmp("Graphics/Pictures/Poketch/Calculator/btnLarge")
    @buttons[0][1].x = 32
    @buttons[0][1].y = 256
    @buttons[0][2] = Sprite.new(@viewport)
    @buttons[0][2].bmp("Graphics/Pictures/Poketch/Calculator/buttonnumbers")
    @buttons[0][2].src_rect.width = 16
    @buttons[0][2].x = @buttons[0][1].x + 24
    @buttons[0][2].y = @buttons[0][1].y + 16
    for i in 0...9
      @buttons[i+1] = []
      @buttons[i+1][0] = i+1
      @buttons[i+1][1] = Sprite.new(@viewport)
      @buttons[i+1][1].bmp("Graphics/Pictures/Poketch/Calculator/btnSmall")
      @buttons[i+1][1].x = 32 + 64 * (i % 3)
      @buttons[i+1][1].y = 192 - 64 * (i / 3).floor
      @buttons[i+1][2] = Sprite.new(@viewport)
      @buttons[i+1][2].bmp("Graphics/Pictures/Poketch/Calculator/buttonnumbers")
      @buttons[i+1][2].src_rect.width = 16
      @buttons[i+1][2].src_rect.x = 16 * (i + 1)
      @buttons[i+1][2].x = @buttons[i+1][1].x + 24
      @buttons[i+1][2].y = @buttons[i+1][1].y + 16
    end
    @operators = []
    for i in 0...6
      @operators[i] = []
      @operators[i][0] = ["+","-","*","/","=","."][i]
      @operators[i][1] = Sprite.new(@viewport)
      @operators[i][1].bmp("Graphics/Pictures/Poketch/Calculator/btn#{i == 4 ? "Large" : "Small"}")
      @operators[i][1].x = [224,288][i % 2]
      @operators[i][1].y = 128 + 64 * (i / 2).floor
      @operators[i][1].x = 160 if i == 5
      @operators[i][1].y = 256 if i == 5
      @operators[i][2] = Sprite.new(@viewport)
      @operators[i][2].bmp("Graphics/Pictures/Poketch/Calculator/operators")
      @operators[i][2].src_rect.width = 24
      @operators[i][2].src_rect.x = i * 24
      @operators[i][2].x = @operators[i][1].x + 17
      @operators[i][2].y = @operators[i][1].y + 14
    end
    @cbtn = []
    @cbtn[0] = nil
    @cbtn[1] = Sprite.new(@viewport)
    @cbtn[1].bmp("Graphics/Pictures/Poketch/Calculator/btnLarge")
    @cbtn[1].x = 224
    @cbtn[1].y = 64
    @cbtn[2] = Sprite.new(@viewport)
    @cbtn[2].bmp("Graphics/Pictures/Poketch/Calculator/cbtn")
    @cbtn[2].x = @cbtn[1].x + 19
    @cbtn[2].y = @cbtn[1].y + 16
    
    @activeoperator = []
    @activeoperator[0] = nil
    @activeoperator[1] = Sprite.new(@viewport)
    @activeoperator[1].x = 20
    @activeoperator[1].y = 18
    
    @activenums = []
    for i in 0...10
      @activenums[i] = []
      @activenums[i][0] = nil
      @activenums[i][1] = Sprite.new(@viewport)
      @activenums[i][1].bmp("Graphics/Pictures/Poketch/Calculator/empty")
      @activenums[i][1].x = 344 - 32 * i
      @activenums[i][1].y = 18
    end
    @old = ""
    @stillactive = false
    @error = false
    @oldop = nil
    @reset_on_next = false
  end
  
  def click?(btn,path,unclicked,clicked=unclicked+"Click")
    return false if !$mouse || !$mouse.click?(btn[1]) || @cooldown > -1
    @tmp = [btn,path,unclicked]
    @tmp[0][1].bmp(@tmp[1]+"/"+clicked)
    @tmp[0][2].y += 12
    @cooldown = 3
    return true
  end
  
  def update
    @cooldown -= 1 if @cooldown > -1
    if @cooldown == 0
      @tmp[0][1].bmp(@tmp[1]+"/"+@tmp[2])
      @tmp[0][2].y -= 12
    end
    for i in 0...@buttons.size
      p = (i == 0 ? "btnLarge" : "btnSmall")
      if click?(@buttons[i],"Graphics/Pictures/Poketch/Calculator",p)
        if @error
          reset_numbers
        end
        if @activeoperator[0] && @stillactive || @reset_on_next
          @stillactive = false
          @old = @activenums.map { |n| n[0] }.join.reverse
          reset_numbers
          @reset_on_next = false
        end
        if !@activenums[9][0]
          @activenums[9][1].dispose
          @activenums[9] = nil
          @activenums.compact!
          for j in 0...@activenums.size
            @activenums[j][1].x -= 32
          end
          n = []
          n[0] = @buttons[i][0]
          n[1] = Sprite.new(@viewport)
          n[1].bmp("Graphics/Pictures/Poketch/Calculator/numbers")
          n[1].src_rect.width = 20
          n[1].src_rect.x = 20 * i
          n[1].x = 344
          n[1].y = 18
          @activenums.insert(0,n)
        end
      end
    end
    for i in 0...@operators.size
      p = (i == 4 ? "btnLarge" : "btnSmall")
      if click?(@operators[i],"Graphics/Pictures/Poketch/Calculator",p)
        if @operators[i][0] == "."
          if !@activenums[9][0]
            @activenums[9][1].dispose
            @activenums[9] = nil
            @activenums.compact!
            for j in 0...@activenums.size
              @activenums[j][1].x -= 32
            end
            n = []
            n[0] = "."
            n[1] = Sprite.new(@viewport)
            n[1].bmp("Graphics/Pictures/Poketch/Calculator/dot")
            n[1].x = 344
            n[1].y = 18
            @activenums.insert(0,n)
            @reset_on_next = false
          end
        elsif @operators[i][0] == "="
          cur = @activenums.map { |n| n[0] }.join.reverse
          if !@old || @old == ""
            return
          end
          ex = nil
          @old = @old.to_f.to_s
          cur = cur.to_f.to_s
          if @activeoperator[0]
            ex = @old + @activeoperator[0] + cur
          else
            ex = cur + @oldop + @old
          end
          if ex.size == 1 || ex.size == 0
            throw_error
            return
          end
          n = (eval(ex) rescue nil)
          if !n
            throw_error
            return
          end
          reset_numbers
          # Some trickery to perform float operations properly, but also cut
          # the .0 if it's a whole numbers (all calculations are done with floats)
          n = n.to_f
          slots = 9 - n.to_s.split('.')[0].size
          n = n.round_to(slots).to_s
          n = n.chomp('.0') if n[n.size - 2..n.size] == '.0'
          n = n.reverse.split("") rescue nil
          if !n || n.size == 0 || n.size > 10
            throw_error
            return
          end
          for j in 0...n.size
            if n[j] == "-"
              @activenums[j][0] = "-"
              @activenums[j][1].bmp("Graphics/Pictures/Poketch/Calculator/operators")
              @activenums[j][1].src_rect.width = 24
              @activenums[j][1].src_rect.x = 24
            elsif n[j] == "."
              @activenums[j][0] = "."
              @activenums[j][1].bmp("Graphics/Pictures/Poketch/Calculator/dot")
            else
              @activenums[j][0] = n[j].to_i
              @activenums[j][1].bmp("Graphics/Pictures/Poketch/Calculator/numbers")
              @activenums[j][1].src_rect.width = 20
              @activenums[j][1].src_rect.x = 20 * n[j].to_i
            end
          end
          @old = cur if @activeoperator[0]
          @oldop = @activeoperator[0] if @activeoperator[0]
          @activeoperator[0] = nil
          @activeoperator[1].bitmap = nil
          @reset_on_next = true
        else
          @activeoperator[0] = @operators[i][0]
          @activeoperator[1].bmp("Graphics/Pictures/Poketch/Calculator/operators")
          @activeoperator[1].src_rect.width = 24
          @activeoperator[1].src_rect.x = 24 * i
          @stillactive = true
          @reset_on_next = false
        end
      end
    end
    if click?(@cbtn,"Graphics/Pictures/Poketch/Calculator","btnLarge")
      reset_numbers
      @old = ""
      @stillactive = false
      @activeoperator[0] = nil
      @activeoperator[1].bitmap = nil
      @oldop = nil
      @error = false
      @reset_on_next = false
    end
  end
  
  def reset_numbers
    for i in 0...10
      @activenums[i][0] = nil
      @activenums[i][1].bmp("Graphics/Pictures/Poketch/Calculator/empty")
    end
  end
  
  def throw_error
    @old = ""
    @stillactive = false
    @activeoperator[0] = nil
    @activeoperator[1].bitmap = nil
    for i in 0...10
      @activenums[i][1].bmp("Graphics/Pictures/Poketch/Calculator/error")
    end
    @error = true
  end
  
  def dispose
    for btn in @buttons
      btn[0] = nil
      btn[1].dispose if btn[1]
      btn[2].dispose if btn[2]
    end
    for op in @operators
      op[0] = nil
      op[1].dispose if op[1]
      op[2].dispose if op[2]
    end
    for n in @activenums
      n[0] = nil
      n[1].dispose if n[1]
      @activeoperator[0] = nil
      @activeoperator[1].dispose if @activeoperator
    end
    @cbtn[0] = nil
    @cbtn[1].dispose if @cbtn[1]
    @cbtn[2].dispose if @cbtn[2]
    @bg.dispose
    super
  end
end


#==============================================================================#
# Pokétch Item Finder. AKA Dowsing Machine.                                    #
#==============================================================================#
# For an item to be picked up by the Itemfinder, make sure it has ".hidden"
# (without the quotation marks) in the event name.

# How you should make your item ball events:
#  -> Kernel.pbItemBall(item)
#  -> Script: pbUnlist(event_id)
#  -> Erase event

class Game_Event
  attr_accessor :listed
  
  alias poketch_init initialize
  def initialize(map_id, event, map = nil)
    poketch_init(map_id, event, map)
    @listed = true # Set to true, but whether it's actually listed or not
                   # depends on the name.
  end
end

# If you call this on an event, it'll be no longer listed in the Itemfinder
# (if it even was)
def pbUnlist(event_id)
  $game_map.events[event_id].listed = false if $game_map.events[event_id]
end

# The Itemfinder will show this event (but still only if it has .hidden in name)
def pbList(event_id)
  $game_map.events[event_id].listed = true if $game_map.events[event_id]
end

class PoketchItemFinder < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Item Finder/background")
    @circles = []
    @items = []
  end
  
  def update
    super
    if $mouse && $mouse.inAreaLeftPress?(32,POKETCH_Y+32,384,320) && @cooldown == -1
      @cooldown = 16
      x = $mouse.x - 32
      y = $mouse.y - POKETCH_Y - 32
      if x < 384 && y < 320
        c = Sprite.new(@viewport)
        c.bmp("Graphics/Pictures/Poketch/Item Finder/circle")
        c.ox = c.bitmap.width / 2
        c.oy = c.bitmap.height / 2
        c.x = x
        c.y = y
        c.zoom_x = 0
        c.zoom_y = 0
        @circles << [40, c]
        redraw((x - 11) / 22, (y - 11) / 22)
      end
    end
    for i in 0...@circles.size
      @circles[i][0] -= 1
      @circles[i][1].zoom_x += 0.06
      @circles[i][1].zoom_y += 0.06
      if @circles[i][0] < 16
        @circles[i][1].opacity -= 16
      end
      if @circles[i][0] == 0
        @circles[i][1].dispose
        @circles[i][1] = nil
        @circles[i] = nil
      end
    end
    @circles.compact!
    for i in 0...@items.size
      @items[i][0] -= 1
      @items[i][1].opacity += 255 / (@items[i][0] > 48 ? 16.0 : @items[i][0] < 32 ? -32.0 : 255)
      if @items[i][0] == 0
        @items[i][1].dispose
        @items[i][1] = nil
        @items[i] = nil
      end
    end
    @items.compact!
    $Poketch.click_up if $mouse.click?($Poketch.btnUp)
    $Poketch.click_down if $mouse.click?($Poketch.btnDown)
  end
  
  def redraw(cx, cy)
    for i in 0...@items.size
      @items[i][1].dispose
      @items[i] = nil
    end
    @items.compact!
    for k in $game_map.events.keys
      e = $game_map.events[k]
      # This one line below is the statement that decides if an event should be
      # shown as a dot. The rest is just positioning, locating, and other crap.
      if e.name.include?(".hidden") && e.listed
        if $game_player.x - e.x >= -8 && $game_player.x - e.x <= 8
          if $game_player.y - e.y >= -7 && $game_player.y - e.y <= 7
            x = e.x - $game_player.x + 8
            y = e.y - $game_player.y + 7
            if cx - x >= -5 && cx - x <= 5
              if cy - y >= -4 && cy - y <= 4
                item = Sprite.new(@viewport)
                item.bmp("Graphics/Pictures/Poketch/Item Finder/item")
                item.x = 11 + 22 * x
                item.y = 11 + 22 * y
                item.opacity = 0
                @items << [64, item]
              end
            end
          end
        end
      end
    end
  end
  
  def dispose
    for c in @circles
      c[1].dispose
    end
    for i in @items
      i[1].dispose
    end
    super
  end
end


#==============================================================================#
# Pokétch Rotom. Tells you things depending on what you predefine.             #
#==============================================================================#
# Normal Rotom Text:
#  Array of message rotom can send by random.

# Forced Rotom Text:
#  Array of messages rotom can send by random.
#  If there are any messages in this array, it will always pick from this array.

# This will delete all other normal rotom messages.
def pbSetRotomText(array_of_messages)
  array_of_messages = [array_of_messages] if !array_of_messages.is_a?(Array)
  $Trainer.poketch_rotom_text = array_of_messages
end

# This will add to all other normal rotom messages.
def pbAddRotomText(text)
  $Trainer.poketch_rotom_text = [] if !$Trainer.poketch_rotom_text
  $Trainer.poketch_rotom_text << text
end

# This will delete a message that equals the passed "text" from the normal rotom messages
def pbDeleteRotomText(text)
  $Trainer.poketch_rotom_text = [] if !$Trainer.poketch_rotom_text
  $Trainer.poketch_rotom_text.delete(text) if $Trainer.poketch_rotom_text.include?(text)
end

# This will delete all other forced rotom messages
def pbSetForcedRotomText(array_of_message)
  array_of_messages = [array_of_messages] if !array_of_messages.is_a?(Array)
  $Trainer.poketch_rotom_text_forced = array_of_messages
end

# This will add to all other forced rotom messages
def pbAddForcedRotomText(text)
  $Trainer.poketch_rotom_text_forced = [] if !$Trainer.poketch_rotom_text_forced
  $Trainer.poketch_rotom_text_forced << text
end

# This will delete a message that equals the passed "text" from the forced rotom messages
def pbDeleteForcedRotomText(text)
  $Trainer.poketch_rotom_text_forced = [] if !$Trainer.poketch_rotom_text_forced
  if $Trainer.poketch_rotom_text_forced.include?(text)
    $Trainer.poketch_rotom_text_forced.delete(text) 
  end
end

class PokeBattle_Trainer
  attr_accessor :poketch_rotom_text
  attr_accessor :poketch_rotom_text_forced
  
  alias poketch_rotom_init initialize
  def initialize(name, trainertype)
    poketch_rotom_init(name, trainertype)
  end
end

class PoketchRotom < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Rotom/idle")
    @bg.src_rect.width = 384
    @txtbar = Sprite.new(@viewport)
    @txtbar.bmp("Graphics/Pictures/Poketch/Rotom/speech")
    @txtbar.y = 320
    @txtsprite = Sprite.new(@viewport)
    @txtsprite.bmp(384,320)
    pbSetSystemFont(@txtsprite.bitmap)
    @txtsprite.bitmap.font.size += 10
    if !$Trainer.poketch_rotom_text
      # Default Normal Rotom Text
      $Trainer.poketch_rotom_text = [
        "Bzzt! I'm here to help you out on your journey!",
        "Z-zzt! Where will we go next?"
      ]
    end
    # Default Forced Rotom Text (if you enter anything in here, this will override
    # all messages you wrote in the Normal Rotom Text array).
    if !$Trainer.poketch_rotom_text_forced
      $Trainer.poketch_rotom_text_forced = [
#        "Message here",
      ]
    end
    @txt = nil
    @i = 0
  end
  
  def update
    if $mouse && $mouse.click?(@bg) && @cooldown == -1
      if @draw
        @cooldown = 1
      else
        draw
      end
    end
    if @draw && @txt && @txt.size > 0
      if @i < @txt.size
        @cooldown = 0
        @bg.y -= 4 if @bg.y > -52
        @txtbar.y -= 5 if @txtbar.y > 210
        @txtsprite.bitmap.clear
        pbSetSystemFont(@txtsprite.bitmap)
        @txtsprite.bitmap.font.size += 2
        t = @txt[0..@i].join
        if @txtbar.y <= 220
          @bg.src_rect.x += 384 if @i % 7 == 0
          @bg.src_rect.x = 0 if @bg.src_rect.x >= @bg.bitmap.width
          drawTextEx(@txtsprite.bitmap,14,248,362,2,t,Color.new(16,41,24),
              Color.new(57,82,49))
          @i += 1
        end
      else
        @cooldown = -1
        @txt = nil
        @i = 0
        @bg.src_rect.x = 0
      end
    end
    if @cooldown == 1
      @bg.y += 4 unless @bg.y == 0
      @txtbar.y += 5 unless @txtbar.y == 320
      @txtsprite.y += 5 unless @txtbar.y == 320
      if @txtbar.y == 320
        @draw = false
        @cooldown = -1
        @txtsprite.bitmap.clear
        @txtsprite.y = 0
      end
    end
  end
  
  def draw
    t = []
    if $Trainer.poketch_rotom_text_forced.size > 0
      t = $Trainer.poketch_rotom_text_forced
    else
      t = $Trainer.poketch_rotom_text
    end
    @txt = t[rand(t.size)].split("")
    @draw = true
  end
  
  def dispose
    @txtbar.dispose
    @txtsprite.dispose
    super
  end
end


#==============================================================================#
# Pokétch Move Tester. Test type effectivenesses.                              #
#==============================================================================#
class PokeBattle_Trainer
  attr_accessor :poketch_move_tester_move
  attr_accessor :poketch_move_tester_type1
  attr_accessor :poketch_move_tester_type2
end

class PoketchMoveTester < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Move Tester/background")
    @moveBtnLeft = Sprite.new(@viewport)
    @moveBtnLeft.bmp("Graphics/Pictures/Poketch/Move Tester/btnLeft")
    @moveBtnLeft.y = 191
    @moveBtnRight = Sprite.new(@viewport)
    @moveBtnRight.bmp("Graphics/Pictures/Poketch/Move Tester/btnRight")
    @moveBtnRight.x = 176
    @moveBtnRight.y = 192
    @type1BtnLeft = Sprite.new(@viewport)
    @type1BtnLeft.bmp("Graphics/Pictures/Poketch/Move Tester/btnLeft")
    @type1BtnLeft.x = 160
    @type1BtnLeft.y = 16
    @type1BtnRight = Sprite.new(@viewport)
    @type1BtnRight.bmp("Graphics/Pictures/Poketch/Move Tester/btnRight")
    @type1BtnRight.x = 336
    @type1BtnRight.y = 16
    @type2BtnLeft = Sprite.new(@viewport)
    @type2BtnLeft.bmp("Graphics/Pictures/Poketch/Move Tester/btnLeft")
    @type2BtnLeft.x = 160
    @type2BtnLeft.y = 80
    @type2BtnRight = Sprite.new(@viewport)
    @type2BtnRight.bmp("Graphics/Pictures/Poketch/Move Tester/btnRight")
    @type2BtnRight.x = 336
    @type2BtnRight.y = 80
    @move = $Trainer.poketch_move_tester_move || 0
    @type1 = $Trainer.poketch_move_tester_type1 || 0
    @type2 = $Trainer.poketch_move_tester_type2 || -1
    @txtsprite = Sprite.new(@viewport)
    @txtsprite.bmp(384,320)
    @txt = @txtsprite.bitmap
    @excl = []
    refresh
  end
  
  def update
    super
    if click?(@moveBtnLeft,"Graphics/Pictures/Poketch/Move Tester","btnLeft")
      @move -= 1
      @move = PBTypes.maxValue if @move == -1
      @move -= 1 if PBTypes.isPseudoType?(@move)
      $Trainer.poketch_move_tester_move = @move
      refresh
    end
    if click?(@moveBtnRight,"Graphics/Pictures/Poketch/Move Tester","btnRight")
      @move += 1
      @move = 0 if @move > PBTypes.maxValue
      @move += 1 if PBTypes.isPseudoType?(@move)
      $Trainer.poketch_move_tester_move = @move
      refresh
    end
    if click?(@type1BtnLeft,"Graphics/Pictures/Poketch/Move Tester","btnLeft")
      @type1 -= 1
      @type1 = PBTypes.maxValue if @type1 == -1
      @type1 -= 1 if PBTypes.isPseudoType?(@type1)
      $Trainer.poketch_move_tester_type1 = @type1
      refresh
    end
    if click?(@type1BtnRight,"Graphics/Pictures/Poketch/Move Tester","btnRight")
      @type1 += 1
      @type1 = 0 if @type1 > PBTypes.maxValue
      @type1 += 1 if PBTypes.isPseudoType?(@type1)
      $Trainer.poketch_move_tester_type1 = @type1
      refresh
    end
    if click?(@type2BtnLeft,"Graphics/Pictures/Poketch/Move Tester","btnLeft")
      @type2 -= 1
      if @type2 == -2
        @type2 = PBTypes.maxValue
      elsif PBTypes.isPseudoType?(@type2)
        @type2 -= 1
      end
      $Trainer.poketch_move_tester_type2 = @type2
      refresh
    end
    if click?(@type2BtnRight,"Graphics/Pictures/Poketch/Move Tester","btnRight")
      @type2 += 1
      @type2 = -1 if @type2 > PBTypes.maxValue
      @type2 += 1 if PBTypes.isPseudoType?(@type2)
      $Trainer.poketch_move_tester_type2 = @type2
      refresh
    end
  end
  
  def refresh
    @txt.clear
    pbSetSystemFont(@txt)
    name2 = (@type2 == -1 ? "None" : PBTypes.getName(@type2).upcase)
    pbDrawTextPositions(@txt,[
        [PBTypes.getName(@move).upcase,112,207,2,Color.new(16,41,24),Color.new(57,82,49)],
        [PBTypes.getName(@type1).upcase,272,31,2,Color.new(16,41,24),Color.new(57,82,49)],
        [name2,272,95,2,Color.new(16,41,24),Color.new(57,82,49)]
    ])
    eff = PBTypes.getCombinedEffectiveness(@move, @type1, (@type2 == -1 ? nil : @type2))
    txt = _INTL("Regularly effective")
    txt = _INTL("Super effective") if eff > 8
    txt = _INTL("Not very effective") if eff < 8
    txt = _INTL("Not effective") if eff == 0
    pbDrawTextPositions(@txt,[
        [txt,16,271,0,Color.new(16,41,24),Color.new(57,82,49)]
    ])
    # Determines how many exclamation marks to put
    e = 0 if eff == 0
    e = 1 if eff == 1 || eff == 2
    e = 2 if eff == 4
    e = 3 if eff == 8
    e = 4 if eff == 16
    e = 5 if eff == 32
    for i in 0...6
      @excl[i].dispose if @excl[i]
      if i < e
        @excl[i] = Sprite.new(@viewport)
        @excl[i].bmp("Graphics/Pictures/Poketch/Move Tester/effectiveness")
        @excl[i].x = 48 + 16 * i
        @excl[i].y = 40
      end
    end
  end
  
  def dispose
    for e in @excl
      e.dispose
    end
    @moveBtnLeft.dispose
    @moveBtnRight.dispose
    @type1BtnRight.dispose
    @type1BtnLeft.dispose
    @type2BtnRight.dispose
    @type2BtnLeft.dispose
    @txtsprite.dispose
    super
  end
end


#==============================================================================#
# Pokétch Pedometer. Counts your steps.                                        #
#==============================================================================#
class PokeBattle_Trainer
  attr_accessor :steps
end

Events.onStepTaken += proc do
  $Trainer.steps = 0 if !$Trainer.steps
  $Trainer.steps += 1
  $Poketch.refresh if $Poketch && $Poketch.app.is_a?(PoketchPedometer)
end

class PoketchPedometer < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Pedometer/background")
    @btn = Sprite.new(@viewport)
    @btn.bmp("Graphics/Pictures/Poketch/Pedometer/btn")
    @btn.x = 133
    @btn.y = 161
    $Trainer.steps = 0 if !$Trainer.steps
    @numbers = []
    refresh
  end
  
  def update
    super
    if click?(@btn, "Graphics/Pictures/Poketch/Pedometer", "btn")
      $Trainer.steps = 0
      refresh
    end
  end
  
  def refresh
    n = pbFormat($Trainer.steps, 5)
    n = n.to_s.split("")
    for i in 0...5
      @numbers[i].dispose if @numbers[i]
      @numbers[i] = nil
      @numbers[i] = Sprite.new(@viewport)
      @numbers[i].bmp("Graphics/Pictures/Poketch/Pedometer/numbers")
      @numbers[i].src_rect.width = 24
      @numbers[i].src_rect.x = n[i].to_i * 24
      @numbers[i].x = 117 + 32 * i
      @numbers[i].y = 66
    end
  end
  
  def dispose
    @btn.dispose
    for n in @numbers
      n.dispose
    end
    super
  end
end


#==============================================================================#
# Pokétch Marking Map. Allows you to draw markers onto the map.                 #
#==============================================================================#
class PokeBattle_Trainer
  attr_accessor :poketch_markingmap_circle
  attr_accessor :poketch_markingmap_star
  attr_accessor :poketch_markingmap_cube
  attr_accessor :poketch_markingmap_triangle
  attr_accessor :poketch_markingmap_heart
  attr_accessor :poketch_markingmap_diamond
end

class PoketchMarkingMap < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Marking Map/background")
    @circle = Sprite.new(@viewport)
    @circle.bmp("Graphics/Pictures/Poketch/Marking Map/markings")
    @circle.src_rect.width = 20
    @circle.x = 208
    @circle.y = 304
    @circle.ox = @circle.bitmap.width / 6
    @circle.oy = @circle.bitmap.height / 2
    @star = Sprite.new(@viewport)
    @star.bmp("Graphics/Pictures/Poketch/Marking Map/markings")
    @star.src_rect.width = 20
    @star.src_rect.x = 20
    @star.x = 240
    @star.y = 304
    @star.ox = @star.bitmap.width / 6
    @star.oy = @star.bitmap.height / 2
    @cube = Sprite.new(@viewport)
    @cube.bmp("Graphics/Pictures/Poketch/Marking Map/markings")
    @cube.src_rect.width = 20
    @cube.src_rect.x = 40
    @cube.x = 272
    @cube.y = 304
    @cube.ox = @circle.bitmap.width / 6
    @cube.oy = @cube.bitmap.height / 2
    @triangle = Sprite.new(@viewport)
    @triangle.bmp("Graphics/Pictures/Poketch/Marking Map/markings")
    @triangle.src_rect.width = 20
    @triangle.src_rect.x = 60
    @triangle.x = 304
    @triangle.y = 304
    @triangle.ox = @triangle.bitmap.width / 6
    @triangle.oy = @triangle.bitmap.height / 2
    @heart = Sprite.new(@viewport)
    @heart.bmp("Graphics/Pictures/Poketch/Marking Map/markings")
    @heart.src_rect.width = 20
    @heart.src_rect.x = 80
    @heart.x = 336
    @heart.y = 304
    @heart.ox = @heart.bitmap.width / 6
    @heart.oy = @heart.bitmap.height / 2
    @diamond = Sprite.new(@viewport)
    @diamond.bmp("Graphics/Pictures/Poketch/Marking Map/markings")
    @diamond.src_rect.width = 20
    @diamond.src_rect.x = 100
    @diamond.x = 368
    @diamond.y = 304
    @diamond.ox = @diamond.bitmap.width / 6
    @diamond.oy = @diamond.bitmap.height / 2
    @circle.x, @circle.y = $Trainer.poketch_markingmap_circle if $Trainer.poketch_markingmap_circle
    @star.x, @star.y = $Trainer.poketch_markingmap_star if $Trainer.poketch_markingmap_star
    @cube.x, @cube.y = $Trainer.poketch_markingmap_cube if $Trainer.poketch_markingmap_cube
    @triangle.x, @triangle.y = $Trainer.poketch_markingmap_triangle if $Trainer.poketch_markingmap_triangle
    @heart.x, @heart.y = $Trainer.poketch_markingmap_heart if $Trainer.poketch_markingmap_heart
    @diamond.x, @diamond.y = $Trainer.poketch_markingmap_diamond if $Trainer.poketch_markingmap_diamond
    @obj = [@circle, @star, @cube, @triangle, @heart, @diamond]
    @active = nil
  end
  
  def update
    super
    for i in 0...@obj.size
      if @cooldown == -1 && $mouse && $mouse.click?(@obj[i]) && !@active
        @active = i
      end
    end
    if @active && $mouse.x - 32 > 0 && $mouse.x - 32 < 384 && 
       $mouse.y - POKETCH_Y - 32 > 0 && $mouse.y - POKETCH_Y - 32 < 320
      @obj[@active].zoom_x = 2
      @obj[@active].zoom_y = 2
      @obj[@active].x = $mouse.x - 32
      @obj[@active].y = $mouse.y - POKETCH_Y - 32
      $Trainer.poketch_markingmap_circle = @circle.x, @circle.y if @active == 0
      $Trainer.poketch_markingmap_star = @star.x, @star.y if @active == 1
      $Trainer.poketch_markingmap_cube = @cube.x, @cube.y if @active == 2
      $Trainer.poketch_markingmap_triangle = @triangle.x, @triangle.y if @active == 3
      $Trainer.poketch_markingmap_heart = @heart.x, @heart.y if @active == 4
      $Trainer.poketch_markingmap_diamond = @diamond.x, @diamond.y if @active == 5
      if $mouse.press?
        @obj[@active].x = $mouse.x - 32
        @obj[@active].y = $mouse.y - POKETCH_Y - 32
        @obj[@active].zoom_x = 1
        @obj[@active].zoom_y = 1
        @active = nil
        @cooldown = 5
      end
    end
  end
  
  def dispose
    for obj in @obj
      obj.dispose
    end
    super
  end
end


#==============================================================================#
# Pokétch Matchup Checker. Check how your Pokémon match up with one another.   #
#==============================================================================#
def pbGetCompat(poke1, poke2)
  temp1 = $PokemonGlobal.daycare[0].clone
  temp2 = $PokemonGlobal.daycare[1].clone
  $PokemonGlobal.daycare[0] = [poke1,poke1.level]
  $PokemonGlobal.daycare[1] = [poke2,poke2.level]
  compat = pbDayCareGetCompat
  $PokemonGlobal.daycare[0] = temp1
  $PokemonGlobal.daycare[1] = temp2
  return compat
end

class PoketchMatchupChecker < PoketchApp
  def self.usable?
    return $Trainer.party.size > 1
  end
  
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Matchup Checker/background")
    @btn = Sprite.new(@viewport)
    @btn.bmp("Graphics/Pictures/Poketch/Matchup Checker/btn")
    @btn.x = 144
    @btn.y = 232
    @poke1 = 0
    @poke2 = 1
    @icons = [nil, nil]
    draw_pokes
    @hearts = []
    @luvdiscLeft = Sprite.new(@viewport)
    @luvdiscLeft.bmp("Graphics/Pictures/Poketch/Matchup Checker/luvdisc")
    @luvdiscLeft.x = 36
    @luvdiscLeft.y = 104
    
    @luvdiscRight = Sprite.new(@viewport)
    @luvdiscRight.bmp("Graphics/Pictures/Poketch/Matchup Checker/luvdisc")
    @luvdiscRight.x = 288
    @luvdiscRight.y = 104
    @luvdiscRight.mirror = true
    @n = nil
  end
  
  def update
    super
    if !@n
      if click?(@btn, "Graphics/Pictures/Poketch/Matchup Checker", "btn")
        redraw
        c = pbGetCompat($Trainer.party[@poke1], $Trainer.party[@poke2])
        @n = [[72,29,59,69][c], c, -1]
      end
      if $mouse.inAreaLeftPress?(32+16,POKETCH_Y+32+228,96,72) && @cooldown == -1
        @poke1 += 1
        @poke1 = 0 if @poke1 >= $Trainer.party.size
        @poke1 += 1 if @poke1 == @poke2
        @poke1 = 0 if @poke1 >= $Trainer.party.size
        pbPlayCry($Trainer.party[@poke1].species)
        @cooldown = 5
        redraw
      elsif $mouse.inAreaLeftPress?(32+272,POKETCH_Y+32+228,96,72) && @cooldown == -1
        @poke2 += 1
        @poke2 = 0 if @poke2 >= $Trainer.party.size
        @poke2 += 1 if @poke2 == @poke1
        @poke2 = 0 if @poke2 >= $Trainer.party.size
        pbPlayCry($Trainer.party[@poke2].species)
        @cooldown = 5
        redraw
      end
    end
    if @n
      if @n[1] == 0
        if @n[0] >= 40
          @luvdiscLeft.x += 1
          @luvdiscRight.x -= 1
        elsif @n[0] <= 24
          @luvdiscRight.mirror = false
          @luvdiscLeft.mirror = true
          @luvdiscLeft.x -= 2
          @luvdiscRight.x += 2
        end
      elsif @n[1] > 0
        @luvdiscLeft.x += 1
        @luvdiscRight.x -= 1
      end
      @n[0] -= 1
      if @n[1] > 0 && @n[0] % 30 == 0
        @n[2] += 1
        @hearts[@n[2]] = Sprite.new(@viewport)
        @hearts[@n[2]].bmp("Graphics/Pictures/Poketch/Matchup Checker/heart")
        @hearts[@n[2]].x = 100 + 64 * @n[2]
        @hearts[@n[2]].y = 4
      end
      @n = nil if @n[0] == 0
    end
  end
  
  def redraw
    draw_pokes
    @luvdiscLeft.x = 36
    @luvdiscLeft.mirror = false
    @luvdiscRight.x = 288
    @luvdiscRight.mirror = true
    for i in 0...3
      @hearts[i].dispose if @hearts[i]
    end
  end
  
  def draw_pokes
    for i in 0...@icons.size
      @icons[i].dispose if @icons[i]
      @icons[i] = nil
      @icons[i] = Sprite.new(@viewport)
      sp = pbFormat($Trainer.party[[@poke1,@poke2][i]].species)
      @icons[i].bmp("Graphics/Icons/icon#{sp}")
      @icons[i].poketch_average
      @icons[i].src_rect.width = @icons[i].bitmap.width / 2
      @icons[i].ox = @icons[i].bitmap.width / 4
      @icons[i].oy = @icons[i].bitmap.height / 2
      @icons[i].x = [64,320][i]
      @icons[i].y = 264
    end
  end
  
  def dispose
    for i in @icons
      i.dispose
    end
    @luvdiscLeft.dispose
    @luvdiscRight.dispose
    for h in @hearts
      h.dispose
    end
    super
  end
end


#==============================================================================#
# Pokétch Party app. Displays your team with their items.                      #
#==============================================================================#
class PoketchParty < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/blank")
    @pokemon = []
    refresh
  end
  
  def update
    super
    # Refresh every 80 frames
    if @cooldown == -1
      refresh
      @cooldown = 80
    end
    for p in @pokemon
      if $mouse.press?(p[1])
        pbPlayCry(p[0])
      end
    end
  end
  
  def refresh
    for i in 0...6
      if @pokemon[i]
        @pokemon[i][1].dispose if @pokemon[i][1]
        @pokemon[i][2].dispose if @pokemon[i][2]
        @pokemon[i][3].dispose if @pokemon[i][3]
        @pokemon[i][4].dispose if @pokemon[i][4]
        @pokemon[i] = nil
      end
      if $Trainer.party[i]
        @pokemon[i] = []
        @pokemon[i][0] = $Trainer.party[i].species
        @pokemon[i][1] = Sprite.new(@viewport)
        @pokemon[i][1].bmp("Graphics/Icons/icon#{pbFormat($Trainer.party[i].species)}")
        if $Trainer.party[0].eggsteps == 0 && $Trainer.party[0].hp <= 0
          @pokemon[i][1].color = Color.new(82,132,82)
        else
          @pokemon[i][1].poketch_average
        end
        @pokemon[i][1].src_rect.width = @pokemon[i][1].bitmap.width / 2
        @pokemon[i][1].ox = @pokemon[i][1].bitmap.width / 4
        @pokemon[i][1].oy = @pokemon[i][1].bitmap.height / 2
        @pokemon[i][1].zoom_x = 1.5
        @pokemon[i][1].zoom_y = 1.5
        @pokemon[i][1].x = [95,287][i % 2]
        @pokemon[i][1].y = [46,142,238][(i / 2).floor]
        @pokemon[i][1].z = 1
        @pokemon[i][2] = Sprite.new(@viewport)
        @pokemon[i][2].bmp("Graphics/Pictures/Poketch/Party/hpbar")
        @pokemon[i][2].x = [28,220][i % 2]
        @pokemon[i][2].y = [86,182,270][(i / 2).floor]
        @pokemon[i][3] = Sprite.new(@viewport)
        @pokemon[i][3].bmp("Graphics/Pictures/Poketch/Party/hp")
        perc = $Trainer.party[i].hp.to_f / $Trainer.party[i].totalhp.to_f
        @pokemon[i][3].src_rect.width = perc * @pokemon[i][3].bitmap.width
        @pokemon[i][3].x = @pokemon[i][2].x + 4
        @pokemon[i][3].y = @pokemon[i][2].y + 4
        if $Trainer.party[i].item && $Trainer.party[i].item > 0
          @pokemon[i][4] = Sprite.new(@viewport)
          @pokemon[i][4].bmp("Graphics/Pictures/Poketch/Party/item")
          @pokemon[i][4].x = @pokemon[i][2].x + 112
          @pokemon[i][4].y = @pokemon[i][2].y - 26
        end
      end
    end
  end
  
  def dispose
    for i in 0...6
      if @pokemon[i]
        @pokemon[i][1].dispose if @pokemon[i][1]
        @pokemon[i][2].dispose if @pokemon[i][2]
        @pokemon[i][3].dispose if @pokemon[i][3]
        @pokemon[i][4].dispose if @pokemon[i][4]
        @pokemon[i] = nil
      end
    end
    super
  end
end


#==============================================================================#
# Pokétch Color Changer. Changes the overlay color of the screen.              #
#==============================================================================#
class PokeBattle_Trainer
  attr_accessor :poketch_color
end

class PoketchColorChanger < PoketchApp
  def initialize
    super
    @pos = [48,80,144,176,240,272]
    @bg.bmp("Graphics/Pictures/Poketch/Color Changer/background")
    @sel = $Trainer.poketch_color || 0
    @slider = Sprite.new(@viewport)
    @slider.bmp("Graphics/Pictures/Poketch/Color Changer/slider")
    @slider.ox = 64
    @slider.x = @pos[@sel]
    @slider.y = 232
  end
  
  def update
    if $mouse && $mouse.drag_object_x?(@slider)
      @slider.x = 48 if @slider.x < 48
      @slider.x = 272 if @slider.x > 272
      case @slider.x
      when 48..64
        @sel = 0
      when 65..112
        @sel = 1
      when 113..160
        @sel = 2
      when 161..208
        @sel = 3
      when 209..256
        @sel = 4
      else
        @sel = 5
      end
      @slider.x = @pos[@sel]
      if @sel == 0
        $Poketch.no_color
      else
        $Poketch.set_color("Graphics/Pictures/Poketch/Color Changer/overlay#{@sel}")
      end
      $Trainer.poketch_color = @sel
    end
  end
  
  def dispose
    @slider.dispose
    super
  end
end


#==============================================================================#
# Pokétch Kitchen Timer. Can count down from 99 minutes max.                   #
#==============================================================================#
class PokemonTemp
  attr_reader :poketch_timer
  attr_accessor :poketch_timer_running
  
  def poketch_timer=(value)
    @poketch_timer = value
    @poketch_timer = 0 if @poketch_timer < 0
  end
end

module Graphics
  class << Graphics
    alias poketch_timer_update update
  end
  
  def self.update
    poketch_timer_update
    return if !$Poketch
    return if !$PokemonTemp || !$PokemonTemp.poketch_timer || !$PokemonTemp.poketch_timer_running
    if Graphics.frame_count % Graphics.frame_rate == 0
      $PokemonTemp.poketch_timer -= 1
      $Poketch.app.refresh if $Poketch.app.is_a?(PoketchKitchenTimer)
    end
  end
end

class PoketchKitchenTimer < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Kitchen Timer/#{$PokemonTemp.poketch_timer_running ? "active" : "idle"}")
    @startBtn = Sprite.new(@viewport)
    $PokemonTemp.poketch_timer = 0 if !$PokemonTemp.poketch_timer
    path = "startBtn"
    path = "startBtnClick" if $PokemonTemp.poketch_timer_running ||
                              $PokemonTemp.poketch_timer == 0
    @startBtn.bmp("Graphics/Pictures/Poketch/Kitchen Timer/#{path}")
    @startBtn.y = 256
    @stopBtn = Sprite.new(@viewport)
    path = $PokemonTemp.poketch_timer_running ? "stopBtn" : "stopBtnClick"
    @stopBtn.bmp("Graphics/Pictures/Poketch/Kitchen Timer/#{path}")
    @stopBtn.x = 128
    @stopBtn.y = 256
    @resetBtn = Sprite.new(@viewport)
    @resetBtn.bmp("Graphics/Pictures/Poketch/Kitchen Timer/resetBtn")
    @resetBtn.x = 256
    @resetBtn.y = 256
    @numbers = []
    @arrows = []
    refresh
    for i in 0...8
      @arrows[i] = Sprite.new(@viewport)
      path = ["up","down"][(i / 4).floor]
      @arrows[i].bmp("Graphics/Pictures/Poketch/Kitchen Timer/arrow#{path}")
      @arrows[i].x = [114,146,210,242][i % 4]
      @arrows[i].y = [136,224][(i / 4).floor]
      @arrows[i].visible = !$PokemonTemp.poketch_timer_running
    end
    @canstart = false if $PokemonTemp.poketch_timer_running || $PokemonTemp.poketch_timer == 0
    @frame = 0
    @i = nil
  end
  
  def update
    super
    if @i
      @i += 1
      if @i == 8
        @bg.bmp("Graphics/Pictures/Poketch/Kitchen Timer/done1")
      elsif @i == 16
        @bg.bmp("Graphics/Pictures/Poketch/Kitchen Timer/done2")
      end
      @i = 0 if @i == 16
    end
    @frame += 1
    @frame = 0 if @frame == 41
    unless $PokemonTemp.poketch_timer_running
      for i in 0...8
        if $mouse.click?(@arrows[i])
          increment = [600,60,10,1][i % 4]
          $PokemonTemp.poketch_timer += [1,-1][(i / 4).floor] * increment
          $PokemonTemp.poketch_timer = 0 if $PokemonTemp.poketch_timer >= 6000
          update_can_start
          refresh
        end
        @arrows[i].visible = @frame < 20
      end
    end
    if click?(@resetBtn,"Graphics/Pictures/Poketch/Kitchen Timer","resetBtn")
      $PokemonTemp.poketch_timer_running = false
      $PokemonTemp.poketch_timer = 0
      for i in 0...8
        @arrows[i].visible = true
      end
      @bg.bmp("Graphics/Pictures/Poketch/Kitchen Timer/idle")
      update_can_start
      @stopBtn.bmp("Graphics/Pictures/Poketch/Kitchen Timer/stopBtnClick")
      refresh
      @frame = 20
      @i = nil
    end
    if $mouse.click?(@startBtn) && !$PokemonTemp.poketch_timer_running && @canstart
      @startBtn.bmp("Graphics/Pictures/Poketch/Kitchen Timer/startBtnClick")
      @stopBtn.bmp("Graphics/Pictures/Poketch/Kitchen Timer/stopBtn")
      $PokemonTemp.poketch_timer_running = true
      for i in 0...8
        @arrows[i].visible = false
      end
      @bg.bmp("Graphics/Pictures/Poketch/Kitchen Timer/active")
      @i = nil
    end
    if $mouse.click?(@stopBtn) && $PokemonTemp.poketch_timer_running
      @startBtn.bmp("Graphics/Pictures/Poketch/Kitchen Timer/startBtn")
      @stopBtn.bmp("Graphics/Pictures/Poketch/Kitchen Timer/stopBtnClick")
      for i in 0...8
        @arrows[i].visible = true
      end
      @bg.bmp("Graphics/Pictures/Poketch/Kitchen Timer/idle")
      update_can_start
      $PokemonTemp.poketch_timer_running = false
      @frame = 20
      @i = nil
    end
  end
  
  def update_can_start
    if $PokemonTemp.poketch_timer > 0
      @canstart = true
      @startBtn.bmp("Graphics/Pictures/Poketch/Kitchen Timer/startBtn")
    else
      @canstart = false
      @startBtn.bmp("Graphics/Pictures/Poketch/Kitchen Timer/startBtnClick")
    end
  end
  
  def refresh
    n = [0,0,0,0]
    begin
      mins = ($PokemonTemp.poketch_timer / 60).floor
      secs = $PokemonTemp.poketch_timer % 60
      nmin = pbFormat(mins, 2).split("")
      nsec = pbFormat(secs, 2).split("")
      n = nmin.concat(nsec)
    rescue; end
    for i in 0...4
      @numbers[i].dispose if @numbers[i]
      @numbers[i] = nil
      @numbers[i] = Sprite.new(@viewport)
      @numbers[i].bmp("Graphics/Pictures/Poketch/Kitchen Timer/numbers")
      @numbers[i].src_rect.width = 24
      @numbers[i].src_rect.x = 24 * n[i].to_i
      @numbers[i].x = [116,148,212,244][i]
      @numbers[i].y = 160
    end
    @i = 0 if $PokemonTemp.poketch_timer <= 0 && !@i && $PokemonTemp.poketch_timer_running
  end
  
  def dispose
    @startBtn.dispose
    @stopBtn.dispose
    @resetBtn.dispose
    for n in @numbers
      n.dispose
    end
    super
  end
end


#==============================================================================#
# Pokétch Analog Watch. Displays the current time, but analog.                 #
#==============================================================================#
class PoketchAnalogWatch < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Analog Watch/background")
    @long = Sprite.new(@viewport)
    @long.bmp("Graphics/Pictures/Poketch/Analog Watch/long")
    @long.ox = @long.bitmap.width / 2
    @long.oy = @long.bitmap.height
    @long.x = 192
    @long.y = 168
    @short = Sprite.new(@viewport)
    @short.bmp("Graphics/Pictures/Poketch/Analog Watch/short")
    @short.ox = @short.bitmap.width / 2
    @short.oy = @short.bitmap.height
    @short.x = 192
    @short.y = 168
    @time = Time.now
    position
  end
  
  def position
    @short.angle = (@time.hour % 12) / 12.0 * -360
    @long.angle = @time.min / 60.0 * -360
  end
  
  def update
    if @time.hour != Time.now.hour || @time.min != Time.now.min
      @time = Time.now
      position
    end
  end
  
  def dispose
    @long.dispose
    @short.dispose
    super
  end
end


#==============================================================================#
# Pokétch Stat Display. Shows party members' EVs/IVs.                          #
#==============================================================================#
class PoketchStatDisplay < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Stat Display/background")
    @evBtn = Sprite.new(@viewport)
    @evBtn.bmp("Graphics/Pictures/Poketch/Stat Display/evBtnClick")
    @evBtn.x = 268
    @evBtn.y = 108
    @ivBtn = Sprite.new(@viewport)
    @ivBtn.bmp("Graphics/Pictures/Poketch/Stat Display/ivBtn")
    @ivBtn.x = 268
    @ivBtn.y = 188
    @sel = 0
    @mode = :ev
    @icon = Sprite.new(@viewport)
    @icon.bmp("Graphics/Icons/icon#{pbFormat($Trainer.party[@sel].species)}")
    @icon.poketch_average
    @icon.src_rect.width = @icon.bitmap.width / 2
    @icon.ox = @icon.bitmap.width / 4
    @icon.oy = @icon.bitmap.height / 2
    @icon.x = 312
    @icon.y = 52
    @txtsprite = Sprite.new(@viewport)
    @txtsprite.bmp(384,320)
    @txt = @txtsprite.bitmap
    pbSetSystemFont(@txt)
    @stats = []
    draw
  end
  
  def update
    super
    if $mouse.click?(@ivBtn)
      @ivBtn.bmp("Graphics/Pictures/Poketch/Stat Display/ivBtnClick")
      @evBtn.bmp("Graphics/Pictures/Poketch/Stat Display/evBtn")
      @mode = :iv
      draw
    end
    if $mouse.click?(@evBtn)
      @evBtn.bmp("Graphics/Pictures/Poketch/Stat Display/evBtnClick")
      @ivBtn.bmp("Graphics/Pictures/Poketch/Stat Display/ivBtn")
      @mode = :ev
      draw
    end
    if $mouse.inAreaLeftPress?(296,POKETCH_Y+48,98,72) && @cooldown == -1
      @cooldown = 8
      @sel += 1
      @sel = 0 if @sel >= $Trainer.party.size
      pbPlayCry($Trainer.party[@sel].species)
      @icon.bmp("Graphics/Icons/icon#{pbFormat($Trainer.party[@sel].species)}")
      @icon.poketch_average
      @icon.src_rect.width = @icon.bitmap.width / 2
      @icon.ox = @icon.bitmap.width / 4
      @icon.oy = @icon.bitmap.height / 2
      draw
    end
  end
  
  def draw
    @txt.clear
    pbDrawTextPositions(@txt,[
        [_INTL("HP"),102,12,0,Color.new(16,41,24),Color.new(57,82,49)],
        [_INTL("Atk."),102,64,0,Color.new(16,41,24),Color.new(57,82,49)],
        [_INTL("Def."),102,116,0,Color.new(16,41,24),Color.new(57,82,49)],
        [_INTL("SpAtk."),102,168,0,Color.new(16,41,24),Color.new(57,82,49)],
        [_INTL("SpDef."),102,220,0,Color.new(16,41,24),Color.new(57,82,49)],
        [_INTL("Speed"),102,272,0,Color.new(16,41,24),Color.new(57,82,49)]
    ])
    a = (@mode == :ev ? $Trainer.party[@sel].ev : $Trainer.party[@sel].iv)
    # Sorting it to [HP,Atk,Def,SpAtk,SpDef,Speed]
    t = a[3]
    a[3] = nil
    a.compact!
    a << t
    for i in 0...a.size
      @stats[i] = [] if !@stats[i]
      n = pbFormat(a[i], a[i].to_s.size).split("")
      for j in 0...3
        @stats[i][j].dispose if @stats[i][j]
        if j < n.size
          @stats[i][j] = Sprite.new(@viewport)
          @stats[i][j].bmp("Graphics/Pictures/Poketch/Stat Display/numbers")
          @stats[i][j].src_rect.width = 20
          @stats[i][j].src_rect.x = 20 * n[j].to_i
          @stats[i][j].x = [[40],[24,56],[16,40,64]][n.size - 1][j]
          @stats[i][j].y = 12 + 52 * i
        end
      end
    end
  end
  
  def dispose
    @evBtn.dispose
    @ivBtn.dispose
    for i in 0...6
      next if !@stats[i]
      for j in 0...3
        @stats[i][j].dispose if @stats[i][j]
      end
      @stats[i] = nil
    end
    @icon.dispose
    @txtsprite.dispose
    super
  end
end


#==============================================================================#
# Pokétch Roulette. Spins an arrow and stops when you tell it to.              #
#==============================================================================#
class PoketchRoulette < PoketchApp
  # Only usable if RPG.Net is found
  # RNET is a boolean; true if RPG.Net.dll is found, false if not.
  def self.usable?
    return RNET
  end
  
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Roulette/background")
    @arrow = Sprite.new(@viewport)
    @arrow.bmp("Graphics/Pictures/Poketch/Roulette/arrow")
    @arrow.ox = @arrow.bitmap.width / 2
    @arrow.oy = @arrow.bitmap.height / 2
    @arrow.x = 160
    @arrow.y = 160
    @arrow.z = 2
    @playBtn = Sprite.new(@viewport)
    @playBtn.bmp("Graphics/Pictures/Poketch/Roulette/playBtn")
    @playBtn.x = 310
    @playBtn.y = 28
    @stopBtn = Sprite.new(@viewport)
    @stopBtn.bmp("Graphics/Pictures/Poketch/Roulette/stopBtnClick")
    @stopBtn.x = 310
    @stopBtn.y = 120
    @clearBtn = Sprite.new(@viewport)
    @clearBtn.bmp("Graphics/Pictures/Poketch/Roulette/clearBtn")
    @clearBtn.x = 310
    @clearBtn.y = 212
    
    @board = Sprite.new(@viewport)
    @board.bmp(280,280)
    @board.x = 20
    @board.y = 20
    
    @overlays = []
    @overlays[0] = Sprite.new(@viewport)
    @overlays[0].bmp("Graphics/Pictures/Poketch/Roulette/circleOverlay1")
    @overlays[0].x = 128
    @overlays[0].y = 128
    @overlays[0].z = 1
    @overlays[1] = Sprite.new(@viewport)
    @overlays[1].bmp("Graphics/Pictures/Poketch/Roulette/circleOverlay2")
    @overlays[1].x = 20
    @overlays[1].y = 20
    @overlays[1].z = 1
    
    @playing = false
    @stopping = false
    @frame = 0
    
    @olddata = []
    @newdata = []
  end
  
  def update
    super
    if $mouse.click?(@playBtn) && !@playing
      @playBtn.bmp("Graphics/Pictures/Poketch/Roulette/playBtnClick")
      @stopBtn.bmp("Graphics/Pictures/Poketch/Roulette/stopBtn")
      @clearBtn.bmp("Graphics/Pictures/Poketch/Roulette/clearBtnClick")
      @playing = true
    end
    if @playing
      if @stopping
        @arrow.angle -= 3 * [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16][[(@frame / 4).floor - 1,0].max]
        @frame -= 1
        if @frame <= 0
          @frame = 0
          @playing = false
          @stopping = false
          @playBtn.bmp("Graphics/Pictures/Poketch/Roulette/playBtn")
          @stopBtn.bmp("Graphics/Pictures/Poketch/Roulette/stopBtnClick")
          @clearBtn.bmp("Graphics/Pictures/Poketch/Roulette/clearBtn")
        end
      else
        @arrow.angle -= 3 * [(@frame / 2).floor,16].min
        @frame += 1
      end
    end
    if !@playing && click?(@clearBtn,"Graphics/Pictures/Poketch/Roulette","clearBtn")
      @board.bitmap.clear
    end
    if $mouse.click?(@stopBtn) && @playing
      @stopBtn.bmp("Graphics/Pictures/Poketch/Roulette/stopBtnClick")
      @frame = 64
      @stopping = true
    end
    if !@playing
      if $mouse.press?(@board) && !@player
        @newdata = [$mouse.x-52,$mouse.y-POKETCH_Y-52]
      else
        @olddata.clear
        @newdata.clear
      end
    end
    if @newdata.size > 0
      if @olddata.size > 0
        @board.bitmap.draw_line(@olddata[0],@olddata[1],@newdata[0],@newdata[1],
            Color.new(16,41,24),4)
      end
      @olddata = @newdata.clone
      @newdata.clear
    end
  end
  
  def dispose
    @playBtn.dispose
    @stopBtn.dispose
    @clearBtn.dispose
    @arrow.dispose
    for o in @overlays
      o.dispose
    end
    @board.dispose
    super
  end
end


#==============================================================================#
# Pokétch Day-Care Checker. Shows you what you got going on in the Day-care.   #
#==============================================================================#
class PoketchDayCareChecker < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Day Care Checker/background")
    @pokes = []
    refresh
    @frame = 0
  end
  
  def update
    @frame += 1
    if @frame % 50 == 0
      @egg.dispose if @egg
      if pbEggGenerated?
        @egg = Sprite.new(@viewport)
        @egg.bmp("Graphics/Pictures/Poketch/Day Care Checker/egg")
        @egg.x = 166
        @egg.y = 204
      end
    end
    if @frame == 100
      refresh
      @frame = 0
    end
  end
  
  def refresh
    for i in 0...2
      @pokes[i] = [] if !@pokes[i]
      if $PokemonGlobal.daycare[i] && $PokemonGlobal.daycare[i][0].is_a?(PokeBattle_Pokemon)
        p = $PokemonGlobal.daycare[i]
        @pokes[i][0].dispose if @pokes[i][0]
        @pokes[i][0] = Sprite.new(@viewport)
        @pokes[i][0].bmp("Graphics/Icons/icon#{pbFormat(p[0].species)}")
        @pokes[i][0].poketch_average
        @pokes[i][0].src_rect.width = @pokes[i][0].bitmap.width / 2
        @pokes[i][0].mirror = true
        @pokes[i][0].ox = @pokes[i][0].bitmap.width / 4
        @pokes[i][0].oy = @pokes[i][0].bitmap.height / 2
        @pokes[i][0].zoom_x = 2
        @pokes[i][0].zoom_y = 2
        @pokes[i][0].x = [82,304][i]
        @pokes[i][0].y = 224
        n = pbFormat(p[1]).split("")
        for j in 0...3
          @pokes[i][j+1].dispose if @pokes[i][j+1]
          @pokes[i][j+1] = Sprite.new(@viewport)
          @pokes[i][j+1].bmp("Graphics/Pictures/Poketch/Day Care Checker/numbers")
          @pokes[i][j+1].src_rect.width = 16
          @pokes[i][j+1].src_rect.x = n[j].to_i * 16
          @pokes[i][j+1].x = [56,264][i] + 32 * j
          @pokes[i][j+1].y = 40
        end
      end
    end
  end
  
  def dispose
    for i in 0...2
      next if !@pokes[i]
      for j in 0...4
        next if !@pokes[i][j]
        @pokes[i][j].dispose
      end
    end
    @egg.dispose if @egg
    super
  end
end


#==============================================================================#
# Pokétch Pokémon History. Lists 12 most recent caught, evolved, and hatched.  #
#==============================================================================#
# Whenever a Pokémon evolves, is traded, caught, or hatched, it needs to be
# registered. This below all handles that tracking, and then the actual app.

#========= This all handles Pokémon History tracking =========#
# The actual history list (tracked in $Trainer)
class PokeBattle_Trainer
  attr_writer :pokemonhistory
  
  def pokemonhistory
    @pokemonhistory = [] if !@pokemonhistory
    return @pokemonhistory
  end
end

# Pushes to $Trainer.pokemonhistory and deletes a duplicate if found
def pbPushHistory(pokemon)
  unless $Trainer.pokemonhistory.size > 0 &&
         isConst?($Trainer.pokemonhistory[$Trainer.pokemonhistory.size - 1].species,
         PBSpecies,:NINJASK) && isConst?(pokemon.species,PBSpecies,:SHEDINJA)
    for i in 0...$Trainer.pokemonhistory.size
      if $Trainer.pokemonhistory[i].personalID == pokemon.personalID
        $Trainer.pokemonhistory[i] = nil
        break
      end
    end
  end
  $Trainer.pokemonhistory.compact!
  $Trainer.pokemonhistory << pokemon.clone
  $Poketch.app.refresh if $Poketch && $Poketch.app.is_a?(PoketchPokemonHistory)
end

# Registers traded Pokémon to $Trainer.pokemonhistory
if defined?(PokemonTrade_Scene)
  class PokemonTrade_Scene
    alias poketch_trade pbTrade
    def pbTrade
      poketch_trade
      pbPushHistory(@pokemon2)
    end
  end
else
  class PokemonTradeScene
    alias poketch_trade pbTrade
    def pbTrade
      poketch_trade
      pbPushHistory(@pokemon2)
    end
  end
end

# Registers evolved Pokémon to $Trainer.pokemonhistory
class PokemonTemp
  attr_accessor :registerOnCalc
end

class PokeBattle_Pokemon
  alias poketch_calcStats calcStats
  def calcStats
    poketch_calcStats
    pbPushHistory(self) if $PokemonTemp.registerOnCalc
  end
end

class PokemonEvolutionScene
  alias poketch_evolution pbEvolution
  def pbEvolution(cancancel = true)
    $PokemonTemp.registerOnCalc = true
    poketch_evolution(cancancel)
    $PokemonTemp.registerOnCalc = false
  end
end

# Registers hatched Pokémon to $Trainer.pokemonhistory
alias poketch_hatch pbHatch
def pbHatch(pokemon)
  poketch_hatch(pokemon)
  pbPushHistory(pokemon)
end

# Registers caught Pokémon to $Trainer.pokemonhistory
module PokeBattle_BattleCommon
  alias poketch_store pbStorePokemon
  def pbStorePokemon(pokemon)
    poketch_store(pokemon)
    pbPushHistory(pokemon)
  end
end
#========= End all handling Pokémon History tracking =========#

class PoketchPokemonHistory < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Pokemon History/background")
    @pokemon = []
    refresh
  end
  
  def update
    $Poketch.click_up if $mouse.click?($Poketch.btnUp)
    $Poketch.click_down if $mouse.click?($Poketch.btnDown)
    for p in @pokemon
      if $mouse.click?(p[0])
        pbPlayCry(p[1])
      end
    end
  end
  
  def refresh
    ret = $Trainer.pokemonhistory.clone
    if $Trainer.pokemonhistory.size > 12
      ret = $Trainer.pokemonhistory[-12,12]
    end
    ret.reverse!
    for i in 0...12
      @pokemon[i] = [] if !@pokemon[i]
      @pokemon[i][0].dispose if @pokemon[i][0]
      if i <= ret.size - 1
        @pokemon[i][0] = Sprite.new(@viewport)
        @pokemon[i][0].bmp("Graphics/Icons/icon#{pbFormat(ret[i].species)}")
        @pokemon[i][0].poketch_average
        @pokemon[i][0].src_rect.width = @pokemon[i][0].bitmap.width / 2
        @pokemon[i][0].zoom_x = 1.5
        @pokemon[i][0].zoom_y = 1.5
        @pokemon[i][0].ox = @pokemon[i][0].bitmap.width / 4
        @pokemon[i][0].oy = @pokemon[i][0].bitmap.height / 2
        @pokemon[i][0].x = [64,144,224,304][i % 4]
        @pokemon[i][0].y = [82,168,256][(i / 4).floor]
        @pokemon[i][1] = ret[i].species
      end
    end
  end
  
  def dispose
    for p in @pokemon
      p[0].dispose if p[0]
    end
    @pokemon.clear
    super
  end
end


#==============================================================================#
# Pokétch Calendar. Shows you the days of this month.                          #
#==============================================================================#
class PokeBattle_Trainer
  attr_accessor :calendar_month
  attr_accessor :calendar_marked
end

def pbIsLeapYear?(y)
  return (y % 4 == 0) && !(y % 100 == 0) || (y % 400 == 0)
end

def pbGetTotalDays(t)
  return 29 if t.month == 2 && pbIsLeapYear?(t.year)
  return [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][t.month - 1]
end

def pbFirstDayOfMonth(t)
  wday = t.wday
  (t.day - 1).times do
    wday -= 1
    wday = 6 if wday < 0
  end
  return wday
end

class PoketchCalendar < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Calendar/background")
    @header = []
    @time = Time.now
    if @time.month != $Trainer.calendar_month
      $Trainer.calendar_month = @time.month
      $Trainer.calendar_marked = []
    end
    n = @time.month.to_s.split("")
    for i in 0...n.size
      @header[i] = Sprite.new(@viewport)
      @header[i].bmp("Graphics/Pictures/Poketch/Calendar/numbersheader")
      @header[i].src_rect.width = 20
      @header[i].src_rect.x = 20 * n[i].to_i
      @header[i].x = [[181],[170,192]][n.size - 1][i]
      @header[i].y = 4
    end
    @start = pbFirstDayOfMonth(@time)
    @days = []
    for i in @start...(pbGetTotalDays(@time) + @start)
      idx = i - @start
      @days[idx] = []
      @days[idx][0] = Sprite.new(@viewport)
      w = 12
      w = 16 if (i % 7) == 0
      @days[idx][0].bmp("Graphics/Pictures/Poketch/Calendar/#{w == 12 ? "numbers" : "numbersfirst"}")
      @days[idx][0].src_rect.width = w
      @days[idx][0].src_rect.x = w * ((i + 1 - @start).to_s.split("")[0].to_i)
      @days[idx][0].x = 48 + 48 * (i % 7)
      @days[idx][0].y = 56 + 48 * (i / 7).floor
      @days[idx][0].z = 4
      if (i + 1 - @start).to_s.size > 1
        @days[idx][0].x -= 14
        @days[idx][0].x -= 4 if i % 7 == 0
        @days[idx][1] = Sprite.new(@viewport)
        @days[idx][1].bmp("Graphics/Pictures/Poketch/Calendar/#{w == 12 ? "numbers" : "numbersfirst"}")
        @days[idx][1].src_rect.width = w
        @days[idx][1].src_rect.x = w * ((i + 1 - @start).to_s.split("")[1].to_i)
        @days[idx][1].x = 48 + 48 * (i % 7)
        @days[idx][1].y = 56 + 48 * (i / 7).floor
        @days[idx][1].z = 4
      end
      @days[idx][2] = Sprite.new(@viewport)
      if $Trainer.calendar_marked.include?(i + 1 - @start)
        @days[idx][2].bmp("Graphics/Pictures/Poketch/Calendar/marked")
        @days[idx][2].z = 3
      else
        @days[idx][2].bmp(32,32)
        @days[idx][2].z = 2
      end
      @days[idx][2].x = (@days[idx][1] || @days[idx][0]).x - (i % 7 == 0 ? 14 : 16)
      @days[idx][2].y = @days[idx][0].y - 8
      if @time.day == (i + 1 - @start)
        @days[idx][3] = Sprite.new(@viewport)
        @days[idx][3].bmp("Graphics/Pictures/Poketch/Calendar/selector")
        @days[idx][3].x = (@days[idx][1] || @days[idx][0]).x - (w == 16 ? 18 : 20)
        @days[idx][3].y = @days[idx][0].y - 12
        @days[idx][3].z = 2
      end
      @days[idx][4] = i + 1 - @start
    end
  end
  
  def toggle_marker(day)
    @days[day][2] = Sprite.new(@viewport) if !@days[day][2]
    if @days[day][2].z == 2
      @days[day][2].bmp("Graphics/Pictures/Poketch/Calendar/marked")
      @days[day][2].z = 3
    else
      @days[day][2].bmp(32,32)
      @days[day][2].z = 2
    end
    @days[day][2].x = (@days[day][1] || @days[day][0]).x - ((@days[day][1] || @days[day][0]).x == 48 ? 14 : 16)
    @days[day][2].y = @days[day][0].y - 8
  end
  
  def update
    $Trainer.calendar_marked.clear
    for i in 0...@days.size
      toggle_marker(i) if $mouse.click?(@days[i][2])
      $Trainer.calendar_marked << @days[i][4] if @days[i][2].z == 3
    end
  end
  
  def dispose
    for day in @days
      day[0].dispose if day[0]
      day[1].dispose if day[1]
      day[2].dispose if day[2]
      day[3].dispose if day[3]
    end
    super
  end
end


#==============================================================================#
# Pokétch Coin Flip. Flip a coin.                                              #
#==============================================================================#
class PoketchCoinFlip < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Coin Flip/background")
    @coin = Sprite.new(@viewport)
    @coin.x = 128
    set(192,"front")
    @idle = true
    @i = 0
  end
  
  def set(y, path = nil)
    @coin.y = y
    @coin.bmp("Graphics/Pictures/Poketch/Coin Flip/#{path}") if path
  end
  
  def update
    if @idle && $mouse.click?(@coin)
      @idle = false
    end
    if !@idle
      @i += 1
      # Yep. This is the whole animation.
      case @i
      when 1..2
        set(172)
      when 3..4
        set(170,"middle")
      when 5..6
        set(120,"back")
      when 7..8
        set(122,"middle")
      when 9..10
        set(62,"front")
      when 11..12
        set(80,"middle")
      when 13..14
        set(72)
      when 15..16
        set(30,"back")
      when 17..18
        set(58,"middle")
      when 19..20
        set(22,"front")
      when 21..22
        set(64,"middle")
      when 23..24
        set(44,"back")
      when 25..26
        set(92,"middle")
      when 27..28
        set(80,"front")
      when 29..30
        set(144,"middle")
      when 31..32
        set(146,"back")
      when 33..34
        set(216,"middle")
      when 35..36
        set(192,"front")
      when 37..38
        set(204,"middle")
      when 39..40
        set(152,"back")
      when 41..42
        set(172,"middle")
      when 43..44
        set(128,"front")
      when 45..46
        set(162,"middle")
      when 47..48
        set(132,"back")
      when 49..50
        set(172,"middle")
      when 51..52
        set(180)
      when 53..54
        set(160,"front")
      when 55..56
        set(218,"middle")
      when 57..58
        set(188,"back")
      when 59..60
        set(214,"middle")
      when 61..62
        set(168,"front")
      when 63..64
        set(200,"middle")
      when 65..66
        set(170,"back")
      when 67..68
        set(208,"middle")
      when 69..70
        set(184,"front")
      when 71..72
        set(222,"middle")
      when 73..74
        set(184,"back")
      when 75..76
        set(214,"middle")
      when 77..78
        set(182,["front","back"][rand(2)])
        @i = 0
        @idle = true
      end
      # Yeah, it was fun extracting the official animation's frames one by one.
    end
  end
  
  def dispose
    @coin.dispose
    super
  end
end


#==============================================================================#
# Pokétch Stopwatch. Counts up instead of down.                                #
#==============================================================================#
class PokemonTemp
  attr_accessor :stopwatch_running
  attr_accessor :stopwatch_seconds
  attr_accessor :stopwatch_ms
end

module Graphics
  class << Graphics
    alias poketch_stopwatch_update update
  end
  
  def self.update
    poketch_stopwatch_update
    return if !$Poketch
    return if !$PokemonTemp.stopwatch_running
    return if !$PokemonTemp || !$PokemonTemp.stopwatch_seconds || !$PokemonTemp.stopwatch_ms
    if Graphics.frame_count % Graphics.frame_rate == 0
      $PokemonTemp.stopwatch_seconds += 1
      $PokemonTemp.stopwatch_ms = 0
    end
    # Typically ends up being "+= 100.0 / 40.0", so "+= 2.5"
    $PokemonTemp.stopwatch_ms += 100.0 / Graphics.frame_rate.to_f
    $Poketch.app.refresh if $Poketch && $Poketch.app.is_a?(PoketchStopwatch)
  end
end

class PoketchStopwatch < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Stopwatch/background")
    $PokemonTemp.stopwatch_running = false
    $PokemonTemp.stopwatch_seconds = 0
    $PokemonTemp.stopwatch_ms = 0
    @numbers = []
    @voltorb = Sprite.new(@viewport)
    @voltorb.bmp("Graphics/Pictures/Poketch/Stopwatch/idle")
    @voltorb.ox = @voltorb.bitmap.width / 2
    @voltorb.oy = @voltorb.bitmap.height / 2
    @voltorb.x = 192
    @voltorb.y = 200
    @i = 1
    refresh
  end
  
  def refresh
    s = $PokemonTemp.stopwatch_seconds % 60
    m = ($PokemonTemp.stopwatch_seconds / 60).floor % 60
    h = (($PokemonTemp.stopwatch_seconds / 60).floor / 60).floor
    n = [pbFormat(h,2).split(""),pbFormat(m,2).split(""),pbFormat(s,2).split(""),
        pbFormat($PokemonTemp.stopwatch_ms,2).split("")]
    for i in 0...8
      @numbers[i].dispose if @numbers[i]
      @numbers[i] = nil
      @numbers[i] = Sprite.new(@viewport)
      @numbers[i].bmp("Graphics/Pictures/Poketch/Stopwatch/numbers")
      @numbers[i].src_rect.width = 24
      @numbers[i].src_rect.x = 24 * n[(i / 2).floor][i % 2].to_i
      @numbers[i].x = [20,52,116,148,212,244,308,340][i]
      @numbers[i].y = 16
    end
  end
  
  def update
    @cooldown -= 1 if @cooldown > -1
    if @cooldown == -1 && @click
      @voltorb.bmp("Graphics/Pictures/Poketch/Stopwatch/#{@click}")
      @voltorb.ox = @voltorb.bitmap.width / 2
      @voltorb.oy = @voltorb.bitmap.height / 2
      $PokemonTemp.stopwatch_running = true if @click.include?("active")
      @click = nil
      @cooldown = 1
    end
    if !$PokemonTemp.stopwatch_running
      if $mouse.click?(@voltorb)
        @voltorb.bmp("Graphics/Pictures/Poketch/Stopwatch/click")
        @voltorb.ox = @voltorb.bitmap.width / 2
        @voltorb.oy = @voltorb.bitmap.height / 2
        @cooldown = 2
        @click = "active#{@i}"
      end
    else
      if @cooldown == -1 && !@click
        @voltorb.bmp("Graphics/Pictures/Poketch/Stopwatch/active#{@i}")
        if @i == 1
          @i = 2
        else
          @i = 1
        end
        @voltorb.ox = @voltorb.bitmap.width / 2
        @voltorb.oy = @voltorb.bitmap.height / 2
        @cooldown = 2
      end
      if $mouse.click?(@voltorb)
        $PokemonTemp.stopwatch_running = false
        @voltorb.bmp("Graphics/Pictures/Poketch/Stopwatch/click")
        @voltorb.ox = @voltorb.bitmap.width / 2
        @voltorb.oy = @voltorb.bitmap.height / 2
        @cooldown = 2
        @click = "idle"
      end
    end
  end
  
  def dispose
    @voltorb.dispose
    for n in @numbers
      n.dispose
    end
    $PokemonTemp.stopwatch_running = false
    $PokemonTemp.stopwatch_seconds = 0
    $PokemonTemp.stopwatch_ms = 0
    super
  end
end


#==============================================================================#
# Pokéch Notepad. You can write stuff down here.                               #
#==============================================================================#
class PokeBattle_Trainer
  attr_accessor :poketch_note
end

class PoketchNotepad < PoketchApp
  # 0x00 format: UTF-8 Hex
  # 000  format: JavaScript Keycodes
  BUTTONS = {
    0x41 => ["a","A"],
    0x42 => ["b","B"],
    0x43 => ["c","C"],
    0x44 => ["d","D"],
    0x45 => ["e","E"],
    0x46 => ["f","F"],
    0x47 => ["g","G"],
    0x48 => ["h","H"],
    0x49 => ["i","I"],
    0x4A => ["j","J"],
    0x4B => ["k","K"],
    0x4C => ["l","L"],
    0x4D => ["m","M"],
    0x4E => ["n","N"],
    0x4F => ["o","O"],
    0x50 => ["p","P"],
    0x51 => ["q","Q"],
    0x52 => ["r","R"],
    0x53 => ["s","S"],
    0x54 => ["t","T"],
    0x55 => ["u","U"],
    0x56 => ["v","V"],
    0x57 => ["w","W"],
    0x58 => ["x","X"],
    0x59 => ["y","Y"],
    0x5A => ["z","Z"],
    0x20 => [" "," "],
    0x30 => ["0",")"],
    0x31 => ["1","!"],
    0x32 => ["2","@"],
    0x33 => ["3","#"],
    0x34 => ["4","$"],
    0x35 => ["5","%"],
    0x36 => ["6","^"],
    0x37 => ["7","&"],
    0x38 => ["8","*"],
    0x39 => ["9","("],
    189  => ["-","_"],
    187  => ["=","+"],
    188  => [",","<"],
    190  => [".",">"],
    191  => ["/","?"],
    222  => ["'", '"'],
    219  => ["[","{"],
    221  => ["]","}"],
    13   => ["\n","\n"],
    186  => [";",":"],
    192  => ["`","~"],
    220  => ["\\","|"]
  }
  
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Notepad/background")
    @pencil = Sprite.new(@viewport)
    @pencil.bmp("Graphics/Pictures/Poketch/Notepad/btn")
    @pencil.x = 320
    @pencil.y = 84
    @drawing = false
    @bmp = Sprite.new(@viewport)
    @bmp.x = 16
    @bmp.y = 24
    @txt = $Trainer.poketch_note || ""
    draw_text
  end
  
  def update
    if $mouse.click?(@pencil)
      @drawing = true
      @pencil.bmp("Graphics/Pictures/Poketch/Notepad/btnClick")
    end
    if @drawing
      loop do
        @cooldown -= 1 if @cooldown > -1
        Graphics.update
        Input.update
        oldtxt = @txt
        for key in BUTTONS.keys
          if Input.triggerex?(key)
            @txt += BUTTONS[key][Input.press?(Input::SHIFT) || Input.press?(20) ? 1 : 0]
          end
        end
        # Special
        if @cooldown == -1 && Input.pressex?(0x08) # Backspace
          @txt.chop!
          draw_text
          @cooldown = 5
        end
        draw_text if oldtxt != @txt
        if $mouse.click?(@pencil)
          @drawing = false
          @pencil.bmp("Graphics/Pictures/Poketch/Notepad/btn")
          break
        end
        if $mouse.click?($Poketch.btnUp)
          $Poketch.click_up
          break
        end
        if $mouse.click?($Poketch.btnDown)
          $Poketch.click_down
          break
        end
      end
    end
  end
  
  def draw_text
    @bmp.bitmap = nil
    @bmp.bmp(276,268)
    pbSetSystemFont(@bmp.bitmap)
    drawTextEx(@bmp.bitmap,0,0,276,8,@txt,Color.new(16,41,24),Color.new(57,82,49))
    $Trainer.poketch_note = @txt
  end
  
  def dispose
    @pencil.dispose
    super
  end
end


#==============================================================================#
# Pokétch Alarm Clock.                                                         #
#==============================================================================#
class PokeBattle_Trainer
  attr_accessor :poketch_alarm
  attr_accessor :poketch_alarm_running
end

class PoketchAlarmClock < PoketchApp
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Alarm Clock/background1")
    @numbers = []
    $Trainer.poketch_alarm = 0 if !$Trainer.poketch_alarm
    $Trainer.poketch_alarm_running = false if !$Trainer.poketch_alarm_running
    draw_time($Trainer.poketch_alarm)
    @arrows = []
    for i in 0...4
      @arrows[i] = Sprite.new(@viewport)
      path = "arrow" + (i < 2 ? "Up" : "Down")
      @arrows[i].bmp("Graphics/Pictures/Poketch/Alarm Clock/#{path}")
      @arrows[i].x = [88,184][i % 2]
      @arrows[i].y = [184,284][(i / 2).floor]
    end
    @running = false
    @btns = []
    @btns[0] = Sprite.new(@viewport)
    @btns[0].bmp("Graphics/Pictures/Poketch/Alarm Clock/btn")
    @btns[0].x = 324
    @btns[0].y = 116
    @btns[1] = Sprite.new(@viewport)
    @btns[1].bmp("Graphics/Pictures/Poketch/Alarm Clock/btnClick")
    @btns[1].x = 324
    @btns[1].y = 180
    @time = Time.now
    @i = -1
    set_running if $Trainer.poketch_alarm_running
  end
  
  def draw_time(mins)
    n = pbFormat((mins / 60).floor, 2).split("")
    n.concat(pbFormat(mins % 60, 2).split(""))
    for i in 0...4
      @numbers[i].dispose if @numbers[i]
      @numbers[i] = nil
      @numbers[i] = Sprite.new(@viewport)
      @numbers[i].bmp("Graphics/Pictures/Poketch/Alarm Clock/numbers")
      @numbers[i].src_rect.width = 24
      @numbers[i].src_rect.x = 24 * n[i].to_i
      @numbers[i].x = [84,116,180,212][i]
      @numbers[i].y = 224
    end
  end
  
  def update
    @i += 1
    if !@running
      for i in 0...4
        @arrows[i].visible = @i < 24
      end
      @i = 0 if @i == 47
      oldt = $Trainer.poketch_alarm
      if $mouse.click?(@arrows[0])
        $Trainer.poketch_alarm += 60
        $Trainer.poketch_alarm -= 1440 if $Trainer.poketch_alarm >= 1440
      end
      if $mouse.click?(@arrows[1])
        $Trainer.poketch_alarm += 1
        $Trainer.poketch_alarm -= 60 if $Trainer.poketch_alarm % 60 == 0
      end
      if $mouse.click?(@arrows[2])
        $Trainer.poketch_alarm -= 60
        $Trainer.poketch_alarm += 1440 if $Trainer.poketch_alarm < 0
      end
      if $mouse.click?(@arrows[3])
        $Trainer.poketch_alarm -= 1
        $Trainer.poketch_alarm += 60 if $Trainer.poketch_alarm % 60 == 59
      end
      draw_time($Trainer.poketch_alarm) if oldt != $Trainer.poketch_alarm
    else
      if @time.hour != Time.now.hour || @time.min != Time.now.min
        @time = Time.now
        @sum = @time.min + @time.hour * 60
        draw_time(@sum)
        @i = 0 if @sum == $Trainer.poketch_alarm
      end
      if @sum == $Trainer.poketch_alarm
        if @i % 6 == 0
          @bg.bmp("Graphics/Pictures/Poketch/Alarm Clock/background3")
        elsif @i % 3 == 0
          @bg.bmp("Graphics/Pictures/Poketch/Alarm Clock/background4")
        end
        @alarm = true
        if @i == 18
          for i in 0...4
            @numbers[i].visible = !@numbers[i].visible
          end
          @i = 0
        end
      elsif @alarm
        @bg.bmp("Graphics/Pictures/Poketch/Alarm Clock/background2")
        @alarm = false
        for i in 0...4
          @numbers[i].visible = true
        end
      end
    end
    if !@running && $mouse.click?(@btns[0])
      set_running
    end
    if @running && $mouse.click?(@btns[1])
      $Trainer.poketch_alarm_running = false
      @bg.bmp("Graphics/Pictures/Poketch/Alarm Clock/background1")
      @btns[0].bmp("Graphics/Pictures/Poketch/Alarm Clock/btn")
      @btns[1].bmp("Graphics/Pictures/Poketch/Alarm Clock/btnClick")
      @running = false
      @i = 0
      @time = Time.now
      draw_time($Trainer.poketch_alarm)
    end
  end
  
  def set_running
    $Trainer.poketch_alarm_running = true
    @bg.bmp("Graphics/Pictures/Poketch/Alarm Clock/background2")
    @running = true
    for i in 0...4
      @arrows[i].visible = false
    end
    @time = Time.now
    @sum = @time.min + @time.hour * 60
    draw_time(@sum)
    @btns[0].bmp("Graphics/Pictures/Poketch/Alarm Clock/btnClick")
    @btns[1].bmp("Graphics/Pictures/Poketch/Alarm Clock/btn")
    @i = 0 if @sum == $Trainer.poketch_alarm
  end
  
  def dispose
    for btn in @btns
      btn.dispose
    end
    for n in @numbers
      n.dispose
    end
    for arrow in @arrows
      arrow.dispose
    end
    super
  end
end


#==============================================================================#
# Pokétch Safari Helper. Shows you some things like steps and balls left.      #
#==============================================================================#
class PoketchSafariHelper < PoketchApp
  def self.usable? # Only usable when in the Safari Zone
    return pbSafariState && pbSafariState.inProgress?
  end
  
  def initialize
    super
    @bg.bmp("Graphics/Pictures/Poketch/Safari Helper/background")
    @exit = Sprite.new(@viewport)
    @exit.bmp("Graphics/Pictures/Poketch/Safari Helper/exit")
    @exit.x = 284
    @exit.y = 208
    @balls = pbSafariState.ballcount
    @steps = pbSafariState.steps
    @ballsprites = []
    @stepsprites = []
    draw_balls
    draw_steps
  end
  
  def update
    super
    if @balls != pbSafariState.ballcount
      @balls = pbSafariState.ballcount
      draw_balls
    end
    if @steps != pbSafariState.steps
      @steps = pbSafariState.steps
      draw_steps
    end
    if click?(@exit,"Graphics/Pictures/Poketch/Safari Helper","exit")
      if Kernel.pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
        pbSafariState.decision = 1
        pbSafariState.pbGoToStart
        $Poketch.click_down(false)
      end
    end
  end
  
  def draw_balls
    n = pbFormat(@balls, 2).split("")
    for i in 0...2
      @ballsprites[i].dispose if @ballsprites[i]
      @ballsprites[i] = nil
      @ballsprites[i] = Sprite.new(@viewport)
      @ballsprites[i].bmp("Graphics/Pictures/Poketch/Safari Helper/numbers")
      @ballsprites[i].src_rect.width = 24
      @ballsprites[i].src_rect.x = 24 * n[i].to_i
      @ballsprites[i].x = [100,132][i]
      @ballsprites[i].y = 27
    end
  end
  
  def draw_steps
    n = pbFormat(@steps).split("")
    for i in 0...3
      @stepsprites[i].dispose if @stepsprites[i]
      @stepsprites[i] = nil
      @stepsprites[i] = Sprite.new(@viewport)
      @stepsprites[i].bmp("Graphics/Pictures/Poketch/Safari Helper/numbers")
      @stepsprites[i].src_rect.width = 24
      @stepsprites[i].src_rect.x = 24 * n[i].to_i
      @stepsprites[i].x = [279,311,343][i]
      @stepsprites[i].y = 27
    end
  end
  
  def dispose
    for b in @ballsprites
      b.dispose
    end
    for s in @stepsprites
      s.dispose
    end
    @exit.dispose
    super
  end
end


#==============================================================================#
# All apps. To make a new app, you have to register it in this module.         #
# This is also the displayed order of the apps. The names are the class names. #
# The numbers you see after the name of an app is that app's ID.               #
# If you want to enable/disable an app, rather than looking up the ID, you     #
# could do something like "pbEnableApp(PoketchApps::PoketchNotepad)"           #
#==============================================================================#
module PoketchApps
  PoketchClock          = 0
  PoketchClicker        = 1
  PoketchCalculator     = 2
  PoketchPedometer      = 3
  PoketchItemFinder     = 4
  PoketchMoveTester     = 5
  PoketchRotom          = 6
  PoketchMarkingMap     = 7
  PoketchMatchupChecker = 8
  PoketchParty          = 9
  PoketchColorChanger   = 10
  PoketchKitchenTimer   = 11
  PoketchAnalogWatch    = 12
  PoketchStatDisplay    = 13
  PoketchRoulette       = 14
  PoketchDayCareChecker = 15
  PoketchPokemonHistory = 16
  PoketchCalendar       = 17
  PoketchCoinFlip       = 18
  PoketchStopwatch      = 19
  PoketchNotepad        = 20
  PoketchAlarmClock     = 21
  PoketchSafariHelper   = 22
end