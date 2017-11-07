# Every PokéRide should have MoveSheet, MoveSpeed, ActionSheet, and ActionSpeed.
# A PokéRide can also have one or more of the following options:

#  -> RockSmash: While the action button (Z) is being pressed, any rock you
#                walk up to will be smashed.
#  -> CanSurf: This Pokémon can be surfed with.
#  -> WalkOnMudsdale: With this PokéRide, you can walk over terrain with
#                     terrain tag 17.
#  -> Strength: Boulders can be moved if the action button is held down.
#  -> ShowHidden: If the action button is held down, any listed event with
#                 ".hidden" (without the quotation marks) within a 4x4 radius
#                 will cause the Pokéride to use "HiddenNearbySheet" and
#                 "HiddenNearbySpeed". Those two must also be implemented if your
#                 Pokéride has "ShowHidden"
#  -> RockClimb: If set to true, 

# You can have multiple of these options at once. They should all be compatible
# with one another.


# Rock Smash rocks still have to be called "Rock" without the quotation marks.
# Boulders still have to be called "Boulder" and their trigger method should be
#     "Player Touch" and it should have just one line of script: "pbPushThisBoulder"

# Hidden items are ".hidden" without the quotation marks for compatibility
# with my Pokétch resource.
# They work the same way as hidden items there:
# pbUnlist(event_id): The event becomes hidden from the Itemfinder (Stoutland)
# pbList(event_id): The event becomes visible for the Itemfinder (Stoutland)
#                   IF the event has ".hidden" in the name.


# If you want Surf to be the normal surf, set this to nil. Else, set it to the
# name of the PokéRide in a string (e.g. "Sharpedo")
SURF_MOUNT = "Sharpedo"

# If you want a Pokéride to be able to perform Rock Climb, set this to the
# name of the Pokéride. If you don't want Rock Climb, set this to nil.
ROCK_CLIMB_MOUNT = "Rhyhorn"
# This is the Pokéride that is called if you press C in front of a Rock Climb tile
# while not being on a Pokéride that can already use Rock Climb, which means
# that this is essentially the same as "SURF_MOUNT".


# A Pokéride can also have an effect that is activated when you mount it.
# To implement something there, add your code in a method called "def self.mount".
# The same can be done for dismounting, but in "def self.dismount"


# pbMount(Tauros)
module Tauros
  MoveSheet = ["Pokeride/boy_tauros","Pokeride/girl_tauros"]
  MoveSpeed = 5.0
  ActionSheet = ["Pokeride/boy_tauros_charge","Pokeride/girl_tauros_charge"]
  ActionSpeed = 5.6
  RockSmash = true
end

# pbMount(Lapras)
module Lapras
  MoveSheet = ["Pokeride/boy_lapras","Pokeride/girl_lapras"]
  MoveSpeed = 4.8
  ActionSheet = ["Pokeride/boy_lapras_fast","Pokeride/girl_lapras_fast"]
  ActionSpeed = 5.4
  CanSurf = true
end

module Sharpedo
  MoveSheet = ["Pokeride/boy_sharpedo","Pokeride/girl_sharpedo"]
  MoveSpeed = 5.4
  ActionSheet = ["Pokeride/boy_sharpedo_fast","Pokeride/girl_sharpedo_fast"]
  ActionSpeed = 6.0
  CanSurf = true
  RockSmash = true
end

# pbMount(Machamp)
module Machamp
  MoveSheet = ["Pokeride/boy_machamp","Pokeride/girl_machamp"]
  MoveSpeed = 4.3
  ActionSheet = ["Pokeride/boy_machamp_push","Pokeride/girl_machamp_push"]
  ActionSpeed = 3.8
  Strength = true
end

# You get the idea now. pbMount(Mudsdale)
module Mudsdale
  MoveSheet = ["Pokeride/boy_mudsdale","Pokeride/girl_mudsdale"]
  MoveSpeed = 4.1
  ActionSheet = ["Pokeride/boy_mudsdale_run","Pokeride/girl_mudsdale_run"]
  ActionSpeed = 4.6
  WalkOnMudsdale = true
end

module Stoutland
  MoveSheet = ["Pokeride/boy_stoutland","Pokeride/girl_stoutland"]
  MoveSpeed = 4.6
  ActionSheet = ["Pokeride/boy_stoutland_search","Pokeride/girl_stoutland_search"]
  ActionSpeed = 3.6
  HiddenNearbySheet = ["Pokeride/boy_stoutland_found","Pokeride/girl_stoutland_found"]
  HiddenNearbySpeed = 3.6
  ShowHidden = true
end

module Rhyhorn
  MoveSheet = ["Pokeride/boy_rhyhorn","Pokeride/girl_rhyhorn"]
  MoveSpeed = 4.4
  ActionSheet = ["Pokeride/boy_rhyhorn","Pokeride/girl_rhyhorn"]
  ActionSpeed = 4.4
  RockClimb = true
end
