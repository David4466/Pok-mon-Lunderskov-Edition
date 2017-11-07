#===============================================================================
#  The Trade Expert
#    by Luka S.J.
# 
#  Provides an emulated experience of Wonder Trade, but uses the base stat total
#  of a Pokemon species to determine which Pokemon you'll obtain from the trade.
#  Includes dialogues to make the event more interesting when trading your Pokemon.
#  To use, simply call it in an event via the script command:
#      tradeExpert(margin)
#  where margin is a percentage value (from 0.0 to 1.0) that determines the
#  increase in upper and lower base stat total values for the traded Pokemon.
#  By default, it is set to 0.1; meaning that the Pokemon you recieve will be
#  in the base stat total range of within 90% - 110% of the base stat total of
#  the Pokemon you're giving up for trade. The 'margin' parameter can be
#  omitted.
#  Look at the 'def tradePokemon' if you want to customize the Pokemon you're
#  getting from the trade even further.
#
#  Enjoy the script, and make sure to give credit!
#  (DO NOT ALTER THE NAMES OF THE INDIVIDUAL SCRIPT SECTIONS OR YOU WILL BREAK
#   YOUR SYSTEM!)
#===============================================================================                           
# Main class for handling the Trade Expert
class TradeExpert
  
  # starts up the Trade Expert
  def initialize(margin = 0.1)
    # flavour text displaying a little intro for the Trade Expert
    Kernel.pbMessage(_INTL("Hey! They call me the Trade Expert!"))
    Kernel.pbMessage(_INTL("I specialize in finding rare Pokémon and trading them to trainers for Pokémon of equal worth."))
    # confirmation for the trade
    if Kernel.pbConfirmMessage(_INTL("Is there any Pokémon you'd like me to take a look at? I might have something to offer you."))
      giveID = self.givePokemon
      return Kernel.pbMessage(_INTL("Looks like you don't have a Pokémon to give me.")) if giveID.nil?
      give = $Trainer.party[giveID]
      giveBST = calcBST(give)
      # protects trading from abuse
      if !$cachedTrade["#{giveBST}"].nil?
        recv = $cachedTrade["#{giveBST}"]
      else
        recv = self.fetchEqualSpecies(give,margin)
        # cancels the trade if the Trade Expert cannot offer you anything in return
        if recv.length < 1
          Kernel.pbMessage(_INTL("Wow, that {1} is an overwhelming Pokémon! I don't really have anything I could possibly offer. Sorry!",PBSpecies.getName(give.species)))
          return false
        end
        recv = recv[rand(recv.length - 1)]
      end
      Kernel.pbMessage(_INTL("Hmm ... hmm ..."))
      bst = calcBST(PokeBattle_Pokemon.new(recv,5))
      # flavour text displayed when evaluating the offered Pokemon species
      if bst <= 200
        Kernel.pbMessage(_INTL("That {1} is a very weak Pokémon.",PBSpecies.getName(give.species)))
      elsif bst <= 300
        Kernel.pbMessage(_INTL("That {1} isn't a very intimidating Pokémon.",PBSpecies.getName(give.species)))
      elsif bst <= 400
        Kernel.pbMessage(_INTL("That {1} of yours isn't a bad Pokémon.",PBSpecies.getName(give.species)))
      elsif bst <= 500  
        Kernel.pbMessage(_INTL("That {1} of yours is certainly an interesting Pokémon.",PBSpecies.getName(give.species)))
      elsif bst <= 600
        Kernel.pbMessage(_INTL("That {1} of yours is what I'd call a fierce Pokémon.",PBSpecies.getName(give.species)))
      else
        Kernel.pbMessage(_INTL("That {1}! Now that ... is a great Pokémon!",PBSpecies.getName(give.species)))
      end
      # protects trading from abuse
      $cachedTrade["#{giveBST}"] = recv
      # final confirmation for the trade
      if Kernel.pbConfirmMessage(_INTL("How about my {1} for your {2}?",PBSpecies.getName(recv),PBSpecies.getName(give.species)))
        $cachedTrade.delete("#{giveBST}")
        self.tradePoke(giveID,recv)
        Kernel.pbMessage(_INTL("It's been nice doing business with you! Let me know if you want to do any more trades."))
        self.saveCache
        return true
      else
        Kernel.pbMessage(_INTL("I think it would have been a fair trade."))
        Kernel.pbMessage(_INTL("Well ... if you ever change your mind, let me know."))
        self.saveCache
        return false
      end
    else
      # the trade was cancelled at the start
      return Kernel.pbMessage(_INTL("Well ... if you ever change your mind, let me know."))
    end
  end
  
  # method used to get a list of Pokemon you cannot get in a trade
  def getBlacklist
    list = []
    for poke in TRADING_BLACKLIST
      if poke.is_a?(Numeric)
        list.push(poke)
      elsif poke.is_a?(Symbol)
        list.push(getConst(PBSpecies,poke))
      end
    end
    return list
  end
  
  # method used to get a list of Pokemon you cannot give in a trade
  def sendBlacklist
    list = []
    for poke in GIVING_BLACKLIST
      if poke.is_a?(Numeric)
        list.push(poke)
      elsif poke.is_a?(Symbol)
        list.push(getConst(PBSpecies,poke))
      end
    end
    return list
  end
  
  # method used to calculate the base stat total of a Pokemon
  def calcBST(poke)
    stats = poke.baseStats
    bst = 0
    for stat in stats
      bst += stat
    end
    return bst
  end
  
  # method used to return a list of Pokemon that would be of similar value to your Pokemon
  def fetchEqualSpecies(poke,margin = 0.1)
    bst = self.calcBST(poke)
    upper = bst*(1 + margin)
    lower = bst*(1 - margin)
    potential = []
    for i in 1..PBSpecies.maxValue
      spec = PokeBattle_Pokemon.new(i, 5)
      stats = self.calcBST(spec)
      potential.push(i) if stats >= lower && stats <= upper && !getBlacklist.include?(i) && i != poke.species
    end
    return potential
  end
  
  # brings up the UI to select a Pokemon to give to the Trade Expert
  def givePokemon
    # decides the parameters that determine Pokemon trade elegibility
    ableProc = proc{|poke| !poke.egg? && !poke.isShadow? && !sendBlacklist.include?(poke.species)}
    chosen = 0
    pbFadeOutIn(99999){
       if isVersion17?
         scene = PokemonParty_Scene.new
         screen = PokemonPartyScreen.new(scene,$Trainer.party)
       else  
         scene = PokemonScreen_Scene.new
         screen = PokemonScreen.new(scene,$Trainer.party)
       end
       if ableProc
         chosen = screen.pbChooseAblePokemon(ableProc,false)      
       else
         screen.pbStartScene(_INTL("Choose a Pokémon."),false)
         chosen = screen.pbChoosePokemon
         screen.pbEndScene
       end
    }
    return (chosen >= 0 ? chosen : nil)
  end
  
  # brings up the trading UI (you can further customize the traded Pokemon here)
  def tradePoke(give,recv)
    myPokemon = $Trainer.party[give]
    # name of the Trade Expert is decided here
    opponent = PokeBattle_Trainer.new("Trade Expert", 0)
    opponent.setForeignID($Trainer)
    # custom trainer ID of the Trade Expert
    opponent.id = 1204
    # generates the Pokemon
    yourPokemon = PokeBattle_Pokemon.new(recv,myPokemon.level,opponent)
    # sets the Pokemon's mode to be traded
    yourPokemon.obtainMode = 2
    # handles moves
    yourPokemon.resetMoves
    yourPokemon.pbRecordFirstMoves
    # registers Pokemon in the Pokedex
    $Trainer.seen[yourPokemon.species] = true
    $Trainer.owned[yourPokemon.species] = true
    pbSeenForm(yourPokemon)
    # starts trading sequence
    pbFadeOutInWithMusic(99999){
      if isVersion17?
        evo = PokemonTrade_Scene.new
      else
        evo = PokemonTradeScene.new
      end
      evo.pbStartScreen(myPokemon,yourPokemon,$Trainer.name,opponent.name)
      evo.pbTrade
      evo.pbEndScreen
    }
    # sets traded Pokemon
    $Trainer.party[give] = yourPokemon
  end
  
  # saves cached trades
  def saveCache
    File.open(RTP.getSaveFileName("trexpert"),"wb"){|f|
       Marshal.dump($cachedTrade,f)
    }
  end
end
  
# Method used to call the Trade Expert in event
def tradeExpert(margin = 0.1)
  return TradeExpert.new(margin)
end

# Used so that the Player can't infinitely reject and get whatever new Pokemon
# before completing an old trade first
if safeExists?(RTP.getSaveFileName("trexpert"))
  File.open(RTP.getSaveFileName("trexpert")){|f|
    $cachedTrade = Marshal.load(f)
  }
else
  $cachedTrade = {}
end